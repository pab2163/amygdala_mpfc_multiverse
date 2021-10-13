# Group-level analses

There is a *lot* of code in the subfolders here! While the below documentation describes where to find different pieces, for demonstration purposes we have provided simulated data & code that can be run with it that accomplishes many of the sama analyses [here](https://pab2163.github.io/amygdala_mpfc_multiverse/into_the_bayesian_multiverse.html.)

Some documentation on how code is organized here:

## `0_compile_data`

Scripts for compiling data into tabular form, ready to run many group-level models. 

## `1_run_multiverse_group_level_models`

Scripts that run hundreds/thousands of `brms` group-level models for amygdala reactivity, amygdala-mPFC functional connectivity, and associations with separation anxiety behaviors. Note: code similar to this  that can be run with simulated data can be found [here](https://pab2163.github.io/amygdala_mpfc_multiverse/into_the_bayesian_multiverse.html).

## `2_make_plots_inspect_models`

Scripts that compile multiverse model output results, pull statistics, and plot specification curves (and other visualizations based on the model specifications).Note: code with very similar function that can be run with simulated data can be found [here](https://pab2163.github.io/amygdala_mpfc_multiverse/into_the_bayesian_multiverse.html).

## `3_simulate_amygdala_reactivity`

Use a multivariate Bayesian regression model to simulate fake data in the structure and sharing many of the properties of the real amygdala reactivity data for 8 different example amygdala reactivity outcomes. Add noise to ages and re-label/shuffle subids for extra deidentification. 