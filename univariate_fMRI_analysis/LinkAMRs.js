var nSubjects = 23; // number of subjects (23)
var nSessions = 2; // number of sessions (2)

var sub, se;
for (sub=1; sub<=nSubjects; sub++)
{

	// getID() subfunction removed to prevent subject re-identification


	// This small patch takes care that all subject numbers are composed of two digits
	function doubleDigit(sub)
	{
 	return sub > 9 ? "" + sub: "0" + sub;
	}
	sub = doubleDigit(sub); // now values of 'sub' will be converted from the single-digit format "1-9" to the double-digit format "01-09"
	

	for (se=1; se<=nSessions; se++)
	{
		Link_inverted_AMR();
	}
}



function Link_inverted_AMR()
{
	// indicate path to the motion corrected FMR for the 1st run of a session
	FMRpath = "G:/Analysis_OANT/SUB" + sub + "_" + ID + "/S0" + se + "/bv/SUB" + sub + "_" + ID + "_01_S0" + se + "_OANT_SCCAI_3DMCTS_LTR_THP3c.fmr"; 

	// indicate path to the pseudo-amr manually created for the "_firstvol.fmr" of the 1st run (params: inverted intensities, inverted background, intensity threshold = 80)
	AMRpath =  "G:/Analysis_OANT/SUB" + sub + "_" + ID + "/S0" + se + "/bv/SUB" + sub + "_" + ID + "_01_S0" + se + "_OANT_firstvol_as_anat_i.amr";
  
 	

	var docFMR = BrainVoyagerQX.OpenDocument(FMRpath); // open the indicated FMR
	docFMR.LinkAMR(AMRpath); // link the inverted AMR
	docFMR.SaveAs(FMRpath); // save the changes in the FMR
	docFMR.Close(); // close the updated FMR
}