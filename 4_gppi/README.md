# Generalized Psychophysiological Interaction (gPPI) Analyses

This subfolder contains scripts for setting up regressors and running gPPI models using FSL's feat for *each individual scan*. We run 2 gPPI models for each scan:
1. "FSL style" - No deconvolution is used in creating the gPPI regressor
2. "AFNI style" - Deconvolution is used in greating the gPPI regressor




## `0_extractSeedTS.py`

For each scan run and a given mask (here we use the Harvard-Oxford bilateral amygdala), extract the mean 'seed timeseries' of the preprocessed BOLD data for that mask (i.e. the average timeseries for voxels in the masked ROI). We use `fslmeants` here to get a seed timeseries for the bilateral amygdala for each scan. 

## `1_make_afni_style_regressors.py`

