library(tidyverse)
library(brms)
library(lme4)
library(broom)

# Load in data
bsc = read.csv('compiled_data/comps_amyg_all_contrasts_bsc_master.csv', stringsAsFactors = FALSE)

# Tidy it
bsc_long = bsc %>%
  tidyr::gather(., key = 'pipeline', value = 'bsc', contains('pfc'))


# Nest and set indices
bsc_model_frame = bsc_long %>%
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
for (ii in 1:nrow(bsc_model_frame)){
  if (file.exists(paste0('output/bsc/bsc_coefs_', ii, '.csv'))){
    print(paste0('already have run models for index ', ii))
  }else{
    bsc_model_frame_index = bsc_model_frame %>%
    dplyr::filter(index == ii) %>%
    group_by(pipeline) %>%
    mutate(.,
           modLinear = map(data, 
                           ~brm(bsc ~ ageCenter + 
                                   motion + (ageCenter|Subject), 
                                 data = ., cores = 2, chains = 4, family = 'student', prior = prior(gamma(4, 1), class = nu))),
           modQuadratic = map(data, 
                              ~brm(bsc ~ poly(ageCenter,2, raw = TRUE) + 
                                      motion + (ageCenter|Subject), 
                                    data = ., cores = 2, chains = 4, family = 'student', prior = prior(gamma(4, 1), class = nu))),
           modLinearScanner = map(data, 
                                  ~brm(bsc ~ ageCenter + 
                                          motion + scanner + (ageCenter|Subject), 
                                        data = ., cores = 2, chains = 4, family = 'student', prior = prior(gamma(4, 1), class = nu))),
           modLinearBlock = map(data, 
                           ~brm(bsc ~ ageCenter + 
                                   motion + blockBin + (ageCenter|Subject), 
                                 data = ., cores = 2, chains = 4, family = 'student', prior = prior(gamma(4, 1), class = nu))),
           modQuadraticBlockScanner = map(data, 
                                   ~brm(bsc ~ poly(ageCenter,2, raw = TRUE) + 
                                           motion + blockBin + scanner + (ageCenter|Subject), 
                                         data = ., cores = 2, chains = 4, family = 'student', prior = prior(gamma(4, 1), class = nu))),
           modLinearBlockScanner = map(data, 
                                ~brm(bsc ~ ageCenter + 
                                        motion + blockBin + scanner + (ageCenter|Subject), 
                                      data = ., cores = 2, chains = 4, family = 'student', prior = prior(gamma(4, 1), class = nu))),
           modLinearNoRandomSlopes = map(data, 
                                   ~brm(bsc ~ ageCenter + 
                                           motion + (1|Subject), 
                                         data = ., cores = 2, chains = 4, family = 'student', prior = prior(gamma(4, 1), class = nu)))) %>%
    tidyr::gather(key = 'model_type', value = 'model_object', contains('mod'))
    
    # pull coefficients from models
    bsc_coefs = bsc_model_frame_index %>%
      mutate(., coefs = map(model_object, ~broom::tidy(.))) %>%
      dplyr::select(., -data, -model_object) %>%
      unnest(coefs)
    
    # Get predicitions for every point in the grid for each model (takes a little while)
    bsc_model_preds = bsc_model_frame_index %>%
      mutate(., model_preds = map(model_object, ~fitted(., newdata = predGridBlockBinScanner, re_formula = NA) %>% 
                                    cbind(predGridBlockBinScanner, .))) %>%
      dplyr::select(-data, -model_object) 
    
    # unnest predictions
    bsc_model_preds_unnest = bsc_model_preds %>%
      unnest(model_preds)
    
    # Save results for that index to csv
    write.csv(bsc_coefs, file = paste0('output/bsc/bsc_coefs_', ii, '.csv'), row.names = FALSE)
    write.csv(bsc_model_preds_unnest, file = paste0('output/bsc/bsc_model_preds_', ii, '.csv'), row.names = FALSE)
  }
}