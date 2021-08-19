library(tidyverse)
library(brms)
library(lme4)
library(broom.mixed)
library(sjstats)


icc_specs = function(input_data_path, contrast){
  # Fear > Baseline --------------------------------------------------------------------
  # Load in data
  amyg = read.csv(input_data_path, stringsAsFactors = FALSE) %>%
    dplyr::filter(censoredTR <= 40)
  
  # Tidy it
  amyg_long = amyg %>%
    tidyr::gather(., key = 'pipeline', value = 'reactivity', contains('amyg'),contains('Amyg')) %>%
    dplyr::filter(!grepl('High', pipeline), !grepl('Low', pipeline), !grepl('right', pipeline), !grepl('left', pipeline))
  
  # Nest and set indices
  reactivity_model_frame = amyg_long %>%
    group_by(pipeline) %>%
    nest() %>%
    ungroup() %>%
    mutate(., index = 1:nrow(.))
  
  
  # Loop through the nested data objects and run all models on each
  reactivity_model_frame_index = reactivity_model_frame %>%
      group_by(pipeline) %>%
      mutate(.,
             model_object= map(data, 
                             ~brm(reactivity ~ ageCenter + 
                                     motion + (ageCenter|Subject), 
                                   data = ., cores = 2, chains = 4, family = 'student', 
                                  prior = prior(gamma(4, 1), class = nu))))
      
  # pull coefficients from models
  reactivity_coefs = reactivity_model_frame_index %>%
    mutate(., coefs = map(model_object, ~performance::variance_decomposition(.))) 
  
  reactivity_icc = reactivity_coefs %>%
    dplyr::select(-model_object, -data)
      
  save(reactivity_icc, file = paste0('output/reactivity/reactivity_20_pipelines_', contrast, '_icc.rda'))
       
  reactivity_icc = dplyr::mutate(reactivity_icc, icc = NA, lower = NA, upper = NA)
  for (row in 1:nrow(reactivity_icc)){
    reactivity_icc$icc[row] = reactivity_icc$coefs[[row]]$ICC_decomposed
    reactivity_icc$lower[row] = reactivity_icc$coefs[[row]]$ICC_CI[1]
    reactivity_icc$upper[row] = reactivity_icc$coefs[[row]]$ICC_CI[2]
  }
  
  
  reactivity_icc$pipeline = gsub('_tstat', ': Tstat', reactivity_icc$pipeline)
  reactivity_icc$pipeline = gsub('_beta', ': Beta', reactivity_icc$pipeline)
  reactivity_icc$pipeline= gsub('og_ho_amyg_bilateral', 'Prereg FSL: MNI Space' ,reactivity_icc$pipeline)
  reactivity_icc$pipeline = gsub('og_native_amyg_bilateral', 'Prereg FSL: Native Space' ,reactivity_icc$pipeline)
  reactivity_icc$pipeline = gsub('afni_', 'C-PAC + AFNI: ', reactivity_icc$pipeline)
  reactivity_icc$pipeline = gsub('fsl_', 'C-PAC + FSL: ', reactivity_icc$pipeline)
  reactivity_icc$pipeline = gsub('5_bilateralAmyg', '6motion: 1G HRF: highpass' ,reactivity_icc$pipeline)
  reactivity_icc$pipeline = gsub('6_bilateralAmyg', '6motion: 1G HRF: quadratic detrend' ,reactivity_icc$pipeline)
  reactivity_icc$pipeline = gsub('7_bilateralAmyg', '18motion+WM+CSF: 1G HRF: highpass' ,reactivity_icc$pipeline)
  reactivity_icc$pipeline = gsub('8_bilateralAmyg', '18motion+WM+CSF: 1G HRF: quadratic detrend' ,reactivity_icc$pipeline)
  reactivity_icc$pipeline = gsub('1_bilateralAmyg', '6motion: 2G HRF: highpass' ,reactivity_icc$pipeline)
  reactivity_icc$pipeline = gsub('2_bilateralAmyg', '18motion+WM+CSF: 2G HRF:  highpass' ,reactivity_icc$pipeline)
  reactivity_icc$pipeline = gsub('3_bilateralAmyg', '6motion: 1G HRF: highpass' ,reactivity_icc$pipeline)
  reactivity_icc$pipeline = gsub('4_bilateralAmyg', '18motion+WM+CSF: 1G HRF: highpass' ,reactivity_icc$pipeline)
  
  reactivity_longitudinal_icc = ggplot(reactivity_icc, aes(x = pipeline, y = icc)) +
    geom_hline(yintercept = 0, lty = 2) +
    geom_point() +
    geom_errorbar(aes(ymin = lower, ymax = upper)) +
    coord_flip() +
    theme_bw() +
    labs(y = '', x = 
           'Pipeline')
  
  return(reactivity_longitudinal_icc)
}


g = read_csv('compiled_data/comps_amyg_neut_reactivity_master.csv')

icc_plt_fear_minus_neutral = icc_specs(input_data = 'compiled_data/comps_amyg_fear_minus_neut_reactivity_master.csv', contrast = 'fear_minus_neutral')
icc_plt_fear = icc_specs(input_data = 'compiled_data/comps_amyg_fear_reactivity_master.csv', contrast = 'fear')


icc_reactivity = plot_grid(icc_plt_fear + labs(y = 'ICC: Fear > Baseline'), 
          icc_plt_fear_minus_neutral + theme(axis.text.y = element_blank()) + labs(y = 'ICC: Fear > Neutral', x = ''), 
          rel_widths = c(2.5, 1), labels = c('A', 'B'))


cowplot::save_plot(icc_reactivity, filename = 'plots/supplement/reactivity_icc.png', base_width = 10)




