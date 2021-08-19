Into the (Bayesian) Multiverse!
===============================

As if multiverse analyses weren’t enough….

Load Packages
-------------

``` r
library(tidyverse)
```

    ## ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.0 ──

    ## ✓ ggplot2 3.3.3.9000     ✓ purrr   0.3.3     
    ## ✓ tibble  3.1.2          ✓ dplyr   1.0.3     
    ## ✓ tidyr   1.0.2          ✓ stringr 1.4.0     
    ## ✓ readr   1.3.1          ✓ forcats 0.4.0

    ## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

``` r
library(specr)
library(brms)
```

    ## Loading required package: Rcpp

    ## Loading 'brms' package (version 2.12.0). Useful instructions
    ## can be found by typing help('brms'). A more detailed introduction
    ## to the package is available through vignette('brms_overview').

    ## 
    ## Attaching package: 'brms'

    ## The following object is masked from 'package:stats':
    ## 
    ##     ar

``` r
fake_data = read_csv('../../sb_gonogo/mri_scripts/9_compile_results/simulated_amygdala_reactivity.csv')
```

    ## Parsed with column specification:
    ## cols(
    ##   ho_right_amyg_beta = col_double(),
    ##   ho_left_amyg_beta = col_double(),
    ##   ho_right_amyg_tstat = col_double(),
    ##   ho_left_amyg_tstat = col_double(),
    ##   native_right_amyg_beta = col_double(),
    ##   native_left_amyg_beta = col_double(),
    ##   native_right_amyg_tstat = col_double(),
    ##   native_left_amyg_tstat = col_double(),
    ##   id = col_double(),
    ##   age = col_double(),
    ##   motion = col_double(),
    ##   wave = col_double()
    ## )

``` r
head(fake_data)
```

    ## # A tibble: 6 x 12
    ##   ho_right_amyg_beta ho_left_amyg_beta ho_right_amyg_tstat ho_left_amyg_tstat
    ##                <dbl>             <dbl>               <dbl>              <dbl>
    ## 1             1.03               1.30                1.12              1.15  
    ## 2             1.45               1.70                1.52              1.67  
    ## 3            -0.653             -0.847              -0.498            -0.488 
    ## 4            -0.963             -1.65               -1.09             -1.75  
    ## 5            -0.0265             0.909               0.445             1.34  
    ## 6             0.332             -0.260               0.177            -0.0843
    ## # … with 8 more variables: native_right_amyg_beta <dbl>,
    ## #   native_left_amyg_beta <dbl>, native_right_amyg_tstat <dbl>,
    ## #   native_left_amyg_tstat <dbl>, id <dbl>, age <dbl>, motion <dbl>, wave <dbl>
