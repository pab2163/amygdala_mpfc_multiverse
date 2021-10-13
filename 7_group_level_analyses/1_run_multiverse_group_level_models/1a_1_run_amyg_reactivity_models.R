# For accessing environment on Elvis, change .libPaths() order
paths = .libPaths()
paths = c(paths[2], paths[1])
.libPaths(paths)

library(tidyverse)
library(brms)
library(lme4)
library(broom)
library(broom.mixed)



# Fear > Baseline --------------------------------------------------------------------
# Load in data
amyg = read.csv('compiled_data/comps_amyg_fear_reactivity_master.csv', stringsAsFactors = FALSE) %>%
  dplyr::filter(censoredTR <= 40)

# Tidy it
amyg_long = amyg %>%
  tidyr::gather(., key = 'pipeline', value = 'reactivity', contains('amyg'),contains('Amyg'))


# Nest and set indices
reactivity_model_frame = amyg_long %>%
  group_by(pipeline) %>%
  nest() %>%
  ungroup() %>%
  mutate(., index = 1:nrow(.))

# Make prediction grid for all models
predGridBlockBinScanner = expand.grid(ageCenter = seq(-7, 10, 1), 
                                      blockBin = c('first', 'notFirst'),
                                      scanner = c(1,2),
                                      motion = 0)


# Loop through the nested data objects and run all models on each
for (ii in 1:nrow(reactivity_model_frame)){
  if (file.exists(paste0('output/reactivity/reactivity_coefs_', ii, '.csv'))){
    print(paste0('already have run models for index ', ii))
  }else{
    reactivity_model_frame_index = reactivity_model_frame %>%
    dplyr::filter(index == ii) %>%
    group_by(pipeline) %>%
    mutate(.,
           modLinear = map(data, 
                           ~brm(reactivity ~ ageCenter + 
                                   motion + (ageCenter|Subject), 
                                 data = ., cores = 2, chains = 4)),
           modLinearExclude = map(data, 
                           ~brm(reactivity ~ ageCenter + 
                                  motion + (ageCenter|Subject), 
                                data = dplyr::filter(., is.na(prev_studied)), cores = 2, chains = 4)),
           modQuadraticExclude = map(data, 
                                  ~brm(reactivity ~ poly(ageCenter,2, raw = TRUE) + 
                                         motion + (ageCenter|Subject), 
                                       data = dplyr::filter(., is.na(prev_studied)), cores = 2, chains = 4)),
           modQuadratic = map(data, 
                              ~brm(reactivity ~ poly(ageCenter,2, raw = TRUE) + 
                                      motion + (ageCenter|Subject), 
                                    data = ., cores = 2, chains = 4)),
           modLinearScanner = map(data, 
                                  ~brm(reactivity ~ ageCenter + 
                                          motion + scanner + (ageCenter|Subject), 
                                        data = ., cores = 2, chains = 4)),
           modLinearBlock = map(data, 
                           ~brm(reactivity ~ ageCenter + 
                                   motion + blockBin + (ageCenter|Subject), 
                                 data = ., cores = 2, chains = 4)),
           modQuadraticBlockScanner = map(data, 
                                   ~brm(reactivity ~ poly(ageCenter,2, raw = TRUE) + 
                                           motion + blockBin + scanner + (ageCenter|Subject), 
                                         data = ., cores = 2, chains = 4)),
           modLinearBlockScanner = map(data, 
                                ~brm(reactivity ~ ageCenter + 
                                        motion + blockBin + scanner + (ageCenter|Subject), 
                                      data = ., cores = 2, chains = 4)),
           modLinearNoRandomSlopes = map(data, 
                                   ~brm(reactivity ~ ageCenter + 
                                           motion + (1|Subject), 
                                         data = ., cores = 2, chains = 4))) %>%
    tidyr::gather(key = 'model_type', value = 'model_object', contains('mod'))
    
    # pull coefficients from models
    reactivity_coefs = reactivity_model_frame_index %>%
      mutate(., coefs = map(model_object, ~broom.mixed::tidy(.))) %>%
      dplyr::select(., -data, -model_object) %>%
      unnest(coefs)
    
    # Get predicitions for every point in the grid for each model (takes a little while)
    reactivity_model_preds = reactivity_model_frame_index %>%
      mutate(., model_preds = map(model_object, ~fitted(., newdata = predGridBlockBinScanner, re_formula = NA) %>% 
                                    cbind(predGridBlockBinScanner, .))) %>%
      dplyr::select(-data, -model_object) 
    
    # unnest predictions
    reactivity_model_preds_unnest = reactivity_model_preds %>%
      unnest(model_preds)
    
    # Save results for that index to csv
    write.csv(reactivity_coefs, file = paste0('output/reactivity/reactivity_coefs_', ii, '.csv'), row.names = FALSE)
    write.csv(reactivity_model_preds_unnest, file = paste0('output/reactivity/reactivity_model_preds_', ii, '.csv'), row.names = FALSE)
    
    rm(reactivity_model_frame_index)
    gc()
  }
}


#  Neutral > Baseline -----------------------------------------------------
# clear environment just in case
remove(list = ls())
# Load in data
amyg = read.csv('compiled_data/comps_amyg_neut_reactivity_master.csv', stringsAsFactors = FALSE) %>%
  dplyr::filter(censoredTR <= 40)

# Tidy it
amyg_long = amyg %>%
  tidyr::gather(., key = 'pipeline', value = 'reactivity', contains('amyg'),contains('Amyg'))


# Nest and set indices
reactivity_model_frame = amyg_long %>%
  group_by(pipeline) %>%
  nest() %>%
  ungroup() %>%
  mutate(., index = 1:nrow(.))

# Make prediction grid for all models
predGridBlockBinScanner = expand.grid(ageCenter = seq(-7, 10, 1), 
                                      blockBin = c('first', 'notFirst'),
                                      scanner = c(1,2),
                                      motion = 0)


# Loop through the nested data objects and run all models on each
for (ii in 1:nrow(reactivity_model_frame)){
  if (file.exists(paste0('output/reactivity/reactivity_coefs_neutral_', ii, '.csv'))){
    print(paste0('already have run models for index ', ii))
  }else{
    reactivity_model_frame_index = reactivity_model_frame %>%
      dplyr::filter(index == ii) %>%
      group_by(pipeline) %>%
      mutate(.,
             modLinear = map(data, 
                             ~brm(reactivity ~ ageCenter + 
                                    motion + (ageCenter|Subject), 
                                  data = ., cores = 2, chains = 4)),
             modLinearExclude = map(data, 
                                    ~brm(reactivity ~ ageCenter + 
                                           motion + (ageCenter|Subject), 
                                         data = dplyr::filter(., is.na(prev_studied)), cores = 2, chains = 4)),
             modQuadraticExclude = map(data, 
                                       ~brm(reactivity ~ poly(ageCenter,2, raw = TRUE) + 
                                              motion + (ageCenter|Subject), 
                                            data = dplyr::filter(., is.na(prev_studied)), cores = 2, chains = 4)),
             modQuadratic = map(data, 
                                ~brm(reactivity ~ poly(ageCenter,2, raw = TRUE) + 
                                       motion + (ageCenter|Subject), 
                                     data = ., cores = 2, chains = 4)),
             modLinearScanner = map(data, 
                                    ~brm(reactivity ~ ageCenter + 
                                           motion + scanner + (ageCenter|Subject), 
                                         data = ., cores = 2, chains = 4)),
             modLinearBlock = map(data, 
                                  ~brm(reactivity ~ ageCenter + 
                                         motion + blockBin + (ageCenter|Subject), 
                                       data = ., cores = 2, chains = 4)),
             modQuadraticBlockScanner = map(data, 
                                            ~brm(reactivity ~ poly(ageCenter,2, raw = TRUE) + 
                                                   motion + blockBin + scanner + (ageCenter|Subject), 
                                                 data = ., cores = 2, chains = 4)),
             modLinearBlockScanner = map(data, 
                                         ~brm(reactivity ~ ageCenter + 
                                                motion + blockBin + scanner + (ageCenter|Subject), 
                                              data = ., cores = 2, chains = 4)),
             modLinearNoRandomSlopes = map(data, 
                                           ~brm(reactivity ~ ageCenter + 
                                                  motion + (1|Subject), 
                                                data = ., cores = 2, chains = 4))) %>%
      tidyr::gather(key = 'model_type', value = 'model_object', contains('mod'))
    
    # pull coefficients from models
    reactivity_coefs = reactivity_model_frame_index %>%
      mutate(., coefs = map(model_object, ~broom.mixed::tidy(.))) %>%
      dplyr::select(., -data, -model_object) %>%
      unnest(coefs)
    
    # Get predicitions for every point in the grid for each model (takes a little while)
    reactivity_model_preds = reactivity_model_frame_index %>%
      mutate(., model_preds = map(model_object, ~fitted(., newdata = predGridBlockBinScanner, re_formula = NA) %>% 
                                    cbind(predGridBlockBinScanner, .))) %>%
      dplyr::select(-data, -model_object) 
    
    # unnest predictions
    reactivity_model_preds_unnest = reactivity_model_preds %>%
      unnest(model_preds)
    
    # Save results for that index to csv
    write.csv(reactivity_coefs, file = paste0('output/reactivity/reactivity_coefs_neutral_', ii, '.csv'), row.names = FALSE)
    write.csv(reactivity_model_preds_unnest, file = paste0('output/reactivity/reactivity_model_preds_neutral_', ii, '.csv'), row.names = FALSE)
  }
}
# Fear > Neutral ----------------------------------------------------------

# clear environment just in case
remove(list = ls())
# Load in data
amyg = read.csv('compiled_data/comps_amyg_fear_minus_neut_reactivity_master.csv', stringsAsFactors = FALSE) %>%
  dplyr::filter(censoredTR <= 40)

# Tidy it
amyg_long = amyg %>%
  tidyr::gather(., key = 'pipeline', value = 'reactivity', contains('amyg'),contains('Amyg'))


# Nest and set indices
reactivity_model_frame = amyg_long %>%
  group_by(pipeline) %>%
  nest() %>%
  ungroup() %>%
  mutate(., index = 1:nrow(.))

# Make prediction grid for all models
predGridBlockBinScanner = expand.grid(ageCenter = seq(-7, 10, 1), 
                                      blockBin = c('first', 'notFirst'),
                                      scanner = c(1,2),
                                      motion = 0)


# Loop through the nested data objects and run all models on each
for (ii in 1:nrow(reactivity_model_frame)){
  if (file.exists(paste0('output/reactivity/reactivity_coefs_fear_minus_neutral_', ii, '.csv'))){
    print(paste0('already have run models for index ', ii))
  }else{
    reactivity_model_frame_index = reactivity_model_frame %>%
      dplyr::filter(index == ii) %>%
      group_by(pipeline) %>%
      mutate(.,
             modLinear = map(data, 
                             ~brm(reactivity ~ ageCenter + 
                                    motion + (ageCenter|Subject), 
                                  data = ., cores = 2, chains = 4)),
             modLinearExclude = map(data, 
                                    ~brm(reactivity ~ ageCenter + 
                                           motion + (ageCenter|Subject), 
                                         data = dplyr::filter(., is.na(prev_studied)), cores = 2, chains = 4)),
             modQuadraticExclude = map(data, 
                                       ~brm(reactivity ~ poly(ageCenter,2, raw = TRUE) + 
                                              motion + (ageCenter|Subject), 
                                            data = dplyr::filter(., is.na(prev_studied)), cores = 2, chains = 4)),
             modQuadratic = map(data, 
                                ~brm(reactivity ~ poly(ageCenter,2, raw = TRUE) + 
                                       motion + (ageCenter|Subject), 
                                     data = ., cores = 2, chains = 4)),
             modLinearScanner = map(data, 
                                    ~brm(reactivity ~ ageCenter + 
                                           motion + scanner + (ageCenter|Subject), 
                                         data = ., cores = 2, chains = 4)),
             modLinearBlock = map(data, 
                                  ~brm(reactivity ~ ageCenter + 
                                         motion + blockBin + (ageCenter|Subject), 
                                       data = ., cores = 2, chains = 4)),
             modQuadraticBlockScanner = map(data, 
                                            ~brm(reactivity ~ poly(ageCenter,2, raw = TRUE) + 
                                                   motion + blockBin + scanner + (ageCenter|Subject), 
                                                 data = ., cores = 2, chains = 4)),
             modLinearBlockScanner = map(data, 
                                         ~brm(reactivity ~ ageCenter + 
                                                motion + blockBin + scanner + (ageCenter|Subject), 
                                              data = ., cores = 2, chains = 4)),
             modLinearNoRandomSlopes = map(data, 
                                           ~brm(reactivity ~ ageCenter + 
                                                  motion + (1|Subject), 
                                                data = ., cores = 2, chains = 4))) %>%
      tidyr::gather(key = 'model_type', value = 'model_object', contains('mod'))
    
    # pull coefficients from models
    reactivity_coefs = reactivity_model_frame_index %>%
      mutate(., coefs = map(model_object, ~broom.mixed::tidy(.))) %>%
      dplyr::select(., -data, -model_object) %>%
      unnest(coefs)
    
    # Get predicitions for every point in the grid for each model (takes a little while)
    reactivity_model_preds = reactivity_model_frame_index %>%
      mutate(., model_preds = map(model_object, ~fitted(., newdata = predGridBlockBinScanner, re_formula = NA) %>% 
                                    cbind(predGridBlockBinScanner, .))) %>%
      dplyr::select(-data, -model_object) 
    
    # unnest predictions
    reactivity_model_preds_unnest = reactivity_model_preds %>%
      unnest(model_preds)
    
    # Save results for that index to csv
    write.csv(reactivity_coefs, file = paste0('output/reactivity/reactivity_coefs_fear_minus_neutral_', ii, '.csv'), row.names = FALSE)
    write.csv(reactivity_model_preds_unnest, file = paste0('output/reactivity/reactivity_model_preds_fear_minus_neutral_', ii, '.csv'), row.names = FALSE)
    
    rm(reactivity_model_frame_index)
    gc()
  }
}



