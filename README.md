# Age-related change in task-evoked amygdala-prefrontal circuitry: a multiverse approach with an accelerated longitudinal cohort aged 4-22 years

Analysis scripts and documentation for this project, and README files within each sub-directory give more detailed information on how each step was carried out (and where to find the code). 

## Links:

* [Preprint Manuscript](osf.io)
* [Multiverse analysis tutorial + walkthrough](https://pab2163.github.io/amygdala_mpfc_multiverse/into_the_bayesian_multiverse.html)
* [Interactive multiverse explorer app](https://pbloom.shinyapps.io/amygdala_mpfc_multiverse/)
* [Materials & preregistration on Open Science Framework](https://osf.io/hvdmx/)
* [Developmental Affective Neurocience Lab (Tottenham Lab)](https://danlab.psychology.columbia.edu/)

## Repository table of contents:

| Sub-directory      | Contents |
| ----------- | ----------- |
| [0_setup_and_behavioral_analyses](0_setup_and_behavioral_analyses/)      | Compiling behavioral files collected in the scanner, making onset timing files, task behavior analyses       |
| 1_head_motion   | In-scanner head motion assessment        |
| 2_prereg_level1      | Pre-registered FSL preprocessing pipeline      |
| 3_pull_prereg_roi  | Get amygdala reactivity estimates (native & MNI space) for preregistered pipelin  |
| 4_gppi     | Run generalized psychophysiological interaction models for task-based amygdala functional connectivity       |
| 5_beta_series_correlation  | Run beta series correlations for task-based amygdala functional connectivity         |
| 6_multiverse_cpac_preproc      | Run forked C-PAC preprocessing and FSL/AFNI GLM models to create proc multiverse       |
| 7_group_level_aanalyses  | Run all group-level analyses involving the fMRI data to make specification curves      |
| 8_interactive_multiverse_app      | Code for shiny application       |
| 9_specification_curve_walkthrough  | Markdown files for spec curve tutorial & simulated amygdala reactivity dataset |


Analysis code written by Paul A. Bloom

## Questions? 

Email *paul.bloom@columbia.edu*
