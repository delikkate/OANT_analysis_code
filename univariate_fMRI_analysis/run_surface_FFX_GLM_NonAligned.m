function run_surface_FFX_GLM_NonAligned(subNum, hemisphere)
% The script runs a fixed-effects GLM for a subject (both sessions
% combined, 16 runs in total) on a subject's SPH mesh (prior to
% cortex-based group alignment).

%created by KD 21-07-2017

%example call:
%run_surface_FFX_GLM_NonAligned(1, 'LH')
%run_surface_FFX_GLM_NonAligned(1, 'RH')


ID = getID(subNum);
subID = sprintf('SUB%02d_%s', subNum, ID);

pathToMeshdata = 'G:/Analysis_OANT/meshdata/';

if subNum == 7 || subNum == 9 || subNum == 14 || subNum == 17 || subNum == 21 % for five subjects we segmented TAL.vmr for session 2
    sesNum = 2;
else
    sesNum = 1;
end
pathToVMR = [pathToMeshdata subID sprintf('_S%02d_MPRAGE_ISO_IIHC_TAL.vmr', sesNum)];

pathToMDM = sprintf('MDM_surface_FFX_SUB%02d_sm6mm_%s_NonAligned.mdm', subNum, hemisphere); % filename without path (should reside in the same folder as VMR)


pathToSRF = [pathToMeshdata sprintf('%s_S%02d_MPRAGE_ISO_IIHC_TAL_WM_%s_RECOSMx_D80k_SPH.srf', subID, sesNum, hemisphere)];

GLMname = sprintf('FFX_GLM_SUB%02d_sm6mm_%s_NonAligned.glm', subNum, hemisphere);


bvqx = actxserver('BrainVoyagerQX.BrainVoyagerQXScriptAccess.1');
docVMR = bvqx.OpenDocument(pathToVMR);

docVMR.LoadMesh(pathToSRF);
meshSRF = docVMR.CurrentMesh;


meshSRF.ClearDesignMatrix();
meshSRF.LoadMultiStudyGLMDefinitionFile(pathToMDM);

meshSRF.CorrectForSerialCorrelations = 1;

meshSRF.ComputeMultiStudyGLM();

meshSRF.SaveGLM(GLMname);

docVMR.Close();
