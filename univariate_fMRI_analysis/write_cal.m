% The function creates a .cal text file that is used to check the
% improvement of alignment introduced by CBA (Meshes: Cortex-Based
% Alignment -> Options -> radio button "Curvature" (default) -> Average)

% created by KD 11-04-2017

% examples:
% write_cal('LH')
% write_cal('RH')

function write_cal(hemisphere)

calname = sprintf('curvatureAlignmentList_20subs_%s.cal', hemisphere);
fid = fopen(calname,'w+t');

% print the header
fprintf(fid,'%s\n','FileVersion: 1');
fprintf(fid,'\n');
fprintf(fid,'%s\n','NrOfEntries: 20');

% add a line with path to curvature file for each subject
for subNum = [1:14, 16:17, 19:22]
    
    subID = getID(subNum);
    
    if subNum == 7 || subNum == 9 || subNum == 14 || subNum == 17 || subNum == 21 % for five subjects we segmented TAL.vmr for session 2
        sesNum = 2;
    else
        sesNum = 1;
    end
    
    pathToSMP = sprintf('"G:/Analysis_OANT/meshdata/SUB%02d_%s_S%02d_MPRAGE_ISO_IIHC_TAL_WM_%s_RECOSMx_D80k_SPH_CURVATURE.smp"', subNum, subID, sesNum, hemisphere);
    % For some reason 'x' in 'RECOSMx' became capital in the names of full CBA .ssm files ('_GROUPALIGNED.ssm')
    pathToSSM = sprintf('"G:/Analysis_OANT/meshdata/SUB%02d_%s_S%02d_MPRAGE_ISO_IIHC_TAL_WM_%s_RECOSMX_D80K_SPH_GROUPALIGNED.ssm"', subNum, subID, sesNum, hemisphere);
    fprintf(fid,'%s %s\n', pathToSMP, pathToSSM);
end

fclose(fid);