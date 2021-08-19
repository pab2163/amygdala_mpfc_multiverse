# For accessing environment on Elvis, change .libPaths() order
paths = .libPaths()
paths = c(paths[2], paths[1])
.libPaths(paths)

library(tidyverse)
library(brms)
library(lme4)
library(broom)
library(broom.mixed)


# reactivity fear
reactivity_fear = read.csv('compiled_data/comps_amyg_fear_reactivity_master.csv', stringsAsFactors = FALSE) %>%
  dplyr::select(name, Subject, wave, Block, ageCenter, Age, meanAge, prev_studied, motion, scanner, blockBin,
                fear_reactivity_native = og_native_amyg_bilateral_tstat, 
                fear_reactivity_ho = og_ho_amyg_bilateral_tstat,) 
# reactivity neutral
reactivity_neutral = read.csv('compiled_data/comps_amyg_neut_reactivity_master.csv', stringsAsFactors = FALSE) %>%
  dplyr::select(name, neut_reactivity_native = og_native_amyg_bilateral_tstat, 
                neut_reactivity_ho = og_ho_amyg_bilateral_tstat) 

# reactivity fear > neutral
reactivity_fear_minus_neutral = read.csv('compiled_data/comps_amyg_fear_minus_neut_reactivity_master.csv', stringsAsFactors = FALSE)%>%
  dplyr::select(name, fear_minus_neut_reactivity_native = og_native_amyg_bilateral_tstat, 
                fear_minus_neut_reactivity_ho = og_ho_amyg_bilateral_tstat) 

# ppi
ppi = read.csv('compiled_data/comps_amyg_all_contrasts_ppi_master.csv', stringsAsFactors = FALSE) %>%
  dplyr::select(name, contains('vmpfc'), -contains('beta'))

# bsc
bsc = read.csv('compiled_data/comps_amyg_all_contrasts_bsc_master.csv', stringsAsFactors = FALSE) %>%
  dplyr::select(name, contains('vmpfc'), -contains('beta'), -contains('left'), -contains('right')) %>%
  mutate_if(is.numeric, scale, center = FALSE)

# compile all metrics
brain_metrics = reactivity_fear %>%
  left_join(., reactivity_neutral, by = 'name') %>%
  left_join(., reactivity_fear_minus_neutral, by = 'name') %>%
  left_join(., ppi, by = 'name') %>%
  left_join(., bsc, by = 'name') 


# make lists of reactivity variables and outcome variables
reactivity_vars = names(brain_metrics)[grepl('reactivity', names(brain_metrics))]
outcome_vars = names(brain_metrics)[grepl('gsr', names(brain_metrics)) | grepl('deconv', names(brain_metrics))]


reactivity_connectivity_model = function(reactivity_ind, outcome_ind, interaction){
  # define model formula
  if (interaction == TRUE){
    formula = as.formula(paste0(outcome_vars[outcome_ind], "~", reactivity_vars[reactivity_ind], 
                                '*ageCenter + motion + ', '(', reactivity_vars[reactivity_ind],
                                '+ ageCenter|Subject)'))
  }else{
    formula = as.formula(paste0(outcome_vars[outcome_ind], "~", reactivity_vars[reactivity_ind], 
                                ' + ageCenter + motion + ', '(', reactivity_vars[reactivity_ind],
                                '+ ageCenter|Subject)'))
  }
  # fit the model
  fit_model = brm(data = brain_metrics, formula = formula, chains = 4, cores = 4, family = 'student', prior = prior(gamma(4, 1), class = nu))
  
  # pull the coefficients into a data frame, label dataframe with outcome and predictor variables
  coefs = broom.mixed::tidy(fit_model)
  coefs$outcome = outcome_vars[outcome_ind]
  coefs$predictor = reactivity_vars[reactivity_ind]
  
  # make predictions for 3 different ages across the range of reactivity values (standardized)
  pred_grid = expand.grid(ageCenter = c(-4, 0, 4), motion = 0,  predictor = seq(from = -2.5, to =2.5, by = .5))
  names(pred_grid)[3] = reactivity_vars[reactivity_ind]
  pred_grid$outcome = outcome_vars[outcome_ind]
  pred_grid$predictor = reactivity_vars[reactivity_ind]
  model_predictions = fitted(fit_model, newdata=pred_grid, re_formula = NA) %>% cbind(pred_grid, .)
  # change prediction column name back to 'reactivity' so prediction column has the same name across models
  names(model_predictions)[3] = 'reactivity'
  
  # remove model object from memory, run garbage collector just in case
  rm(fit_model)
  gc()
  return(list('model_coefs' = coefs, 'model_predictions' = model_predictions))

}

# loop through outcomes and predictor combinations and model each, saving model predictions and coefficients (6 reactivity predictors X 12 connectivity outcomes)
for (i in 1:6){
  for (j in 1:12){
    print(i, j)
    model_outputs = reactivity_connectivity_model(reactivity_ind = i, outcome_ind = j, interaction = FALSE)
    if (i== 1 & j ==1){
      coefs_multiverse = model_outputs$model_coefs
      preds_multiverse = model_outputs$model_predictions
    }else{
      coefs_multiverse = plyr::rbind.fill(coefs_multiverse, model_outputs$model_coefs)
      preds_multiverse = plyr::rbind.fill(preds_multiverse, model_outputs$model_predictions)
    }
  }
}


# write out results
write.csv(coefs_multiverse, file = 'output/multi_metric/reactivity_connectivity_coefs.csv', row.names = FALSE)
write.csv(preds_multiverse, file = 'output/multi_metric/reactivity_connectivity_preds.csv', row.names = FALSE)


for (i in 1:6){
  for (j in 1:12){
    print(i, j)
    model_outputs = reactivity_connectivity_model(reactivity_ind = i, outcome_ind = j, interaction = TRUE)
    if (i== 1 & j ==1){
      coefs_multiverse = model_outputs$model_coefs
      preds_multiverse = model_outputs$model_predictions
    }else{
      coefs_multiverse = plyr::rbind.fill(coefs_multiverse, model_outputs$model_coefs)
      preds_multiverse = plyr::rbind.fill(preds_multiverse, model_outputs$model_predictions)
    }
  }
}


# write out results
write.csv(coefs_multiverse, file = 'output/multi_metric/reactivity_connectivity_coefs_interaction.csv', row.names = FALSE)
write.csv(preds_multiverse, file = 'output/multi_metric/reactivity_connectivity_preds_interaction.csv', row.names = FALSE)
