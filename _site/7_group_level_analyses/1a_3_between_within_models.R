# Runs amygdala reactivity models using student's-t distributions for outcomes, rather than gaussian. This allows for heavier tails, making models more robust to outliers

library(tidyverse)
library(brms)
library(lme4)
library(broom)


# Fear > Baseline --------------------------------------------------------------------
# Load in data
amyg_fear  = read.csv('compiled_data/comps_amyg_fear_reactivity_master.csv', stringsAsFactors = FALSE) %>%
  dplyr::filter(censoredTR <= 40) %>%
  group_by(Subject) %>%
  mutate(age_within_center = ageCenter - mean(ageCenter),
         face_emotion = 'Fear') %>%
  ungroup()


amyg_neut = read.csv('compiled_data/comps_amyg_neut_reactivity_master.csv', stringsAsFactors = FALSE) %>%
  dplyr::filter(censoredTR <= 40) %>%
  group_by(Subject) %>%
  mutate(age_within_center = ageCenter - mean(ageCenter),
         face_emotion = 'Neutral') %>%
  ungroup()

amyg = rbind(amyg_fear, amyg_neut)


# Tidy it
amyg_long = amyg %>%
  tidyr::gather(., key = 'pipeline', value = 'reactivity', 
                (contains('bilateral') & contains('tstat') & !contains('signal')))


# Nest and set indices
reactivity_model_frame = amyg_long %>%
  group_by(pipeline, face_emotion) %>%
  nest() %>%
  ungroup() %>%
  mutate(., index = 1:nrow(.))


reactivity_model_frame_index = reactivity_model_frame %>%
    group_by(pipeline) %>%
    mutate(.,
           model_object = map(data, ~brm(reactivity ~ ageCenter + age_within_center + 
                                           motion + (age_within_center|Subject), 
                                         data = ., cores = 2, chains = 4, family = 'student', 
                                        prior = prior(gamma(4, 1), class = nu)))) 
    
# pull coefficients from models
reactivity_coefs = reactivity_model_frame_index %>%
  mutate(., coefs = map(model_object, ~broom.mixed::tidy(.))) %>%
  dplyr::select(., -data, -model_object) %>%
  unnest(coefs)

reactivity_age_coefs = dplyr::filter(reactivity_coefs, 
  grepl('age', term), 
  !grepl('sd', term),
  !grepl('cor', term)) %>%
  ungroup() %>%
  group_by(term) %>%
  mutate(rank = rank(estimate)) %>%
  ungroup() %>%
  mutate(term = ifelse(term =='ageCenter', 'Between-Participant', 'Within-Participant')) %>%
  dplyr::select(`Face Emotion` = face_emotion, everything())



# Bootstrapping -----------------------------------------------------------

n_boot=500

for (ii in 1:n_boot){
  print(ii)
  set.seed(ii)
  
  # bootstrap observations
  boot_ind=sample(1:nrow(amyg), nrow(amyg), replace = TRUE)
  amyg_resample = amyg[boot_ind,]
  

# Tidy it
amyg_long_boot = amyg_resample %>%
  tidyr::gather(., key = 'pipeline', value = 'reactivity', 
                (contains('bilateral') & contains('tstat') & !contains('signal')))


# Nest and set indices
reactivity_model_frame = amyg_long_boot %>%
  group_by(pipeline, face_emotion) %>%
  nest() %>%
  ungroup() %>%
  mutate(., index = 1:nrow(.))


reactivity_model_frame_index = reactivity_model_frame %>%
  group_by(pipeline) %>%
  mutate(.,
         model_object = map(data, ~lmer(data = ., reactivity ~ ageCenter + age_within_center + 
                                         motion + (1|Subject))))

reactivity_coefs = reactivity_model_frame_index %>%
  mutate(., coefs = map(model_object, ~broom.mixed::tidy(.))) %>%
  dplyr::select(., -data, -model_object) %>%
  unnest(coefs) %>%
  dplyr::filter(grepl('age', term)) 

estimates = reactivity_coefs %>%
  ungroup() %>%
  group_by(term) %>%
  mutate(rank = rank(estimate), iteration = ii)

  if (ii == 1){
    boot_estimates = estimates
  }else{
    boot_estimates = rbind(boot_estimates, estimates)
  }
  
  # save some memory
  rm(reactivity_model_frame)
  rm(reactivity_model_frame_index)
  gc()
}

# bootstrap summary
boot_bounds = boot_estimates %>% group_by(iteration, term) %>%
  summarise(med_est = median(estimate)) %>%
  group_by(term) %>%
  summarise(lwr = quantile(med_est, .025), 
            upr = quantile(med_est, .975)) %>%
  mutate(term = ifelse(term == 'age_within_center', 'Within-Participant', 'Between-Participant'))

reactivity_age_coefs = left_join(reactivity_age_coefs, boot_bounds, by = 'term') %>%
  group_by(term) %>%
  mutate(median_est = median(estimate)) %>%
  ungroup()

# Make plot

# median model
reactivity_age_coefs_median = reactivity_age_coefs %>%
  group_by(term) %>%
  summarise(estimate = median(estimate), conf.low = median(conf.low), conf.high = median(conf.high), rank= median(rank))


between_within = ggplot(reactivity_age_coefs, aes(x = rank, y = estimate, color = `Face Emotion`)) +
  geom_hline(aes(yintercept = median_est), lty = 2) +
  geom_hline(yintercept = 0) +
  geom_point(position = position_dodge(width = .2)) + 
  geom_errorbar(aes(ymin = conf.low, ymax = conf.high), 
                width = 0, position = position_dodge(width = .2)) +
  geom_point(data = reactivity_age_coefs_median, aes(x = rank, y = estimate), color = 'black') +
  geom_errorbar(data = reactivity_age_coefs_median, aes(x = rank, y = estimate, ymin = conf.low, ymax = conf.high), 
                 color = 'black', width = 0) +
  facet_grid(~term) +
  theme_bw() +
  theme(axis.text.x = element_text(hjust = 1, angle = 90), legend.position = 'none') +
  scale_color_brewer(palette = 'Set2') +
  labs(x = 'Models Ranked by Estimate', y = 'Estimated Age-Related Change')




save(reactivity_coefs, reactivity_age_coefs, between_within, boot_bounds, boot_estimates, file = 'output/reactivity/between_within.rda')  

