# For accessing environment on Elvis, change .libPaths() order
paths = .libPaths()
paths = c(paths[2], paths[1])
.libPaths(paths)

library(tidyverse)
library(brms)
library(lme4)
library(broom.mixed)

# Load in data
ppi = read.csv('compiled_data/comps_amyg_fear_ppi_master.csv', stringsAsFactors = FALSE) %>%
  dplyr::filter(censoredTR <= 40) 

# Tidy it
ppi_long = ppi %>%
  tidyr::gather(., key = 'pipeline', value = 'ppi', contains('conv'))


# Nest and set indices
ppi_model_frame = ppi_long %>%
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
for (ii in 1:nrow(ppi_model_frame)){
  if (file.exists(paste0('output/ppi/ppi_coefs_', ii, '.csv'))){
    print(paste0('already have run models for index ', ii))
  }else{
    ppi_model_frame_index = ppi_model_frame %>%
    dplyr::filter(index == ii) %>%
    group_by(pipeline) %>%
    mutate(.,
           modLinear = map(data, 
                           ~brm(ppi ~ ageCenter + 
                                   motion + (ageCenter|Subject), 
                                 data = ., cores = 4, chains = 4)),
           modLinearExclude = map(data, 
                           ~brm(ppi ~ ageCenter + 
                                  motion + (ageCenter|Subject), 
                                data = dplyr::filter(., is.na(prev_studied)), cores = 4, chains = 4)),
           modQuadraticExclude = map(data, 
                                  ~brm(ppi ~ poly(ageCenter,2, raw = TRUE) + 
                                         motion + (ageCenter|Subject), 
                                       data = dplyr::filter(., is.na(prev_studied)), cores = 4, chains = 4)),
           modQuadratic = map(data, 
                              ~brm(ppi ~ poly(ageCenter,2, raw = TRUE) + 
                                      motion + (ageCenter|Subject), 
                                    data = ., cores = 4, chains = 4)),
           modLinearScanner = map(data, 
                                  ~brm(ppi ~ ageCenter + 
                                          motion + scanner + (ageCenter|Subject), 
                                        data = ., cores = 4, chains = 4)),
           modLinearBlock = map(data, 
                           ~brm(ppi ~ ageCenter + 
                                   motion + blockBin + (ageCenter|Subject), 
                                 data = ., cores = 4, chains = 4)),
           modQuadraticBlockScanner = map(data, 
                                   ~brm(ppi ~ poly(ageCenter,2, raw = TRUE) + 
                                           motion + blockBin + scanner + (ageCenter|Subject), 
                                         data = ., cores = 4, chains = 4)),
           modLinearBlockScanner = map(data, 
                                ~brm(ppi ~ ageCenter + 
                                        motion + blockBin + scanner + (ageCenter|Subject), 
                                      data = ., cores = 4, chains = 4)),
           modLinearNoRandomSlopes = map(data, 
                                   ~brm(ppi ~ ageCenter + 
                                           motion + (1|Subject), 
                                         data = ., cores = 4, chains = 4))) %>%
    tidyr::gather(key = 'model_type', value = 'model_object', contains('mod'))
    
    # pull coefficients from models
    ppi_coefs = ppi_model_frame_index %>%
      mutate(., coefs = map(model_object, ~broom.mixed::tidy(.))) %>%
      dplyr::select(., -data, -model_object) %>%
      unnest(coefs)
    
    # Get predicitions for every point in the grid for each model (takes a little while)
    ppi_model_preds = ppi_model_frame_index %>%
      mutate(., model_preds = map(model_object, ~fitted(., newdata = predGridBlockBinScanner, re_formula = NA) %>% 
                                    cbind(predGridBlockBinScanner, .))) %>%
      dplyr::select(-data, -model_object) 
    
    # unnest predictions
    ppi_model_preds_unnest = ppi_model_preds %>%
      unnest(model_preds)
    
    # Save results for that index to csv
    write.csv(ppi_coefs, file = paste0('output/ppi/ppi_coefs_', ii, '.csv'), row.names = FALSE)
    write.csv(ppi_model_preds_unnest, file = paste0('output/ppi/ppi_model_preds_', ii, '.csv'), row.names = FALSE)
    
    rm(ppi_model_frame_index)
    gc()
  }
}

# NEUTRAL & FEAR-NEUTRAL
# Load in data
ppi_neut_subtract = read.csv('compiled_data/comps_amyg_all_contrasts_ppi_master.csv', stringsAsFactors = FALSE) %>%
  dplyr::select(-contains('fear_deconv'), -contains('fear_no_deconv')) %>%
  dplyr::filter(censoredTR <= 40) 

# Tidy it
ppi_neut_subtract_long = ppi_neut_subtract %>%
  tidyr::gather(., key = 'pipeline', value = 'ppi', contains('conv'))


# Nest and set indices
ppi_neut_subtract_long_model_frame = ppi_neut_subtract_long %>%
  group_by(pipeline) %>%
  nest() %>%
  ungroup() %>%
  mutate(., index = 1:nrow(.))


# Loop through the nested data objects and run all models on each
for (ii in 1:nrow(ppi_neut_subtract_long_model_frame)){
  if (file.exists(paste0('output/ppi/ppi_neut_subtract_coefs_', ii, '.csv'))){
    print(paste0('already have run models for index ', ii))
  }else{
    ppi_neut_subtract_model_index = ppi_neut_subtract_long_model_frame %>%
      dplyr::filter(index == ii) %>%
      group_by(pipeline) %>%
      mutate(.,
             modLinear = map(data, 
                             ~brm(ppi ~ ageCenter + 
                                    motion + (ageCenter|Subject), 
                                  data = ., cores = 4, chains = 4)),
             modLinearExclude = map(data, 
                                    ~brm(ppi ~ ageCenter + 
                                           motion + (ageCenter|Subject), 
                                         data = dplyr::filter(., is.na(prev_studied)), cores = 4, chains = 4)),
             modQuadraticExclude = map(data, 
                                       ~brm(ppi ~ poly(ageCenter,2, raw = TRUE) + 
                                              motion + (ageCenter|Subject), 
                                            data = dplyr::filter(., is.na(prev_studied)), cores = 4, chains = 4)),
             modQuadratic = map(data, 
                                ~brm(ppi ~ poly(ageCenter,2, raw = TRUE) + 
                                       motion + (ageCenter|Subject), 
                                     data = ., cores = 4, chains = 4)),
             modLinearScanner = map(data, 
                                    ~brm(ppi ~ ageCenter + 
                                           motion + scanner + (ageCenter|Subject), 
                                         data = ., cores = 4, chains = 4)),
             modLinearBlock = map(data, 
                                  ~brm(ppi ~ ageCenter + 
                                         motion + blockBin + (ageCenter|Subject), 
                                       data = ., cores = 4, chains = 4)),
             modQuadraticBlockScanner = map(data, 
                                            ~brm(ppi ~ poly(ageCenter,2, raw = TRUE) + 
                                                   motion + blockBin + scanner + (ageCenter|Subject), 
                                                 data = ., cores = 4, chains = 4)),
             modLinearBlockScanner = map(data, 
                                         ~brm(ppi ~ ageCenter + 
                                                motion + blockBin + scanner + (ageCenter|Subject), 
                                              data = ., cores = 4, chains = 4)),
             modLinearNoRandomSlopes = map(data, 
                                           ~brm(ppi ~ ageCenter + 
                                                  motion + (1|Subject), 
                                                data = ., cores = 4, chains = 4))) %>%
      tidyr::gather(key = 'model_type', value = 'model_object', contains('mod'))
    
    # pull coefficients from models
    ppi_neut_subtract_coefs = ppi_neut_subtract_model_index  %>%
      mutate(., coefs = map(model_object, ~broom.mixed::tidy(.))) %>%
      dplyr::select(., -data, -model_object) %>%
      unnest(coefs)
    
    # Get predicitions for every point in the grid for each model (takes a little while)
    ppi_neut_subtract_model_preds = ppi_neut_subtract_model_index %>%
      mutate(., model_preds = map(model_object, ~fitted(., newdata = predGridBlockBinScanner, re_formula = NA) %>% 
                                    cbind(predGridBlockBinScanner, .))) %>%
      dplyr::select(-data, -model_object) 
    
    # unnest predictions
    ppi_neut_subtract_model_preds_unnest = ppi_neut_subtract_model_preds %>%
      unnest(model_preds)
    
    # Save results for that index to csv
    write.csv(ppi_neut_subtract_coefs, file = paste0('output/ppi/ppi_neut_subtract_coefs_', ii, '.csv'), row.names = FALSE)
    write.csv(ppi_neut_subtract_model_preds_unnest, file = paste0('output/ppi/ppi_neut_subtract_model_preds_', ii, '.csv'), row.names = FALSE)
    
    rm(ppi_neut_subtract_model_index)
    gc()
  }
}
