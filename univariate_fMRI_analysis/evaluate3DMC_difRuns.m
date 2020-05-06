function evaluate3DMC_difRuns(subject, session)

% example call:
% evaluate3DMC_difRuns(1, 1)


pathToData = 'G:\Analysis_OANT\groupdata\';

[dicomFolderVec, nVol, ~, ~] = getDicomFolderVec(subject, session);
ID = getID(subject);
subID = sprintf('SUB%02d_%s', subject, ID);
nRuns = length(dicomFolderVec);

% HERE WE CALCULATE THE MAXIMUM NUMBER OF VOLUMES IN A RUN FOR THIS SESSION
maxNVOL = max(nVol) - 3; % how many volumes are specified in "getDicomFolderVec" minus the three skipped ones (they are not in 3DMC matrix)

Cfg.plotFirstDerivative = 0;
Cfg.plotAll3DMCseparate = 1;
%RsubVec = {'AS'; 'GE'; 'LC'};
maxTrans = 1.5;
maxRot = 1;
maxCorr = 0.3;
minP = .001;

maxTransQuadDiff = maxTrans.^2;
maxRotQuadDiff = maxRot.^2;
msgVec = {'X'; 'Y'; 'Z'; 'X'; 'Y'; 'Z'};

for run = 1 : nRuns
    subplot(4, 2, run);
    sdmName=([pathToData sprintf('%s_%02d_S%02d_OANT_SCCAI_3DMC.sdm', subID, run, session)]);
    sdm = BVQXfile(sdmName); %these are provided in tal coordinates
    t=1;
    %----------------------------------------------------------------
    for mocoInd = 1 : 6 % loop through all 6 translation/rotation parameters
        difference = diff(sdm.SDMMatrix(:,mocoInd)).^2;
        my_nans = NaN(maxNVOL - length(difference),1); % how many NaNs we need to append at the end of the column
        yd(:,mocoInd, run) = [difference; my_nans];
    end
    
 
    if Cfg.plotFirstDerivative == 1
        figure
        for i = 1 : 6
            subplot(4, 2, i);
            h = plot([sdm.SDMMatrix(:,i) yd(1:nVol(run)-3,i, run)]);
            set(h(1), 'color', 'k', 'linewidth', 2);
            set(h(2), 'color', 'r', 'linewidth', 2);
            if i < 4
                axis([0 160 -maxTrans*1.5 maxTrans*1.5]);
            else if i > 3
                    axis([0 160 -maxRot*1.5 maxRot*1.5]);
                end
            end
            htit = title(sprintf('%s', char(sdm.PredictorNames(i))));
            %set(htit, 'interpreter', 'latex');
        end
    end
    
    

    if Cfg.plotAll3DMCseparate == 1 
        for i = 1 : 6 % loop through all 6 translation/rotation parameters
        %figure
            dat(:,i)=sdm.SDMMatrix(:,i) - sdm.SDMMatrix(1,i); % subtract the motion parameters at the beginning of the run
        end
        %h = plot(sdm.SDMMatrix);
        h = plot(dat);
        htit = title(sprintf('SUBJECT %d, SESSION %d, RUN %d', subject, session, run));
        t=1;
        axis([0 150 -1.5 1.5]);
        set(gca, 'ytick', [-2:0.5:2]);
        %set(htit, 'interpreter', 'latex');
        dat = [];
    end
    
end
