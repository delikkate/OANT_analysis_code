function TFCE_simple_contrast_varNumArg(hemisphere, varargin)

% This function performs group permutation analysis with Threshold-Free
% Cluster Enhancement (TFCE). This function will run different contrasts,
% based on the number of inputs. Variable 'varargin' collects all input
% arguments into a cell array. After specification of the hemisphere, all
% maps participating in the contrast need to be listed in the correct
% order.

% varargin = 'S1_NU' | 'S1_NT' | 'S1_VU' | 'S1_VT' | 'S1_Sq'
% | 'S2_NU' | 'S2_NT' | 'S2_VU'| 'S2_VT'| 'S2_Sq'
% hemisphere = 'LH' | 'RH'

% Created by KD 29-06-2018

% Example uses:
% TFCE_simple_contrast_varNumArg('LH', 'S2_VT', 'S2_VU')
% TFCE_simple_contrast_varNumArg('LH', 'S1_NU', 'S1_NT', 'S1_Sq')
% TFCE_simple_contrast_varNumArg('RH', 'S1_VU', 'S1_VT', 'S1_NU', 'S1_NT')
% TFCE_simple_contrast_varNumArg('RH', 'S1_NU', 'S1_NT', 'S1_VU', 'S1_VT', 'S1_Sq')


%% initial setup

% indicate the number of subjects
subVec = [1:14, 16:17, 19:22];
nSub = length(subVec);

% indicate the path to searchlight maps
pathToSMP = [pwd sprintf('\\individualSMPs\\%s\\', hemisphere)];

%% load individual maps

% initiate a variable to keep all individual datasets
ds_sub=cell(1, nSub);

% set the counter
i = 0;

% loop over subjects
for iSub = subVec
    
    i = i + 1; % we need the counter to put subject datasets into sequential cells (without gaps between 14 and 16, 17 and 19)
    
    % define the name of the current individual SMP
    filename_smp=fullfile(pathToSMP, sprintf('SUB%02d_tenMaps_%s_ALIGNED.smp', iSub, hemisphere));
    
    % import the SMP in the cosmo format
    ds_sub{i}=cosmo_surface_dataset(filename_smp);
    
    % give human readable labels to conditions
    ds_sub{i}.sa.Name2{1,1} = 'S1_NU';
    ds_sub{i}.sa.Name2{2,1} = 'S1_NT';
    ds_sub{i}.sa.Name2{3,1} = 'S1_VU';
    ds_sub{i}.sa.Name2{4,1} = 'S1_VT';
    ds_sub{i}.sa.Name2{5,1} = 'S1_Sq';
    ds_sub{i}.sa.Name2{6,1} = 'S2_NU';
    ds_sub{i}.sa.Name2{7,1} = 'S2_NT';
    ds_sub{i}.sa.Name2{8,1} = 'S2_VU';
    ds_sub{i}.sa.Name2{9,1} = 'S2_VT';
    ds_sub{i}.sa.Name2{10,1} = 'S2_Sq';
    
    % set chunks: each chunk, or independent measurement, is our subject
    ds_sub{i}.sa.chunks=ones(size(ds_sub{i}.samples, 1),1)*i;
    
end
surf_ds=cosmo_stack(ds_sub);


%% just keep the conditions of interest (get rid of unwanted predictors)

for cond = 1:length(varargin)
    cond_filter = varargin(cond);
    cond_idx = ~cellfun(@isempty, regexp(surf_ds.sa.Name2, cond_filter));
    oneCond_surf_ds{cond} = cosmo_slice(surf_ds, cond_idx);
end

sliced_surf_ds = cosmo_stack(oneCond_surf_ds);


%% define targets
sliced_surf_ds.sa.targets=zeros(length(sliced_surf_ds.sa.chunks),1); % preallocate target vector

if length(varargin) == 2 % for the most simple contrasts (where we compare two conditions)
    condA_idx=~cellfun(@isempty, regexp(sliced_surf_ds.sa.Name2, varargin(1)));
    sliced_surf_ds.sa.targets(condA_idx)=1;

    condB_idx=~cellfun(@isempty, regexp(sliced_surf_ds.sa.Name2, varargin(2)));
    sliced_surf_ds.sa.targets(condB_idx)=2;

elseif length(varargin) == 3 % for object and action naming networks
% objects: S1_NU+S1_NT > S1_Sq
% actions: S1_VU+S1_VT > S1_Sq
    condA_idx=~cellfun(@isempty, regexp(sliced_surf_ds.sa.Name2, varargin(1))); % S1_NU | S1_VU
    sliced_surf_ds.sa.targets(condA_idx)=1;

    condB_idx=~cellfun(@isempty, regexp(sliced_surf_ds.sa.Name2, varargin(2))); % S1_NT | S1_VT
    sliced_surf_ds.sa.targets(condB_idx)=1; 
    
    condC_idx=~cellfun(@isempty, regexp(sliced_surf_ds.sa.Name2, varargin(3))); % S1_Sq
    sliced_surf_ds.sa.targets(condC_idx)=2;
    
elseif length(varargin) == 4 % for word class and training effects (across word classes)
% word class (VERBS vs. NOUNS): S1_VU+S1_VT > S1_NU+S1_NT
% training (TRAINED vs. UNTRAINED): S2_NT+S2_VT > S2_NU+S2_VU
    condA_idx=~cellfun(@isempty, regexp(sliced_surf_ds.sa.Name2, varargin(1)));
    sliced_surf_ds.sa.targets(condA_idx)=1;

    condB_idx=~cellfun(@isempty, regexp(sliced_surf_ds.sa.Name2, varargin(2)));
    sliced_surf_ds.sa.targets(condB_idx)=1;
    
	condC_idx=~cellfun(@isempty, regexp(sliced_surf_ds.sa.Name2, varargin(3)));
    sliced_surf_ds.sa.targets(condC_idx)=2;

    condD_idx=~cellfun(@isempty, regexp(sliced_surf_ds.sa.Name2, varargin(4)));
    sliced_surf_ds.sa.targets(condD_idx)=2; 
    
elseif length(varargin) == 5 % for picture naming network
% S1_NU+S1_NT+S1_VU+S1_VT > S1_Sq
    condA_idx=~cellfun(@isempty, regexp(sliced_surf_ds.sa.Name2, varargin(1)));
    sliced_surf_ds.sa.targets(condA_idx)=1;

    condB_idx=~cellfun(@isempty, regexp(sliced_surf_ds.sa.Name2, varargin(2)));
    sliced_surf_ds.sa.targets(condB_idx)=1;
    
	condC_idx=~cellfun(@isempty, regexp(sliced_surf_ds.sa.Name2, varargin(3)));
    sliced_surf_ds.sa.targets(condC_idx)=1;

    condD_idx=~cellfun(@isempty, regexp(sliced_surf_ds.sa.Name2, varargin(4)));
    sliced_surf_ds.sa.targets(condD_idx)=1;
    
    condE_idx=~cellfun(@isempty, regexp(sliced_surf_ds.sa.Name2, varargin(5)));
    sliced_surf_ds.sa.targets(condE_idx)=2;    
    
end

%% for each subject, average across trials
sliced_surf_ds=cosmo_fx(sliced_surf_ds, @(x)mean(x, 1), {'targets', 'chunks'});


%% load group average surface mesh for LH
surface_mesh = [pwd sprintf('\\GroupAligned_foldedMesh_%s_20sub_grey.srf', hemisphere)];
[vertices, faces] = surfing_read(surface_mesh);



%% Run Threshold-Free Cluster Enhancement (TFCE)

% define neighborhood for each feature
cluster_nbrhood=cosmo_cluster_neighborhood(sliced_surf_ds,...
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
ds_tfce = cosmo_montecarlo_cluster_stat(sliced_surf_ds,cluster_nbrhood,opt);

%% Show results

fprintf('TFCE z-score dataset\n');
cosmo_disp(ds_tfce);


% choose a name for your map
if length(varargin) == 2
    mapName = sprintf('%s_vs._%s_TFCE_%s', varargin{1}, varargin{2}, hemisphere);
elseif length(varargin) == 3
    if strcmp(varargin(1), 'S1_NU') == 1
        mapName = sprintf('Object_naming_TFCE_%s', hemisphere);
    elseif strcmp(varargin(1), 'S1_VU') == 1
        mapName = sprintf('Action_naming_TFCE_%s', hemisphere);
    end
elseif length(varargin) == 4
    if strcmp(varargin(1), 'S1_VU') == 1
        mapName = sprintf('VERBS_vs._NOUNS_S01_TFCE_%s', hemisphere);
    elseif strcmp(varargin(1), 'S2_NT') == 1
        mapName = sprintf('TRAINED_vs._UNTRAINED_S02_TFCE_%s', hemisphere);
    end
elseif length(varargin) == 5
    mapName = sprintf('Picture_naming_TFCE_%s', hemisphere);
end

ds_tfce.sa.labels = {mapName};

%% map to brainvoyager -- convert the CoSMo dataset 'zmap' into a .VMP object readable by BrainVoyager and Neuroelf
smp = cosmo_map2surface(ds_tfce, '-bv_smp');

%% Let's adjust the map legend
smp.Map.LowerThreshold = 1.96; %two-tail threshold; for one-tail, set to 1.645
%smp.Map.UpperThreshold = 4;

%% you can now keep working using Neuroelf or just save the vmp
corrected_smp_name = [mapName sprintf('_%dit.smp', opt.niter)];
smp.SaveAS(corrected_smp_name);

