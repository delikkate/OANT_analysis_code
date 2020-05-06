function smoothVTCs(subNum, sesNum)
%2014-06-04 AL
%Adapted for OANT experiment: 2016-12-29 KD


ID = getID(subNum);
subID = sprintf('SUB%02d_%s', subNum, ID);

pathToData = 'G:\Analysis_OANT\groupdata\';

[dicomFolderVec, ~, ~, ~] = getDicomFolderVec(subNum, sesNum);

nRuns = length(dicomFolderVec);

opts.spat = true;
opts.spkern = [6, 6, 6]; % spatial smoothing with a 6x6x6 mm kernel

for iRun = 1:nRuns
    vtc = BVQXfile([pathToData sprintf('%s_%02d_S%02d_OANT_SCCAI_3DMCTS_LTR_THP3c_TAL.vtc', subID, iRun, sesNum)]);
    vtcSmoothed = vtc.Filter(opts);
    vtcSmoothed.SaveAs([pathToData sprintf('%s_%02d_S%02d_OANT_SCCAI_3DMCTS_LTR_THP3c_TAL_6mm.vtc', subID, iRun, sesNum)]);
    vtc.ClearObject;
    %vtcSmoothed.ClearObject;
end

