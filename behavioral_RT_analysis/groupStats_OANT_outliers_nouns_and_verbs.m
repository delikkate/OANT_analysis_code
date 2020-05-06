function [totalOutlierPercentage, totalOutlierPercentage_NOUNS, totalOutlierPercentage_VERBS, totalOutlierPercentage_SQUIGGLES] = groupStats_OANT_outliers_nouns_and_verbs()
% Adapted from the function in ASFdemos folder: 30-11-2016 KD
% The function calculates descriptive statistics for a group of subjects
% and writes a .dat table for further import to SPSS.

% Updated 14-06-2017 by KD: The overall number of outliers is now
% calculated and stored in the variable 'totalOutlierNumber'; the
% precentage of outliers is reported in the output variable
% 'totalOutlierPercentage'.

% Updated 13-05-2018 by KD: We now also report the number and percentage of
% outliers for nouns and verbs separately.


nSubjects = 12;


%% Create 12x10 matrices M and S containing mean RTs and SDs for each condition in each subject
totalOutlierNumber = 0; % set the counter
totalOutlierNumber_NOUNS = 0;
totalOutlierNumber_VERBS = 0;
totalOutlierNumber_SQUIGGLES = 0;

for iSubject = 1:nSubjects
    [M(iSubject, :), S(iSubject, :), outlierNumber(iSubject), ...
        outlierNumber_NOUNS(iSubject), outlierNumber_VERBS(iSubject), ...
        outlierNumber_SQUIGGLES(iSubject)] = ...
        calcDescriptiveSubject_OANT_outliers_nouns_and_verbs(iSubject);
    totalOutlierNumber = totalOutlierNumber + outlierNumber(iSubject); % calculate the total number of outliers in the group
    totalOutlierNumber_NOUNS = totalOutlierNumber_NOUNS + outlierNumber_NOUNS(iSubject);
    totalOutlierNumber_VERBS = totalOutlierNumber_VERBS + outlierNumber_VERBS(iSubject);
    totalOutlierNumber_SQUIGGLES = totalOutlierNumber_SQUIGGLES + outlierNumber_SQUIGGLES(iSubject);
end


%% Percentage of outliers:
totalNumberOfTrials = (528-80)*12; % (528 trials per subject in all 16 runs - 80 excluded "empty" trials)*12 subjects
totalOutlierPercentage = totalOutlierNumber/totalNumberOfTrials*100;


%% UPD 13-05-2018 by KD: calculate the total percentage of NOUN and VERB outliers separately and use them as output variables
totalNumberOfTrials_NOUNS = 160*12; % we have in total 10 nouns per run * 16 runs * 12 subjects
totalOutlierPercentage_NOUNS = totalOutlierNumber_NOUNS/totalNumberOfTrials_NOUNS*100;

totalNumberOfTrials_VERBS = 160*12; % we have in total 10 verbs per run * 16 runs * 12 subjects
totalOutlierPercentage_VERBS = totalOutlierNumber_VERBS/totalNumberOfTrials_VERBS*100;

totalNumberOfTrials_SQUIGGLES = 128*12; % we have in total 8 squiggles per run * 16 runs * 12 subjects
totalOutlierPercentage_SQUIGGLES = totalOutlierNumber_SQUIGGLES/totalNumberOfTrials_SQUIGGLES*100;


%% Export the table (matrix M) into an SPSS-readable .dat file
exportName = 'behavioral_OANT_outliersRemoved.dat';
fprintf(1, 'Writing data for SPSS to %s ...', exportName);
fid = fopen(exportName, 'w');

nConditions = size(M,2);


% NOW WRITE DATA IN THE SAME ORDER AS VARIABLE NAMES, ONE LINE PER SUBJECT
for iSubject = 1:nSubjects
    for iCondition = 1:nConditions
        fprintf(fid, '%9.2f ', M(iSubject, iCondition));
    end
    fprintf(fid, '\n');
end
fclose(fid);

fprintf(1, 'DONE.\n')

% Now the .dat file is ready to be exported to SPSS.
