# Beta series correlation analyses & single-trial estimates

This folder contains scripts for running level-1 GLM models for single-trial amygdala reactivity estimates, then computing beta series correlations for each scan.

## `0_set_up_single_trial_regressors.py`

This script prepares stimulus files for level-1 GLM models for each scan for 'Least Squares Separate' (LSS) modeling [(Abdulrahman & Henson, 2016)](https://pubmed.ncbi.nlm.nih.gov/26549299/), such that a separate GLM is fit to estimate BOLD responses for each trial (face stimulus). For each GLM, the trial of interest is given one regressor, and all other trials are 'collapsed' into another regressor. 

So, here we set up regressors for 48 GLMs as there are are 48 trials in each scan run (24 each fear and neutral faces). Each GLM will have 1 regressor for the trial of interest, and 1 regressof for all other trials combined. All such stimulus files for regressors are stored in the [3-column format](../0_setup_and_behavioral_analyses/example_fear_stimulus_onsets_fsl_fomat.txt) for input to FSL. 


## `1_make_lss_fsf_files.py`

Using `lssTemplate.fsf`, this script sets up 48 `.fsf` files for each scan to run the LSS model approach. 

**Info on the `lssTemplate.fsf`:**

* These models are run using the BOLD data preprocessed through the preregistered FSL-based pipeline [see info](../2_prereg_level1/feat_template_24motion_no_errors.fsf).
* Prewhitening is used in the GLM
* `set fmri(confoundevs) 1` and `set confoundev_files(1) "/danl/SB/Investigators/PaulCompileTGNG/data/SUBNUM/model/fear/24motion.feat/confoundevs.txt"` -- pulls all the nuisance regressors from the [level-1 GLM used for reactivity](../2_prereg_level1/feat_template_24motion_no_errors.fsf), which are 24 head motion parameters + downweighting any volumes where `FD > 0.9mm`.
* `EV1` = the "target" single trial being modeled in the respective GLM, convolved with a Double-Gamma HRF, with the temporal derivative added (`set fmri(deriv_yn1) 1`)
* `EV2` = all other 47 trials (fear and neutral) collapsed into 1 regressor, convolved with a Double-Gamma HRF, with the temporal derivative added (`set fmri(deriv_yn1) 1`)
* The only contrast used in each GLM is for the `single trial > baseline`. 



## `2_run_all_single_trial_models_haba.sh`

This launches 1 slurm job for `run_single_trial_model_haba.sh` for each scan, so there will be 1 slurm job for each scan. Each slurm job will run the 48 GLMs for that given scan (i.e. so GLMs are parallelized across scans, but run serially across trials within a scan). This runs on the Columbia [Habanero](https://cuit.columbia.edu/shared-research-computing-facility) computing cluster. 

**Info on `run_single_trial_model_haba.sh`:**

Runs (serially) the 48 level-1 GLMs, each from a separate `.fsf` file, for a given scan. Since no preprocessing is involved here (just the GLM), 48 GLMs finish on 4 cores within 12 hours. 


## `3_merge_single_trial_estimates.py`

For each scan, use `fslmerge -t` to merge the contrast estimates for the 24 fear trials and 24 neutral trials into resspective 4D BOLD images. Thus, the 4D volumes represent the 'beta series' of responses to fear & neutral face trials, respectively. **Note:** here we use `cope1.nii.gz` images for contrast parameter estimates (not t-statistics).

## `4_register_beta_series.py`

Warp the beta series images constructed in the previous step to MNI space using the matrices calculated in the preregisted FSL-based preprocessing pipeline. Here, we bring the beta series images to MNI space so that we can pull estimates from ROIs using the Harvard-Oxford atlas and mPFC ROIs in standard space. 

## `5_global_signal_correction.ipynb`

Apply a post-hoc mean-centering (mean subtraction, see [Yan et al., 2014](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4074397/)) approach to correcting beta series images for fluctuations in the 'global signal', calculated as the global mean across brain voxels. 

Steps:
* Load in beta series image (each of the 24 volumes is the contrast parameter estimate map for a particular trial).
* Mask the image to just contain brain voxels
* Get the timeseries of the mean signal across the brain for each of the 24 volumes here, then subtract this timeseries from all voxels in each volume
* Zero out non-brain voxels and save images out


## `6_pull_amygdala_mpfc_bsc.py`

This script loops through [all 4 mPFC masks](../4_gppi/images/pfc_crop_2.png) and amygdala masks (Harvard-Oxford bilateral, right, & left) to calculate beta series correlations for each pair of regions.

Notes:

* First calculates the mean beta estimate within each ROI for each trial
* Then correlates these series of betas using `numpy.corrcoef()` for a product-moment correlation
* Calculates these estimates for all pairwise-combinations of amygdala/mPFC ROIs, for the fear trials and neutral trials separately, and for pipelines with vs. without a global signal correction


## `7_pull_whole_brain_bsc.py`

Similar to `6_pull_amygdala_mpfc_bsc.py`, except that beta series correlations are calculated across all pairs of ROIs within the Harvard-Oxford cortical and subcortical atlases. These connectivity estimates are not used in main analyses, but rather to later assess convergence across functional connectivity pipelines in task-evoked amygdala FC with the rest of the brain. 

## `8_get_trialwise_amygdala_betas.py`

Extracts single-trial amygdala betas (to be used in further analyses of change in amygdala reactivity across trials)

* `getBetas()` calculates a vector of average betas across trials for a given `copeDir` (directory for either global signal or not), `name` (the scan id),  `emotion` (fear or neutral), and `mask` (ROI in MNI space), as well as the slope of those betas (using a rank-order correlation) across trials.

Then, run `getBetas()` for all scans, both `fear` and `neutral` faces, both with global signal correction and without, and for Harvard-Oxford bilateral, left, and right aygdala ROI. 