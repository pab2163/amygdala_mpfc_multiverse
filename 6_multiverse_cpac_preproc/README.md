# C-PAC Preprocessing & Multiverse Pipelines

## 0_run_cpac_preproc

## configs

A config file in `.yaml` format as well as a custom data config file are here, defining the C-PAC preprocessing pipeline. 


### `customPipelineSB.yaml`
This is the config file for preprocessing. There is one forked decision point -- 2 different sets of nuisance regressors. The first fork here gives a total of 18 motion regressors, plus regressors for CSF and WM. The second fork has just the 6 motion regressors

```yaml
Regressors :
 - Motion: # 18 motion
        include_delayed: true
        incldue_squared: true
        include_delayed_squared: true

   CerebrospinalFluid:
        summary: Mean
        extraction_resolution: 2
        erode_mask: true
   WhiteMatter:
        summary: Mean
        extraction_resolution: 2
        erode_mask: true

 - Motion: # Should be empty with just 6 motion regressors
```
The file header says version `1.1.0`, though version `1.4.1` was used for analysis. For more information on how specific preprocessing decisions points were set up here, see the [C-PAC Documentation](https://fcp-indi.github.io/docs/latest/user/index) 


### `dataConfigFear.yaml`

The data configuration file for the custom (non-BIDS) data structure used for this study. We treat the fear run of the data as 'rest' for preproc, even though we'll run subsequent task-based analyses on it. 

## `generate_cpac_data_config.sh`

Used to set up the custom data config file (not needed if data are in BIDS format)

## `run_cpac_1_participant.sh`

Launches a slurm job to preprocess 1 participant's data through C-PAC, built for Columbia's Habanero cluster. The job is given 8 hours and is run through the singularity image for C-PAC 1.4.1 (`fcpindi_c-pac_latest-2019-04-02-4c454af5b8ff.img`) 

## `submit_cpac_jobs.py`

Loop through all scans and submit slurm jobs to preprocess all individual scans in parallel on Columbia's Habanero Cluster. 

Includes funky wildcard syntax to label each slurm status file for output/errors with the `idx` variable representing a particular scan

```python
for idx in range(0, numScans):
	print(idx)

	jobSubmitMessage = ("sbatch -o %s_%%j.out -e %s_%%j.err runCpac1Subject.sh %s"%(idx, idx, idx))
	os.system(jobSubmitMessage)

```

## 1_run_glm_post_cpac