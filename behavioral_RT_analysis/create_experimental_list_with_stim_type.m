% This code will create an Excel file with the list of stimuli used in a
% given run along with automatically computed RTs for all trials.

%created by KD: 17-06-2016
%UPD by KD: 02-06-2017


function create_experimental_list_with_stim_type(subject, runNum, sesNum)

PathToLog = sprintf('G:\\behavioral_OANT\\new_logs_withIndividualThresholds\\SUB%02d_RUN%02d_S%02d_OANT', subject, runNum, sesNum);
load(PathToLog);


%% Here we will extract the stimulus names out of "ExpInfo.stimNames" and put them in "words"

% Create the "words" vector containing all picture names in the order in
% which they are stored in the .STD file
for i = 1:160 %go through all the stimuli in STD except for the last three (two crosses and a blank)
    path = ExpInfo.stimNames(i); %this will return us a cell storing a path string inside
    path = path{1,1}; %get the path string from the cell
    myHyphenIndex = strfind(path, '-'); %find the index of the hyphen in a string
    underscoreIndices = strfind(path, '_'); %find the indices of the underscores in a string (we're interested in the second one!)
    myUnderscoreIndex = underscoreIndices(2); %that's the one underscore we'll need to use

    words{1,i} = path(myHyphenIndex+1:myUnderscoreIndex-1); %the word we want to extract is a substring between the hyphen and the second underscore
end

% Now let's modify "words" by substituting all even elements of it with
% BERTOVA or SINTOTI, depending on the session
for i = 1:160
    if (mod(i,2) == 0)
        if strcmp(ExpInfo.Cfg.expID, 'OANT_pre') == 1
            words{1,i} = 'BERTOVA';
        elseif strcmp(ExpInfo.Cfg.expID, 'OANT_post') == 1
            words{1,i} = 'SINTOTI';
        end
    end
end


%% Now let's look at how our experimental list is structured - 
% put the list of page numbers as they were presented in a run in the
% vector "pageNum" (1x32 double)

for i = [2:8, 10:16, 18:24, 26:32]
    pageNum(i) = ExpInfo.TrialInfo(i).trial.pageNumber(2);
end


% For each element of "pageNum" extract a stimulus from the vector
% "words" that has the same number.
% Blanks will be shown as empty arrays [].
for i = [2:8, 10:16, 18:24, 26:32]
    stimulusList(i) = words(pageNum(i)); %put paths to stimuli in the 2nd column of the table
end

stimulusList = stimulusList';


%% Print an experimental list in an XLS file

% Put a header in the 1st cell - with subject, session, run name
stimulusList{1} = sprintf('SUB%02d_RUN%02d_S%02d_OANT.mat', subject, runNum, sesNum);


%% UPD: 07-09-2016 KD -- add a column with condition codes

for i = [2:8, 10:16, 18:24, 26:32]
    stimulusList{i,2} = ExpInfo.TrialInfo(i).trial.code; % put the trial codes in the 3rd column of the table
end

% Substitute numeric trial codes with more readable labels:
% "NU" (for codes 1 and 6), "NT" (codes 2 and 7), "VU" (codes 3 and 8),
% "VT" (codes 4 and 9) or "Sq" (codes 5 and 10).
for i = [2:8, 10:16, 18:24, 26:32]
    if stimulusList{i,2} == 1 || stimulusList{i,2} == 6
        stimulusList{i,2} = 'NU';
    elseif stimulusList{i,2} == 2 || stimulusList{i,2} == 7
        stimulusList{i,2} = 'NT'; 
    elseif stimulusList{i,2} == 3 || stimulusList{i,2} == 8
        stimulusList{i,2} = 'VU';
    elseif stimulusList{i,2} == 4 || stimulusList{i,2} == 9
        stimulusList{i,2} = 'VT';
    else
       stimulusList{i,2} = 'Sq';
    end
end
stimulusList{1,2} = 'Code'; % create a header for the 2nd column


%% UPD 06-10-2016 -- add a column with trial numbers

for i = [2:8, 10:16, 18:24, 26:32]
    stimulusList{i,3} = i; % put the trial number in the 1st column of the table
end
stimulusList{1,3} = 'Trial number'; % create a header for the 2nd column


%% UPD 29-11-2016 -- for behavioral experiment: add a column with RTs

for i = [2:8, 10:16, 18:24, 26:32]
    stimulusList{i,4} = ExpInfo.TrialInfo(i).Response.RT; % put the trial number in the 1st column of the table
end
stimulusList{1,4} = 'RT'; % create a header for the 2nd column


%% Print the resulting list in xls format and save it in the current folder

xlsname = sprintf('SUB%02d_S%02d_RUN%02d_OANT.xls', subject, sesNum, runNum);
xlswrite(xlsname, stimulusList);

