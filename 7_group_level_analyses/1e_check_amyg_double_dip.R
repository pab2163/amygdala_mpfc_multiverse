library(tidyverse)
library(brms)
library(lme4)
library(broom)
source('helper_functions.R')


# Load in data & choose pipelines
amyg = read.csv('compiled_data/comps_amyg_fear_reactivity_master.csv', stringsAsFactors = FALSE) %>%
  dplyr::select(name, Subject, wave, Block, motion, ageCenter, prev_studied,
                og_native_amyg_right_tstat, 
                og_native_amyg_left_tstat,
                fsl_1_rightAmyg_tstat,
                fsl_1_leftAmyg_tstat,
                fsl_2_rightAmyg_tstat,
                fsl_2_leftAmyg_tstat,
                fsl_3_rightAmyg_tstat,
                fsl_3_leftAmyg_tstat,
                fsl_4_rightAmyg_tstat,
                fsl_4_leftAmyg_tstat,
                afni_5_rightAmyg_tstat,
                afni_5_leftAmyg_tstat,
                afni_6_rightAmyg_tstat,
                afni_6_leftAmyg_tstat,
                afni_7_rightAmyg_tstat,
                afni_7_leftAmyg_tstat,
                afni_8_rightAmyg_tstat,
                afni_8_leftAmyg_tstat) 

# code participants
amyg$Subject = as.factor(amyg$Subject)

# define datasets for participants previously studied by Gee et al.
amyg$prev_studied = ifelse(is.na(amyg$prev_studied), 0, amyg$prev_studied)

prev_data = dplyr::filter(amyg, prev_studied ==1) 
ex_data = dplyr::filter(amyg, prev_studied == 0) 

ex_models = ex_data %>%
  pivot_longer(cols = contains('tstat'), names_to = 'pipeline', values_to = 'tstat') %>%
  group_by(pipeline) %>%
  nest() %>%
  mutate(model = map(data, ~lmer(data = ., tstat ~ ageCenter + Block + motion + (1|Subject)))) %>%
  mutate(coefs = map(model, ~broom.mixed::tidy(.))) %>%
  unnest(coefs) %>%
  dplyr::select(-model) %>%
  dplyr::filter(term == 'ageCenter')

full_models = amyg %>%
  pivot_longer(cols = contains('tstat'), names_to = 'pipeline', values_to = 'tstat') %>%
  group_by(pipeline) %>%
  nest() %>%
  mutate(model = map(data, ~lmer(data = ., tstat ~ ageCenter + Block + motion + (1|Subject)))) %>%
  mutate(coefs = map(model, ~broom.mixed::tidy(.))) %>%
  unnest(coefs) %>%
  dplyr::select(-model) %>%
  dplyr::filter(term == 'ageCenter')


# loop --------------------------------------------------------------------
n = 500

perm_df = data.frame(age_est = rep(NA, n),
                     age_se = rep(NA, n))

for (i in 1:n){
  indices_to_exclude = sample(1:nrow(ex_data), size = nrow(prev_data), replace = FALSE)
  data_exclude_same_n = rbind(prev_data,
                              ex_data[-indices_to_exclude,])
  
  perm_models_iter = data_exclude_same_n %>%
    pivot_longer(cols = contains('tstat'), names_to = 'pipeline', values_to = 'tstat') %>%
    group_by(pipeline) %>%
    nest() %>%
    mutate(model = map(data, ~lmer(data = ., tstat ~ ageCenter + Block + motion + (1|Subject)))) %>%
    mutate(coefs = map(model, ~broom.mixed::tidy(.))) %>%
    unnest(coefs) %>%
    dplyr::select(-model, -data) %>%
    dplyr::filter(term == 'ageCenter') %>%
    dplyr::mutate(iter = i)
  
  if (i == 1){
    perm_models_output = perm_models_iter
  }else{
    perm_models_output = rbind(perm_models_output, perm_models_iter)
  }

}

perm_models_output = perm_models_output %>%
  dplyr::mutate(laterality = ifelse(grepl('right', pipeline), 'Right Amygdala', 'Left Amygdala'),
                pipeline = gsub('right', '', pipeline),
                pipeline = gsub('left', '', pipeline))

ex_models = ex_models %>%
  dplyr::mutate(laterality = ifelse(grepl('right', pipeline), 'Right Amygdala', 'Left Amygdala'),
                pipeline = gsub('right', '', pipeline),
                pipeline = gsub('left', '', pipeline))


ex_models$pipeline = gsub('_tstat', '', ex_models$pipeline)
ex_models$pipeline= gsub('og_ho_amyg_', 'Prereg FSL: MNI Space' ,ex_models$pipeline)
ex_models$pipeline = gsub('og_native_amyg_', 'Prereg FSL: Native Space' ,ex_models$pipeline)
ex_models$pipeline = gsub('afni_', 'C-PAC + AFNI: ', ex_models$pipeline)
ex_models$pipeline = gsub('fsl_', 'C-PAC + FSL: ', ex_models$pipeline)
ex_models$pipeline = gsub('5_Amyg', '6motion: 1G HRF: highpass' ,ex_models$pipeline)
ex_models$pipeline = gsub('6_Amyg', '6motion: 1G HRF: quadratic detrend' ,ex_models$pipeline)
ex_models$pipeline = gsub('7_Amyg', '18motion+WM+CSF: 1G HRF: highpass' ,ex_models$pipeline)
ex_models$pipeline = gsub('8_Amyg', '18motion+WM+CSF: 1G HRF: quadratic detrend' ,ex_models$pipeline)
ex_models$pipeline = gsub('1_Amyg', '6motion: 2G HRF: highpass' ,ex_models$pipeline)
ex_models$pipeline = gsub('2_Amyg', '18motion+WM+CSF: 2G HRF:  highpass' ,ex_models$pipeline)
ex_models$pipeline = gsub('3_Amyg', '6motion: 1G HRF: highpass' ,ex_models$pipeline)
ex_models$pipeline = gsub('4_Amyg', '18motion+WM+CSF: 1G HRF: highpass' ,ex_models$pipeline)

perm_models_output$pipeline = gsub('_tstat', '', perm_models_output$pipeline)
perm_models_output$pipeline= gsub('og_ho_amyg_', 'Prereg FSL: MNI Space' ,perm_models_output$pipeline)
perm_models_output$pipeline = gsub('og_native_amyg_', 'Prereg FSL: Native Space' ,perm_models_output$pipeline)
perm_models_output$pipeline = gsub('afni_', 'C-PAC + AFNI: ', perm_models_output$pipeline)
perm_models_output$pipeline = gsub('fsl_', 'C-PAC + FSL: ', perm_models_output$pipeline)
perm_models_output$pipeline = gsub('5_Amyg', '6motion: 1G HRF: highpass' ,perm_models_output$pipeline)
perm_models_output$pipeline = gsub('6_Amyg', '6motion: 1G HRF: quadratic detrend' ,perm_models_output$pipeline)
perm_models_output$pipeline = gsub('7_Amyg', '18motion+WM+CSF: 1G HRF: highpass' ,perm_models_output$pipeline)
perm_models_output$pipeline = gsub('8_Amyg', '18motion+WM+CSF: 1G HRF: quadratic detrend' ,perm_models_output$pipeline)
perm_models_output$pipeline = gsub('1_Amyg', '6motion: 2G HRF: highpass' ,perm_models_output$pipeline)
perm_models_output$pipeline = gsub('2_Amyg', '18motion+WM+CSF: 2G HRF:  highpass' ,perm_models_output$pipeline)
perm_models_output$pipeline = gsub('3_Amyg', '6motion: 1G HRF: highpass' ,perm_models_output$pipeline)
perm_models_output$pipeline = gsub('4_Amyg', '18motion+WM+CSF: 1G HRF: highpass' ,perm_models_output$pipeline)



full_models = full_models %>%
  dplyr::mutate(laterality = ifelse(grepl('right', pipeline), 'Right Amygdala', 'Left Amygdala'),
                pipeline = gsub('right', '', pipeline),
                pipeline = gsub('left', '', pipeline))


full_models$pipeline = gsub('_tstat', '', full_models$pipeline)
full_models$pipeline= gsub('og_ho_amyg_', 'Prereg FSL: MNI Space' ,full_models$pipeline)
full_models$pipeline = gsub('og_native_amyg_', 'Prereg FSL: Native Space' ,full_models$pipeline)
full_models$pipeline = gsub('afni_', 'C-PAC + AFNI: ', full_models$pipeline)
full_models$pipeline = gsub('fsl_', 'C-PAC + FSL: ', full_models$pipeline)
full_models$pipeline = gsub('5_Amyg', '6motion: 1G HRF: highpass' ,full_models$pipeline)
full_models$pipeline = gsub('6_Amyg', '6motion: 1G HRF: quadratic detrend' ,full_models$pipeline)
full_models$pipeline = gsub('7_Amyg', '18motion+WM+CSF: 1G HRF: highpass' ,full_models$pipeline)
full_models$pipeline = gsub('8_Amyg', '18motion+WM+CSF: 1G HRF: quadratic detrend' ,full_models$pipeline)
full_models$pipeline = gsub('1_Amyg', '6motion: 2G HRF: highpass' ,full_models$pipeline)
full_models$pipeline = gsub('2_Amyg', '18motion+WM+CSF: 2G HRF:  highpass' ,full_models$pipeline)
full_models$pipeline = gsub('3_Amyg', '6motion: 1G HRF: highpass' ,full_models$pipeline)
full_models$pipeline = gsub('4_Amyg', '18motion+WM+CSF: 1G HRF: highpass' ,full_models$pipeline)

perm_models_summary = perm_models_output %>%
  ungroup() %>%
  group_by(pipeline, laterality) %>%
  summarise(lwr = quantile(estimate, .025),
            median = quantile(estimate, .5),
            upr = quantile(estimate, .975))


exclusion_permutation_plot = ggplot(perm_models_output, aes(x = pipeline, y = estimate)) +
  geom_flat_violin(position = position_nudge(0.1), 
                   aes(color = 'Excluding Random Subsamples of 42 Scans\nNot Previously Studied')) +
  geom_errorbar(data = perm_models_summary, aes(ymin = lwr, ymax = upr, y = median), width = .1) + 
  geom_point(data = perm_models_summary, aes(y = median, color = 'Excluding Random Subsamples of 42 Scans\nNot Previously Studied')) + 
  geom_point(data = ex_models, aes(x = pipeline, y = estimate, color = 'Excluding 42 Previously Studied Scans'), alpha = .8) +
  coord_flip() +
  facet_grid(~laterality) +
  theme_bw() +
  theme(legend.title = element_blank()) +
  scale_color_brewer(palette = 'Set1') +
  labs(y = 'Estimated Linear Age-Related Change\n Amygdala Reactivity Fear > Baseline', x = 'Pipeline')

ggsave(exclusion_permutation_plot, filename = 'plots/supplement/exclusion_permutation_reactivity.png', height = 6, width = 12)

