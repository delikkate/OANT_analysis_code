function moveTalToMeshdata_S02(subNum)
% Move to 'meshdata' TAL.vmr files for S02 of SUB07, SUB09, SUB14, SUB17 and SUB21
% (we will segment anatomical images from S02 of these subjects, because
% their S01 segmentation failed)

% created by KD 05-04-2017

% example call:
% moveTalToMeshdata_S02(1)


ID = getID(subNum);
subID = sprintf('SUB%02d_%s', subNum, ID);

pathToMeshdata = 'G:/Analysis_OANT/meshdata/';
pathToData = ['G:/Analysis_OANT/' subID '/S02/bv/'];

% now save directly in 'meshdata' 
toBeCopiedMRI = [pathToData sprintf('%s_S02_MPRAGE_ISO_IIHC_TAL.vmr', subID)];
copyfile(toBeCopiedMRI,pathToMeshdata);
fprintf('%s copied to %s\n',toBeCopiedMRI, pathToMeshdata);
