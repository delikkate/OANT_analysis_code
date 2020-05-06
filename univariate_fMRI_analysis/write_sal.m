% The function creates a .sal text file that is used to create an averaged
% mesh for a hemisphere (Meshes: Cortex-Based Alignment -> Options -> 
% radio button "Shape" -> Average).

% created by KD 11-04-2017

% examples:
% write_sal('LH')
% write_sal('RH')

function write_sal(hemisphere)

salname = sprintf('shapeAlignmentList_20subs_%s.sal', hemisphere);
fid = fopen(salname,'w+t');

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
    
    pathToSRF = sprintf('"G:/Analysis_OANT/meshdata/SUB%02d_%s_S%02d_MPRAGE_ISO_IIHC_TAL_WM_%s_RECOSMx_D80k_SPH.srf"', subNum, subID, sesNum, hemisphere);
    % For some reason 'x' in 'RECOSMx' became capital in the names of full CBA .ssm files ('_GROUPALIGNED.ssm')
    pathToSSM = sprintf('"G:/Analysis_OANT/meshdata/SUB%02d_%s_S%02d_MPRAGE_ISO_IIHC_TAL_WM_%s_RECOSMX_D80K_SPH_GROUPALIGNED.ssm"', subNum, subID, sesNum, hemisphere);
    fprintf(fid,'%s %s\n', pathToSRF, pathToSSM);
end

fclose(fid);