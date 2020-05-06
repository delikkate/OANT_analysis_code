% Let's run the whole-brain classification searchlight analysis on the data
% from S01 to localize the effects of word class (irrespective of training)


%% Recode conditions for S01 in the original .mat files
% (essentially we just need to add code 5 for squiggles):
% 1 = S1_NU, 2 = S1_NT, 3 = S1_VU, 4 = S1_VT, 5 = S1_Sq

session = 'pre';
for subNum = 1:23
    if subNum == 13, nRuns = 4; else nRuns = 8; end % SUB13 had only 4 runs in this session
    for runNum = 1:nRuns
        recode_conditions_OANT_S01(subNum, runNum, session)
    end
end


%% Recreate PRTs using the new log files

for subNum = 1:23
    for sesNum = 1
        if subNum == 13, nRuns = 4; else nRuns = 8; end
        for run = 1:nRuns
            bv_LOG2PRT_OANT_S01(subNum, run, sesNum)
        end
    end
end


%% Recreate SDMs using the new PRTs

for subNum = 1:23
    for sesNum = 1
        createDesignMatrix_BVQX_S01(subNum, sesNum)
    end
end
% close all;


%% Run single-study GLMs for each run
% GLMs are created on the individual subject surface. In order to run GLMs
% on the group-averaged mesh, apply the SSM transformation to them first,
% using the NeuroElf function newmtc = mtc.ApplySSM(ssm).

for subNum = [1:14, 16:17, 19:22]
    for sesNum = 1
        if subNum == 13, nRuns = 4; else nRuns = 8; end
        for run = 1:nRuns
            run_surface_singleStudyGLM_for_run_S01(subNum, run, sesNum, 'LH')
            run_surface_singleStudyGLM_for_run_S01(subNum, run, sesNum, 'RH')
        end
    end
end

%% Move the .glm files for each hemisphere to the meshdata subfolder "single-run_GLMs_S01_nonAligned_forMVPA_xH"

mkdir('G:\Analysis_OANT\meshdata\single-run_GLMs_S01_nonAligned_forMVPA_LH');
mkdir('G:\Analysis_OANT\meshdata\single-run_GLMs_S01_nonAligned_forMVPA_RH');
for subNum = [1:14, 16:17, 19:22]
    for sesNum = 1
        for hemisphere = {'LH', 'RH'}
            destination = ['G:\Analysis_OANT\meshdata\' sprintf('single-run_GLMs_S01_nonAligned_forMVPA_%s', char(hemisphere))];
            if subNum == 13, nRuns = 4; else nRuns = 8; end
            for run = 1:nRuns
                source = ['G:\Analysis_OANT\meshdata\' sprintf('single_run_GLM_SUB%02d_RUN%02d_S%02d_sm0mm_%s_NonAligned.glm', subNum, run, sesNum, char(hemisphere))];
                movefile(source, destination);
            end
        end
    end
end


%% Extract four t-maps for main effects from the created GLMs
% and combine them into one multi-SMP

for subNum = [1:14, 16:17, 19:22]
    if subNum == 13, nRuns = 4; else nRuns = 8; end
    for runNum = 1:nRuns
        create_t_maps_per_run_S01(subNum, runNum, 'LH')
        create_t_maps_per_run_S01(subNum, runNum, 'RH')
    end
end
% Let's manually move all SMPs to the subfolder "t_maps_per_run_xH".


%% Now we're ready to run MVPA and obtain prediction accuracy maps
% for individual hemispheres.

for subNum = [1:14, 16:17, 19:22]
    surface_searchlight_lda_OANT_verbs_vs_nouns_S01(subNum, 'LH')
    surface_searchlight_lda_OANT_verbs_vs_nouns_S01(subNum, 'RH')
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

TFCE_accuracy('verbs_vs_nouns_S01', 'LH', 1000);
TFCE_accuracy('verbs_vs_nouns_S01', 'RH', 1000);
% Maually move the created maps to "group_decoding_maps/TFCE_z_maps"

%% Create mean accuracy and uncorrected t-maps for the group

create_accuracy_and_t_map_for_group('verbs_vs_nouns_S01', 'LH');
create_accuracy_and_t_map_for_group('verbs_vs_nouns_S01', 'RH');



%% Manually project the TFCE-corrected SMP back into the volume
% (because the output of local maxima is implemented in Neuroelf only for
% VMPs): Load an SMP (Ctrl+M) -> "Advanced" tab -> "Create VMPs from all
% SMPs" (sample from -1 mm to 2 mm).

%% Create a cluster table for each hemisphere with centers-of-gravity of clusters and local maxima

mapName = 'verbs_vs_nouns_S01';
cluster_table_volume_local_maxima_MVPA(mapName, 'talcog', 'LH')
cluster_table_volume_local_maxima_MVPA(mapName, 'talcog', 'RH')

%% Double check the anatomical labeling by projecting the VOIs created
% around local maxima onto the group hemispheric surface and overlapping
% them with the CBA-transformed macroanatomical atlas supplied with BV.
