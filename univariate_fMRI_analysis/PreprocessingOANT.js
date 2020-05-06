// This script will preprocess FMR files previously created with MATLAB.
// There is a stripe artefact appearing in the RFX GLM when preprocessing is run from inside MATLAB
// (potentially due to incorrect slice order identification in random runs),
// so we'll preprocess FMRs inside of BrainVoyager using JavaScript instead.


var nSubjects = 23; // number of subjects (23)
var nSessions = 2; // number of sessions (2)
var nRuns; // declare variable nRuns; we will assign it a value within a for-loop below, depending on how many runs our subjects took part in

var sub, se, run;
for (sub=1; sub<=nSubjects; sub++)
{

	// getID() subfunction removed to prevent re-identification


	// This small patch takes care that all subject numbers are composed of two digits
	function doubleDigit(sub)
	{
 	return sub > 9 ? "" + sub: "0" + sub;
	}
	sub = doubleDigit(sub); // now values of 'sub' will be converted from the single-digit format "1-9" to the double-digit format "01-09"
	

	for (se=1; se<=nSessions; se++)
	{
		if (sub == 13 && se == 1) {nRuns = 4}
		else {nRuns = 8}
		
	 	for (run=1; run<=nRuns; run++)
		{
			Preprocess_FMR();
		}
	}
}



function Preprocess_FMR()
{
	// Open a previously created FMR
	pathToUnprocessedFMR = "G:/Analysis_OANT/SUB" + sub + "_" + ID + "/S0" + se + "/bv/SUB" + sub + "_" + ID + "_0" + run + "_S0" + se + "_OANT.fmr";


	// Step 1: Slice time correction (STC)
	
	var docFMR = BrainVoyagerQX.OpenDocument(pathToUnprocessedFMR); // open the unprocessed FMR

	// set the STC parameters
	var sliceOrder = 1; // ascending interleaved
	var STCInterpolationMethod = 1; // cubic spline

	// run STC
	docFMR.CorrectSliceTiming(sliceOrder, STCInterpolationMethod); // no need to save the new file - it is done automatically in the working folder (with the suffix _SCCAI)
	
	// save the changes and close the tab
	ResultFileName = docFMR.FileNameOfPreprocessdFMR; // store the name of the _SCCAI.fmr in the variable 'ResultFileName'
    	docFMR.Close(); // close the unprocessed FMR


	// Step 2: Motion correction
	
	docFMR = BrainVoyagerQX.OpenDocument(ResultFileName); // open the _SCCAI.fmr

	// set the MoCo parameters
	var targetVolumeNumber = 1; // align to the 1st volume
	//var interpolationMethod = 1; // trilinear detection and trilinear interpolation (the quickest option) - use for testing
	var interpolationMethod = 2; // trilinear detection (estimation) and sinc interpolation (somewhat slowish) - use for finalazing the analysis
	var useFullDataSet = false; // use the reduced dataset (default in GUI)
	var maxNumberOfIterations = 100; // default in GUI
	var createMovies = false;
	var createExtendedLogFile = 1; // save motion estimation parameters in the text file
	
	// run 3D motion correction: align all volumes of all runs in a session to the 1st volume of the 1st run
	if (run == 1) {docFMR.CorrectMotionEx(targetVolumeNumber, interpolationMethod, useFullDataSet, maxNumberOfIterations, createMovies, createExtendedLogFile);} // use run 1 as reference (the closest one in time to anatomy acquisition), don't align it to anything
	else
	{
	var targetFMR = "G:/Analysis_OANT/SUB" + sub + "_" + ID + "/S0" + se + "/bv/SUB" + sub + "_" + ID + "_01_S0" + se + "_OANT.fmr"; // intra-session alignment -- align to the 1st run of the current session
	docFMR.CorrectMotionTargetVolumeInOtherRunEx(targetFMR, targetVolumeNumber, interpolationMethod, useFullDataSet, maxNumberOfIterations, createMovies, createExtendedLogFile); // new file has the suffix _3DMC (for testing) or _3DMCTS (for final analysis)
	}

	// save the changes and close the tab
	ResultFileName = docFMR.FileNameOfPreprocessdFMR;
   	docFMR.Close();


	// Step 3: Temporal High-Pass Filtering

	docFMR = BrainVoyagerQX.OpenDocument(ResultFileName); // open the _SCCAI_3DMCT.fmr

	var cutOffValue = 3;
	var unit = "cycles";
	docFMR.TemporalHighPassFilter(cutOffValue, unit); // older function, includes linear trend removal; adds the suffix _LTR_THP3c

	// save the changes and close the tab
	ResultFileName = docFMR.FileNameOfPreprocessdFMR;
   	docFMR.Close();

	
	
}