%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     I. VOLUMETRIC DATA PROCESSING                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Create FMR projects with functional data for each run
for subNum = 1:23
    for sesNum = 1:2
    [dicomFolderVec, ~] = getDicomFolderVec(subNum,sesNum); % get number of runs in a session
        for runNum = 1:length(dicomFolderVec)
            createFunctionalProject(subNum, sesNum, runNum)
        end
    end
end


%% Preprocess FMRs
% by running JavaScript code "PreprocessingOANT.js" internally from BV
% interface. Running preprocessing from MATLAB invokes misidentification
% of slice order and messes up slice time correction, which
% results in the stripe artefact in the RFX GLM.


%% Manually create pseudo-AMRs
% and link them by running JavaScript code "LinkAMRs"
% (this routine is not scriptable in MATLAB)


%% Create VMR projects with anatomical data for each session
for subNum = 1:23
    for sesNum = 1:2
        createAnatomicalProject(subNum, sesNum)
    end
end


%% Manually process the VMRs
%(1) For S01 and S02:
% -ISO (isovoxelation, i.e. resampling to 1x1x1 mm)
% -IIHC (inhomogeneity correction)
%(2) Only for S01:
% -ACPC (transformation to AC-PC space)
% -TAL (transformation to Talairach space)
%(3) VMR-VMR coregistration (alignment of the two anatomical scans)


%% Manually do FMR-VMR coregistration


%% Create VTCs
for subNum = 1:23
    for sesNum = 1:2
        createVTC(subNum, sesNum)
    end
end


%% Copy files to folder "groupdata"
for subNum = 1:23
    for sesNum = 1:2
        moveToGroupdata(subNum, sesNum)
    end
end


%% Smooth VTCs
for subNum = 1:23
    for sesNum = 1:2
        smoothVTCs(subNum, sesNum)
    end
end


%% Recode the conditions in log files
session = 'pre';
for subNum = 1:23
    [dicomFolderVec, ~] = getDicomFolderVec(subNum, 1);
    for run = 1:length(dicomFolderVec)
        recode_conditions_OANT(subNum, run, session)
    end
end
    
session = 'post';
for subNum = 1:23
    [dicomFolderVec, ~] = getDicomFolderVec(subNum, 2);
    for run = 1:length(dicomFolderVec)
        recode_conditions_OANT(subNum, run, session)
    end
end


%% Create PRTs
for subNum = 1:23
    for sesNum = 1:2
    [dicomFolderVec, ~] = getDicomFolderVec(subNum,sesNum);
        for run = 1:length(dicomFolderVec)
            bv_LOG2PRT_OANT(subNum, run, sesNum)
        end
    end
end


%% Create SDMs
for subNum = 1:23
    for sesNum = 1:2
        createDesignMatrix_BVQX(subNum, sesNum)
    end
end

% close all; % close all figures


%% QA: Evaluate motion parameters within a run
for subNum = 1:23
    for sesNum = 1:2
        evaluate3DMC_difRuns(subNum, sesNum);
        % figure
        figure('units','normalized','position',[0 0 1 1])
    end
end

% close all; % close all figures







%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      II. SURFICIAL DATA PROCESSING                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now let's move the analysis to the brain surface.

%% Create the folder 'meshdata'
mkdir('../meshdata/'); % we will store hemispheric meshes and related data in this folder


%% Move ISO_IIHC_TAL.VMRs (for S01) to 'meshdata'
for subNum = [1:14, 16:17, 19:22] % don't move subjects 15 and 18 (wobblers), as well as 23 (cheater)
    moveTalToMeshdata(subNum)
end


%% Move ISO_IIHC_TAL.VMRs for S02 to 'meshdata' for subjects
% for whom segmentation of S01 failed
for subNum = [7, 9, 14, 17, 21]
    moveTalToMeshdata_S02(subNum)
end


%% Obtain curvature map for each subject
for subNum = [1:14, 16:17, 19:22]
    obtainCurvature(subNum, 'RH')
    obtainCurvature(subNum, 'LH')
end


%% Prepare .gal, .sal and .cal files for group CBA
write_gal('LH')
write_gal('RH')

write_sal('LH')
write_sal('RH')

write_cal('LH')
write_cal('RH')


%% Run Cortex-Based Alignment manually (a step-by-step CBA tutorial is
% provided in the BrainVoyager User's Guide:
% https://www.brainvoyager.com/bvqx/doc/UsersGuide/CortexBasedAlignment/CortexBasedAlignmentOfSulciAndGyri.html)



%% %%%%%%%%%%%%%%%%%%%% STATISTICAL ANALYSIS STEPS: %%%%%%%%%%%%%%%%%%%%%%
% (1) Run FFX GLMs for individual non-CBA transformed hemispheres.       %
% (2) Obtain SMP maps with main effects and simple contrasts.            %                                          %
% (3) Perform CBA of individual multi-SMPs (align them to a group mesh). %                                       %
% (4) Submit _ALIGNED.smp files to the permutation analysis with TFCE    %
% correction for multiple comparisons.                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Create an "identity SSM" for LH and RH of each subject
for subNum = [1:14, 16:17, 19:22]
    identity_SSM(subNum, 'LH')
    identity_SSM(subNum, 'RH')
end

%% Write an MDM for FFX GLM on each hemisphere (with flag "z transform")
for subNum = [1:14, 16:17, 19:22]
    write_surface_FFX_mdm_for_subject_NonAligned(subNum, 'LH')
    write_surface_FFX_mdm_for_subject_NonAligned(subNum, 'RH')
end
% Manually move the .mdm-s from the folder with scripts to "meshdata".


%% Run FFX GLMs (with flag "correct for serial correlations")
for subNum = [1:14, 16:17, 19:22]
    run_surface_FFX_GLM_NonAligned(subNum, 'LH')
    run_surface_FFX_GLM_NonAligned(subNum, 'RH')
end


%% Create multi-SMPs with ten t-maps for main effects for each hemisphere
for subNum = [1:14, 16:17, 19:22]
    create_t_maps_main_effects(subNum, 'LH')
    create_t_maps_main_effects(subNum, 'RH')
end
% Manually CBA-transform the created multi-SMPs and save them as 
% SUBxx_tenMaps_LH_ALIGNED.smp.


%% Create multi-SMPs with six t-maps for simple contrasts for each hemisphere
for subNum = [1:14, 16:17, 19:22]
    create_t_maps_simple_contrasts(subNum, 'LH')
    create_t_maps_simple_contrasts(subNum, 'RH')
end
% Manually CBA-transform the created multi-SMPs and save them as 
% SUBxx_sixSimpleContrasts_LH_ALIGNED.smp.




%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%                 Run permutation analysis with TFCE                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%% Compute simple contrasts %%%%%%%%%%%%%%%%%%%%%%%%%
% Training effects (within-session comparison in S02)
TFCE_simple_contrast_varNumArg('LH', 'S2_NT', 'S2_NU')
TFCE_simple_contrast_varNumArg('RH', 'S2_NT', 'S2_NU')

TFCE_simple_contrast_varNumArg('LH', 'S2_VT', 'S2_VU')
TFCE_simple_contrast_varNumArg('RH', 'S2_VT', 'S2_VU')

% Task practice effects
TFCE_simple_contrast_varNumArg('LH', 'S2_NU', 'S1_NU')
TFCE_simple_contrast_varNumArg('RH', 'S2_NU', 'S1_NU')

TFCE_simple_contrast_varNumArg('LH', 'S2_VU', 'S1_VU')
TFCE_simple_contrast_varNumArg('RH', 'S2_VU', 'S1_VU')

% (No) difference between trained and untrained items prior to training
TFCE_simple_contrast_varNumArg('LH', 'S1_NT', 'S1_NU')
TFCE_simple_contrast_varNumArg('RH', 'S1_NT', 'S1_NU')

TFCE_simple_contrast_varNumArg('LH', 'S1_VT', 'S1_VU')
TFCE_simple_contrast_varNumArg('RH', 'S1_VT', 'S1_VU')

% Object naming network: S1_NU+S1_NT > S1_Sq
TFCE_simple_contrast_varNumArg('LH', 'S1_NU', 'S1_NT', 'S1_Sq')
TFCE_simple_contrast_varNumArg('RH', 'S1_NU', 'S1_NT', 'S1_Sq')

% Action naming network: S1_VU+S1_VT > S1_Sq
TFCE_simple_contrast_varNumArg('LH', 'S1_VU', 'S1_VT', 'S1_Sq')
TFCE_simple_contrast_varNumArg('RH', 'S1_VU', 'S1_VT', 'S1_Sq')

% Word class effects: S1_VU+S1_VT > S1_NU+S1_NT
TFCE_simple_contrast_varNumArg('LH', 'S1_VU', 'S1_VT', 'S1_NU', 'S1_NT')
TFCE_simple_contrast_varNumArg('RH', 'S1_VU', 'S1_VT', 'S1_NU', 'S1_NT')



%% %%%%%%%%%%%%%%%%%%%%% Compute compound contrasts %%%%%%%%%%%%%%%%%%%%%%%
% Noun training effects across sessions (with session effects "subtracted")
TFCE_complex_contrast('S2_NTvsS1_NT', 'S2_NUvsS1_NU', 'LH')
TFCE_complex_contrast('S2_NTvsS1_NT', 'S2_NUvsS1_NU', 'RH')

% Verb training effects across sessions (with session effects "subtracted")
TFCE_complex_contrast('S2_VTvsS1_VT', 'S2_VUvsS1_VU', 'LH')
TFCE_complex_contrast('S2_VTvsS1_VT', 'S2_VUvsS1_VU', 'RH')

% Comparison of within-session training effects in two word classes
% (verb vs. noun training)
TFCE_complex_contrast('S2_VTvsS2_VU', 'S2_NTvsS2_NU', 'LH')
TFCE_complex_contrast('S2_VTvsS2_VU', 'S2_NTvsS2_NU', 'RH')

% Comparison of across-session training effects in two word classes
% (verb vs. noun training)
TFCE_complex_contrast('S2_VTvsS1_VT', 'S2_NTvsS1_NT', 'LH')
TFCE_complex_contrast('S2_VTvsS1_VT', 'S2_NTvsS1_NT', 'RH')

% Comparison of session effects in two word classes 
% (single repetition of verbs vs. nouns)
TFCE_complex_contrast('S2_VUvsS1_VU', 'S2_NUvsS1_NU', 'LH')
TFCE_complex_contrast('S2_VUvsS1_VU', 'S2_NUvsS1_NU', 'RH')




%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%                          Print cluster tables                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Combine all TFCE-corrected SMPs for a hemisphere into a multi-map.
% Manually project this multi-SMP back into the volume (because the output
% of local maxima is implemented in Neuroelf only for VMPs): Load an SMP
% (Ctrl+M) -> "Advanced" tab -> "Create VMPs from all SMPs" (sample from -1
% mm to 2 mm).

%% Create cluster tables with the coordinates of centers-of-gravity (COG)
% of active clusters and local maxima for all maps of interest
% (COG is the optimal statistic for spatially smooth maps)
for mapNum = 1:14
    cluster_table_volume_local_maxima(mapNum, 'talcog', 'LH')
    cluster_table_volume_local_maxima(mapNum, 'talcog', 'RH')
end

%% Double check the anatomical labeling by projecting the VOIs created
% around local maxima onto the group hemispheric surface and overlapping
% them with the CBA-transformed macroanatomical atlas supplied with BV.
