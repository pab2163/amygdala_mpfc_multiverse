# For accessing environment on Elvis, change .libPaths() order
paths = .libPaths()
paths = c(paths[2], paths[1])
.libPaths(paths)


library(tidyverse)
library(brms)
library(lme4)
library(broom)
library(broom.mixed)


# Load in data for 3 types of models
slopes = read.csv('compiled_data/habit_slopes_master_comps.csv', stringsAsFactors = FALSE)
halves = read.csv('compiled_data/habit_halves_master_comps.csv', stringsAsFactors = FALSE)
single_trial = read.csv('compiled_data/habit_trials_master_comps.csv', stringsAsFactors = FALSE) %>%
  mutate(., trial_factor = factor(trial))

# Tidy them
slopes_nest = slopes %>%
  tidyr::gather(., key = 'pipeline', value = 'slope', contains('slope')) %>%
  group_by(pipeline) %>%
  nest() %>%
  ungroup() %>%
  mutate(., index = 1:nrow(.))

halves_nest = halves %>%
  dplyr::select(everything(), pipeline = set) %>%
  dplyr::filter(., !is.na(reactivity)) %>%
  group_by(pipeline) %>%
  nest() %>%
  ungroup() %>%
  mutate(., index = 1:nrow(.))

single_trial_nest = single_trial %>%
  tidyr::gather(., key = 'pipeline', value = 'reactivity', contains('gsr')) %>%
  group_by(pipeline) %>%
  nest() %>%
  ungroup() %>%
  mutate(., index = 1:nrow(.))


# Make prediction grid for all models
pred_grid_slopes = expand.grid(ageCenter = seq(-7, 10, 1), 
                                      blockBin = c('first', 'notFirst'),
                                      scanner = c(1,2),
                                      motion = 0)

pred_grid_halves = expand.grid(ageCenter = seq(-7, 10, 1), 
                               blockBin = c('first', 'notFirst'),
                               scanner = c(1,2),
                               motion = 0,
                               half = c('half1', 'half2'))

pred_grid_single_trials = expand.grid(ageCenter = seq(-7, 10, 1), 
                                      blockBin = c('first', 'notFirst'),
                                      scanner = c(1,2),
                                      motion = 0,
                                      trial = 1:24)

pred_grid_single_trials_factor = expand.grid(ageCenter = seq(-7, 10, 1), 
                                      blockBin = c('first', 'notFirst'),
                                      scanner = c(1,2),
                                      motion = 0,
                                      trial_factor = as.factor(1:24))

# SLOPE LOOP --------------------------------------------------------------

# Loop through the nested data objects and run all models on each
for (ii in 1:nrow(slopes_nest)){
  if (file.exists(paste0('output/habit/slope_coefs_', ii, '.csv'))){
    print(paste0('already have run models for index ', ii))
  }else{
    slopes_nest_index = slopes_nest %>%
    dplyr::filter(index == ii) %>%
    group_by(pipeline) %>%
    mutate(.,
           modLinear = map(data, 
                           ~brm(slope ~ ageCenter + 
                                   motion + (ageCenter | Subject), 
                                 data = ., cores = 2, chains =4, family = 'student', prior = prior(gamma(4, 1), class = nu))),
           modQuadratic = map(data, 
                              ~brm(slope ~ poly(ageCenter,2, raw = TRUE) + 
                                      motion + (ageCenter | Subject), 
                                    data = ., cores = 2, chains =4, family = 'student', prior = prior(gamma(4, 1), class = nu))),
           modLinearScanner = map(data, 
                                  ~brm(slope ~ ageCenter + 
                                          motion + scanner + (ageCenter | Subject), 
                                        data = ., cores = 2, chains =4, family = 'student', prior = prior(gamma(4, 1), class = nu))),
           modLinearBlock = map(data, 
                           ~brm(slope ~ ageCenter + 
                                   motion + blockBin + (ageCenter | Subject), 
                                 data = ., cores = 2, chains =4, family = 'student', prior = prior(gamma(4, 1), class = nu))),
           modQuadraticBlockScanner = map(data, 
                                   ~brm(slope ~ poly(ageCenter,2, raw = TRUE) + 
                                           motion + blockBin + scanner + (ageCenter | Subject), 
                                         data = ., cores = 2, chains =4, family = 'student', prior = prior(gamma(4, 1), class = nu))),
           modLinearBlockScanner = map(data, 
                                ~brm(slope ~ ageCenter + 
                                        motion + blockBin + scanner + (ageCenter | Subject), 
                                      data = ., cores = 2, chains =4, family = 'student', prior = prior(gamma(4, 1), class = nu))),
           modLinearNoRandomSlopes = map(data, 
                                   ~brm(slope ~ ageCenter + 
                                           motion + (1|Subject), 
                                         data = ., cores = 2, chains =4, family = 'student', prior = prior(gamma(4, 1), class = nu)))) %>%
    tidyr::gather(key = 'model_type', value = 'model_object', contains('mod'))
    
    # pull coefficients from models
    slope_coefs = slopes_nest_index %>%
      mutate(., coefs = map(model_object, ~broom.mixed::tidy(.))) %>%
      dplyr::select(., -data, -model_object) %>%
      unnest(coefs)
    
    # Get predicitions for every point in the grid for each model (takes a little while)
    slope_model_preds = slopes_nest_index %>%
      mutate(., model_preds = map(model_object, ~fitted(., newdata = pred_grid_slopes, re_formula = NA) %>% 
                                    cbind(pred_grid_slopes, .))) %>%
      dplyr::select(-data, -model_object) 
    
    # unnest predictions
    slope_model_preds_unnest = slope_model_preds %>%
      unnest(model_preds)
    
    # Save results for that index to csv
    write.csv(slope_coefs, file = paste0('output/habit/slope_coefs_', ii, '.csv'), row.names = FALSE)
    write.csv(slope_model_preds_unnest, file = paste0('output/habit/slope_model_preds_', ii, '.csv'), row.names = FALSE)
    
    rm(slopes_nest_index)
    gc()
  }
}



# HALVES LOOP -------------------------------------------------------------

# Loop through the nested data objects and run all models on each
for (ii in 1:nrow(halves_nest)){
  if (file.exists(paste0('output/habit/halves_coefs_', ii, '.csv'))){
    print(paste0('already have run models for index ', ii))
  }else{
    halves_nest_index = halves_nest %>%
      dplyr::filter(index == ii) %>%
      group_by(pipeline) %>%
      mutate(.,
             modLinear_r = map(data, 
                             ~brm(reactivity ~ ageCenter*half + 
                                    motion + (ageCenter|Subject) + (half | name), 
                                  data = ., cores = 2, chains =4, family = 'student', prior = prior(gamma(4, 1), class = nu))),
             modQuadratic_r = map(data, 
                                ~brm(reactivity ~ poly(ageCenter,2, raw = TRUE)*half + 
                                       motion + (ageCenter|Subject) + (half | name), 
                                     data = ., cores = 2, chains =4, family = 'student', prior = prior(gamma(4, 1), class = nu))),
             modLinearScanner_r = map(data, 
                                    ~brm(reactivity ~ ageCenter*half + 
                                           motion + scanner + (ageCenter|Subject) + (half | name), 
                                         data = ., cores = 2, chains =4, family = 'student', prior = prior(gamma(4, 1), class = nu))),
             modLinearBlock_r = map(data, 
                                  ~brm(reactivity ~ ageCenter*half + 
                                         motion + blockBin + (ageCenter|Subject) + (half | name), 
                                       data = ., cores = 2, chains =4, family = 'student', prior = prior(gamma(4, 1), class = nu))),
             modQuadraticBlockScanner_r = map(data, 
                                            ~brm(reactivity ~ poly(ageCenter,2, raw = TRUE)*half + 
                                                   motion + blockBin + scanner + (ageCenter|Subject) + (half | name), 
                                                 data = ., cores = 2, chains =4, family = 'student', prior = prior(gamma(4, 1), class = nu))),
             modLinearBlockScanner_r = map(data, 
                                         ~brm(reactivity ~ ageCenter*half + 
                                                motion + blockBin + scanner + (ageCenter|Subject) + (half | name), 
                                              data = ., cores = 2, chains =4, family = 'student', prior = prior(gamma(4, 1), class = nu))),
             modLinear = map(data, 
                             ~brm(reactivity ~ ageCenter*half + 
                                  motion + (ageCenter | Subject), 
                                  data = ., cores = 2, chains =4, family = 'student', prior = prior(gamma(4, 1), class = nu))),
             modQuadratic = map(data, 
                                ~brm(reactivity ~ poly(ageCenter,2, raw = TRUE)*half + 
                                       motion + (ageCenter | Subject), 
                                     data = ., cores = 2, chains =4, family = 'student', prior = prior(gamma(4, 1), class = nu))),
             modLinearScanner = map(data, 
                                    ~brm(reactivity ~ ageCenter*half + 
                                         motion + scanner + (ageCenter | Subject), 
                                         data = ., cores = 2, chains =4, family = 'student', prior = prior(gamma(4, 1), class = nu))),
             modLinearBlock = map(data, 
                                  ~brm(reactivity ~ ageCenter*half + 
                                       motion + blockBin + (ageCenter | Subject), 
                                       data = ., cores = 2, chains =4, family = 'student', prior = prior(gamma(4, 1), class = nu))),
             modQuadraticBlockScanner = map(data, 
                                            ~brm(reactivity ~ poly(ageCenter,2, raw = TRUE)*half + 
                                                   motion + blockBin + scanner + (ageCenter | Subject), 
                                                 data = ., cores = 2, chains =4, family = 'student', prior = prior(gamma(4, 1), class = nu))),
             modLinearBlockScanner = map(data, 
                                         ~brm(reactivity ~ ageCenter*half + 
                                              motion + blockBin + scanner + (ageCenter | Subject), 
                                              data = ., cores = 2, chains =4, family = 'student', prior = prior(gamma(4, 1), class = nu))),
             modLinearNoRandom = map(data, 
                                           ~brm(reactivity ~ ageCenter*half + 
                                                motion + (1|Subject), 
                                                data = ., cores = 2, chains =4, family = 'student', prior = prior(gamma(4, 1), class = nu)))) %>%
      tidyr::gather(key = 'model_type', value = 'model_object', contains('mod'))
    
    # pull coefficients from models
    halves_coefs = halves_nest_index %>%
      mutate(., coefs = map(model_object, ~broom.mixed::tidy(.))) %>%
      dplyr::select(., -data, -model_object) %>%
      unnest(coefs)
    
    # Get predicitions for every point in the grid for each model (takes a little while)
    halves_model_preds = halves_nest_index %>%
      mutate(., model_preds = map(model_object, ~fitted(., newdata = pred_grid_halves, re_formula = NA) %>% 
                                    cbind(pred_grid_halves, .))) %>%
      dplyr::select(-data, -model_object) 
    
    # unnest predictions
    halves_model_preds_unnest = halves_model_preds %>%
      unnest(model_preds)
    
    # Save results for that index to csv
    write.csv(halves_coefs, file = paste0('output/habit/halves_coefs_', ii, '.csv'), row.names = FALSE)
    write.csv(halves_model_preds_unnest, file = paste0('output/habit/halves_model_preds_', ii, '.csv'), row.names = FALSE)
  }
}




# SINGLE TRIAL LOOP -------------------------------------------------------

# Loop through the nested data objects and run all models on each
for (ii in 1:nrow(single_trial_nest)){
  if (file.exists(paste0('output/habit/single_trial_coefs_', ii, '.csv'))){
    print(paste0('already have run models for index ', ii))
  }else{
    single_trial_nest_index = single_trial_nest %>%
      dplyr::filter(index == ii) %>%
      group_by(pipeline) %>%
      mutate(.,
             modLinear = map(data, 
                             ~brm(reactivity ~ ageCenter*trial + 
                                    motion + (ageCenter | Subject) + (trial | name), 
                                  data = ., cores = 2, chains =4, family = 'student', prior = prior(gamma(4, 1), class = nu))),
             modQuadratic = map(data, 
                                ~brm(reactivity ~ poly(ageCenter,2, raw = TRUE)*trial + 
                                       motion + (ageCenter | Subject) + (trial | name), 
                                     data = ., cores = 2, chains =4, family = 'student', prior = prior(gamma(4, 1), class = nu))),
             modLinearScanner = map(data, 
                                    ~brm(reactivity ~ ageCenter*trial + 
                                           motion + scanner + (ageCenter | Subject) + (trial | name), 
                                         data = ., cores = 2, chains =4, family = 'student', prior = prior(gamma(4, 1), class = nu))),
             modLinearBlock = map(data, 
                                  ~brm(reactivity ~ ageCenter*trial + 
                                         motion + blockBin + (ageCenter | Subject) + (trial | name), 
                                       data = ., cores = 2, chains =4, family = 'student', prior = prior(gamma(4, 1), class = nu))),
             modQuadraticBlockScanner = map(data, 
                                            ~brm(reactivity ~ poly(ageCenter,2, raw = TRUE)*trial + 
                                                   motion + blockBin + scanner + (ageCenter | Subject) + (trial | name), 
                                                 data = ., cores = 2, chains =4, family = 'student', prior = prior(gamma(4, 1), class = nu))),
             modLinearBlockScanner = map(data, 
                                         ~brm(reactivity ~ ageCenter*trial + 
                                                motion + blockBin + scanner + (ageCenter | Subject) + (trial | name), 
                                              data = ., cores = 2, chains =4, family = 'student', prior = prior(gamma(4, 1), class = nu)))) %>%
      tidyr::gather(key = 'model_type', value = 'model_object', contains('mod'))
    
    # pull coefficients from models
    single_trial_coefs = single_trial_nest_index %>%
      mutate(., coefs = map(model_object, ~broom.mixed::tidy(.))) %>%
      dplyr::select(., -data, -model_object) %>%
      unnest(coefs)
    
    # Get predicitions for every point in the grid for each model (takes a little while)
    single_trial_model_preds = single_trial_nest_index %>%
      mutate(., model_preds = map(model_object, ~fitted(., newdata = pred_grid_single_trials, re_formula = NA) %>% 
                                    cbind(pred_grid_single_trials, .))) %>%
      dplyr::select(-data, -model_object) 
    
    # unnest predictions
    single_trial_model_preds_unnest = single_trial_model_preds %>%
      unnest(model_preds)
    
    # Save results for that index to csv
    write.csv(single_trial_coefs, file = paste0('output/habit/single_trial_coefs_', ii, '.csv'), row.names = FALSE)
    write.csv(single_trial_model_preds_unnest, file = paste0('output/habit/single_trial_model_preds_', ii, '.csv'), row.names = FALSE)
  }
}



# SINGLE TRIAL FACTOR MODEL LOOP -------------------------------------------------------

# Loop through the nested data objects and run all models on each
for (ii in 1:nrow(single_trial_nest)){
  if (file.exists(paste0('output/habit/single_trial_coefs_factor_', ii, '.csv'))){
    print(paste0('already have run models for index ', ii))
  }else{
    single_trial_nest_index = single_trial_nest %>%
      dplyr::filter(index == ii) %>%
      group_by(pipeline) %>%
      mutate(.,
             modLinear = map(data, 
                             ~brm(reactivity ~ ageCenter*trial_factor + 
                                    motion + (ageCenter | Subject) + (1 | name), 
                                  data = ., cores = 2, chains =4, family = 'student', prior = prior(gamma(4, 1), class = nu))),
             modQuadratic = map(data, 
                                ~brm(reactivity ~ poly(ageCenter,2, raw = TRUE)*trial_factor + 
                                       motion + (ageCenter | Subject) + (1 | name), 
                                     data = ., cores = 2, chains =4, family = 'student', prior = prior(gamma(4, 1), class = nu))),
             modLinearScanner = map(data, 
                                    ~brm(reactivity ~ ageCenter*trial_factor + 
                                           motion + scanner + (ageCenter | Subject) + (1 | name), 
                                         data = ., cores = 2, chains =4, family = 'student', prior = prior(gamma(4, 1), class = nu))),
             modLinearBlock = map(data, 
                                  ~brm(reactivity ~ ageCenter*trial_factor + 
                                         motion + blockBin + (ageCenter | Subject) + (1 | name), 
                                       data = ., cores = 2, chains =4, family = 'student', prior = prior(gamma(4, 1), class = nu))),
             modQuadraticBlockScanner = map(data, 
                                            ~brm(reactivity ~ poly(ageCenter,2, raw = TRUE)*trial_factor + 
                                                   motion + blockBin + scanner + (ageCenter | Subject) + (1 | name), 
                                                 data = ., cores = 2, chains =4, family = 'student', prior = prior(gamma(4, 1), class = nu))),
             modLinearBlockScanner = map(data, 
                                         ~brm(reactivity ~ ageCenter*trial_factor + 
                                                motion + blockBin + scanner + (ageCenter | Subject) + (1 | name), 
                                              data = ., cores = 2, chains =4, family = 'student', prior = prior(gamma(4, 1), class = nu)))) %>%
      tidyr::gather(key = 'model_type', value = 'model_object', contains('mod'))
    
    # pull coefficients from models
    single_trial_coefs = single_trial_nest_index %>%
      mutate(., coefs = map(model_object, ~broom.mixed::tidy(.))) %>%
      dplyr::select(., -data, -model_object) %>%
      unnest(coefs)
    
    # Get predicitions for every point in the grid for each model (takes a little while)
    single_trial_model_preds = single_trial_nest_index %>%
      mutate(., model_preds = map(model_object, ~fitted(., newdata = pred_grid_single_trials_factor, re_formula = NA) %>% 
                                    cbind(pred_grid_single_trials_factor, .))) %>%
      dplyr::select(-data, -model_object) 
    
    # unnest predictions
    single_trial_model_preds_unnest = single_trial_model_preds %>%
      unnest(model_preds)
    
    # Save results for that index to csv
    write.csv(single_trial_coefs, file = paste0('output/habit/single_trial_coefs_factor_', ii, '.csv'), row.names = FALSE)
    write.csv(single_trial_model_preds_unnest, file = paste0('output/habit/single_trial_model_factor_preds_', ii, '.csv'), row.names = FALSE)
  }
}




