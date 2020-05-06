This folder contains MATLAB and JavaScript code used to perform the univariate analyses of fMRI data.

The analysis pipeline is provided in the script BATCH_univariate_OANT.m.

The analyses were performed in BrainVoyager v. 2.8.4 (with enabled surface module).

Running the code requires:
- enabling COM-scripting to command BrainVoyager from MATLAB (https://support.brainvoyager.com/documents/Automation_Development/Writing_Scripts/ScriptingBrainVoyagerQX284fromMatlab.pdf);
- placing JavaScript code in the folder Documents/BVQXExtensions/Scripts/ in order to run it internally from BrainVoyager (https://support.brainvoyager.com/documents/Automation_Development/Writing_Scripts/BrainVoyagerQX282ScriptingReferenceManual_300614.pdf);
- installing the Neuroelf toolbox to load BrainVoyager files as MATLAB objects (https://neuroelf.net/);
- installing the CoSMoMVPA toolbox for MATLAB to run the permutation testing with Threshold Free Cluster Enhancement (http://www.cosmomvpa.org/).