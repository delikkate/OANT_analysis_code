function moveToGroupdata(subNum, sesNum)
% The function copies VTC files, SDMs with motion correction parameters for
% each run and the TAL.vmr of a subject to groupdata

ID = getID(subNum);
subID = sprintf('SUB%02d_%s', subNum, ID);

[dicomFolderVec, ~] = getDicomFolderVec(subNum, sesNum);

pathToGroupdata = 'G:\Analysis_OANT\groupdata\';
pathToData = ['G:\Analysis_OANT\' subID sprintf('\\S%02d\\bv\\', sesNum)];

if subNum == 7 || subNum == 9 || subNum == 14 || subNum == 17 || subNum == 21 % for five subjects we segmented TAL.vmr for session 2 
    if sesNum == 2
        toBeCopiedMRI = ([pathToData sprintf('%s_S%02d_MPRAGE_ISO_IIHC_TAL.vmr', subID, sesNum)]);
        copyfile(toBeCopiedMRI,pathToGroupdata)
        disp(sprintf('%s copied to %s',toBeCopiedMRI, pathToGroupdata));
    end
else % for all other subjects
    if sesNum == 1
        toBeCopiedMRI = ([pathToData sprintf('%s_S%02d_MPRAGE_ISO_IIHC_TAL.vmr', subID, sesNum)]);
        copyfile(toBeCopiedMRI,pathToGroupdata)
        disp(sprintf('%s copied to %s',toBeCopiedMRI, pathToGroupdata));
    end  
end

for run=1:length(dicomFolderVec)           
    toBeCopiedSDM = ([pathToData sprintf('%s_%02d_S%02d_OANT_SCCAI_3DMC.sdm', subID, run, sesNum)]);
    copyfile(toBeCopiedSDM,pathToGroupdata)
    disp(sprintf('%s copied to %s',toBeCopiedSDM, pathToGroupdata));
      
    toBeCopiedVTC = ([pathToData sprintf('%s_%02d_S%02d_OANT_SCCAI_3DMCTS_LTR_THP3c_TAL.vtc', subID, run, sesNum)]);
    copyfile(toBeCopiedVTC,pathToGroupdata)
    disp(sprintf('%s copied to %s',toBeCopiedVTC, pathToGroupdata));
end

