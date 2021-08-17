# Calculate head motion from BOLD data during task runs

**Note:** These scripts were run on the [Habanero](https://cuit.columbia.edu/shared-research-computing-facility) HPC at Columbia University


## `1_submit_moco_haba.sh`

This is a slurm launch script for running motion correction for *one scan run*. This script will be run many times in parallel by `2_haba_bold_motion_assess_all_emotions.py`. 

1. The script takes 2-command line arguments for `curDir` (the current directory where the BOLD file is saved) and `boldFile` (the BOLD file to be assessed for motion)
2. For the given BOLD file, run `fsl_motion_outliers` to generate an estimate of framewise displacement for each TR, as well as a 1-column file denoting TRs where `FD > 0.9mm`. This file will later be used to downweight these high-motion TRs in the GLM

## `2_haba_bold_motion_assess_all_emotions.py`

Loops through all BOLD files available, then launches `1_submit_moco_haba.sh` to run in parallel for all of them. 