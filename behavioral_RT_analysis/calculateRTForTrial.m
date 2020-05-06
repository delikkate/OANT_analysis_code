% This script computes the RTs using the modified ASF function
% handle_audio_data.m and stores them in ExpInfo. The VOT (voice onset
% threshold) is calibrated for each subject individually based on the
% inspection of the plots produced for each trial by handle_audio_data (the
% threshold is set on line 49 of handle_audio_data and ranges between 0.015
% and 0.1).

% created by KD: 19-06-2016
% Sample call: calculateRTForTrial(1, 1, 1, 23)

function calculateRTForTrial(subject, session, run, trial)

if session == 1
    filename = sprintf('G:\\behavioral_OANT\\wavs\\OANT_pre_SUB%02d-%03d_trial_%05d.wav', subject, run, trial);
elseif session == 2
    filename = sprintf('G:\\behavioral_OANT\\wavs\\OANT_post_SUB%02d-%03d_trial_%05d.wav', subject, run, trial);
end

[audioarray] = audioread(filename);



Cfg = [];
if ~isfield(Cfg, 'audio'), Cfg.audio = []; else end
        if ~isfield(Cfg.audio, 'f'), Cfg.audio.f = 44100; else end
        if ~isfield(Cfg.audio, 'nBits'),Cfg.audio.nBits = 16; else end
        if ~isfield(Cfg.audio, 'nChannels'), Cfg.audio.nChannels = 1; else end
        if ~isfield(Cfg.audio, 'outputPath'), Cfg.audio.outputPath = ''; else end        

% Cfg.plotVOT = 0; %don't plot each trial when doing batch processing, otherwise MATLAB will crash
Cfg.plotVOT = 1;
% figure %will put a plot for the next word in a new figure


RT = handle_audio_data(audioarray, Cfg.audio, 0, filename, Cfg.plotVOT)*1000;


%Load the copy of ExpInfo for the corresponding run and (re)write the RT
%for the trial in TrialInfo(trial).Response.RT
logfile = ['G:\behavioral_OANT\new_logs_withIndividualThresholds\' sprintf('SUB%02d_RUN%02d_S%02d_OANT.mat', subject, run, session)];

load(logfile);
ExpInfo.TrialInfo(trial).Response.RT = RT;

%Save 'ExpInfo' with an updated RT value for the corresponding trial.
%When opening this .mat file to recompute RT for the next trial,
%it will already have updated values for preceding trials.
save(logfile, 'ExpInfo');

