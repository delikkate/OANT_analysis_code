% In this function we'll specify our condition names and calculate the time
% intervals [estart; eend] when trials belonging to each condition appear.
% Then this function will call bv_prt_write.m, which will print the actual
% protocol for a run in the text file *.prt and put it in the "log" folder.


function [prt] = bv_LOG2PRT_OANT_S02(subject, runNum, sesNum)
%Jens Schwarzbach 11/2004
%last change: Angelika Lingnau 2010-09-27
%UPD for OANT project by KD 2018-01-25
%example call: 
%[prt] = bv_LOG2PRT_OANT_S02(1, 1, 1)

Cfg.skipNVol = 3;
Cfg.TR = 2.2;
Cfg.durSec = 2; % stimulus duration
prt.NrOfConditions = 5;


cmap = [255 215 0;
        250 128 114;
        152 251 152;
        135 206 235;
        147 112 219];


newPathToLog = [pwd sprintf('\\log_S02\\SUB%02d_RUN%02d_S%02d_OANT.mat', subject, runNum, sesNum)];
load(newPathToLog);

nTrials = length(ExpInfo.TrialInfo);

codeVec = 1:prt.NrOfConditions;



prt.Experiment=sprintf('OANT');
prt.name=[pwd sprintf('\\log_S02\\SUB%02d_RUN%02d_S%02d_OANT.prt', subject, runNum, sesNum)];
cond_names=     {'S2_NU'; 'S2_NT'; 'S2_VU'; 'S2_VT'; 'S2_Sq'};


%First, let's find the Vertical Blank timestamp (VBLTimestamp) that gives
%us the absolute time according to the computer clock when the flip to page
%2 (picture) occured: ExpInfo.TrialInfo(j).timing(2,2). Now we just need to
%subtract from it the absolute time according to the computer clock when
%the experiment began: ExpInfo.Cfg.experimentStart, and we'll get the time
%of the picture onset starting from the beginning of the experiment.

              
for j = 1 : nTrials
    if length(ExpInfo.TrialInfo(j).trial.pageNumber) > 1 % if it's not a blank trial
       t(j) = ExpInfo.TrialInfo(j).timing(2,2) - ExpInfo.Cfg.experimentStart;   % onset time
    else % if it's a blank trial (containing only one page)
       t(j) = ExpInfo.TrialInfo(j).timing(1,2) - ExpInfo.Cfg.experimentStart; % onset time
    end
    code(j) = [ExpInfo.TrialInfo(j).trial.code]; % condition code
end


%loop through conditions
for i = 1 : length(codeVec)
    if isempty(find(code==codeVec(i)));
        dat{i}.tStart = [];
    else
        dat{i}.tStart = (t(find(code==codeVec(i))) - (Cfg.skipNVol * Cfg.TR)) * 1000;
    end
end


for i=1:prt.NrOfConditions
    prt.Condition{i}.name=char(cond_names(i));
end

for c = 1:length(codeVec)
    %TIME LOCKED WITH ONSET OF COLORED FIXATION CROSS
    if isempty (dat{c}.tStart)
        prt.Condition{c}.ntpts = 0;
    else
        prt.Condition{c}.estart = round(dat{c}.tStart);
        prt.Condition{c}.eend = round(prt.Condition{c}.estart + (Cfg.durSec * 1000));
        prt.Condition{c}.ntpts = length(prt.Condition{c}.estart);
    end
    prt.Condition{c}.color = cmap(c,:);
end

prt = bv_prt_write(prt) % call the function that will print the protocol