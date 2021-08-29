# Pulling Native Space Amygdala Reactivity Estimates

Because [VanTieghem et al (2021)](https://www.sciencedirect.com/science/article/pii/S1878929321000074) generated amygdala ROIs in each participant's "native space" (i.e. defined by the anatomical T1w scan without having to transform to standard space) using Freesurfer (`v6.0`), we used these to pull mean average amygdala reactivity estimates for the bilateral, right, and left amygdala for each scan for the preregistered pipeline. 

## `pull_freesurfer_amyg_activity.py`

This script loops through each participant, and then pulls average amygdala reactivity estimates from the GLM outputs (preregistered pipeline) for the Freesurfer-defined (native space) and Harvard-Oxford-defined (MNI space) ROIs for right, bilateral, and left amygdala using [fslmeants](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/Fslutils)

Notes:
* All GLM statistical output files are in the `24motion.feat/stats` folder for each participant. The number of the file prefixes here indicate the contrast, such that:
    * `*1.nii.gz` are the `fear > baseline` contrast
    * `*2.nii.gz` are the `neutral > baseline` contrast
    * `*3.nii.gz` are the `fear > neutral` contrast
* Here we pull both from the `cope` images and `tstat` images for 2 different amygdala reactivity estmates. What's the difference?
    * The `cope` is the *contrast parameter estimate* and represents the point estimate (beta estimate) of the regression coefficient. Thus, the the `cope` is the *magnitude* of the estimated relationship between the presence of the task stimuli and the BOLD signal
    * The `tstat` represents the estimate scaled by the uncertainty (i.e. by the standard error of the estimate), and so it is a *standardized* effect size measure of the relationship between the presence of the task stimuli and the BOLD signal
* After preregistration we realized there were merits to conducting group-level analyses on either `cope` or `tstat` estimates, so we extracted both for futher modeling. 
