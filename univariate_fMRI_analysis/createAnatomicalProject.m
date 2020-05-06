% This script builds an anatomical project for a scanning session in "bv" folder.
% It creates two files - with extensions .vmr and .v16.

function createAnatomicalProject(subNum, sesNum)
%last change: 23-12-2016 KD
%example call:
%createAnatomicalProject(1, 1)

ID = getID(subNum);
subjectID = sprintf('SUB%02d_%s', subNum, ID);

[~,~,date,dicomFolderNum] = getDicomFolderVec(subNum, sesNum); %fetch session date and number of DICOM folder containing structural data

pathToData = ['G:\Analysis_OANT\' subjectID sprintf('\\S%02d\\', sesNum)];
pathToDicom = [pathToData sprintf('%d_t1_mprage_CNR_pat2\\', dicomFolderNum)];


%% Set flag for renaming DICOM files
renameDicomFiles = 1; %set to 0 if already renamed; set to 1 if you want them to be renamed
    
% Enable COM-scripting mode in BV
bvqx = actxserver('BrainVoyagerQX.BrainVoyagerQXScriptAccess.1');
bvqx.ResizeWindow(1900, 600);
bvqx.ShowLogTab;

%% RENAME DICOM FILES 2014-11-25 AL
if renameDicomFiles == 1
    bvqx.RenameDicomFilesInDirectory(pathToDicom);
end

%% CREATE VMR PROJECTS
sname = [pathToData sprintf('bv\\%s_S%02d_MPRAGE.vmr', subjectID, sesNum)];

filetype = 'DICOM';
firstfilename = [pathToDicom sprintf('%s_%s -000%d-0001-00001.dcm', ID, date, dicomFolderNum)];
nrslices = 176;
swap = false;
xres = 224;
yres = 256;
bytesperpixel = 2;

vmrproject = bvqx.CreateProjectVMR(filetype, firstfilename, nrslices, swap, xres, yres, bytesperpixel);
success = vmrproject.SaveAs(sname);
vmrproject.Close();
