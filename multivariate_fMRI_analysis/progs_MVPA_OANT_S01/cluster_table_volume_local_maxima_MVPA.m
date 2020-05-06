% This function produces a cluster table for an INFORMATION map contained
% in a VMP. The input argument 'stat' defines which cluster statistic will
% be produced: activation peak, center-of-mass, or center-of-gravity. By
% default, the function breaks down clusters larger than 5000 voxels into
% subclusters (of min size - 1000 voxels), for which it reports local
% maxima/minima. The function produces the following output files (for the
% positive tail only, since we don't have accuracies significantly below
% chance):
% - a TXT file,
% - a VOI file,
% - an Excel file.
% The function outputs Talairach labels using the local version of the
% Talairach Daemon. Since those are unreliable, we will project the
% created VOIs on the cortical surface and check their anatomical
% location.


% created 2018-11-10 by KD
% updated for MVPA maps: 2018-12-19 by KD


% example call:
% cluster_table_volume_local_maxima_MVPA('verbs_vs_nouns_S01', 'talcog', 'LH')


function cluster_table_volume_local_maxima_MVPA(mapName, stat, hemisphere)

% mapName: 'training_effects' | 'verbs_vs_nouns_S01'

% stat: 'talpeak'|'talcenter'|'talcog'

% hemisphere: 'LH'|'RH'

if strcmp(stat,'talpeak'), statName = 'peak'; end;
if strcmp(stat,'talcenter'), statName = 'center'; end;
if strcmp(stat,'talcog'), statName = 'cog'; end;

% Load a multi-VMP with
% (map 1) TFCE-corrected accuracy map, and
% (map 2) mean accuracies across the cortex
pathToVMP = [pwd '\vmp\' sprintf('%s_accuracy_20subjects_TFCE_%s_clust10.vmp', mapName, hemisphere)];
vmp = xff(pathToVMP);

mapNum = 1; % the main map of interest is map 1 (TFCE-corrected decoding accuracies)

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

%% Add info from the mean accuracy map (map 2):
opts.altmaps = 2; % alternative maps to extract values from (default: [])
opts.altstat = 'peak'; % either of 'mean' or {'peak'}


%% Create txt cluster table for the positive tail (A > B)
opts.showpos = true; % positive values are considered (default: true)
opts.showneg = false; % negative values are NOT considered (default: false)

% Create cluster table using the params in 'opts'
[c, table] = vmp.ClusterTable(mapNum, vmp.Map(mapNum).LowerThreshold, opts);

% Save cluster table as .txt
filename = sprintf('%s_%s_max%d_min%d_%s.txt', mapName, statName, opts.localmax, opts.localmin, hemisphere);
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
    
voiName = sprintf('%s_%s_max%d_min%d_%s.voi', mapName, statName, opts.localmax, opts.localmin, hemisphere);
voi.SaveAs(voiName);
    

%% Copy cluster table to Excel (print positive tail)
clusterTable = {'Contrast', 'Tail', 'z-thresh', 'hemisphere', ...
    'x TAL', 'y TAL', 'z TAL', 'k (nr of voxels)', ...
    'max stat (peak)', 'mean stat', 'automatic Tal label', ...
    'peak accuracy', 'mean accuracy', 'AltStat_in_given_coord'};

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
    clusterTable{i, 12} = c(k).peakalt; % = vmp.VoxelStats(2, c(k).talpeak, 'Tal'); % accuracy value in the peak voxel of a (sub)cluster
    clusterTable{i, 13} = c(k).meanalt; % mean decoding accuracy value in a (sub)cluster
    clusterTable{i, 14} = vmp.VoxelStats(2, c(k).(stat), 'Tal'); % decoding accuracy value in a chosen coordinate (be it peak, COM or COG)
    if strcmp(c(k).localmax, 'L')
        clusterTable{i,16} = '';
    else
        clusterTable{i,16} = 'cluster'; % put a temporary tag indicating that it's a cluster (and not a local maximum/minimum)
    end
end


%% Write Excel file
xlsname = sprintf('cluster_table_%s_%s_max%d_min%d_%s.xls', mapName, statName, opts.localmax, opts.localmin, hemisphere);
xlswrite(xlsname, clusterTable);



%% Clear the object storage a multiVMP from memory
% (like 'clear' in Matlab for objects WS)
% As the storage is NOT directly associated with any given object variable,
% using Matlab's clear function on any such variable will not lead to the
% allocated memory being freed by Matlab! Instead the .ClearObject call
% must be issued to free up memory. To clear all objects:
xff(0, 'clearallobjects');