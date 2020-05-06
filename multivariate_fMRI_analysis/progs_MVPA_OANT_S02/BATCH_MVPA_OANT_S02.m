% Let's run the whole-brain classification searchlight analysis on the data
% from S02 to see the effects of training (across word classes, i.e. common
% for nouns and verbs).


%% Recode conditions for S02 in the original .mat files
% (essentially we just need to add code 5 for squiggles):
% 1 = S2_NU, 2 = S2_NT, 3 = S2_VU, 4 = S2_VT, 5 = S2_Sq

session = 'post';
for subNum = 1:23
    for runNum = 1:8
        recode_conditions_OANT_S02(subNum, runNum, session)
    end
end


%% Recreate PRTs using the new log files

for subNum = 1:23
    for sesNum = 2
        for run = 1:8
            bv_LOG2PRT_OANT_S02(subNum, run, sesNum)
        end
    end
end


%% Recreate SDMs using the new PRTs

for subNum = 1:23
    for sesNum = 2
        createDesignMatrix_BVQX_S02(subNum, sesNum)
    end
end
% close all;


%% Run single-study GLMs for each run
% GLMs are created on the individual subject surface. In order to run GLMs
% on the group-averaged mesh, apply the SSM transformation to them first,
% using the NeuroElf function newmtc = mtc.ApplySSM(ssm).

for subNum = [1:14, 16:17, 19:22]
    for sesNum = 2
        for run = 1:8
            run_surface_singleStudyGLM_for_run_S02(subNum, run, sesNum, 'LH')
            run_surface_singleStudyGLM_for_run_S02(subNum, run, sesNum, 'RH')
        end
    end
end


%% Move the .glm files for each hemisphere to the meshdata subfolder "single-run_GLMs_S01_nonAligned_forMVPA_xH"

mkdir('G:\Analysis_OANT\meshdata\single-run_GLMs_S02_nonAligned_forMVPA_LH');
mkdir('G:\Analysis_OANT\meshdata\single-run_GLMs_S02_nonAligned_forMVPA_RH');
for subNum = [1:14, 16:17, 19:22]
    for sesNum = 1
        for hemisphere = {'LH', 'RH'}
            destination = ['G:\Analysis_OANT\meshdata\' sprintf('single-run_GLMs_S02_nonAligned_forMVPA_%s', char(hemisphere))];
            if subNum == 13, nRuns = 4; else nRuns = 8; end
            for run = 1:nRuns
                source = ['G:\Analysis_OANT\meshdata\' sprintf('single_run_GLM_SUB%02d_RUN%02d_S%02d_sm0mm_%s_NonAligned.glm', subNum, run, sesNum, char(hemisphere))];
                movefile(source, destination);
            end
        end
    end
end


%% Extract t-maps for main effects from the created GLMs

for subNum = [1:14, 16:17, 19:22]
    for runNum = 1:8
        create_t_maps_per_run_S02(subNum, runNum, 'LH')
        create_t_maps_per_run_S02(subNum, runNum, 'RH')
    end
end
% Let's manually move all SMPs to the subfolder "t_maps_per_run_xH".


%% Now we're ready to run MVPA and obtain prediction accuracy maps
% for individual hemispheres.

% Decode trained vs. untrained items (regardless of word class)
for subNum = [1:14, 16:17, 19:22]
    surface_searchlight_lda_OANT_training_effects(subNum, 'LH')
    surface_searchlight_lda_OANT_training_effects(subNum, 'RH')
end

% Decode trained vs. untrained items in each word class separately
for subNum = [1:14, 16:17, 19:22]
    surface_searchlight_lda_OANT_trained_vs_untrained_verbs(subNum, 'LH')
    surface_searchlight_lda_OANT_trained_vs_untrained_verbs(subNum, 'RH')
end
for subNum = [1:14, 16:17, 19:22]
    surface_searchlight_lda_OANT_trained_vs_untrained_nouns(subNum, 'LH')
    surface_searchlight_lda_OANT_trained_vs_untrained_nouns(subNum, 'RH')
end

% Manually move the maps to the subfolder "searchlight_xH".


%% Manually CBA-align the individual accuracy maps
% Load the group-averaged mesh (it doesn't really matter which mesh to
% load) and open an SMP -> Ctrl+M -> “Advanced” tab -> Options… -> 
% Load a previously created .S2S stored in "meshdata" by pressing "..." 
% -> Align Maps -> check if SUBXX_tenMaps_LH_ALIGNED.smp is created in the 
% subfolder with unaligned maps (you can also see the file name in the 
% title of the Surface Maps dialog).


%% At the group level, run the permutation analysis with TFCE

% Decoding of training effects (data collapsed across word classes)
TFCE_accuracy('training_effects', 'LH', 1000)
TFCE_accuracy('training_effects', 'RH', 1000)

% Decoding of training effects separately for nouns (empty maps)
TFCE_accuracy('trained_vs_untrained_nouns', 'LH', 1000)
TFCE_accuracy('trained_vs_untrained_nouns', 'RH', 1000)

% Decoding of training effects separately for verbs (empty maps)
TFCE_accuracy('trained_vs_untrained_verbs', 'LH', 1000)
TFCE_accuracy('trained_vs_untrained_verbs', 'RH', 1000)

% Maually move the created maps to "group_decoding_maps/TFCE_z_maps"


%% Create mean accuracy and uncorrected t-maps for the group

create_accuracy_and_t_map_for_group('training_effects', 'LH');
create_accuracy_and_t_map_for_group('training_effects', 'RH');



%% Manually project the TFCE-corrected SMP back into the volume
% (because the output of local maxima is implemented in Neuroelf only for
% VMPs): Load an SMP (Ctrl+M) -> "Advanced" tab -> "Create VMPs from all
% SMPs" (sample from -1 mm to 2 mm).

%% Create a cluster table for each hemisphere with centers-of-gravity of clusters and local maxima

mapName = 'training_effects';
cluster_table_volume_local_maxima_MVPA(mapName, 'talcog', 'LH')
cluster_table_volume_local_maxima_MVPA(mapName, 'talcog', 'RH')

%% Double check the anatomical labeling by projecting the VOIs created
% around local maxima onto the group hemispheric surface and overlapping
% them with the CBA-transformed macroanatomical atlas supplied with BV.
