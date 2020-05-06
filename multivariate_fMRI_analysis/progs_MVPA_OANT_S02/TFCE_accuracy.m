function TFCE_accuracy(map_name, hemisphere, niter)

% map_name = 'verbs_vs_nouns_S01' | 'training_effects'
% hemisphere = 'LH' | 'RH'

% niter = 1000 | 5000 | 10000   % number of permutations

%% initial setup

% indicate the number of subjects
subVec = [1:14, 16:17, 19:22];
nSub = length(subVec);

% indicate the path to searchlight maps
pathToSMP = [pwd sprintf('\\searchlightSMPs\\%s\\%s\\', map_name, hemisphere)];

%% load accuracy maps

% initiate a variable to keep all individual datasets
ds_sub=cell(1, nSub);

% set the counter
i = 0;

% loop over subjects
for iSub = subVec
    
    i = i + 1; % we need the counter to put subject datasets into sequential cells (without gaps between 14 and 16, 17 and 19)
    
    % define the name of the current individual SMP
    filename_smp=fullfile(pathToSMP, sprintf('SUB%02d_%s_accuracy_map_%s_ALIGNED.smp', iSub, map_name, hemisphere));
    
    % import the SMP in the cosmo format
    ds_sub{i}=cosmo_surface_dataset(filename_smp);
    
end
surf_ds=cosmo_stack(ds_sub);


%% define chunks and targets

% Set chunks to (1:10)', indicating that all samples are assumed to be independent
surf_ds.sa.chunks = (1:nSub)';

surf_ds.sa.targets = ones(nSub,1);



%% load group average surface mesh for LH
surface_mesh = sprintf('GroupAligned_foldedMesh_%s_20sub_grey.srf', hemisphere);
[vertices, faces] = surfing_read(surface_mesh);



%% Run Threshold-Free Cluster Enhancement (TFCE)

% define neighborhood for each feature
cluster_nbrhood=cosmo_cluster_neighborhood(surf_ds,...
                                        'vertices',vertices,'faces',faces);

fprintf('Cluster neighborhood:\n');
cosmo_disp(cluster_nbrhood);

opt=struct();

opt.cluster_stat  = 'tfce';
opt.niter = niter; % for publication-quality, use >=1000; 10000 is even better
opt.h0_mean = 0.5; % one-sample t-test against chance (1/Nr of conditions = 0.5)

fprintf('Running multiple-comparison correction with these options:\n');
cosmo_disp(opt);

% Run TFCE-based cluster correction for multiple comparisons.
% The output has z-scores for each node indicating the probablity to find
% the same, or higher, TFCE value under the null hypothesis.
ds_tfce = cosmo_montecarlo_cluster_stat(surf_ds,cluster_nbrhood,opt);

%% Show results

fprintf('TFCE z-score dataset\n');
cosmo_disp(ds_tfce);


% choose a name for your map
ds_tfce.sa.labels = {sprintf('%s_accuracy_TFCE_%s_%s',map_name, hemisphere, niter)};

%% map to brainvoyager -- convert the CoSMo dataset 'zmap' into a .VMP object readable by BrainVoyager and Neuroelf
smp = cosmo_map2surface(ds_tfce, '-bv_smp');

%% Let's adjust the map legend
smp.Map.LowerThreshold = 1.96; % two-tail threshold; for one-tail, set to 1.645
smp.Map.UpperThreshold = 4;
smp.Map.UseRGBColor = 0;
smp.Map.LUTName = 'C:\Program Files (x86)\BrainVoyager\MapLUTs\angle_hsv_v1.olt';

%% you can now keep working using Neuroelf or just save the vmp
corrected_smp_name = sprintf('%s_accuracy_TFCE_%s_%dit.smp',map_name, hemisphere, niter);
smp.SaveAS(corrected_smp_name);

