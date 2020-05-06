function create_t_maps_simple_contrasts(subNum, hemisphere)

%% set paths and load a surface FFX glm
pathToMeshdata = 'G:/Analysis_OANT/meshdata/';  
pathToFFX = [pathToMeshdata sprintf('FFX_GLM_SUB%02d_sm6mm_%s_NonAligned.glm', subNum, hemisphere)];
glm = xff(pathToFFX);

%% compute a contrast
%Condition order:
% S1_NU     S1_NT   S1_VU   S1_VT   S1_Sq  | S2_NU   S2_NT   S2_VU   S2_VT   S2_Sq

%% training effects within session
% Map 1: S2_VT > S2_VU
S2_VTvsS2_VU = glm.FFX_tMap([0 0 0 0 0 0 0 -1 1 0]);
S2_VTvsS2_VU.Map.Name = sprintf('Subject SUB%02d: Map01_S2_VTvsS2_VU_%s.smp', subNum, hemisphere);

% Map 2: S2_NT > S2_NU
S2_NTvsS2_NU = glm.FFX_tMap([0 0 0 0 0 -1 1 0 0 0]);
S2_NTvsS2_NU.Map.Name = sprintf('Subject SUB%02d: Map02_S2_NTvsS2_NU_%s.smp', subNum, hemisphere);

%% training effects across sessions
% Map 3: S2_VT > S1_VT
S2_VTvsS1_VT = glm.FFX_tMap([0 0 0 -1 0 0 0 0 1 0]);
S2_VTvsS1_VT.Map.Name = sprintf('Subject SUB%02d: Map03_S2_VTvsS1_VT_%s.smp', subNum, hemisphere);

% Map 4: S2_NT > S1_NT
S2_NTvsS1_NT = glm.FFX_tMap([0 -1 0 0 0 0 1 0 0 0]);
S2_NTvsS1_NT.Map.Name = sprintf('Subject SUB%02d: Map04_S2_NTvsS1_NT_%s.smp', subNum, hemisphere);

%% session (task habituation, priming) effects
% Map 5: S2_VU > S1_VU
S2_VUvsS1_VU = glm.FFX_tMap([0 0 -1 0 0 0 0 1 0 0]);
S2_VUvsS1_VU.Map.Name = sprintf('Subject SUB%02d: Map05_S2_VUvsS1_VU_%s.smp', subNum, hemisphere);

% Map 6: S2_NU > S1_NU
S2_NUvsS1_NU = glm.FFX_tMap([-1 0 0 0 0 1 0 0 0 0]);
S2_NUvsS1_NU.Map.Name = sprintf('Subject SUB%02d: Map06_S2_NUvsS1_NU_%s.smp', subNum, hemisphere);



%% combine the maps for individual contrasts into one multi-map
smp = xff('new:smp');

smp.Map(1) = S2_VTvsS2_VU.Map;
smp.Map(2) = S2_NTvsS2_NU.Map;
smp.Map(3) = S2_VTvsS1_VT.Map;
smp.Map(4) = S2_NTvsS1_NT.Map;
smp.Map(5) = S2_VUvsS1_VU.Map;
smp.Map(6) = S2_NUvsS1_NU.Map;

smp.SaveAs([pwd sprintf('\\%s\\SUB%02d_sixSimpleContrasts_%s.smp', hemisphere, subNum, hemisphere)]);
