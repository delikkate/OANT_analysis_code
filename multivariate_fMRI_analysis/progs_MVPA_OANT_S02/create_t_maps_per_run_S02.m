% This function creates 4 t-maps with main effects of condition per
% hemisphere and combines them into a single multi-SMP.

function create_t_maps_per_run_S02(subNum, runNum, hemisphere)

pathToSingleRunGLMs = ['G:/Analysis_OANT/meshdata/single-run_GLMs_S02_nonAligned_forMVPA_' sprintf('%s/', hemisphere)];

% Open a GLM
glmpath = [pathToSingleRunGLMs sprintf('single_run_GLM_SUB%02d_RUN%02d_S02_sm0mm_%s_NonAligned.glm', subNum, runNum, hemisphere)];
glm = xff(glmpath);


% Map 1: S2_NU
S2_NU = glm.FFX_tMap([1 0 0 0 0]);
S2_NU.Map.Name = sprintf('Subject SUB%02d: RUN%02d_Map01_S2_NU_%s.smp', subNum, runNum, hemisphere); %need to rename a map for further alignment

% Map 2: S2_NT
S2_NT = glm.FFX_tMap([0 1 0 0 0]);
S2_NT.Map.Name = sprintf('Subject SUB%02d: RUN%02d_Map02_S2_NT_%s.smp', subNum, runNum, hemisphere);

% Map 3: S2_VU
S2_VU = glm.FFX_tMap([0 0 1 0 0]);
S2_VU.Map.Name = sprintf('Subject SUB%02d: RUN%02d_Map03_S2_VU_%s.smp', subNum, runNum, hemisphere);

% Map 4: S2_VT
S2_VT = glm.FFX_tMap([0 0 0 1 0 ]);
S2_VT.Map.Name = sprintf('Subject SUB%02d: RUN%02d_Map04_S2_VT_%s.smp', subNum, runNum, hemisphere);



%% Combine the 4 t-maps into one multi-SMP
smp = xff('new:smp');

smp.Map(1) = S2_NU.Map;
smp.Map(2) = S2_NT.Map;
smp.Map(3) = S2_VU.Map;
smp.Map(4) = S2_VT.Map;

smp.SaveAs(sprintf('SUB%02d_RUN%02d_fourMaps_%s_onlyS02.smp', subNum, runNum, hemisphere));