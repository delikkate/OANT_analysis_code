function createVTC(subNum, sesNum)
%created: 2010-10-01 AL
%last update: 2014-11-27 AL
%angelika.lingnau@unitn.it

%adapted for OANT: 2016-12-29 KD

%example call:
%createVTC(1,1)


[dicomFolderVec, ~, ~, ~] = getDicomFolderVec(subNum, sesNum);

nRuns = length(dicomFolderVec);

ID = getID(subNum);
subID = sprintf('SUB%02d_%s', subNum, ID);


pathToData = ['G:\Analysis_OANT\' subID sprintf('\\S%02d\\bv\\', sesNum)];
pathToFirstSession = ['G:\Analysis_OANT\' subID '\S01\bv\']; % we'll use .tal files from session 1 when creating VTCs for session 2 (with the exception of 5 subjects for whom we segmented S02)
pathToSecondSession = ['G:\Analysis_OANT\' subID '\S02\bv\'];

bvqx = actxserver('BrainVoyagerQX.BrainVoyagerQXScriptAccess.1');
vmr = bvqx.OpenDocument([pathToData sprintf('%s_S%02d_MPRAGE_ISO_IIHC.vmr', subID, sesNum)]);

vmr.ExtendedTALSpaceForVTCCreation = false;

datatype = 2;  % create a VTC in float format (instead of integer 2-byte format)
resolution = 3;  % target resolution (3x3x3 mm)
interpolation = 1;  % interpolation: 0 - nearest neighbour, 1 - trilinear, 2 - sinc
bbithresh= 100;  % intensity threshold for bounding box; default value is 100

if subNum == 7 || subNum == 9 || subNum == 14 || subNum == 17 || subNum == 21 % for five subjects we segmented TAL.vmr for session 2 
    if sesNum == 1
        for iRun = 1 : nRuns           
            fmr =  [pathToFirstSession sprintf('%s_%02d_S01_OANT_SCCAI_3DMCTS_LTR_THP3c.fmr', subID, iRun)];
            ia =   [pathToFirstSession sprintf('%s_01_S01_OANT_SCCAI_3DMCTS_LTR_THP3c-TO-%s_S01_MPRAGE_ISO_IIHC_IA.trf', subID, subID)]; % result of FMR-VMR coregistration (initial alignment coordinates)
            fa =   [pathToFirstSession sprintf('%s_01_S01_OANT_SCCAI_3DMCTS_LTR_THP3c-TO-%s_S01_MPRAGE_ISO_IIHC_FA.trf', subID, subID)]; % result of FMR-VMR coregistration (final alignment coordinates)
            acpc = [pathToFirstSession sprintf('%s_S01_MPRAGE_ISO_IIHC-TO-%s_S02_MPRAGE_ISO_IIHC_ACPC.trf', subID, subID)]; % rotate S01 to ACPC by aligning it to S02_ACPC
            tal =  [pathToSecondSession sprintf('%s_S02_MPRAGE_ISO_IIHC_ACPC.tal', subID)]; % .tal coordinates are stored in S02
            vtc =  [pathToFirstSession sprintf('%s_%02d_S01_OANT_SCCAI_3DMCTS_LTR_THP3c_TAL.vtc', subID, iRun)];
            
            if exist(fmr)==0
                error(sprintf('file %s not existing', fmr));
            elseif exist(ia)==0
                error(sprintf('file %s not existing', ia));
            elseif exist(fa)==0
                error(sprintf('file %s not existing', fa));
            elseif exist(acpc)==0
                error(sprintf('file %s not existing', acpc));
            elseif exist(tal)==0
                error(sprintf('file %s not existing', tal));
            end

            success = vmr.CreateVTCInTALSpace(fmr, ia, fa, acpc, tal, vtc, datatype, resolution, interpolation, bbithresh);
        end
        
    elseif sesNum == 2
        for iRun = 1 : nRuns           
            fmr =  [pathToSecondSession sprintf('%s_%02d_S02_OANT_SCCAI_3DMCTS_LTR_THP3c.fmr', subID, iRun)];
            ia =   [pathToSecondSession sprintf('%s_01_S02_OANT_SCCAI_3DMCTS_LTR_THP3c-TO-%s_S02_MPRAGE_ISO_IIHC_IA.trf', subID, subID)];
            fa =   [pathToSecondSession sprintf('%s_01_S02_OANT_SCCAI_3DMCTS_LTR_THP3c-TO-%s_S02_MPRAGE_ISO_IIHC_FA.trf', subID, subID)];
            acpc = [pathToSecondSession sprintf('%s_S02_MPRAGE_ISO_IIHC_ACPC.trf', subID)];
            tal =  [pathToSecondSession sprintf('%s_S02_MPRAGE_ISO_IIHC_ACPC.tal', subID)];  % .tal coordinates are stored in S02
            vtc =  [pathToSecondSession sprintf('%s_%02d_S%02d_OANT_SCCAI_3DMCTS_LTR_THP3c_TAL.vtc', subID, iRun, sesNum)];
            
            if exist(fmr)==0
                error(sprintf('file %s not existing', fmr));
            elseif exist(ia)==0
                error(sprintf('file %s not existing', ia));
            elseif exist(fa)==0
                error(sprintf('file %s not existing', fa));
            elseif exist(acpc)==0
                error(sprintf('file %s not existing', acpc));
            elseif exist(tal)==0
                error(sprintf('file %s not existing', tal));
            end

            success = vmr.CreateVTCInTALSpace(fmr, ia, fa, acpc, tal, vtc, datatype, resolution, interpolation, bbithresh);
        end   
    end 

else % for all the other subjects
    
    if sesNum == 1
        for iRun = 1 : nRuns           
            fmr =  [pathToData sprintf('%s_%02d_S%02d_OANT_SCCAI_3DMCTS_LTR_THP3c.fmr', subID, iRun, sesNum)];
            ia =   [pathToData sprintf('%s_01_S%02d_OANT_SCCAI_3DMCTS_LTR_THP3c-TO-%s_S%02d_MPRAGE_ISO_IIHC_IA.trf', subID, sesNum, subID, sesNum)]; % result of FMR-VMR coregistration (initial alignment coordinates)
            fa =   [pathToData sprintf('%s_01_S%02d_OANT_SCCAI_3DMCTS_LTR_THP3c-TO-%s_S%02d_MPRAGE_ISO_IIHC_FA.trf', subID, sesNum, subID, sesNum)]; % result of FMR-VMR coregistration (final alignment coordinates)
            acpc = [pathToData sprintf('%s_S%02d_MPRAGE_ISO_IIHC_ACPC.trf', subID, sesNum)];
            tal =  [pathToData sprintf('%s_S%02d_MPRAGE_ISO_IIHC_ACPC.tal', subID, sesNum)];
            vtc =  [pathToData sprintf('%s_%02d_S%02d_OANT_SCCAI_3DMCTS_LTR_THP3c_TAL.vtc', subID, iRun, sesNum)];
            
            if exist(fmr)==0
                error(sprintf('file %s not existing', fmr));
            elseif exist(ia)==0
                error(sprintf('file %s not existing', ia));
            elseif exist(fa)==0
                error(sprintf('file %s not existing', fa));
            elseif exist(acpc)==0
                error(sprintf('file %s not existing', acpc));
            elseif exist(tal)==0
                error(sprintf('file %s not existing', tal));
            end

            success = vmr.CreateVTCInTALSpace(fmr, ia, fa, acpc, tal, vtc, datatype, resolution, interpolation, bbithresh);
        end

    elseif sesNum == 2
        for iRun = 1 : nRuns           
            fmr =  [pathToData sprintf('%s_%02d_S%02d_OANT_SCCAI_3DMCTS_LTR_THP3c.fmr', subID, iRun, sesNum)];
            ia =   [pathToData sprintf('%s_01_S%02d_OANT_SCCAI_3DMCTS_LTR_THP3c-TO-%s_S%02d_MPRAGE_ISO_IIHC_IA.trf', subID, sesNum, subID, sesNum)];
            fa =   [pathToData sprintf('%s_01_S%02d_OANT_SCCAI_3DMCTS_LTR_THP3c-TO-%s_S%02d_MPRAGE_ISO_IIHC_FA.trf', subID, sesNum, subID, sesNum)];
            acpc = [pathToData sprintf('%s_S02_MPRAGE_ISO_IIHC-TO-%s_S01_MPRAGE_ISO_IIHC_ACPC.trf', subID, subID)];
            tal =  [pathToFirstSession sprintf('%s_S01_MPRAGE_ISO_IIHC_ACPC.tal', subID)];
            vtc =  [pathToData sprintf('%s_%02d_S%02d_OANT_SCCAI_3DMCTS_LTR_THP3c_TAL.vtc', subID, iRun, sesNum)];
            
            if exist(fmr)==0
                error(sprintf('file %s not existing', fmr));
            elseif exist(ia)==0
                error(sprintf('file %s not existing', ia));
            elseif exist(fa)==0
                error(sprintf('file %s not existing', fa));
            elseif exist(acpc)==0
                error(sprintf('file %s not existing', acpc));
            elseif exist(tal)==0
                error(sprintf('file %s not existing', tal));
            end

            success = vmr.CreateVTCInTALSpace(fmr, ia, fa, acpc, tal, vtc, datatype, resolution, interpolation, bbithresh);
        end
    end
end


vmr.Close;
close all;
clear all;

