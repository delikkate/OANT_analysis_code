This folder contains MATLAB code used to perform multivariate analyses of fMRI data.

- The subfolder "progs_MVPA_OANT_S01" contains scripts used for decoding of word class effects (based on data from session 1). The analysis pipeline is provided in the script BATCH_MVPA_OANT_S01.m.

- The subfolder "progs_MVPA_OANT_S02" contains scripts used for decoding of training effects (based on data from session 2). The analysis pipeline is provided in the script BATCH_MVPA_OANT_S02.m.


The analyses were performed in BrainVoyager v. 2.8.4 (with enabled surface module).

Running the code requires:
- installing the Neuroelf toolbox to load BrainVoyager files as MATLAB objects (https://neuroelf.net/);
- installing the CoSMoMVPA toolbox for MATLAB to run searchlight analyses and permutation testing with Threshold Free Cluster Enhancement (http://www.cosmomvpa.org/).