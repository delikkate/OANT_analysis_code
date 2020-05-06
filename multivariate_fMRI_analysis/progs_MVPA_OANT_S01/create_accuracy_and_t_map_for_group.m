% This script puts together individual searchlight maps (after
% CBA-alignment) and creates (1) uncorrected t-scores, and (2) accuracy
% maps.

% created by KD 20-12-2017

function create_accuracy_and_t_map_for_group(map_name, hemisphere)

% map_name = 'verbs_vs_nouns' | 'training_effects'
% hemisphere = 'LH' | 'RH'


%% initial setup

% specify subjects that participated in searchlight analysis
subVec = [1:14, 16:17, 19:22];
nSub = length(subVec);

% indicate path to CBA-transformed individual searchlight maps
pathToData = [pwd sprintf('\\searchlight_%s\\', hemisphere)];


%% preallocate groupMap matrix
groupMap = zeros(40962, nSub); % 40962 = nr of surface nodes on a standard mesh


%% load data from all individual accuracy maps into groupMap

for iSub = subVec

    %load SMP
    smpName = [pathToData sprintf('SUB%02d_%s_accuracy_map_%s_ALIGNED.smp', iSub, map_name, hemisphere)];
    thisSMP = xff(smpName);

    %copy subject accuracy data into the group matrix
    groupMap(:,iSub) = thisSMP.Map.SMPData;

end

% transform accuracy results into percentage
groupMap = groupMap * 100;


%% create a mean decoding accuracy map

% compute mean accuracy percentage across subjects
groupMap_mean = mean(groupMap,2);

% find the highest and lowest accuracy scores
lowest_accuracy = min(groupMap_mean);
highest_accuracy = max(groupMap_mean);

% create an SMP where the results will be stored
smp_accuracy = xff('new:smp');
smp_accuracy.Map.SMPData = groupMap_mean;
smp_accuracy.Map.LowerThreshold = 40;
smp_accuracy.Map.UpperThreshold = 60;
% smp_group.Map.ShowPositiveNegativeFlag = 1; % 1 -> pos, 2 -> neg, 3 -> both  CHANGING THIS SETTING DOESN'T WORK (always both tails are dsplayed)
smp_accuracy.Map.UseRGBColor = 0;
smp_accuracy.Map.LUTName = 'G:\Analysis_OANT\progs_MVPA_OANT_S02\LUTs\red2blue_for_meanAcc_GA.olt';
smp_accuracy.Map.Name = sprintf('mean_accuracy_%s_%02dsubs_%s', map_name, nSub, hemisphere);

% % save the map
smp_accuracy_name = [pwd '\group_decoding_maps\mean_accuracy\'...
    sprintf('mean_accuracy_%s_%02dsubs_%s.smp', map_name, nSub, hemisphere)];
smp_accuracy.SaveAs(smp_accuracy_name);


%% create one-sample t-test map

[~,~,~,stats] = ttest(groupMap, 50, 0.05, 'right', 2);

smp_tstat = xff('new:smp');
smp_tstat.Map.SMPData = stats.tstat;
smp_tstat.Map.DF1 = stats.df(1);
smp_tstat.Map.DF2 = 0;
smp_tstat.Map.Name = sprintf('uncorrected_t_%s_%02dsubs_%s', map_name, nSub, hemisphere);

% save the map
smp_tstat_name = [pwd '\group_decoding_maps\uncorrected_t_maps\'...
    sprintf('uncorrected_t_map_%s_%02dsubs_%s.smp', map_name, nSub, hemisphere)];
smp_tstat.SaveAs(smp_tstat_name);

