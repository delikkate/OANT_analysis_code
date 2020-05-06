function writeOutlierStats()

% This function creates a table with information about the number of
% outliers for each subject, separately for nouns, verbs and scrambles.

% Created by KD 12-11-2019

OutlierTable = {'SubNum', 'Noun_outliers', 'Verb_outliers', 'Scramble_outliers', 'Total_outliers'};

nSubjects = 12;
for iSubject = 1:nSubjects
    [~, ~, outlierNumber, outlierNumber_NOUNS, outlierNumber_VERBS, outlierNumber_SQUIGGLES] = ...
        calcDescriptiveSubject_OANT_outliers_nouns_and_verbs(iSubject);
    
    OutlierTable{iSubject+1,1} = sprintf('SUB%02d', iSubject);
    OutlierTable{iSubject+1,2} = outlierNumber_NOUNS;
    OutlierTable{iSubject+1,3} = outlierNumber_VERBS;
    OutlierTable{iSubject+1,4} = outlierNumber_SQUIGGLES;
    OutlierTable{iSubject+1,5} = outlierNumber;
end

xlsname = 'Outlier_Table.xls';
xlswrite(xlsname, OutlierTable);