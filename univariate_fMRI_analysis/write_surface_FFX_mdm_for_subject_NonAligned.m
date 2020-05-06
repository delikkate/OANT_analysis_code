% The function creates an .mdm text file that is used to run FFX GLM on a
% subject's SPH surface (before group alignment).

% created by KD 21-07-2017

% example call:
% write_surface_FFX_mdm_for_subject_NonAligned(1, 'LH')
% write_surface_FFX_mdm_for_subject_NonAligned(1, 'RH')


function write_surface_FFX_mdm_for_subject_NonAligned(subNum, hemisphere)

mdmname = sprintf('MDM_surface_FFX_SUB%02d_sm6mm_%s_NonAligned.mdm', subNum, hemisphere);
fid = fopen(mdmname,'w+t');

pathToMeshdata = 'G:/Analysis_OANT/meshdata/';
pathToGroupdata = 'G:/Analysis_OANT/groupdata/';

subID = getID(subNum);
if subNum == 13
    numRuns = 12; % with SUB13 we only did four runs in session 1 (thus, twelve in total)
else
    numRuns = 16;
end

% print the header
fprintf(fid,'\n');
fprintf(fid,'%s\n','FileVersion:          3');
fprintf(fid,'%s\n','TypeOfFunctionalData: MTC');
fprintf(fid,'\n');
fprintf(fid,'%s\n','RFX-GLM:              0');
fprintf(fid,'\n');
fprintf(fid,'%s\n','PSCTransformation:    0');
fprintf(fid,'%s\n','zTransformation:      1'); % set 'z transform' flag
fprintf(fid,'%s\n','SeparatePredictors:   0');
fprintf(fid,'\n');
fprintf(fid, sprintf('NrOfStudies:          %02d\n', numRuns));

if subNum == 7 || subNum == 9 || subNum == 14 || subNum == 17 || subNum == 21
    SSM_session = 2;
else
    SSM_session = 1;
end
for sesNum = 1:2
    [dicomFolderVec, ~] = getDicomFolderVec(subNum, sesNum);
    nRuns = length(dicomFolderVec);
    for iRun = 1:nRuns
        path_to_SSM = ['"' pathToMeshdata sprintf('SUB%02d_%s_S%02d_MPRAGE_ISO_IIHC_TAL_WM_%s_RECOSMx_D80K_SPH_identity.ssm', subNum, subID, SSM_session, hemisphere) '"'];
        path_to_MTC = ['"' pathToMeshdata sprintf('SUB%02d_%s_%02d_S%02d_OANT_SCCAI_3DMCTS_LTR_THP3c_TAL_6mm_%s.mtc', subNum, subID, iRun, sesNum, hemisphere) '"'];
        path_to_SDM = ['"' pathToGroupdata sprintf('SUB%02d_%s_%02d_S%02d_OANT.sdm', subNum, subID, iRun, sesNum) '"'];
        fprintf(fid,'%s %s %s\n', path_to_SSM, path_to_MTC, path_to_SDM);
    end
end


fclose(fid);