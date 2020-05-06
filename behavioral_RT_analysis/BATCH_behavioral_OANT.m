%% Calculate RTs for each trial using the ASF function handle_audio_data.m
% Remember to add the "wav" folder to path.

for subject = 1:12
    for session = 1:2
        for run = 1:8
            for trial = 1:33
                calculateRTForTrial(subject, session, run, trial);
            end
        end
    end
end


%% Print the experimental lists with displayed RTs for each run
for subNum = 1:12
    for sesNum = 1:2
        for runNum = 1:8
            create_experimental_list_with_stim_type(subNum, runNum, sesNum)
        end
    end
end


%% Write a .dat table with mean RTs for a condition in a subject
% and display the number of outliers per condition
[totalOutlierPercentage, totalOutlierPercentage_NOUNS, ...
    totalOutlierPercentage_VERBS, totalOutlierPercentage_SQUIGGLES] ...
    = groupStats_OANT_outliers_nouns_and_verbs();


%% Write an Excel table with the number of outliers in different conditions
writeOutlierStats();


%% Manually export the tables with mean RTs and outlier numbers into SPSS
% for inferential analysis