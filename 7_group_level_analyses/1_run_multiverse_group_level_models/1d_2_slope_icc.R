library(tidyverse)
library(brms)
library(lme4)
library(broom)
library(broom.mixed)
library(performance)


# Load in data for 3 types of models
slopes = read.csv('compiled_data/habit_slopes_master_comps.csv', stringsAsFactors = FALSE) %>%
  dplyr::filter(censoredTR <= 40)

# Tidy them
slopes_nest = slopes %>%
  tidyr::gather(., key = 'pipeline', value = 'slope', contains('slope')) %>%
  group_by(pipeline) %>%
  nest() %>%
  ungroup() %>%
  mutate(., index = 1:nrow(.))

slope_model_frame_index = slopes_nest %>%
    group_by(pipeline) %>%
    mutate(.,
             model_object= map(data, 
                             ~brm(slope ~ ageCenter + 
                                     motion + (ageCenter|Subject), 
                                   data = ., cores = 4, chains = 4, family = 'student', 
                                  prior = prior(gamma(4, 1), class = nu))))
      


slope_coefs = slope_model_frame_index %>%
    mutate(., coefs = map(model_object, ~performance::variance_decomposition(.))) 
 
slope_icc = slope_coefs %>%
    dplyr::select(-model_object, -data)

# pull out icc vals
slope_icc = dplyr::mutate(reactivity_icc, icc = NA, lower = NA, upper = NA)
for (row in 1:nrow(slope_icc)){
  slope_icc$icc[row] = slope_icc$coefs[[row]]$ICC_decomposed
  slope_icc$lower[row] = slope_icc$coefs[[row]]$ICC_CI[1]
  slope_icc$upper[row] = slope_icc$coefs[[row]]$ICC_CI[2]
}

save(slope_icc, file = 'output/habit/slope_icc.rda')

slope_icc = mutate(slope_icc, 
                   contrast = ifelse(grepl('fear', pipeline), 'Fear > Baseline', 'Neutral > Baseline'),
                   gsr = ifelse(grepl('no_gsr', pipeline),'No GSS', 'GSS'),
                   roi = case_when(grepl('right', pipeline) ~ 'Right Amygdala',
                                   grepl('bilateral', pipeline) ~ 'Bilateral Amygdala',
                                   grepl('left', pipeline) ~ 'Left Amygdala'))

slope_icc_plot = ggplot(slope_icc, aes(x = roi, y = icc, color = gsr)) +
  geom_point(position = position_dodge(0.5)) +
  geom_hline(yintercept = 0, lty = 2) +
  geom_errorbar(aes(ymin = lower, ymax = upper), width = 0, position = position_dodge(0.5)) +
  coord_flip() +
  theme_bw() +
  facet_grid(~contrast) +
  labs(y = 'ICC: Slopes Across Trials', x = '') +
  theme(legend.title = element_blank())

ggsave(slope_icc_plot, filename = 'plots/supplement/slope_icc_plot.png')
  
