% Let's run the whole-brain classification searchlight analysis on the
% data from S01 investigating the effects of word class (across training
% conditions, wich are irrelevant in session 1 anyway).

% This script requires the COSMoMVPA toolbox to be added to the path.

% targets:
% {S1_VU, S1_VT} = 1;
% {S1_NU, S1_NT} = 2.

% UPD by KD 26-01-2018

function surface_searchlight_lda_OANT_verbs_vs_nouns_S01(subNum, hemisphere)


%% initial setup

% indicate the path to subject meshes and t-maps
pathToSRF = 'G:\Analysis_OANT\meshdata\';
pathToSMP = sprintf('G:\\Analysis_OANT\\progs_MVPA_OANT_S01\\t_maps_per_run_%s', hemisphere);

subID = getID(subNum);
% define session used for anatomy segmentation
if subNum == 7 || subNum == 9 || subNum == 14 || subNum == 17 || subNum == 21
    session = 2; % for five subjects we segmented TAL.vmr for session 2
else
    session = 1;
end

% single mesh surface (WM/GM boundary)
surf_fn = [pathToSRF sprintf('SUB%02d_%s_S%02d_MPRAGE_ISO_IIHC_TAL_WM_%s_RECOSMx_D80k_SPH.srf', subNum, subID, session, hemisphere)];

% indicate the number of runs to be stacked
if subNum == 13, nRuns = 4; else nRuns = 8; end

%% load t-statistics (from .smp)

% initiate a variable to keep all individual datasets
ds_sub=cell(1, nRuns);

% loop over runs
for iRun=1:nRuns
    
    % define the name of the current individual SMP
    filename_smp=fullfile(pathToSMP, sprintf('SUB%02d_RUN%02d_fourMaps_%s_onlyS01.smp', subNum, iRun, hemisphere));
    
    % import the SMP in the cosmo format
    ds_sub{iRun}=cosmo_surface_dataset(filename_smp);
    
    % give human readable labels to conditions
    ds_sub{iRun}.sa.Name2{1,1} = 'S1_NU';
    ds_sub{iRun}.sa.Name2{2,1} = 'S1_NT';
    ds_sub{iRun}.sa.Name2{3,1} = 'S1_VU';
    ds_sub{iRun}.sa.Name2{4,1} = 'S1_VT';    
    
    % define chunks: each chunk, or independent measurement, is our run
    ds_sub{iRun}.sa.chunks=ones(size(ds_sub{iRun}.samples, 1),1)*iRun; % ds_sub{iSub}.sa.chunks = iSub
end
surf_ds=cosmo_stack(ds_sub);

%% define targets
surf_ds.sa.targets=zeros(length(surf_ds.sa.chunks),1); % preallocate target vector

conditionA_filter='S1_VU';
condA_idx=~cellfun(@isempty, regexp(surf_ds.sa.Name2, conditionA_filter)); % logical mask 
surf_ds.sa.targets(condA_idx)=1;

conditionB_filter='S1_VT';
condB_idx=~cellfun(@isempty, regexp(surf_ds.sa.Name2, conditionB_filter));
surf_ds.sa.targets(condB_idx)=1;

conditionC_filter='S1_NU';
condB_idx=~cellfun(@isempty, regexp(surf_ds.sa.Name2, conditionC_filter));
surf_ds.sa.targets(condB_idx)=2;

conditionD_filter='S1_NT';
condB_idx=~cellfun(@isempty, regexp(surf_ds.sa.Name2, conditionD_filter));
surf_ds.sa.targets(condB_idx)=2;

%% sanity check of the result
cosmo_check_dataset(surf_ds);
cosmo_disp(surf_ds);

%% define neighborhood for each feature
radius = 8;
single_surf_offsets = [-1 2]; % select voxels that are 1 mm or closer to the surface on the WM side, up to voxels that are 3 mm from the surface on the pial side
% niter = 10; % number of iterations to downsample the surface; 10 mesh decimation algorithms
surfs = {surf_fn, single_surf_offsets};
% surfs = {surf_fn, single_surf_offsets, niter};

[nbrhood, vo, fo] = cosmo_surficial_neighborhood(surf_ds, surfs,'radius', radius);
fprintf('Neighborhood has %d elements\n', numel(nbrhood.neighbors))
fprintf('Output surface has %d nodes and %d faces\n', size(vo,1), size(fo,1))

%% use the cosmo_cross_validation_measure and set its parameters
measure = @cosmo_crossvalidation_measure;
measure_args = struct();
measure_args.classifier = @cosmo_classify_lda;
measure_args.partitions = cosmo_nfold_partitioner(surf_ds);

%% run the searchlight
lda_results = cosmo_searchlight(surf_ds, nbrhood, measure, measure_args);

%% print searchlight output
fprintf('Dataset output:\n');
cosmo_disp(lda_results);
cosmo_check_dataset(lda_results)


%% choose a name for your map
lda_results.sa.labels={sprintf('Subject SUB%02d: verbs vs.nouns_S01', subNum)};

%% save the resulting accuracy map as an .smp
data_output_fn = sprintf('SUB%02d_verbs_vs_nouns_S01_accuracy_map_%s.smp', subNum, hemisphere);
cosmo_map2surface(lda_results, data_output_fn);



