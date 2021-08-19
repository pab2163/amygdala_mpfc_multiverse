# For accessing environment on Elvis, change .libPaths() order
paths = .libPaths()
paths = c(paths[2], paths[1])
.libPaths(paths)

library(tidyverse)
library(brms)
library(lme4)
library(broom)
library(broom.mixed)


sep_anxiety_brain_frame = read.csv('compiled_data/all_brain_sep_anx_comps.csv', stringsAsFactors = FALSE) %>%
  mutate(rcads_t = rcads_t/sd(rcads_t, na.rm = TRUE),
         rcads_raw = rcads_raw/sd(rcads_raw, na.rm = TRUE),
         scaredSepAnx = scaredSepAnx/sd(scaredSepAnx, na.rm =TRUE))

# make lists of reactivity variables and outcome variables
anx_vars = c('rcads_raw', 'rcads_t', 'scaredSepAnx')
brain_vars = names(sep_anxiety_brain_frame)[grepl('gsr', names(sep_anxiety_brain_frame)) | 
                                      grepl('deconv', names(sep_anxiety_brain_frame)) |
                                      grepl('reactivity', names(sep_anxiety_brain_frame))]


# function to run 1 model at at time for 3 anxiety oucomes * 22 brain metrics
brain_anx_model = function(anxiety_ind, brain_ind, interaction){
  # define model formula
  if (interaction == TRUE){
    formula = as.formula(paste0(anx_vars[anxiety_ind], "~", brain_vars[brain_ind], 
                                '*ageCenter + motion + ', '(', brain_vars[brain_ind],
                                '+ ageCenter|Subject)'))
  }else{
    formula = as.formula(paste0(anx_vars[anxiety_ind], "~", brain_vars[brain_ind], 
                                '+ ageCenter + motion + ', '(', brain_vars[brain_ind],
                                '+ ageCenter|Subject)'))
  }
  # fit the model
  fit_model = brm(data = sep_anxiety_brain_frame, formula = formula, chains = 4, cores = 4, 
                  family = 'student', prior = prior(gamma(4, 1), class = nu))
  
  # pull the coefficients into a data frame, label dataframe with outcome and predictor variables
  coefs = broom.mixed::tidy(fit_model)
  coefs$outcome = anx_vars[anxiety_ind]
  coefs$predictor = brain_vars[brain_ind]
  
  # make predictions for 3 different ages across the range of brain values (standardized)
  pred_grid = expand.grid(ageCenter = c(-4, 0, 4), motion = 0,  predictor = seq(from = -2.5, to =2.5, by = .5))
  names(pred_grid)[3] = brain_vars[brain_ind]
  pred_grid$outcome = anx_vars[anxiety_ind]
  pred_grid$predictor = brain_vars[brain_ind]
  model_predictions = fitted(fit_model, newdata=pred_grid, re_formula = NA) %>% cbind(pred_grid, .)
  # change prediction column name back to 'brain' so prediction column has the same name across models
  names(model_predictions)[3] = 'brain'
  
  # remove model object from memory, run garbage collector just in case
  rm(fit_model)
  gc()
  return(list('model_coefs' = coefs, 'model_predictions' = model_predictions))
}


# No interactions ---------------------------------------------------------

# loop through outcomes and predictor combinations and model each, saving model predictions and coefficients (6 reactivity predictors X 12 connectivity outcomes)
for (i in 1:length(anx_vars)){
  for (j in 1:length(brain_vars)){
    model_outputs = brain_anx_model(anxiety_ind = i, brain_ind = j, interaction = FALSE)
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
write.csv(coefs_multiverse, file = 'output/multi_metric/brain_anxiety_coefs.csv', row.names = FALSE)
write.csv(preds_multiverse, file = 'output/multi_metric/brain_anxiety_preds.csv', row.names = FALSE)



# Rerun with interaction models -------------------------------------------
for (i in 1:length(anx_vars)){
  for (j in 1:length(brain_vars)){
    model_outputs = brain_anx_model(anxiety_ind = i, brain_ind = j, interaction = TRUE)
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
write.csv(coefs_multiverse, file = 'output/multi_metric/brain_anxiety_coefs_interaction.csv', row.names = FALSE)
write.csv(preds_multiverse, file = 'output/multi_metric/brain_anxiety_preds_interaction.csv', row.names = FALSE)
