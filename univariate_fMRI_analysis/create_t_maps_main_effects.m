% This function creates 10 t-maps with main effects for each hemisphere and
% combines them into one multi-SMP that will be further manually aligned to
% the group surface using CBA transformation file.

function create_t_maps_main_effects(subNum, hemisphere)

pathToMeshdata = 'G:/Analysis_OANT/meshdata/';

% Open a GLM
glmpath = [pathToMeshdata sprintf('FFX_GLM_SUB%02d_sm6mm_%s_NonAligned.glm', subNum, hemisphere)];
glm = xff(glmpath);

%Condition order:
% S1_NU     S1_NT   S1_VU   S1_VT   S1_Sq  | S2_NU   S2_NT   S2_VU   S2_VT   S2_Sq

% Map 1: S1_NU
S1_NU = glm.FFX_tMap([1 0 0 0 0 0 0 0 0 0]);
S1_NU.Map.Name = sprintf('Subject SUB%02d: Map01_S1_NU_%s.smp', subNum, hemisphere); %need to rename a map for subsequent alignment

% Map 2: S1_NT
S1_NT = glm.FFX_tMap([0 1 0 0 0 0 0 0 0 0]);
S1_NT.Map.Name = sprintf('Subject SUB%02d: Map02_S1_NT_%s.smp', subNum, hemisphere);

% Map 3: S1_VU
S1_VU = glm.FFX_tMap([0 0 1 0 0 0 0 0 0 0]);
S1_VU.Map.Name = sprintf('Subject SUB%02d: Map03_S1_VU_%s.smp', subNum, hemisphere);

% Map 4: S1_VT
S1_VT = glm.FFX_tMap([0 0 0 1 0 0 0 0 0 0]);
S1_VT.Map.Name = sprintf('Subject SUB%02d: Map04_S1_VT_%s.smp', subNum, hemisphere);

% Map 5: S1_Sq
S1_Sq = glm.FFX_tMap([0 0 0 0 1 0 0 0 0 0]);
S1_Sq.Map.Name = sprintf('Subject SUB%02d: Map05_S1_Sq_%s.smp', subNum, hemisphere);

% Map 6: S2_NU
S2_NU = glm.FFX_tMap([0 0 0 0 0 1 0 0 0 0]);
S2_NU.Map.Name = sprintf('Subject SUB%02d: Map06_S2_NU_%s.smp', subNum, hemisphere);

% Map 7: S2_NT
S2_NT = glm.FFX_tMap([0 0 0 0 0 0 1 0 0 0]);
S2_NT.Map.Name = sprintf('Subject SUB%02d: Map07_S2_NT_%s.smp', subNum, hemisphere);

% Map 8: S2_VU
S2_VU = glm.FFX_tMap([0 0 0 0 0 0 0 1 0 0]);
S2_VU.Map.Name = sprintf('Subject SUB%02d: Map08_S2_VU_%s.smp', subNum, hemisphere);

% Map 9: S2_VT
S2_VT = glm.FFX_tMap([0 0 0 0 0 0 0 0 1 0]);
S2_VT.Map.Name = sprintf('Subject SUB%02d: Map09_S2_VT_%s.smp', subNum, hemisphere);

% Map 10: S2_Sq
S2_Sq = glm.FFX_tMap([0 0 0 0 0 0 0 0 0 1]);
S2_Sq.Map.Name = sprintf('Subject SUB%02d: Map10_S2_Sq_%s.smp', subNum, hemisphere);



%% Combine the individual t-maps into one multi-map
smp = xff('new:smp');

smp.Map(1) = S1_NU.Map;
smp.Map(2) = S1_NT.Map;
smp.Map(3) = S1_VU.Map;
smp.Map(4) = S1_VT.Map;
smp.Map(5) = S1_Sq.Map;
smp.Map(6) = S2_NU.Map;
smp.Map(7) = S2_NT.Map;
smp.Map(8) = S2_VU.Map;
smp.Map(9) = S2_VT.Map;
smp.Map(10) = S2_Sq.Map;

smp.SaveAs(sprintf('SUB%02d_tenMaps_%s.smp', subNum, hemisphere));

