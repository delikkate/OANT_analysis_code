function TFCE_complex_contrast(contrast_name1, contrast_name2, hemisphere)

% This function performs group permutation analysis with Threshold-Free
% Cluster Enhancement (TFCE).

% contrast_name = 'S2_VTvsS2_VU' | 'S2_NTvsS2_NU' | 'S2_VTvsS1_VT'
% 'S2_NTvsS1_NT' | 'S2_VUvsS1_VU' | 'S2_NUvsS1_NU'
% hemisphere = 'LH' | 'RH'


%% initial setup

% indicate the number of subjects
subVec = [1:14, 16:17, 19:22];
nSub = length(subVec);

% indicate the path to searchlight maps
pathToSMP = [pwd sprintf('\\%s\\', hemisphere)];

%% load accuracy maps

% initiate a variable to keep all individual datasets
ds_sub=cell(1, nSub);

% set the counter
i = 0;

% loop over subjects
for iSub = subVec
    
    i = i + 1; % we need the counter to put subject datasets into sequential cells (without gaps between 14 and 16, 17 and 19)
    
    % define the name of the current individual SMP
    filename_smp=fullfile(pathToSMP, sprintf('SUB%02d_sixSimpleContrasts_%s_ALIGNED.smp', iSub, hemisphere));
    
    % import the SMP in the cosmo format
    ds_sub{i}=cosmo_surface_dataset(filename_smp);
    
    % give human readable labels to conditions
    ds_sub{i}.sa.Name2{1,1} = 'S2_VTvsS2_VU';
    ds_sub{i}.sa.Name2{2,1} = 'S2_NTvsS2_NU';
    ds_sub{i}.sa.Name2{3,1} = 'S2_VTvsS1_VT';
    ds_sub{i}.sa.Name2{4,1} = 'S2_NTvsS1_NT';
    ds_sub{i}.sa.Name2{5,1} = 'S2_VUvsS1_VU';
    ds_sub{i}.sa.Name2{6,1} = 'S2_NUvsS1_NU';
    
    % set chunks: each chunk, or independent measurement, is our subject
    ds_sub{i}.sa.chunks=ones(size(ds_sub{i}.samples, 1),1)*i;
    
end
surf_ds=cosmo_stack(ds_sub);


%% just keep the conditions of interest (get rid of unwanted predictors)

conditionA_filter=contrast_name1;
condA_idx=~cellfun(@isempty, regexp(surf_ds.sa.Name2, conditionA_filter));

conditionB_filter=contrast_name2;
condB_idx=~cellfun(@isempty, regexp(surf_ds.sa.Name2, conditionB_filter));

surf_ds=cosmo_slice(surf_ds, condA_idx|condB_idx);

%% define targets

surf_ds.sa.targets=zeros(length(surf_ds.sa.chunks),1);
condA_idx=~cellfun(@isempty, regexp(surf_ds.sa.Name2, conditionA_filter));
surf_ds.sa.targets(condA_idx)=1;

condB_idx=~cellfun(@isempty, regexp(surf_ds.sa.Name2, conditionB_filter));
surf_ds.sa.targets(condB_idx)=2;


%% load group average surface mesh for LH
surface_mesh = ['G:\Analysis_OANT\meshdata\' sprintf('GroupAligned_foldedMesh_%s_20sub_grey.srf', hemisphere)];
[vertices, faces] = surfing_read(surface_mesh);



%% Run Threshold-Free Cluster Enhancement (TFCE)

% define neighborhood for each feature
cluster_nbrhood=cosmo_cluster_neighborhood(surf_ds,...
                                        'vertices',vertices,'faces',faces);

fprintf('Cluster neighborhood:\n');
cosmo_disp(cluster_nbrhood);

opt=struct();

opt.cluster_stat  = 'tfce';
opt.niter = 1000; %for publication-quality, use >=1000; 10000 is even better

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
ds_tfce.sa.labels = {sprintf('%s_>_%s_TFCE_%s',contrast_name1, contrast_name2, hemisphere)};

%% map to brainvoyager -- convert the CoSMo dataset 'zmap' into a .VMP object readable by BrainVoyager and Neuroelf
smp = cosmo_map2surface(ds_tfce, '-bv_smp');

%% Let's adjust the map legend
smp.Map.LowerThreshold = 1.96; %two-tail threshold; for one-tail, set to 1.645
%smp.Map.UpperThreshold = 4;

%% you can now keep working using Neuroelf or just save the vmp
corrected_smp_name = sprintf('%s_vs._%s_TFCE_%s_%dit.smp', contrast_name1, contrast_name2, hemisphere, opt.niter);
smp.SaveAS(corrected_smp_name);

