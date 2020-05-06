% In this function we'll specify our condition names and calculate the time
% intervals [estart; eend] when trials belonging to each condition appear.
% Then this function will call bv_prt_write.m, which will print the actual
% protocol for a run in the text file *.prt and put it in the "log" folder.


function [prt] = bv_LOG2PRT_OANT(subject, runNum, sesNum)
%Jens Schwarzbach 11/2004
%last change: Angelika Lingnau 2010-09-27
%Adapted for OANT: KD 2016-03-14

%example call: 
%[prt] = bv_LOG2PRT_OANT(1, 1, 1)

Cfg.skipNVol = 3;
Cfg.TR = 2.2;
Cfg.durSec = 2; % duration of stimulus presentation
prt.NrOfConditions = 10;
%----------------------------------------------------------------

cmap = [255 215 0;
        250 128 114;
        152 251 152;
        135 206 235;
        147 112 219;
        255 140 0;
        255 0 0;
        50 205 50;
        0 0 255;
        128 0 128];

newPathToLog = sprintf('G:\\Analysis_OANT\\log\\SUB%02d_RUN%02d_S%02d_OANT', subject, runNum, sesNum);
load(newPathToLog); % load .mat file with ExpInfo for the current run

nTrials = length(ExpInfo.TrialInfo); % in each run  nTrials = 33;


codeVec = 1:prt.NrOfConditions;


%-------------------------------------------------------
prt.Experiment=sprintf('OANT');
prt.name=sprintf('G:\\Analysis_OANT\\log\\SUB%02d_RUN%02d_S%02d_OANT.prt', subject, runNum, sesNum); %we'll store our protocols in the same folder as .mat files
cond_names=     {'S1_NU'; 'S1_NT'; 'S1_VU'; 'S1_VT'; 'S1_Sq'; ...   
                 'S2_NU'; 'S2_NT'; 'S2_VU'; 'S2_VT'; 'S2_Sq'};


%First, let's find the Vertical Blank timestamp (VBLTimestamp) that gives
%us the absolute time according to the computer clock when the flip to page
%2 (picture) occured: ExpInfo.TrialInfo(j).timing(2,2). Now we just need to
%subtract from it the absolute time according to the computer clock when
%the experiment began: ExpInfo.Cfg.experimentStart, and we'll get the time
%of the picture onset starting from the beginning of the experiment.
              
for j = 1 : nTrials
    if length(ExpInfo.TrialInfo(j).trial.pageNumber) > 1
       t(j) = ExpInfo.TrialInfo(j).timing(2,2) - ExpInfo.Cfg.experimentStart; % onset time
    else
       t(j) = ExpInfo.TrialInfo(j).timing(1,2) - ExpInfo.Cfg.experimentStart; % onset time
    end
    code(j) = [ExpInfo.TrialInfo(j).trial.code]; % condition code
end


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
    if isempty (dat{c}.tStart)% if the condition doesn't exist(FOR SESSION 1, ONLY CONDITIONS 1-4 OCCUR; FOR SESSION 2, ONLY CONDITIONS 5-8 OCCUR)
        prt.Condition{c}.ntpts = 0;
    else
        prt.Condition{c}.estart = round(dat{c}.tStart);
        prt.Condition{c}.eend = round(prt.Condition{c}.estart + (Cfg.durSec * 1000)); % eend in msec
        prt.Condition{c}.ntpts = length(prt.Condition{c}.estart);
    end
    prt.Condition{c}.color = cmap(c,:);
end

prt = bv_prt_write(prt) % call function 'bv_prt_write.m' that will print the protocol