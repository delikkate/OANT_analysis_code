% The function creates a .gal text file that is loaded on "Align Group" tab
% of Cortex-Based Alignment dialog when running rigid and full CBA.

% created by KD 11-04-2017

% examples:
% write_gal('LH')
% write_gal('RH')

function write_gal(hemisphere)

galname = sprintf('groupAlignmentList_20subs_%s.gal', hemisphere);
fid = fopen(galname,'w+t');

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
    
    pathToCurvatureSMP = sprintf('"./SUB%02d_%s_S%02d_MPRAGE_ISO_IIHC_TAL_WM_%s_RECOSMx_D80k_SPH_CURVATURE.smp"', subNum, subID, sesNum, hemisphere);
    fprintf(fid,'%s\n', pathToCurvatureSMP);
end

fclose(fid);