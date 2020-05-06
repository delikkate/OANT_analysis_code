% This function creates 4 t-maps with main effects of condition per
% hemisphere and combines them into a single multi-SMP.

function create_t_maps_per_run_S01(subNum, runNum, hemisphere)

pathToSingleRunGLMs = ['G:/Analysis_OANT/meshdata/single-run_GLMs_S01_nonAligned_forMVPA_' sprintf('%s/', hemisphere)];

% Open a GLM
glmpath = [pathToSingleRunGLMs sprintf('single_run_GLM_SUB%02d_RUN%02d_S01_sm0mm_%s_NonAligned.glm', subNum, runNum, hemisphere)];
glm = xff(glmpath);


% Map 1: S1_NU
S1_NU = glm.FFX_tMap([1 0 0 0 0]);
S1_NU.Map.Name = sprintf('Subject SUB%02d: RUN%02d_Map01_S1_NU_%s.smp', subNum, runNum, hemisphere); %need to rename a map for further alignment

% Map 2: S1_NT
S1_NT = glm.FFX_tMap([0 1 0 0 0]);
S1_NT.Map.Name = sprintf('Subject SUB%02d: RUN%02d_Map02_S1_NT_%s.smp', subNum, runNum, hemisphere);

% Map 3: S1_VU
S1_VU = glm.FFX_tMap([0 0 1 0 0]);
S1_VU.Map.Name = sprintf('Subject SUB%02d: RUN%02d_Map03_S1_VU_%s.smp', subNum, runNum, hemisphere);

% Map 4: S1_VT
S1_VT = glm.FFX_tMap([0 0 0 1 0 ]);
S1_VT.Map.Name = sprintf('Subject SUB%02d: RUN%02d_Map04_S1_VT_%s.smp', subNum, runNum, hemisphere);



%% Combine the 4 t-maps into one multi-SMP
smp = xff('new:smp');

smp.Map(1) = S1_NU.Map;
smp.Map(2) = S1_NT.Map;
smp.Map(3) = S1_VU.Map;
smp.Map(4) = S1_VT.Map;

smp.SaveAs(sprintf('SUB%02d_RUN%02d_fourMaps_%s_onlyS01.smp', subNum, runNum, hemisphere));