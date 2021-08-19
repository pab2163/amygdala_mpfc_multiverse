# Calculate head motion from BOLD data during task runs

**Note:** These scripts were run on the [Habanero](https://cuit.columbia.edu/shared-research-computing-facility) HPC at Columbia University


## `1_submit_moco_haba.sh`

This is a slurm launch script for running motion correction for *one scan run*. This script will be run many times in parallel by `2_haba_bold_motion_assess_all_emotions.py`. 

1. The script takes 2-command line arguments for `curDir` (the current directory where the BOLD file is saved) and `boldFile` (the BOLD file to be assessed for motion)
2. For the given BOLD file, run [fsl_motion_outliers](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSLMotionOutliers) to generate an estimate of [framewise displacement](https://wiki.cam.ac.uk/bmuwiki/FMRI) for each TR, as well as a 1-column file denoting TRs where `FD > 0.9mm` (we chose a threshold of .9mm). This file will later be used to downweight these high-motion TRs in the GLM

This file, called `confound.txt` will have 1 column and 130 rows (1 row per TR). For example, if the below were the first 5 rows of the file, this would indicate that in the 3rd volume there was a spike in framewise displacement (FD) above our threshold of .9mm. Later, we'll downweight this volume in the GLM so that BOLD signal specifically during this volume doesn't influence estimates of task-evoked reactivity or functional connectivity. 

```
0
0
1
0
0
```

This also creates a file called `outlier_output.txt` with some useful info on how many total outliers of the chosen metric (framewise displacement) were detected. 

```
ndel = 0 ; mask =  ; do_moco = yes ; thresh = .9 ; use_thresh = yes ; metric = fd
brainmed = 714.000000  ; maskmean = 0.345725 
Calculating outliers
Range of metric values: 0.012444 1.400310 
Found 1 outliers over .9
Generating EVs
Found spikes at  128
```


## `2_haba_bold_motion_assess_all_emotions.py`

Loops through all BOLD files available, then launches `1_submit_moco_haba.sh` to run in parallel for all of them. 