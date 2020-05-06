function [M, S, outlierNumber, outlierNumber_NOUNS, outlierNumber_VERBS, outlierNumber_SQUIGGLES] = calcDescriptiveSubject_OANT_outliers_nouns_and_verbs(subNum)
% Adapted from the function in ASFdemos folder: 30-11-2016 KD
% The function calculates descriptive statistics for a single subject.
%
% Updated 14-06-2017 by KD: Added outlier removal (two SDs from the mean RT
% for a subject).

% Updated 13-05-2018 by KD: We now also report the number and percentage of
% outliers for nouns and verbs separately.

% Returns a row vector M(1,10) with mean RTs and vector S(1,10) with
% standard deviations for each of the ten conditions.

% Later at a group level we will concatenate these row vectors for all
% subjects into one table using the function
% groupStats_OANT_outliers_nouns_and_verbs.m.


% Example call:
% [M, S, outlierNumber, outlierNumber_NOUNS, outlierNumber_VERBS, outlierNumber_SQUIGGLES] = calcDescriptiveSubject_OANT_outliers_nouns_and_verbs(1)

fprintf(1, 'PROCESSING SUB%02d ...\n', subNum);

logConcat = [];
for session = 1:2
    for run = 1:8
        pathToLog = ['..\' sprintf('new_logs_withIndividualThresholds\\SUB%02d_RUN%02d_S%02d_OANT.mat', subNum, run, session)];
        load(pathToLog);
        
        logRun = ASF_readExpInfo(ExpInfo);%provides you with a matrix log which contains trial by trial (rows) information needed for data analysis (columns)
        %Log contains:  COL1: CODE, COL2: RT, COL3: CORRECT RESPONSE, COL4: ACTUAL RESPONSE, COL5: EVALUATION 
    
    % Let's store the log tables from all 16 runs of a subject in one matrix
    logConcat = [logConcat; logRun];
    end
end

logConcat = logConcat(:,1:2); % let's get rid of extra columns - we are only interested in condition codes and RTs


%% UPD 14-06-2017: Removing outliers

% 1) If the condition code is 0 ("empty" trial at the beginning of the
% mini-block), change the RT to NaN (instead of 150 ms).
indices_cond0 = logConcat(:,1)==0; % find in which rows we find empty trials (with condition code 0)
logConcat(indices_cond0,2) = NaN;

% 2) Exclude the outliers (mean +- 2SD).
sd_value = nanstd(logConcat(:,2));
mean_value = nanmean(logConcat(:,2));
% Identify, calculate and remove upper outliers (more than two standard
% deviations ABOVE the mean)
upperOutlierIndex = find(logConcat(:,2) > mean_value + 2*sd_value);
upperOutlierNumber = length(upperOutlierIndex); % calculate the number of upper outliers for a subject


%% UPD 13-05-2018 by KD: calculate the number of upper NOUN, VERB and SQUIGGLE outliers separately
upperOutlierIndex_NOUNS = find((logConcat(:,2) > mean_value + 2*sd_value) & (logConcat(:,1) == 1 | logConcat(:,1) ==  2 | logConcat(:,1) == 6 | logConcat(:,1) == 7));
upperOutlierNumber_NOUNS = length(upperOutlierIndex_NOUNS);
upperOutlierIndex_VERBS = find((logConcat(:,2) > mean_value + 2*sd_value) & (logConcat(:,1) == 3 | logConcat(:,1) ==  4 | logConcat(:,1) == 8 | logConcat(:,1) == 9));
upperOutlierNumber_VERBS = length(upperOutlierIndex_VERBS);
upperOutlierIndex_SQUIGGLES = find((logConcat(:,2) > mean_value + 2*sd_value) & (logConcat(:,1) == 5 | logConcat(:,1) ==  10));
upperOutlierNumber_SQUIGGLES = length(upperOutlierIndex_SQUIGGLES);
%%
logConcat(upperOutlierIndex,2) = NaN;

% Identify, calculate and remove bottom outliers (more than two standard
% deviations BELOW the mean)
bottomOutlierIndex = find(logConcat(:,2) < mean_value - 2*sd_value);
bottomOutlierNumber = length(bottomOutlierIndex); % calculate the number of bottom outliers for a subject

%% UPD 13-05-2018 by KD: calculate the number of bottom NOUN, VERB and SQUIGGLE outliers separately
bottomOutlierIndex_NOUNS = find((logConcat(:,2) < mean_value - 2*sd_value) & (logConcat(:,1) == 1 | logConcat(:,1) ==  2 | logConcat(:,1) == 6 | logConcat(:,1) == 7));
bottomOutlierNumber_NOUNS = length(bottomOutlierIndex_NOUNS);
bottomOutlierIndex_VERBS = find((logConcat(:,2) < mean_value - 2*sd_value) & (logConcat(:,1) == 3 | logConcat(:,1) ==  4 | logConcat(:,1) == 8 | logConcat(:,1) == 9));
bottomOutlierNumber_VERBS = length(bottomOutlierIndex_VERBS);
bottomOutlierIndex_SQUIGGLES = find((logConcat(:,2) < mean_value - 2*sd_value) & (logConcat(:,1) == 5 | logConcat(:,1) ==  10));
bottomOutlierNumber_SQUIGGLES = length(bottomOutlierIndex_SQUIGGLES);
%%
logConcat(bottomOutlierIndex,2) = NaN;

% Calculate the overall number of outliers per subject
outlierNumber = upperOutlierNumber + bottomOutlierNumber; % make 'outlierNumber' a third output variable

%% UPD 13-05-2018 by KD: calculate the total number of NOUN, VERB and SQUIGGLE outliers separately and use them as output variables
outlierNumber_NOUNS = upperOutlierNumber_NOUNS + bottomOutlierNumber_NOUNS; % make 'outlierNumber_NOUNS' a fourth output variable
outlierNumber_VERBS = upperOutlierNumber_VERBS + bottomOutlierNumber_VERBS; % make 'outlierNumber_VERBS' a fifth output variable
outlierNumber_SQUIGGLES = upperOutlierNumber_SQUIGGLES + bottomOutlierNumber_SQUIGGLES; % make 'outlierNumber_SQUIGGLES' a sixth output variable
%%


nConditions = 10; % we have ten experimental conditions
% (we'll ignore trials with code 0 - they represent blanks at the beginning/end of the trial)
%S1_NU == 1, S1_NT == 2, S1_VU == 3, S1_VT == 4, S1_Sq == 5;
%S2_NU == 6, S2_NT == 7, S2_VU == 8, S2_VT == 9, S2_Sq == 10.

M = [];
S = [];
for iCond = 1:nConditions
    cases = logConcat(:,1) == iCond;
    RTs = logConcat(cases,2);
    
    M(1,iCond) = nanmean(RTs); % mean RT for a condition
    S(1,iCond) = nanstd(RTs); % SD for a condition
end



%% Send message to command window upon completion
fprintf(1, 'DONE\n');
