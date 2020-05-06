function createDesignMatrix_BVQX_S02(subNum, sesNum)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script to create a design matrix from a stimulation protocol in Matlab
% Works with BrainVoyager QX 2.8.4
% created 2014-03-27 angelika.lingnau@unitn.it
% Adapted for OANT: 2018-01-25 KD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;
Cfg.expName = 'OANT';
Cfg.addDeriv = 0;%[1 2];%1
Cfg.add3DMC = 1;%1
Cfg.addFilter = 0;

Cfg.normalizePredictors = 1;

pathToLog  = [pwd '\log_S02\'];
pathToData = '..\groupdata\';

[dicomFolderVec, nVol, ~, ~] = getDicomFolderVec(subNum, sesNum);
ID = getID(subNum);
subID = sprintf('SUB%02d_%s', subNum, ID);
nRuns = length(dicomFolderVec);

params.hshape = 'twogamma';%'boynton'
params.nderiv = Cfg.addDeriv;
%params.params.ortho = 1;
%params.params.opts.norm = 1;
params.prtr = 2200; %Time of repetition


if Cfg.normalizePredictors == 1
    params.opts.norm = 1;%ztrans predictors
end

params.rcond = 0;


for iRun = 1 : nRuns
    params.nvol = nVol(iRun)-3;
            prt = BVQXfile([pathToLog sprintf('SUB%02d_RUN%02d_S%02d_OANT.prt', subNum, iRun, sesNum)]);
            sdm = prt.CreateSDM(params);
            sdmName = [pathToData sprintf('%s_%02d_S%02d_OANT_onlyS02.sdm', subID, iRun, sesNum)];


    %READ IN 3DMC
    if Cfg.add3DMC == 1
        sdm3DMC = BVQXfile([pathToData sprintf('%s_%02d_S%02d_OANT_SCCAI_3DMC.sdm', subID, iRun, sesNum)]);
        
        %PUT TOGETHER NEW MATRIX by concatenating the study design matrix
        %created above with the matrix containing motion parameters
        sdm.NrOfPredictors = sdm.NrOfPredictors + sdm3DMC.NrOfPredictors;
        sdm.SDMMatrix = [sdm.SDMMatrix sdm3DMC.SDMMatrix];
        sdm.PredictorNames =  [sdm.PredictorNames  sdm3DMC.PredictorNames];
        sdm.PredictorColors = [sdm.PredictorColors; sdm3DMC.PredictorColors];
        end
    %----------------------------------------------------------------------
    subplot(2,nRuns/2,iRun)
    plot(sdm.SDMMatrix);
    %plot(sdm.SDMMatrix(:, 1:2:20));
    axis([0 params.nvol -1 2]);%-80 100]);
    sdm.SaveAs(sdmName);
end

