library(tidyverse)
library(brms)
library(lme4)
library(broom)


# Load in data
amyg = read.csv('compiled_data/comps_amyg_fear_reactivity_master.csv', stringsAsFactors = FALSE)
amyg$Subject = as.factor(amyg$Subject)


cutoffs = c(.2, .3, .4, .5, .6, .7, .8, .9, 1)

# ho tstat
for (ii in (1:length(cutoffs))){
  cutoff_val = cutoffs[ii]
  df_cutoff = dplyr::filter(amyg, meanFdAll <= cutoff_val)
  cutoff_mod = brm(data = df_cutoff,
                     fsl_1_bilateralAmyg_tstat ~ ageCenter + scanner + motion + (ageCenter|Subject), cores = 4, chains = 4,
                   family = 'student', prior = prior(gamma(4, 1), class = nu))
  model_stats = broom.mixed::tidy(cutoff_mod)
  model_stats$cutoff = cutoff_val
  if (ii == 1){
    model_comp_ho_tstat = model_stats
  }else{
    model_comp_ho_tstat = rbind(model_comp_ho_tstat, model_stats)
  }
  rm(cutoff_mod)
  gc()
}

# ho beta
for (ii in (1:length(cutoffs))){
  cutoff_val = cutoffs[ii]
  df_cutoff = dplyr::filter(amyg, meanFdAll <= cutoff_val)
  cutoff_mod = brm(data = df_cutoff,
                   fsl_1_bilateralAmyg_beta ~ ageCenter + scanner + motion + (ageCenter|Subject), cores = 4, chains = 4,
                   family = 'student', prior = prior(gamma(4, 1), class = nu))
  model_stats = broom.mixed::tidy(cutoff_mod)
  model_stats$cutoff = cutoff_val
  if (ii == 1){
    model_comp_ho_beta = model_stats
  }else{
    model_comp_ho_beta = rbind(model_comp_ho_beta, model_stats)
  }
  rm(cutoff_mod)
  gc()
}


# native tstat
for (ii in (1:length(cutoffs))){
  cutoff_val = cutoffs[ii]
  df_cutoff = dplyr::filter(amyg, meanFdAll <= cutoff_val)
  cutoff_mod = brm(data = df_cutoff,
                   og_native_amyg_bilateral_tstat ~ ageCenter + scanner + motion + (ageCenter|Subject), cores = 4, chains = 4,
                   family = 'student', prior = prior(gamma(4, 1), class = nu))
  model_stats = broom.mixed::tidy(cutoff_mod)
  model_stats$cutoff = cutoff_val
  if (ii == 1){
    model_comp_native_tstat = model_stats
  }else{
    model_comp_native_tstat = rbind(model_comp_native_tstat, model_stats)
  }
  rm(cutoff_mod)
  gc()
}


# native beta
for (ii in (1:length(cutoffs))){
  cutoff_val = cutoffs[ii]
  df_cutoff = dplyr::filter(amyg, meanFdAll <= cutoff_val)
  cutoff_mod = brm(data = df_cutoff,
                   og_native_amyg_bilateral_beta ~ ageCenter + scanner + motion + (ageCenter|Subject), cores = 4, chains = 4,
                   family = 'student', prior = prior(gamma(4, 1), class = nu))
  model_stats = broom.mixed::tidy(cutoff_mod)
  model_stats$cutoff = cutoff_val
  if (ii == 1){
    model_comp_native_beta = model_stats
  }else{
    model_comp_native_beta = rbind(model_comp_native_beta, model_stats)
  }
  rm(cutoff_mod)
  gc()
}


model_comp_ho_beta= mutate(model_comp_ho_beta, 
                           amygdala = 'Harvard-Oxford Amyg',
                           estimate_type = 'Beta')

model_comp_ho_tstat= mutate(model_comp_ho_tstat, 
                           amygdala = 'Harvard-Oxford Amyg',
                           estimate_type = 'T-stat')


model_comp_native_beta= mutate(model_comp_native_beta, 
                           amygdala = 'Freesurfer-Defined Amyg',
                           estimate_type= 'Beta')

model_comp_native_tstat= mutate(model_comp_native_tstat, 
                            amygdala = 'Freesurfer-Defined Amyg',
                            estimate_type = 'T-stat')

model_comp_all = rbind(model_comp_ho_beta, model_comp_ho_tstat, model_comp_native_beta, model_comp_native_tstat)


motion_exclusion_plot = dplyr::filter(model_comp_all, term == 'ageCenter') %>%
  ggplot(data = ., aes(x = cutoff, y = estimate, color = estimate_type)) +
  geom_hline(yintercept = 0, lty =2) + 
  geom_point(position = position_dodge(width = .02)) +
  geom_line(position = position_dodge(width = .02)) + 
  geom_errorbar(aes(ymin = conf.low, ymax = conf.high), width = 0, position = position_dodge(width = .02)) +
  labs(x = 'Mean FD Exclusion Threshold (mm)', y = 'Beta Estimate\nAge-Related Change') +
  theme_bw() +
  facet_grid(~amygdala)

save(model_comp_all, motion_exclusion_plot, file = 'compiled_data/motion_exclusion_miniverse.rda')

ggsave(motion_exclusion_plot, file = 'plots/motion_exclusion/motion_exclusion.pdf', height = 4, width = 8)

