% This function produces a cluster table for an activation map contained
% in a VMP. The input argument 'stat' defines which cluster statistic will
% be produced: activation peak, center-of-mass, or center-of-gravity. By
% default, the function breaks down clusters larger than 5000 voxels into
% subclusters (of min size - 1000 voxels), for which it reports local
% maxima/minima. The function produces the following output files:
% - two TXT files (for the positive and negative tail separately),
% - two VOI files (for the positive and negative tail separately),
% - one Excel file (with tables for both tails merged in one worksheet).
% The function outputs Talairach labels using the local version of the
% Talairach Daemon. Since those are unreliable, we will project the
% created VOIs back on the cortical surface and check their anatomical
% location.


% created 2018-11-10 by KD
% last update: 2018-12-11 by KD


% example call:
% cluster_table_volume_local_maxima(1, 'talcog', 'LH')


function cluster_table_volume_local_maxima(mapNum, stat, hemisphere)

% Map numbers (mapNum):
% Map1 S1_NU + S1_NT > S1_Control
% Map2 S1_VU + S1_VT > S1_Control
% Map3 S1_NU + S1_NT + S1_VU + S1_VT > S1_Control
% Map4 S1_VU + S1_VT > S1_NU + S1_NT
% Map5 S2_NT > S2_NU
% Map6 S2_VT > S2_VU
% Map7 (S2_VT > S2_VU) > (S2_NT > S2_NU) = 0
% Map8* (S2_NT > S1_NT) > (S2_NU > S1_NU), at z=1.65
% Map9* (S2_VT > S1_VT) > (S2_VU > S1_VU), at z=1.65
% Map10 S2_NU > S1_NU
% Map11 S2_VU > S1_VU
% Map12 (S2_NU > S1_VU) > (S2_NU > S1_NU) = 0
% Map13 S1_NT > S1_NU = 0
% Map14 S1_VT > S1_VU = 0

% stat: 'talpeak'|'talcenter'|'talcog'   % 'center' (center-of-mass, i.e.,
% average coordinate) and 'cog' report similar results, since activations 
% in the cluster voxels are quite homogenous

% hemisphere: 'LH'|'RH'

contrastDescription = {'Object_naming'; 'Action_naming'; 'Picture_naming'; ...
    'Word_class_effect'; 'Noun_training_S02'; 'Verb_training_S02'; ...
    'Verb_vs_noun_training_S02 (empty)'; 'Training_vs_session_effect_Nouns_z1.65'; ...
    'Training_vs_session_effect_Verbs_z1.65'; 'Session_effect_Nouns'; ...
    'Session_effect_Verbs'; 'Session_effect_Verbs_vs_Nouns (empty)'; ...
    'Balancing_Nouns (empty)'; 'Balancing_Verbs (empty)'};

if strcmp(stat,'talpeak'), statName = 'peak'; end;
if strcmp(stat,'talcenter'), statName = 'center'; end;
if strcmp(stat,'talcog'), statName = 'cog'; end;

% Load a multi-VMP with 14 submaps of interest
pathToVMP = sprintf('zmap_tfce_14FinalMaps_%s_1000it.vmp', hemisphere);
vmp = xff(pathToVMP);

% Define parameters for cluster table creation
opts = [];
opts.tdclient = true; % look up closest talairach label (default: false)
opts.lupcrd = statName; % look-up coordinate: {'peak'}(activation peak)|'center'(center of mass)|'cog' (center of gravity)

%% Default settings:
% opts.sorting = 'maxstat'; % {'maxstat'}|'size'|'x'|'y'|'z'
% opts.clconn = 'edge'; % cluster connectivity: {'edge'}|'face'|'vertex'

%% Print out local maxima (default: no):
opts.localmax = 5000; % break down larger clusters threshold (default: Inf)
opts.localmin = 1000; % minimum size for sub-clusters (default: 2)
% opts.localmaxi = true; % iterate over sub-clusters until no more splitting can be performed (default: false)
% opts.localmsz = true; % print sub-cluster sizes (default: false)


%%%%%%%%%%%%%%%%%%%% POSITIVE TAIL %%%%%%%%%%%%%%%%%%%%%
%% Create txt cluster table for the positive tail (A > B)

opts.showpos = true; % positive values are considered (default: true)
opts.showneg = false; % negative values are NOT considered (default: false)

% Create cluster table using the params in 'opts'
[c, table] = vmp.ClusterTable(mapNum, vmp.Map(mapNum).LowerThreshold, opts);

% Save cluster table as .txt
filename = sprintf('Map%02d_%s_%s_max%d_min%d_%s_positiveTail.txt', mapNum, ...
    contrastDescription{mapNum}, statName, opts.localmax, opts.localmin, hemisphere);
fileID = fopen(filename, 'w');
fprintf(fileID, table);
fclose(fileID);

%% Create multi-VOI with sperical ROIs around activation peaks
% (to facilitate manual labeling of clusters from the surface,
% since automatic labeling in the volume using TD is not reliable)

colorMatrix = [... % Let's pick a palette for out spherical ROIs:
    255 0 0;...   1. red
    255 165 0;... 2. orange
    255 255 0;... 3. yellow
    0 128 0;...   4. green (dark-green, emerald)
    0 255 255;... 5. cyan (aqua)
    0 0 128;...   6. navy blue (dark-blue)
    128 0 128;... 7. purple
    128 0 0;...   8. maroon
    128 128 0;... 9. olive
    0 128 128;... 10. teal
    255 0 255;... 11. fuchsia (magenta)
    0 255 0;...   12. lime (light-green)
    205 133 63;...13. brown (peru)
    ];

% We have 13 colors ready to be picked for ROIs. However, if those won't be
% enough, we will just repeat them: for cluster #14 - color #1, for cluster
% #15 - color #2, etc.
numRep = ceil(length(c)/13); % round up to the nearest integer
newColorMatrix = repmat(colorMatrix, numRep, 1); % replicate color matrix
% enough times to have colors assigned to all clusters

voi = xff('new:voi');

% Note that below some structure fields are referenced dynamically, i.e, using
% variable names: https://www.mathworks.com/matlabcentral/answers/80200-access-elements-fields-from-a-struct
for i = 1:length(c) % for each cluster
    voi.AddSphericalVOI(c(i).(stat), 4); % create a spherical ROI (r=4 mm) around the activation peak coordinate
    voi.VOI(i).Color = newColorMatrix(i,1:3); % assign one of the predetermined colors
end
    
voiName = sprintf('Map%02d_%s_%s_max%d_min%d_%s_positiveTail.voi', mapNum, ...
    contrastDescription{mapNum}, statName, opts.localmax, opts.localmin, hemisphere);
voi.SaveAs(voiName);
    

%% Copy cluster table to Excel (print positive tail)
clusterTable = {'Contrast', 'Tail', 'z-thresh', 'hemisphere', ...
    'x TAL', 'y TAL', 'z TAL', 'k (nr of voxels)', ...
    'max stat (peak)', 'mean stat', 'automatic Tal label'};

k = 0; % initiate counter
for i = 2:(length(c)+1) % let's loop through all clusters in struct 'c'
    k = k + 1;
    clusterTable{i,1} = vmp.Map(mapNum).Name; % contrast name
    clusterTable{i,2} = 'pos.'; % hardwire the tail name: 'pos.'|'neg.'
    clusterTable{i,3} = vmp.Map(mapNum).LowerThreshold; % z-threshold: 1.96|1.65
    clusterTable{i,4} = hemisphere; % hemisphere: 'LH'|'RH'
    clusterTable{i,5} = c(k).(stat)(1); % Talairach x coordinate
    clusterTable{i,6} = c(k).(stat)(2); % Talairach y coordinate
    clusterTable{i,7} = c(k).(stat)(3); % Talairach z coordinate
	clusterTable{i,8} = c(k).rwsize; % k (nr of voxels in the cluster)
    clusterTable{i,9} = c(k).max; % activation peak statistic (z)
    clusterTable{i,10} = c(k).mean; % mean activation statistic in the cluster
    clusterTable{i,11} = c(k).talout; % Talairach label from local copy of Talairach Daemon
    if strcmp(c(k).localmax, 'L')
        clusterTable{i,13} = '';
    else
        clusterTable{i,13} = 'cluster'; % put a temporary tag indicating that it's a cluster (and not a local maximum/minimum)
    end
end




%%%%%%%%%%%%%%%%%%%% NEGATIVE TAIL %%%%%%%%%%%%%%%%%%%%%
%% Create txt cluster table for the negative tail (A < B)

opts.showpos = false; % positive values are NOT considered (default: true)
opts.showneg = true; % negative values are considered (default: false)

% Create cluster table using the params in 'opts'
[c, table] = vmp.ClusterTable(mapNum, vmp.Map(mapNum).LowerThreshold, opts);

% Save cluster table as .txt
filename = sprintf('Map%02d_%s_%s_max%d_min%d_%s_negativeTail.txt', mapNum, ...
    contrastDescription{mapNum}, statName, opts.localmax, opts.localmin, hemisphere);
fileID = fopen(filename, 'w');
fprintf(fileID, table);
fclose(fileID);


%% Create multi-VOI with sperical ROIs around activation peaks

numRep = ceil(length(c)/13); % round up to the nearest integer
newColorMatrix = repmat(colorMatrix, numRep, 1); % replicate color matrix
% enough times to have colors assigned to all clusters

voi = xff('new:voi');

for i = 1:length(c) % for each cluster
    voi.AddSphericalVOI(c(i).(stat), 4); % create a spherical ROI (r=4 mm) around the activation peak coordinate
	voi.VOI(i).Color = newColorMatrix(i,1:3); % assign one of the predetermined colors
end

voiName = sprintf('Map%02d_%s_%s_max%d_min%d_%s_negativeTail.voi', mapNum, ...
    contrastDescription{mapNum}, statName, opts.localmax, opts.localmin, hemisphere);
voi.SaveAs(voiName);


%% Copy cluster table to Excel (print negative tail)
nRows = size(clusterTable,1); % current row count
k = 0; % initiate counter
for i = (nRows+1):(nRows+length(c)) % let's loop through all clusters in struct 'c'
    k = k + 1; % counter
    clusterTable{i,1} = vmp.Map(mapNum).Name; % contrast name
    clusterTable{i,2} = 'neg.'; % hardwire the tail name: 'pos.'|'neg.'
    clusterTable{i,3} = vmp.Map(mapNum).LowerThreshold; % z-threshold: 1.96|1.65
    clusterTable{i,4} = hemisphere; % hemisphere: 'LH'|'RH'
    clusterTable{i,5} = c(k).(stat)(1); % Talairach x coordinate
    clusterTable{i,6} = c(k).(stat)(2); % Talairach y coordinate
    clusterTable{i,7} = c(k).(stat)(3); % Talairach z coordinate
	clusterTable{i,8} = c(k).rwsize; % k (nr of voxels in the cluster)
    clusterTable{i,9} = c(k).max; % activation peak statistic (z)
    clusterTable{i,10} = c(k).mean; % mean activation statistic in the cluster
    clusterTable{i,11} = c(k).talout; % Talairach label from local copy of Talairach Daemon
    if strcmp(c(k).localmax, 'L')
        clusterTable{i,13} = '';
    else
        clusterTable{i,13} = 'cluster'; % put a temporary tag indicating that it's a cluster (and not a local maximum/minimum)
    end
end


%% Write Excel file (both positive and negative tail on the same worksheet)
xlsname = sprintf('cluster_table_map%02d_%s_%s_max%d_min%d_%s.xls', mapNum, ...
    contrastDescription{mapNum}, statName, opts.localmax, opts.localmin, hemisphere);
xlswrite(xlsname, clusterTable);



%% Clear the object storage to delete an 800+ Mb multiVMP from memory
% (like 'clear' in Matlab for objects WS)
% As the storage is NOT directly associated with any given object variable,
% using Matlab's clear function on any such variable will not lead to the
% allocated memory being freed by Matlab! Instead the .ClearObject call
% must be issued to free up memory. To clear all objects:
xff(0, 'clearallobjects');