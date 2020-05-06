function moveTalToMeshdata(subNum)
% The script copies Talairach-transformed VMRs for session 1 of each subject
% into the folder 'meshdata'

% created by KD 18-01-2017

% example call:
% moveTalToMeshdata(1)


ID = getID(subNum);
subID = sprintf('SUB%02d_%s', subNum, ID);

pathToMeshdata = 'G:/Analysis_OANT/meshdata/';
pathToData = ['G:/Analysis_OANT/' subID '/S01/bv/'];

% now save directly in 'meshdata' 
toBeCopiedMRI = [pathToData sprintf('%s_S01_MPRAGE_ISO_IIHC_TAL.vmr', subID)];
copyfile(toBeCopiedMRI,pathToMeshdata);
fprintf('%s copied to %s\n',toBeCopiedMRI, pathToMeshdata);



