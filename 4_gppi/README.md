# Generalized Psychophysiological Interaction (gPPI) Analyses

This subfolder contains scripts for setting up regressors and running gPPI models using FSL's feat for *each individual scan*. We run 2 gPPI models for each scan:
1. No deconvolution is used in creating the gPPI regressor
2. Deconvolution is used in creating the gPPI regressor


## `0_extractSeedTS.py`

For each scan run and a given mask (here we use the Harvard-Oxford bilateral amygdala), extract the mean 'seed timeseries' of the preprocessed BOLD data for that mask (i.e. the average timeseries for voxels in the masked ROI). We use `fslmeants` here to get a seed timeseries for the bilateral amygdala for each scan. 

## `1_make_deconvolved_regressors.py`

This script makes the regressors for each scan for gPPI including a deconvolution step following many of the AFNI defaults. Steps roughly follow [AFNI docs](https://afni.nimh.nih.gov/CD-CorrAna)  as follows

First, detrend the amygdala 'seed timeseries' using `3dDetrend -polort 2` (adding Legendre polynomials of order up to 2). Save this detrended timeseries to a `.1D` and `.txt` file for later use. 

Next, create a gamma HRF at the sampling frequency of the data (TR = 2s) and save to a `GammaHR.1D` file using `waver -dt 2 -GAM -inline 1@1`

Run the actual deconvolution step with [3dTfitter](https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dTfitter.html). In theory, this step deconvolves the gamma HRF signal from the amygdala BOLD timeseries to recover the "neurological timeseries" (i.e. the timeseries representing 'neuronal' signal before being blurred by the HRF ). Note, the docs here say *"Deconvolution is a tricky business, so be careful out there e.g., experiment with the different parameters to make sure the results in your type of problems make sense".* Accordingly, we compared different parameter settings in later scripts. Here, it looks like this:


 ```
 3dTfitter -RHS seed_ts.1D -FALTUNG GammaHR.1D seed_deconvolved 012 0
 ```

What does this do?
* `-RHS seed_ts.1D` specifies that the amygdala seed timeseries is the 'right-hand-side' dataset (i.e. the outcome variable in the model)
* `FALTUNG GammaHR.1D seed_deconvolved 012 0`. 'Faltung' means 'convolution' in German, and everything here specifies the 'left-hand-side' (or LHS predictor matrix) of the equation. This pecifies that `GammaHR.1D` is the known convolution kernel, and `seed_deconvolved` is the timeseries we are solving for (this file will be reated). Also, the `012` indicates that we will use the sum of 3 penalty functions when solving for the deconvoled timeseries, trying to keep the timeseries values, and first and second derivatives of the timeseries over time small (see `pen` options in [docs](https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dTfitter.html)). The last `0` here is the weighting of the penalty function, with 0 indicating that the program "chooses a range of penalty factors, does the deconvolution regression for each one, and then chooses the fit it likes best (as a tradeoff between fit error and solution size)" (see `fac` option in [docs](https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dTfitter.html))

Next, pull in the stimulus timing files for both the fear & neutral faces. These are the 3-column files previously set up for FSL, but we'll need to convert them here. We use the following code to use [timing_tool.py](https://afni.nimh.nih.gov/pub/dist/doc/program_help/timing_tool.py.html): 

```
timing_tool.py -timing fear_times.1D -tr 2 -stim_dur .350 -min_frac .05 -run_len 260 -timing_to_1D afni_fear_times.1D
```

* This line take `fear_times.1D`, and knowing that the `tr` = 2 and the stimulus duration (`stim_dur`) is .350s, creates a 1-column file with a 1 in each row if there is a stimulus ocurring in at least `min_frac` of the TR, and a 0 if not. So, here if there is a fear face in a TR for 5% of the time, or 0.1s, we will have a 1 during that TR for the stimulus being 'on'. We also specify the `run_len` for the run length in seconds here. The new timings are exported to the file `afni_fear_times.1D` here.

Now that we have the stimulus timing file and the deconvolved seed timeseries, we make the interaction regressor by multiplying the two timeseries by one another. This gives the interaction timeseries!

```
1deval -a seed_deconvolved.1D\' -b afni_fear_times.1D -expr 'a*b' > fear_gppi_term.1D
```

Note: the `\'` following `seed_deconvolved.1D` transposes the timeseries so it can be multiplied.

Last, we *re-convolve* the interaction regressor with the same gamma HRF, make sure it is at the temporal resolution of the data by specificying the TR and number of total volumes (`numout`) and scale the regressor to have a `peak` value of 1:

```
waver -GAM -peak 1 -TR 2 -input %s/fear_gppi_term.1D -numout 130 > fear_gppi_term_scaled.txt
```

This `fear_gppi_term_scaled.txt` is now the gPPI term we'll use in the deconvolved verion of the model. Note: the script also makes a similar term for the neutral faces for the full gPPI model. 

## `2_make_ppi_fsfs_for_haba.py`

Loops through the gPPI template files `feat_template_gppi_deconv.fsf` and `feat_template_gppi_no_deconv.fsf` to make scan-specific feat files for launching on the Habanero computing cluster. 

### Info on `feat_template_gppi_deconv.fsf`

* Uses preprocessed BOLD data from the preregistered FSL pipeline, only running a new first-level analysis for the gPPI statistical model (no more preprocessing here)
* GLM Regressors:
    * EV1 = Fear faces (same as level1 reactivity GLM), convolved with HRF, and temporal derivative
    * EV2 = Neutral faces (same as level1 reactivity GLM), convolved with HRF, and temporal derivative
    * EV3 = 'PHYSIO' regressor, the detrended amygdala seed timeseries. No convolution here, since it is BOLD data already. 
    * EV4 = fear gPPI term, the `fear_gppi_term_scaled.txt` timeseries created using AFNI tools
    * EV5 = neutral gPPI term, the `neutral_gppi_term_scaled.txt` timeseries created using AFNI tools
    * All nuisance parameters (24 head motion parameters + any regressors for downweighting high motion (FD > 0.9mm) TRs are included in the model through an additional `confoundevs.txt` file)
* Contrasts:
    * Fear faces > baseline gPPI
    * Neutral faces > baseline gPPI
    * Fear faces > neutral faces gPPI


### Info on `feat_template_gppi_no_deconv.fsf`

This gPPI setup was based on the [FSL PPI analysis documentation](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/PPIHowToRun). The only differences compared to the pipeline with deconvolution are in how the gPPI regressors (EV4-5) themselves are created. 
    * EV4 = fear gPPI term, but this time made through FSL's `Interaction` option, as an interaction between EV1-EV3. Before the interaction term is created, EV1 is demeaned such that the minimum value is 0, and EV3 is demeaned such that the mean value is 0. No orthogonalization, temporal derivative, or temporal filtering. 
    * EV4 = neutral gPPI term, but this time made through FSL's `Interaction` option, as an interaction between EV2-EV3. Before the interaction term is created, EV2 is demeaned such that the minimum value is 0, and EV3 is demeaned such that the mean value is 0. No orthogonalization, temporal derivative, or temporal filtering. 


## `3_submit_ppi_feat_jobs.py`

Loops through all scan-specific `.fsf` scripts and launches `run_ppi_fsl.sh` many times using the `sbatch` command to run the gPPI models for many scans in parallel on the Habanero computing cluster. 

## `4_register_ppi_stats_to_standard.py`

Warps output gPPI statmap files to MNI space for subsequent pulling amygdala-mPFC gPPI estimates.

## `5_amyg_mpfc_gppi.ipynb`

Pull beta and t-statistic estimates for amygdala-mPFC gPPI for 4 different mPFC regions (see [OSF](https://osf.io/hvdmx/) for ROI files). 


![](https://mfr.osf.io/export?url=https://osf.io/f53sj/?direct%26mode=render%26action=download%26public_file=True&initialWidth=750&childId=mfrIframe&parentTitle=OSF+%7C+pfc_crop_2.png&parentUrl=https://osf.io/f53sj/&format=2400x2400.jpeg)

* Estimates are pulled for the `fear faces > baseline`, `neutral faces > baseline`, and `fear faces > neutral faces` gPPI contrasts for each ROI, as well as the `PHYSIO` term representing the association between the amygdala & mPFC timeseries controlling for the task. 
* Estimates are pulled separately for both the gPPI pipeline with, and the pipeline without, deconvolution. 

## `6_pull_amyg_harvard_oxford_parcel_gppi.ipynb`

Pull beta and t-statistic estimates for amygdala-seeded with all Harvard-Oxford cortical and subcortical parcels. These will be used to assess cross-pipeline similarity (i.e. with vs. without deconvolution).