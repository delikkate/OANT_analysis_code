%% This script creates an "identity SSM" to further link it to FFX GLM
% performed on a subject's SPH surface

function identity_SSM(subNum, hemisphere)

ID = getID(subNum);
subID = sprintf('SUB%02d_%s', subNum, ID);

pathToSRF = 'G:/Analysis_OANT/meshdata/';

% Indicate path to SRF
if subNum == 7 || subNum == 9 || subNum == 14 || subNum == 17 || subNum == 21
	srfname = [pathToSRF sprintf('%s_S02_MPRAGE_ISO_IIHC_TAL_WM_%s_RECOSMx_D80k_SPH.srf', subID, hemisphere)];
else
	srfname = [pathToSRF sprintf('%s_S01_MPRAGE_ISO_IIHC_TAL_WM_%s_RECOSMx_D80k_SPH.srf', subID, hemisphere)];
end

% load SRF
srf = xff(srfname);

% create SSM
ssm = xff('new:ssm');

% copy settings
ssm.NrOfTargetVertices = srf.NrOfVertices;
ssm.NrOfSourceVertices = srf.NrOfVertices;
ssm.SourceOfTarget = 1:srf.NrOfVertices;

% save SSM file
ssm.SaveAs(strrep(srf.FilenameOnDisk, '.srf', '_identity.ssm'));

% clear objects
ssm.ClearObject;
srf.ClearObject

