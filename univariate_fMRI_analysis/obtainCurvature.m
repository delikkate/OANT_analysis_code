% This script takes a manually reconstructed, smoothed and simplified
% mesh for a subject and obtains a curvature map for further CBA.

% Created by KD 23-03-2017
% example call: obtainCurvature(6, 'LH')

%% UPD 09-04-2017: UPDATED SESSION NUMBER FOR FIVE SUBJECTS (SUB 07, 09, 14, 17, 21)

function obtainCurvature(subNum, hemisphere)

% Indicate paths to data
subID = getID(subNum);
if subNum == 7 || subNum == 9 || subNum == 14 || subNum == 17 || subNum == 21 % for five subjects we segmented TAL.vmr for session 2
    sesNum = 2;
else
    sesNum = 1;
end
pathToTal = sprintf('G:/Analysis_OANT/meshdata/SUB%02d_%s_S%02d_MPRAGE_ISO_IIHC_TAL.vmr', subNum, subID, sesNum);
pathToD80k = sprintf('G:/Analysis_OANT/meshdata/SUB%02d_%s_S%02d_MPRAGE_ISO_IIHC_TAL_WM_%s_RECOSMx_D80k.srf', subNum, subID, sesNum, hemisphere);

% Start BV and load VMR
bvqx = actxserver('BrainVoyagerQX.BrainVoyagerQXScriptAccess.1');
docVMR = bvqx.OpenDocument(pathToTal);

% Load _D80k.srf mesh
meshScene = docVMR.MeshScene; %open surface view
meshScene.LoadMesh(pathToD80k); %load simplified mesh (80 000 vertices)
meshSRF = docVMR.CurrentMesh; %store in "meshSRF" _D80k.srf

% Overlay curvature map
meshSRF.CalculateCurvatureCBA(); %obtain curvature
meshSRF.SmoothCurrentMap(5); %smooth in 5 steps (GUI doesn't provide 'Nr of smoothing steps' as parameter)

% Inflate mesh to sphere and correct distortion
meshSRF.MeshScene.UpdateSurfaceWindow();
% meshSRF.MorphingUpdateInterval = 50; %update screen every 50 iterations (50 is a default)
meshSRF.InflateMeshToSphere(800); %morph in 800 steps (GUI default)
meshSRF.CorrectInflatedSphereMesh(3000); %correct distortions in 3000 steps (GUI default)
% Save result with as _SPHERE.srf
sphere_name = sprintf('G:/Analysis_OANT/meshdata/SUB%02d_%s_S%02d_MPRAGE_ISO_IIHC_TAL_WM_%s_RECOSMx_D80k_SPHERE.srf', subNum, subID, sesNum, hemisphere);
meshSRF.SaveAs(sphere_name);

% Update current state
docVMR = bvqx.ActiveDocument;
meshScene = docVMR.MeshScene;
meshSRF = meshScene.CurrentMesh; %store in "meshSRF" _SPHERE.srf

% Create mapping between subject and standard sphere to reduce vertices
meshScene.SphereResolutionCBA = 1; %1 - standard resolution (GUI default)
ssm_file = meshScene.MapSphereMeshFromStandardSphere(); %creates _SPHERE.ssm

% Apply mapping
sph_srf_file = meshScene.SetStandardSphereToFoldedMesh(pathToD80k); %automatically saves _SPH.srf

% Calculate curvature at each vertex
meshSRF = meshScene.CurrentMesh; %store in "meshSRF" _SPH.srf
curvature_file = meshSRF.CreateMultiScaleCurvatureMap(2, 7, 20, 40); %creates curvature map with four submaps (smoothed at 2, 7, 20 and 40 - GUI default)


% Report success
success_message = sprintf('%s successfully saved!', curvature_file);
bvqx.PrintToLog(success_message);






