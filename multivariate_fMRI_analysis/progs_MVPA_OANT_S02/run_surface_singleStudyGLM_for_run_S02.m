% The function runs a single-study GLM (separately for each run) on the
% individual subject mesh. As input, mesh times courses (MTC) and design
% matrices (SDM) for individual runs are used. We will run single-run GLMs
% on individual subject surfaces, and align the maps to the group-averaged
% mesh using SSM files at a later stage.

% created by KD 16-12-2017
% UPD by KD 25-01-2018

% example call:
% create_singleStudyGLM_for_run_S02(1,1,2,'LH')
% create_singleStudyGLM_for_run_S02(1,1,2,'RH')

function run_surface_singleStudyGLM_for_run_S02(subNum, runNum, sesNum, hemisphere)

%% set paths to data

ID = getID(subNum);
subID = sprintf('SUB%02d_%s', subNum, ID);

% session = session used for anatomy segmentation (is always the same for a subject)
% sesNum = session, to which the current run belongs (varies from run to run)

% For five subjects we segmented TAL.vmr for session 2
if subNum == 7 || subNum == 9 || subNum == 14 || subNum == 17 || subNum == 21
    session = 2;
else
    session = 1;
end

pathToMeshdata = 'G:/Analysis_OANT/meshdata/';
pathToGroupdata = 'G:/Analysis_OANT/groupdata/';

pathToVMR = [pathToMeshdata subID sprintf('_S%02d_MPRAGE_ISO_IIHC_TAL.vmr', session)];
pathToSRF = [pathToMeshdata sprintf('%s_S%02d_MPRAGE_ISO_IIHC_TAL_WM_%s_RECOSMx_D80k_SPH.srf', subID, session, hemisphere)];
pathToMTC = [pathToMeshdata sprintf('%s_%02d_S%02d_OANT_SCCAI_3DMCTS_LTR_THP3c_TAL_%s.mtc', subID, runNum, sesNum, hemisphere)]; %unsmoothed MTC
pathToSDM = [pathToGroupdata sprintf('%s_%02d_S%02d_OANT_onlyS02.sdm', subID, runNum, sesNum)];

GLMname = sprintf('single_run_GLM_SUB%02d_RUN%02d_S%02d_sm0mm_%s_NonAligned.glm', subNum, runNum, sesNum, hemisphere);


%% enable COM scripting mode and run the GLM

bvqx = actxserver('BrainVoyagerQX.BrainVoyagerQXScriptAccess.1');

docVMR = bvqx.OpenDocument(pathToVMR);
docVMR.LoadMesh(pathToSRF);
meshSRF = docVMR.CurrentMesh;
meshSRF.LinkMTC(pathToMTC);
meshSRF.LoadSingleStudyGLMDesignMatrix(pathToSDM);

meshSRF.CorrectForSerialCorrelations = 1; % 1 -> AR(1), 2 -> AR(2)
meshSRF.ComputeSingleStudyGLM();
meshSRF.ShowGLM();
meshSRF.SaveGLM(GLMname);

docVMR.Close();