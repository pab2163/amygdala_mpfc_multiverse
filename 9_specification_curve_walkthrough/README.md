# What's in here?

## `simulated_amygdala_reactivity.csv`

Simulated data in the structure of the actual data used in the study. 

Here's what is in each column:

* `id` - participant ID, identifies a participant across time points
* `wave` - the study time point (either `1`, `2`, or `3`)
* `age` - participant age at the given time point, in years
* `block` - the temporal position of the task run relative to other tasks in the scanner (`1` = first, `2` = second, `3` = third)
* `motion` - head motion (mean framewise displacement), which has been z-scored here
* `scanner` - whether the data were collected on a first MRI scanner (`1`= time points 1 & 2) or a second (`2` = time point 3). Both were Siemens Tim Trio
* `prev_studied`- whether this scan was previously analyzed in similar work by [Gee et al (2013)](https://www.jneurosci.org/content/33/10/4584). `1` indicates a scan was previously studied

All of the rest of the columns are measurements of amygdala reactivity to fear faces > baseline for each scan, labeled such that:

* columns with the `ho` prefix are from amygdala ROIs defined by the Harvard-Oxford subcortical atlas, `native` prefix columns are in native space defined through Freesurfer
* columns with the `right` prefix are the right amygdala, and `left` are the left
* columns with the `beta` prefix denote raw beta estimates of amygdala reactivity magnitude, while the `tstat` prefix denote t-statistic measurements of amygdala reactivity scaled by estimation uncertainty (the standard error)

## `into_the_bayesian_multiverse.Rmd`

Code and walkthrough for running (Bayesian) specification curve analyses using the simulated data!
