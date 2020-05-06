% When we created .TRDs, we assigned all trials a code 1, 2, 3 or 4
% based on in what mini-block it appeared (0 for blanks).
% In them we can't tell squiggles (scrambled images) from normal pictures.

% Let's add the code for squiggles, so that:
% S2_NU == 1, S2_NT == 2, S2_VU == 3, S2_VT == 4, S2_Sq == 5.
%
% The function takes original .mat files from "log_old" and puts the new
% .mat files with the updated codes into "log_S02".


function recode_conditions_OANT_S02(subNum, runNum, session)

% UPD by KD: 15-12-2017
% example call: recode_conditions_OANT_S02(1, 1, 'pre')


subID = getID(subNum);

pathToLog = ['G:\\Analysis_OANT\\log_old\\OANT_' session sprintf('_%s-%03d.mat', subID, runNum)];
load(pathToLog);
    
 
%% First, let's recode our squiggles to 5; it's easy to do since we know that all even stimuli in the .STD file are scrambles


% Extract trial codes and put them into vector "ID"
for i = 1:ExpInfo.Cfg.nTrials
    ID(i) = ExpInfo.TrialInfo(i).trial.code;
end
        
% Extract numbers of picture stimuli (on page 2) in each trial and put them into vector "PicNum"
for i = 1:length(ID)
    if length(ExpInfo.TrialInfo(i).trial.pageNumber) > 1 % if this is an experimental trial (as opposed to blanks between the mini-blocks that only have one page)
        PicNum(i) = ExpInfo.TrialInfo(i).trial.pageNumber(2);   
    else
        PicNum(i) = 161; % if it is a blank, then its number is 161
    end
end

        
% If the picture number is even, it means it's a squiggle. Then change the condition code to 5.
for i = 1:length(ID)
    if (mod(PicNum(i),2) == 0)
        ID(i) = 5;
    end
end
              


%% Now let's put the updated codes that we store in "ID" into the field "code" of ExpInfo.
for i = 1:length(ID)
    ExpInfo.TrialInfo(i).trial.code = ID(i);
end



%% Now let's save the changed ExpInfo into a new .mat file and put it into the "log" folder.
% We'll rename the .mat file in a more convenient way (we'll use integers 1
% and 2 instead of string prefixes 'pre' and 'post').

if strcmp(session, 'pre') == 1
    sesNum = 1;
elseif strcmp(session, 'post') == 1
    sesNum = 2;
end


newPathToLog = [pwd sprintf('\\log_S02\\SUB%02d_RUN%02d_S%02d_OANT.mat', subNum, runNum, sesNum)];
save(newPathToLog, 'ExpInfo');


        
        
        