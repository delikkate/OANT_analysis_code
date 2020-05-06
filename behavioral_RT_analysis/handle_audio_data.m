% This function is borrowed from the older version of the ASF toolbox.

function rt = handle_audio_data(audioarray, cfg_audio, startstim, wavname, plotVOT)
%    wavwrite(audioarray, audio.f, audio.nBits, wavname)
%    plot((1:length(audioarray))./audio.f, [audioarray, sqrt(audioarray.^2)])
%    legend({'data', 'demeaned', 'abs'})
t = (0:length(audioarray)-1)./cfg_audio.f;

audioarray_stimlocked = audioarray(t >= startstim);
t2 =    (0:length(audioarray_stimlocked)-1)./cfg_audio.f;

% "WAVWRITE has been removed. Use AUDIOWRITE instead." -- note that the order of
% arguments has been changed

% wavwrite(audioarray_stimlocked, cfg_audio.f, cfg_audio.nBits, wavname);
audiowrite(wavname, audioarray_stimlocked, cfg_audio.f, 'BitsPerSample', cfg_audio.nBits);
cfg.fnames = wavname;
rt = get_rts(cfg);

if plotVOT
    subplot(2, 1, 1)
    plot(t, audioarray)
    ylim = get(gca, 'ylim');
    hold on
    plot([startstim, startstim], ylim, 'r')
    hold off

    subplot(2, 1, 2)
    plot(t2, audioarray_stimlocked)

    hold on
    ylim = get(gca, 'ylim');
    plot([rt, rt], ylim, 'g')
    hold off
    set(gcf, 'name', sprintf('%s, RT = %f', wavname, rt))
    drawnow
end

function rt = get_rts(cfg)
%%function rt = get_rts(cfg)
%%EXAMPLE CALL:
%cfg.thresh = 0.2;
%cfg.fnames = '*.wav';
%cfg.verbose = 0;
%rt = get_rts(cfg)

% if(~isfield(cfg, 'thresh')), cfg.thresh = 0.2; end
% if(~isfield(cfg, 'thresh')), cfg.thresh = 0.1; end
% if(~isfield(cfg, 'thresh')), cfg.thresh = 0.05; end
% if(~isfield(cfg, 'thresh')), cfg.thresh = 0.03; end
if(~isfield(cfg, 'thresh')), cfg.thresh = 0.015; end
if(~isfield(cfg, 'fnames')), cfg.fnames = '*.wav'; end
if(~isfield(cfg, 'verbose')), cfg.verbose = 0; end
if(~isfield(cfg, 'ShowRTAnalysis')), cfg.ShowRTAnalysis = 0; end

%cfg.ShowRTAnalysis = 1;
d = dir(cfg.fnames);
nFiles = length(d);

if nFiles > 1
    h = waitbar(0,'Please wait...');
    rt(nFiles) = 0;
else
    h = [];
end
for i = 1:nFiles
    if ~isempty(h)
        waitbar(i/nFiles,h)
    end
    fname = d(i).name;
    %    [y, fs, nbits, opts] =   wavread(fname, [22050, 88000]);
%     [y, fs, nbits, opts] =   wavread(fname);
% "WAVREAD has been removed. Use AUDIOREAD instead."
    [y, fs] =   audioread(fname);

    
    t = (0:length(y)-1)/fs;
    
    %REMOVE BEGINNING PERIOD
    cases_to_remove = find(t < 0.15);
    y(cases_to_remove) = [];
    t(cases_to_remove) = [];
    
    if cfg.ShowRTAnalysis
        figure
        plot_wav(t, y)
        set(gcf, 'Name', 'Original Signal')
    end
    y = y - mean(y);
    y = y - min(y);
    y = y./max(y)*2-1;
    if cfg.ShowRTAnalysis
        figure
        plot_wav(t, y)
        set(gcf, 'Name', 'Normalized Signal')
    end

    ey = sqrt(y.^2);
    bl = mean(ey(1:max(find((t-t(1))<0.2))));




    cfg.FilterLengthInSamples = 100;
    b = ones(cfg.FilterLengthInSamples, 1)/cfg.FilterLengthInSamples;  % cfg.FilterLengthInSamples point averaging filter
    eyf = filtfilt(b, 1, ey); % Noncausal filtering; smoothes data without delay

    if cfg.ShowRTAnalysis
        figure
        plot_wav(t, ey);
        hold on
        plot(t, eyf, 'Color', 'r', 'LineWidth', 3);
        hold off
        set(gcf, 'Name', 'Power')
        ylabel('sqrt(y^2)')
        legend('Power', 'Smoothed Power')
        
    end

    current_thresh = cfg.thresh;
    %     first_sample = [];
    %     %LOOK FOR ONSET, IF NOTHING FOUND DECREASE THRESHOLD
    %     while isempty(first_sample)
    %         first_sample = min(find(eyf-bl >current_thresh));
    %         if isempty(first_sample)
    %             current_thresh = current_thresh*.9;
    %         end
    %
    %     end
    first_sample = min(find(eyf-bl >current_thresh));
    if isempty(first_sample)
        rt(i) = NaN;
    else
        rt(i) = t(first_sample);
    end

    if cfg.ShowRTAnalysis
        figure
        plot_wav(t, eyf)
        set(gcf, 'Name', 'Smoothed Power')
        ylabel('sqrt(y^2)')
        hold on
        tbl = t(find(t<0.2));
        plot([tbl(1), tbl(end)], [bl, bl], 'Color', [.6 .6 .6], 'LineWidth', 3)
        plot([t(1), t(end)], [bl+current_thresh, bl+current_thresh], ':', 'Color', [.6 .6 .6], 'LineWidth', 3)
        ylim = get(gca, 'ylim');
        plot([rt(i), rt(i)], ylim, 'r', 'LineWidth', 3)
        hold off
    end

    if cfg.verbose
        subplot(2,2,1)
        plot(t, [y, ey])

        subplot(2,2,2)
        lh = plot(t, [ey, eyf]);
        set(lh(2), 'LineWidth', 2)
        legend('org', 'filt')
        ylim = get(gca, 'ylim');
        hold on
        plot([rt(i), rt(i)], ylim, 'r')
        hold off
        pause
    end
end
if ~isempty(h)
    close(h)
end
if cfg.verbose
    figure
    plot(rt, 'k.')
    figure
    plot(sort(rt), 'k.')
end

function ph = plot_wav(t, y)
set(gcf, 'DefaultAxesFontSize', 16)
ph = plot(t, y, 'k', 'LineWidth', 2);
xlabel('Time [s]')
ylabel('Signal')