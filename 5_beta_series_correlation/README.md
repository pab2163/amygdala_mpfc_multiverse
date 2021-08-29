# Beta series correlation analyses & single-trial estimates

This folder contains scripts for running level-1 GLM models for single-trial amygdala reactivity estimates, then computing beta series correlations for each scan.

`0_set_up_single_trial_regressors.py`

This script prepares stimulus files for level-1 GLM models for each scan for 'Least Squares Separate' (LSS) modeling [(Abdulrahman & Henson, 2016)](https://pubmed.ncbi.nlm.nih.gov/26549299/), such that a separate GLM is fit to estimate BOLD responses for each trial (face stimulus). For each GLM, the trial of interest is given one regressor, and all other trials are 'collapsed' into another regressor. 

So, here we set up regressors for 48 GLMs as there are are 48 trials in each scan run (24 each fear and neutral faces). Each GLM will have 1 regressor for the trial of interest, and 1 regressof for all other trials combined. All such stimulus files for regressors are stored in the [3-column format](0_setup_and_behavioral_analyses/example_fear_stimulus_onsets_fsl_fomat.txt) for input to FSL. 


`1_make_lss_fsf_files.py`

Using `lssTemplate.fsf`, this script sets up 48 `.fsf` files for each scan to run the LSS model approach. 

**Info on the `lssTemplate.fsf`**

* These models are run using the BOLD data preprocessed through the preregistered FSL-based pipeline [see info](../2_prereg_level1/feat_template_24motion_no_errors.fsf).
* Prewhitening is used in the GLM
* `set fmri(confoundevs) 1` and `set confoundev_files(1) "/danl/SB/Investigators/PaulCompileTGNG/data/SUBNUM/model/fear/24motion.feat/confoundevs.txt"` -- pulls all the nuisance regressors from the [level-1 GLM used for reactivity](../2_prereg_level1/feat_template_24motion_no_errors.fsf), which are 24 head motion parameters + downweighting any volumes where `FD > 0.9mm`.
* `EV1` = the "target" single trial being modeled, where the t