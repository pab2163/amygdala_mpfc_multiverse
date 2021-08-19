# Preregistered Preprocessing & Level-1 GLMs in FSL

*Scripts for the initial [preregistered](https://osf.io/8nyj7/) FSL preprocessing pipeline*

## `feat_template_24motion_no_errors.fsf`

This is a template feat file for preprocessing and level1 GLM for which all scan-specific feat (`V6.00`) files are based. 

Notable preprocessing points for this file include:

* `set fmri(tr) 2.000000`: TR = 2s
* `set fmri(npts) 130`: 130 total volumes per run (only complete runs analyzed here)
* `set fmri(ndelete) 0`: No volumes deleted
* `set fmri(mc) 1`: MCFLIRT motion correction
* `set fmri(st) 0`: no slice-timing correction
* `set fmri(bet_yn) 1` BET brain extraction (BOLD)
* `set fmri(smooth) 6`: 6mm FWHM spatial smoothing
* `set fmri(norm_yn) 0`: no intensity normalization
* `set fmri(temphp_yn) 1`: highpass temporal filtering (but no lowpass) with `set fmri(paradigm_hp) 100`, filter cutoff at 100s (.01Hz)
* `set fmri(reghighres_dof) BBR` : Boundary-based registration of BOLD with anatomical
* `set fmri(regstandard_yn) 1` : register to standard space
* `set fmri(regstandard) "/usr/share/fsl/data/standard/MNI152_T1_2mm_brain"` : register to standard MNI brain at 2mm resolution with `set fmri(regstandard_dof) 12` 12 degrees of freedom
* `set fmri(regstandard_nonlinear_yn) 1`: use nonlinear registration from anatomical to standard space with `set fmri(regstandard_nonlinear_warpres) 10 ` for warp resolution of 10mm


GLM Specifics
* `set fmri(prewhiten_yn) 1`: use prewhitening for GLM
* `set fmri(motionevs) 2`: to add 24 motion parameters ("standard + extended") to GLM
* `set confoundev_files(1) "/danl/SB/PaulCompileTGNG/data/SUBNUM/BOLD/motion_assess/confound.txt"`: add an additional confound regressor for downweighting of high-motion TRs (as identified previously by `fsl_motion_outliers` - each column of the file will be all `0` except for 1 volume marked with a `1` - these volumes will be downweighted)
* 2 EVs (explanatory variables). Both are `set fmri(shape2) 3` to indicate that the regressor will be in the 3-column format (see the README file in the `0_setup_and_behavioral_aanalysis` folder). They will be convolved with a double-gamma HRF (`set fmri(convolve2) 3`) and will include an extra regresssor with the demporal derivative (`set fmri(deriv_yn2) 1`) since there is no slice-timing correction in the pipeline.
    1. *fear face stimuli*
    2. *neutral face stimuli*
* Contrasts of interest here are `fear faces > baseline`, `neutral faces > baseline`, and `fear faces > neutral faces`



## `1_make_fsfs_for_haba.py`

## `2_gather_level1_jobs_haba.py`


## `3_submit_level1_jobs.haba.py`