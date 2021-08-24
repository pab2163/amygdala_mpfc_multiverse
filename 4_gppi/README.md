# Generalized Psychophysiological Interaction (gPPI) Analyses

This subfolder contains scripts for setting up regressors and running gPPI models using FSL's feat for *each individual scan*. We run 2 gPPI models for each scan:
1. No deconvolution is used in creating the gPPI regressor
2. Deconvolution is used in creating the gPPI regressor


## `0_extractSeedTS.py`

For each scan run and a given mask (here we use the Harvard-Oxford bilateral amygdala), extract the mean 'seed timeseries' of the preprocessed BOLD data for that mask (i.e. the average timeseries for voxels in the masked ROI). We use `fslmeants` here to get a seed timeseries for the bilateral amygdala for each scan. 

## `1_make_deconvolved_regressors.py`

This script makes the regressors for each scan for gPPI including a deconvolution step following many of the AFNI defaults. Steps roughly follow [AFNI docs](https://afni.nimh.nih.gov/CD-CorrAna)  as follows

1. Detrend the amygdala 'seed timeseries' using `3dDetrend -polort 2` (adding Legendre polynomials of order up to 2). Save this detrended timeseries to a `.1D` and `.txt` file for later use. 
2. Create a gamma HRF at the sampling frequency of the data (TR = 2s) and save to a `GammaHR.1D` file using `waver -dt 2 -GAM -inline 1@1`
3. Run the actual deconvolution step with [3dTfitter](https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dTfitter.html). In theory, this step deconvolves the gamma HRF signal from the amygdala BOLD timeseries to recover the "neurological timeseries" (i.e. the timeseries representing 'neuronal' signal before being blurred by the HRF ). Note, the docs here say *"Deconvolution is a tricky business, so be careful out there e.g., experiment with the different parameters to make sure the results in your type of problems make sense".* Accordingly, we compared different parameter settings in later scripts. 

    * `3dTfitter -RHS seed_ts.1D -FALTUNG GammaHR.1D seed_deconvolved 012 0`
        * `-RHS seed_ts.1D` specifies that the amygdala seed is the 'right-hand-side' dataset (i.e. the outcome variable in the model)
        * `FALTUNG GammaHR.1D seed_deconvolved 012 0`. 'Faltung' means 'convolution' in German, and everything here specifies the 'left-hand-side' (or LHS matrix) of the equation. This pecifies that `GammaHR.1D` is the known convolution kernel, and `seed_deconvolved` is the timeseries we are solving for (this file will be reated). Also, the `012` indicates that we will use the sum of 3 penalty functions when solving for the deconvoled timeseries, trying to keep the timeseries values, and first and second derivatives of the timeseries over time small (see `pen` options in [docs](https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dTfitter.html)). The last `0` here is the weighting of the penalty function, with 0 indicating that the program "chooses a range of penalty factors, does the deconvolution regression for each one, and then chooses the fit it likes best (as a tradeoff between fit error and solution size)" (see `fac` option in [docs](https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dTfitter.html))