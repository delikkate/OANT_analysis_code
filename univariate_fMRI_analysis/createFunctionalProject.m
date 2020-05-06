function createFunctionalProject(subNum, sesNum, runNum)
% This function creates an FMR project for a given run.

% example call:
% createFunctionalProject(1, 1, 1)


%% Set flag for renaming DICOM files
renameDicomFiles = 1; % 0 = do not rename; 1 = rename


%% Get subject-specific data
[dicomFolderVec, nVol] = getDicomFolderVec(subNum, sesNum);

ID = getID(subNum);
subID = sprintf('SUB%02d_%s', subNum, ID);

pathToData = ['G:\Analysis_OANT\' subID sprintf('\\S%02d\\', sesNum)];
pathToBVFolder = [pathToData, 'bv'];
if ~exist(pathToBVFolder, 'dir') % in each session folder create a subfolder for BV files
    mkdir(pathToData, 'bv');
end

sourceFolder = [pathToData sprintf('%d_lnif_epi1_3x3x3TR2200_MAIN_DiCo', dicomFolderVec(runNum)),'\'];
sourceFolderInfo = dir([sourceFolder,'*00032.dcm']);


%% Enable COM-scripting mode in BV
bvqx = actxserver('BrainVoyagerQX.BrainVoyagerQXScriptAccess.1');
bvqx.ResizeWindow(1900, 600);
bvqx.ShowLogTab;


%% Rename DICOM files, if necessary
if renameDicomFiles == 1
	bvqx.RenameDicomFilesInDirectory(sourceFolder);
end


%% Set FMR parameters
fileType = 'DICOM';
dicomName = sourceFolderInfo.name;   % name of the first DICOM file in the folder after renaming
nrOfVols = nVol(runNum); % number of volumes varies across runs (due to temporal jittering)
skipVols = 3; % discard first three volumes in a run
createAMR = 1; % 0 = no; 1 = yes
nrSlices = 31;
FMRPrefix = sprintf('%s_%02d_S%02d_OANT', subID, runNum, sesNum);
byteswap = 0;
bytesPerPixel = 2;
targetFolder = [pathToData 'bv\'];
nrVolsInImg = 1;
sizeX = 64;
sizeY = 64;
mosaicSizeX = ceil(sqrt(nrSlices))* sizeX; % calculated from image matrix size and number of slices
mosaicSizeY = ceil(sqrt(nrSlices))* sizeY; % calculated from image matrix size and number of slices 


%% Call BV function that creates an FMR project
fmrproject = bvqx.CreateProjectMosaicFMR(fileType, dicomName, nrOfVols,...
    skipVols, createAMR, nrSlices, FMRPrefix, byteswap,mosaicSizeX,...
    mosaicSizeY, bytesPerPixel, targetFolder, nrVolsInImg, sizeX, sizeY);


%% Save the FMR file and close the project
fmrname = fullfile(targetFolder, [FMRPrefix, '.fmr']);
fmrproject.SaveAs(fmrname);

fmrproject.Close;