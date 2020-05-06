%When we created .TRDs, we assigned all trials a code 1, 2, 3 or 4
%based on in what mini-block they appeared: NU == 1, NT == 2, VU == 3,
% VT == 4 (blanks == 0). It causes two problems:
%
%(1) we can't tell squiggles (scrambled images) from real pictures;
%(2) we can't contrast the conditions in session 1 vs. session 2.
%
%Let's reassign the codes for our conditions this way:
% S1_NU == 1, S1_NT == 2, S1_VU == 3, S1_VT == 4, S1_Sq == 5;
% S2_NU == 6, S2_NT == 7, S2_VU == 8, S2_VT == 9, S2_Sq == 10.
%
% The function takes original .mat files from "log_old" and puts the new
% .mat files with updated codes into "log".



function recode_conditions_OANT(subNum, runNum, session)
%14-03-2016 KD
%example call: recode_conditions_OANT(1, 1, 'pre')

subID = getID(subNum);

pathToLog = ['G:\\Analysis_OANT\\log_old\\OANT_' session sprintf('_%s-%03d.mat', subID, runNum)];
load(pathToLog); %load ExpInfo for a run
    
 

%% First, let's recode squiggles to 5; it's easy to do since we know that all even stimuli in the .STD file are scrambles

% Extract trial codes and put them into vector "ID"
for i = 1:ExpInfo.Cfg.nTrials % for each of the 33 trials
    ID(i) = ExpInfo.TrialInfo(i).trial.code;
end
        
% Extract numbers of picture stimuli (on page 2) in each trial and put them into vector "PicNum"
for i = 1:length(ID) % for all 33 trials
    if length(ExpInfo.TrialInfo(i).trial.pageNumber) > 1 % if this is an experimental trial (as opposed to blanks between the mini-blocks that only have one page)
        PicNum(i) = ExpInfo.TrialInfo(i).trial.pageNumber(2);   
    else
        PicNum(i) = 161; % if it is a blank, then its number is 161
    end
end

        
% If the picture number is even, it means it's a squiggle.
for i = 1:length(ID)
    if (mod(PicNum(i),2) == 0)
        ID(i) = 5; % assign the new experimental code '5'
    end
end
              


%% In session 2 ('post') we will now change the codes for ALL experimental conditions in our vector "ID"

if strcmp(session, 'post') == 1
    for i = 1:length(ID)
        if ID(i) == 1
            ID(i) = 6; %S2_NU == 6
        elseif ID(i) == 2
            ID(i) = 7; %S2_NT == 7
        elseif ID(i) == 3
            ID(i) = 8; %S2_VU == 8
        elseif ID(i) == 4
            ID(i) = 9; %S2_VT == 9
        elseif ID(i) == 5;
            ID(i) = 10; %S2_Sq == 10
        end
    end
end



%% Now let's put the updated codes that we store in "ID" into the field "code" of ExpInfo.

for i = 1:length(ID)
    ExpInfo.TrialInfo(i).trial.code = ID(i);
end



%% Now let's save the changed ExpInfo into a new .mat file in the "log" folder.
% We'll rename the .mat file in a more convenient way (we'll use integers 1
% and 2 instead of string prefixes 'pre' and 'post').

if strcmp(session, 'pre') == 1
    sesNum = 1;
elseif strcmp(session, 'post') == 1
    sesNum = 2;
end


newPathToLog = [sprintf('G:\\Analysis_OANT\\log\\SUB%02d_RUN%02d_S%02d_OANT', subNum, runNum, sesNum)];
save(newPathToLog, 'ExpInfo');


        
        
        