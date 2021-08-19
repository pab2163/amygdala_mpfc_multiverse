library(shiny)
library(tidyverse)
library(ggplot2)
library(gridExtra)
library(shinythemes)
theme_set(theme_bw())



# Load data ---------------------------------------------------------------
load('cleaned_shiny_data_no_ui.rda')

# source user interfaces
source('reactivity_ui.R')
source('gppi_ui.R')
source('bsc_ui.R')
source('info_ui.R')


# Define the shiny UI -----------------------------------------------------

# all ui sourced from separate scripts
ui = navbarPage('Interactive multiverse analysis explorer!', info_ui, reactivity_ui, gppi_ui, bsc_ui, theme = shinytheme('cosmo'))


# Backend server functinos ------------------------------------------------

server = shinyServer(function(input, output){
  # newdat = rnorm(1)
  # observeEvent(once = TRUE,ignoreNULL = FALSE, ignoreInit = FALSE, eventExpr = newdat, { 
  #   # event will be called when histdata changes, which only happens once, when it is initially calculated
  #   showModal(modalDialog(
  #     title = "Interactive Multiverse Analysis Explorer!", 
  #     h1('Interactive Multiverse Analysis Explorer!'),
  #     p('Theoretically you can put whatever content you want in here')
  #   ))
  # })

# reactivity_fear_plot ----------------------------------------------------
  output$plot_reactivity_fear = renderPlot({
      # options based on user input
      tstat_choice = ifelse(input$tstat== 'T-Stat', '|', '*')
      amyg_right_choice = ifelse(grepl('right', tolower(input$amyg_roi)), '|', '*')
      amyg_left_choice = ifelse(grepl('left', tolower(input$amyg_roi)), '|', '*')
      amyg_bilateral_choice = ifelse(grepl('bilateral', tolower(input$amyg_roi)), '|', '*')
      amyg_high_sig_choice = ifelse(grepl('high', tolower(input$amyg_roi)), '|', '*')
      amyg_low_sig_choice = ifelse(grepl('low', tolower(input$amyg_roi)), '|', '*')
      amyg_native_choice = ifelse(grepl('native', tolower(input$amyg_roi)), '|', '*')
      glm_afni_choice = ifelse(input$glm_software == 'AFNI', '|', '*')
      hrf_2g_choice = ifelse(input$hrf == '2 Gamma (FSL pipelines only)', '|', '*')
      motion_choice6 = ifelse(input$motion_reg == '6', '|', '*')
      motion_choice24 = ifelse(input$motion_reg == '24 (FSL Pipelines Only)', '|', '*')
      exclude_choice = ifelse(input$exclude == 'Yes', '|', '*')
      frequency_choice = ifelse(input$frequency_flt == 'Highpass Filter (.01hz)', '*', '|')
      robust_choice = ifelse(input$robust == 'Yes', '|', '*')
      
      
      # update frame for index selection
      reactivity_sca_fear_frame_mod = reactivity_sca_fear_frame
      reactivity_sca_fear_frame_mod[is.na(reactivity_sca_fear_frame_mod)] = '*'
      
      model_type_choice =  ''
      if (input$randomEffects == 'Intercepts Only'){
        model_type_choice = 'modLinearNoRandomSlopes'
      }
      else{
        model_type_choice = case_when(
          input$modelType == 'Linear' & input$covariates == 'Motion Only' & input$exclude == 'No'~'modLinear',
          input$modelType == 'Linear' & input$covariates == 'Motion Only' & input$exclude == 'Yes'~ 'modLinearExclude',
          input$modelType == 'Linear' & input$covariates == 'Motion + Scanner' ~ 'modLinearScanner',
          input$modelType == 'Linear' & input$covariates == 'Motion + Block' ~ 'modLinearBlock',
          input$modelType == 'Linear' & input$covariates == 'Motion + Scanner + Block' ~ 'modLinearBlockScanner',
          input$modelType == 'Quadratic' & input$covariates == 'Motion Only' & input$exclude == 'No'~ 'modQuadratic',
          input$modelType == 'Quadratic' & input$covariates == 'Motion Only' & input$exclude == 'Yes'~ 'modQuadraticExclude',
          input$modelType == 'Quadratic' & input$covariates == 'Motion + Scanner + Block' ~ 'modQuadraticBlockScanner',
          input$modelType == 'Quadratic' & input$exclude == 'Yes' ~ 'modQuadraticExclude',
          input$modelType == 'Linear' & input$exclude == 'Yes' ~ 'modLinearExclude')
      }
      index_select_frame = dplyr::filter(reactivity_sca_fear_frame_mod, 
                                         tstat == tstat_choice, 
                                         model_type == model_type_choice,
                                         amyg_right == amyg_right_choice, 
                                         amyg_left == amyg_left_choice, 
                                         amyg_high_sig == amyg_high_sig_choice,
                                         amyg_low_sig == amyg_low_sig_choice,
                                         native_space == amyg_native_choice,
                                         glm_fsl == glm_afni_choice,
                                         hrf_2gamma == hrf_2g_choice,
                                         motion_reg6 == motion_choice6,
                                         motion_reg24 == motion_choice24,
                                         exclude_prev == exclude_choice,
                                         highpass == frequency_choice,
                                         robust == robust_choice)
      print(paste0(nrow(index_select_frame), 'selected indices'))
      if (nrow(index_select_frame) ==1){
        # the selected index of the model to look at
        index_select = index_select_frame$index[1]

        # Filter raw data, model predictions, and coefs based participant choice
        filtered_model_preds = dplyr::filter(reactivity_preds_fear, model_type == model_type_choice, 
                                             index == index_select, robust == robust_choice,
                                             scanner ==1, blockBin == 'first')
        filtered_raw_data = dplyr::filter(reactivity_fear_raw_data, index == index_select)
        filtered_coef = dplyr::filter(reactivity_sca_fear_frame, index == index_select, model_type == model_type_choice, 
                                      robust == robust_choice)
        filtered_coef_long = dplyr::filter(reactivity_sca_fear_long, index == index_select, 
                                           model_type == model_type_choice) 
        
        # plot selected model predictions (right)
        selected_model_pred = ggplot(data = filtered_raw_data, aes(x = Age, y = reactivity)) +
          geom_hline(yintercept = 0, lty = 2) +
          geom_point(alpha = .5) +
          geom_line(aes(group = Subject), alpha = .2) +
          geom_ribbon(data = filtered_model_preds, aes(x = Age, y = Estimate, 
                                                       ymin = Q2.5, ymax = Q97.5), 
                      alpha = .3) +
          geom_line(data = filtered_model_preds, aes(x = Age, y = Estimate), lwd = 2) +
          theme_classic() +
          labs(y = 'Amygdala Reactivity') +
          scale_color_brewer(palette = 'Set1') +
          scale_fill_brewer(palette = 'Set1')
        
        # plot sca model estimates (left)
        reactivity_sca_fear_top =  reactivity_sca_fear_top + 
          geom_point(data = filtered_coef, size = 4, color = 'black') + 
          geom_errorbar(data = filtered_coef, aes(ymin = conf.low, ymax = conf.high), width = 0, lwd = 1, color = 'black') +
          labs(x = 'Model ranked by age-related change coef')
        
        # make the panel plot
        cowplot::plot_grid(reactivity_sca_fear_top, selected_model_pred, 
                           ncol = 2, rel_widths = c(1,1), labels = c('Coefficients for all models', 'Selected model predictions'))
        
      }
      # IF USER SELECTS A MODEL SPEC NOT AVAILABLE
      else{
        selected_model_pred = ggplot(data = reactivity_fear_raw_data, aes(x = Age, y = reactivity)) +
          geom_hline(yintercept = 0, lty = 2) +
          theme_classic() +
          labs(title = '', y = 'Amygdala Reactivity') +
          scale_color_brewer(palette = 'Set1') +
          scale_fill_brewer(palette = 'Set1') 
        
          # make the panel plot
          cowplot::plot_grid(reactivity_sca_fear_top, selected_model_pred, 
                           ncol = 2, rel_widths = c(1,1), labels = c('Coefficients for all models', 'No models of this specification!'))
      }
    })
  

# reactivity_neutral_plot -------------------------------------------------
  output$plot_reactivity_neut = renderPlot({
    # options based on user input
    tstat_choice = ifelse(input$neut_tstat== 'T-Stat', '|', '*')
    amyg_right_choice = ifelse(grepl('right', tolower(input$neut_amyg_roi)), '|', '*')
    amyg_left_choice = ifelse(grepl('left', tolower(input$neut_amyg_roi)), '|', '*')
    amyg_bilateral_choice = ifelse(grepl('bilateral', tolower(input$neut_amyg_roi)), '|', '*')
    amyg_high_sig_choice = ifelse(grepl('high', tolower(input$neut_amyg_roi)), '|', '*')
    amyg_low_sig_choice = ifelse(grepl('low', tolower(input$neut_amyg_roi)), '|', '*')
    amyg_native_choice = ifelse(grepl('native', tolower(input$neut_amyg_roi)), '|', '*')
    glm_afni_choice = ifelse(input$neut_glm_software == 'AFNI', '|', '*')
    hrf_2g_choice = ifelse(input$neut_hrf == '2 Gamma (FSL pipelines only)', '|', '*')
    motion_choice6 = ifelse(input$neut_motion_reg == '6', '|', '*')
    motion_choice24 = ifelse(input$neut_motion_reg == '24 (FSL Pipelines Only)', '|', '*')
    exclude_choice = ifelse(input$neut_exclude == 'Yes', '|', '*')
    frequency_choice = ifelse(input$neut_frequency_flt == 'Highpass Filter (.01hz)', '*', '|')
    robust_choice = ifelse(input$neut_robust == 'Yes', '|', '*')
    
    
    # update frame for index selection
    reactivity_sca_neut_frame_mod = reactivity_sca_neut_frame
    reactivity_sca_neut_frame_mod[is.na(reactivity_sca_neut_frame_mod)] = '*'
    
    model_type_choice =  ''
    if (input$neut_randomEffects == 'Intercepts Only'){
      model_type_choice = 'modLinearNoRandomSlopes'
    }
    else{
      model_type_choice = case_when(
        input$neut_modelType == 'Linear' & input$neut_covariates == 'Motion Only' & input$neut_exclude == 'No'~'modLinear',
        input$neut_modelType == 'Linear' & input$neut_covariates == 'Motion Only' & input$neut_exclude == 'Yes'~ 'modLinearExclude',
        input$neut_modelType == 'Linear' & input$neut_covariates == 'Motion + Scanner' ~ 'modLinearScanner',
        input$neut_modelType == 'Linear' & input$neut_covariates == 'Motion + Block' ~ 'modLinearBlock',
        input$neut_modelType == 'Linear' & input$neut_covariates == 'Motion + Scanner + Block' ~ 'modLinearBlockScanner',
        input$neut_modelType == 'Quadratic' & input$neut_covariates == 'Motion Only' & input$neut_exclude == 'No'~ 'modQuadratic',
        input$neut_modelType == 'Quadratic' & input$neut_covariates == 'Motion Only' & input$neut_exclude == 'Yes'~ 'modQuadraticExclude',
        input$neut_modelType == 'Quadratic' & input$neut_covariates == 'Motion + Scanner + Block' ~ 'modQuadraticBlockScanner',
        input$neut_modelType == 'Quadratic' & input$neut_exclude == 'Yes' ~ 'modQuadraticExclude',
        input$neut_modelType == 'Linear' & input$neut_exclude == 'Yes' ~ 'modLinearExclude')
    }
    index_select_frame = dplyr::filter(reactivity_sca_neut_frame_mod, 
                                       tstat == tstat_choice, 
                                       model_type == model_type_choice,
                                       amyg_right == amyg_right_choice, 
                                       amyg_left == amyg_left_choice, 
                                       amyg_high_sig == amyg_high_sig_choice,
                                       amyg_low_sig == amyg_low_sig_choice,
                                       native_space == amyg_native_choice,
                                       glm_fsl == glm_afni_choice,
                                       hrf_2gamma == hrf_2g_choice,
                                       motion_reg6 == motion_choice6,
                                       motion_reg24 == motion_choice24,
                                       exclude_prev == exclude_choice,
                                       highpass == frequency_choice,
                                       robust == robust_choice)
    print(paste0(nrow(index_select_frame), 'selected indices'))
    if (nrow(index_select_frame) ==1){
      # the selected index of the model to look at
      index_select = index_select_frame$index[1]
      
      # Filter raw data, model predictions, and coefs based participant choice
      filtered_model_preds = dplyr::filter(reactivity_preds_neut, model_type == model_type_choice, 
                                           index == index_select, robust == robust_choice,
                                           scanner ==1, blockBin == 'first')
      filtered_raw_data = dplyr::filter(reactivity_neut_raw_data, index == index_select)
      filtered_coef = dplyr::filter(reactivity_sca_neut_frame, index == index_select, model_type == model_type_choice, 
                                    robust == robust_choice)
      filtered_coef_long = dplyr::filter(reactivity_sca_neut_long, index == index_select, 
                                         model_type == model_type_choice) 
      
      # plot selected model predictions (right)
      selected_model_pred = ggplot(data = filtered_raw_data, aes(x = Age, y = reactivity)) +
        geom_hline(yintercept = 0, lty = 2) +
        geom_point(alpha = .5) +
        geom_line(aes(group = Subject), alpha = .2) +
        geom_ribbon(data = filtered_model_preds, aes(x = Age, y = Estimate, 
                                                     ymin = Q2.5, ymax = Q97.5), 
                    alpha = .3) +
        geom_line(data = filtered_model_preds, aes(x = Age, y = Estimate), lwd = 2) +
        theme_classic() +
        labs(y = 'Amygdala Reactivity') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
      
      # plot sca model estimates (left)
      reactivity_sca_neut_top =  reactivity_sca_neut_top + 
        geom_point(data = filtered_coef, size = 4, color = 'black') + 
        geom_errorbar(data = filtered_coef, aes(ymin = conf.low, ymax = conf.high), width = 0, lwd = 1, color = 'black') +
        labs(x = 'Model ranked by age-related change coef')
      
      # make the panel plot
      cowplot::plot_grid(reactivity_sca_neut_top, selected_model_pred, 
                         ncol = 2, rel_widths = c(1,1), labels = c('Coefficients for all models', 'Selected model predictions'))
      
    }
    # IF USER SELECTS A MODEL SPEC NOT AVAILABLE
    else{
      selected_model_pred = ggplot(data = reactivity_neut_raw_data, aes(x = Age, y = reactivity)) +
        geom_hline(yintercept = 0, lty = 2) +
        theme_classic() +
        labs(title = '', y = 'Amygdala Reactivity') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1') 
      
      # make the panel plot
      cowplot::plot_grid(reactivity_sca_neut_top, selected_model_pred, 
                         ncol = 2, rel_widths = c(1,1), labels = c('Coefficients for all models', 'No models of this specification!'))
    }
  })

  # reactivity_fear_minus_neutral_plot -------------------------------------------------
  output$plot_reactivity_fear_minus_neut = renderPlot({
    # options based on user input
    tstat_choice = ifelse(input$fear_minus_neut_tstat== 'T-Stat', '|', '*')
    amyg_right_choice = ifelse(grepl('right', tolower(input$fear_minus_neut_amyg_roi)), '|', '*')
    amyg_left_choice = ifelse(grepl('left', tolower(input$fear_minus_neut_amyg_roi)), '|', '*')
    amyg_bilateral_choice = ifelse(grepl('bilateral', tolower(input$fear_minus_neut_amyg_roi)), '|', '*')
    amyg_high_sig_choice = ifelse(grepl('high', tolower(input$fear_minus_neut_amyg_roi)), '|', '*')
    amyg_low_sig_choice = ifelse(grepl('low', tolower(input$fear_minus_neut_amyg_roi)), '|', '*')
    amyg_native_choice = ifelse(grepl('native', tolower(input$fear_minus_neut_amyg_roi)), '|', '*')
    glm_afni_choice = ifelse(input$fear_minus_neut_glm_software == 'AFNI', '|', '*')
    hrf_2g_choice = ifelse(input$fear_minus_neut_hrf == '2 Gamma (FSL pipelines only)', '|', '*')
    motion_choice6 = ifelse(input$fear_minus_neut_motion_reg == '6', '|', '*')
    motion_choice24 = ifelse(input$fear_minus_neut_motion_reg == '24 (FSL Pipelines Only)', '|', '*')
    exclude_choice = ifelse(input$fear_minus_neut_exclude == 'Yes', '|', '*')
    frequency_choice = ifelse(input$fear_minus_neut_frequency_flt == 'Highpass Filter (.01hz)', '*', '|')
    robust_choice = ifelse(input$fear_minus_neut_robust == 'Yes', '|', '*')
    
    
    # update frame for index selection
    reactivity_sca_fear_minus_neut_frame_mod = reactivity_sca_fear_minus_neut_frame
    reactivity_sca_fear_minus_neut_frame_mod[is.na(reactivity_sca_fear_minus_neut_frame_mod)] = '*'
    
    model_type_choice =  ''
    if (input$fear_minus_neut_randomEffects == 'Intercepts Only'){
      model_type_choice = 'modLinearNoRandomSlopes'
    }
    else{
      model_type_choice = case_when(
        input$fear_minus_neut_modelType == 'Linear' & input$fear_minus_neut_covariates == 'Motion Only' & input$fear_minus_neut_exclude == 'No'~'modLinear',
        input$fear_minus_neut_modelType == 'Linear' & input$fear_minus_neut_covariates == 'Motion Only' & input$fear_minus_neut_exclude == 'Yes'~ 'modLinearExclude',
        input$fear_minus_neut_modelType == 'Linear' & input$fear_minus_neut_covariates == 'Motion + Scanner' ~ 'modLinearScanner',
        input$fear_minus_neut_modelType == 'Linear' & input$fear_minus_neut_covariates == 'Motion + Block' ~ 'modLinearBlock',
        input$fear_minus_neut_modelType == 'Linear' & input$fear_minus_neut_covariates == 'Motion + Scanner + Block' ~ 'modLinearBlockScanner',
        input$fear_minus_neut_modelType == 'Quadratic' & input$fear_minus_neut_covariates == 'Motion Only' & input$fear_minus_neut_exclude == 'No'~ 'modQuadratic',
        input$fear_minus_neut_modelType == 'Quadratic' & input$fear_minus_neut_covariates == 'Motion Only' & input$fear_minus_neut_exclude == 'Yes'~ 'modQuadraticExclude',
        input$fear_minus_neut_modelType == 'Quadratic' & input$fear_minus_neut_covariates == 'Motion + Scanner + Block' ~ 'modQuadraticBlockScanner',
        input$fear_minus_neut_modelType == 'Quadratic' & input$fear_minus_neut_exclude == 'Yes' ~ 'modQuadraticExclude',
        input$fear_minus_neut_modelType == 'Linear' & input$fear_minus_neut_exclude == 'Yes' ~ 'modLinearExclude')
    }
    index_select_frame = dplyr::filter(reactivity_sca_fear_minus_neut_frame_mod, 
                                       tstat == tstat_choice, 
                                       model_type == model_type_choice,
                                       amyg_right == amyg_right_choice, 
                                       amyg_left == amyg_left_choice, 
                                       amyg_high_sig == amyg_high_sig_choice,
                                       amyg_low_sig == amyg_low_sig_choice,
                                       native_space == amyg_native_choice,
                                       glm_fsl == glm_afni_choice,
                                       hrf_2gamma == hrf_2g_choice,
                                       motion_reg6 == motion_choice6,
                                       motion_reg24 == motion_choice24,
                                       exclude_prev == exclude_choice,
                                       highpass == frequency_choice,
                                       robust == robust_choice)
    print(paste0(nrow(index_select_frame), 'selected indices'))
    if (nrow(index_select_frame) ==1){
      # the selected index of the model to look at
      index_select = index_select_frame$index[1]
      
      # Filter raw data, model predictions, and coefs based participant choice
      filtered_model_preds = dplyr::filter(reactivity_preds_fear_minus_neut, model_type == model_type_choice, 
                                           index == index_select, robust == robust_choice,
                                           scanner ==1, blockBin == 'first')
      filtered_raw_data = dplyr::filter(reactivity_fear_minus_neut_raw_data, index == index_select)
      filtered_coef = dplyr::filter(reactivity_sca_fear_minus_neut_frame, index == index_select, model_type == model_type_choice, 
                                    robust == robust_choice)
      filtered_coef_long = dplyr::filter(reactivity_sca_fear_minus_neut_long, index == index_select, 
                                         model_type == model_type_choice) 
      
      # plot selected model predictions (right)
      selected_model_pred = ggplot(data = filtered_raw_data, aes(x = Age, y = reactivity)) +
        geom_hline(yintercept = 0, lty = 2) +
        geom_point(alpha = .5) +
        geom_line(aes(group = Subject), alpha = .2) +
        geom_ribbon(data = filtered_model_preds, aes(x = Age, y = Estimate, 
                                                     ymin = Q2.5, ymax = Q97.5), 
                    alpha = .3) +
        geom_line(data = filtered_model_preds, aes(x = Age, y = Estimate), lwd = 2) +
        theme_classic() +
        labs(y = 'Amygdala Reactivity') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
      
      # plot sca model estimates (left)
      reactivity_sca_fear_minus_neut_top =  reactivity_sca_fear_minus_neut_top + 
        geom_point(data = filtered_coef, size = 4, color = 'black') + 
        geom_errorbar(data = filtered_coef, aes(ymin = conf.low, ymax = conf.high), width = 0, lwd = 1, color = 'black') +
        labs(x = 'Model ranked by age-related change coef')
      
      # make the panel plot
      cowplot::plot_grid(reactivity_sca_fear_minus_neut_top, selected_model_pred, 
                         ncol = 2, rel_widths = c(1,1), labels = c('Coefficients for all models', 'Selected model predictions'))
      
    }
    # IF USER SELECTS A MODEL SPEC NOT AVAILABLE
    else{
      selected_model_pred = ggplot(data = reactivity_fear_minus_neut_raw_data, aes(x = Age, y = reactivity)) +
        geom_hline(yintercept = 0, lty = 2) +
        theme_classic() +
        labs(title = '', y = 'Amygdala Reactivity') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1') 
      
      # make the panel plot
      cowplot::plot_grid(reactivity_sca_fear_minus_neut_top, selected_model_pred, 
                         ncol = 2, rel_widths = c(1,1), labels = c('Coefficients for all models', 'No models of this specification!'))
    }
  })
  
  # fear > baseline ppi plot ------------------------------------------------
    output$plot_ppi_fear = renderPlot({
      ppi_decision_frame_fear_mod = ppi_sca_fear$sca_decision_frame
      ppi_decision_frame_fear_mod[ppi_decision_frame_fear_mod == '|'] = 'yes'
      
      ppi_decision_frame_fear_mod[is.na(ppi_decision_frame_fear_mod)] = 'no'
      
      quadratic_choice = ifelse(input$ppi_fear_modelType == 'Quadratic', 'yes', 'no')
      pfc_choice = case_when(input$ppi_fear_mpfc_roi == 'mPFC 1' ~ 'mpfc1',
                             input$ppi_fear_mpfc_roi == 'mPFC 2' ~ 'mpfc2',
                             input$ppi_fear_mpfc_roi == 'mPFC 3' ~ 'mpfc3',
                             input$ppi_fear_mpfc_roi == 'large vmPFC' ~ 'mpfc_big')
      ctrl_block_choice = ifelse(grepl('Block', input$ppi_fear_covariates), 'yes', 'no')
      ctrl_scanner_choice =  ifelse(grepl('Scanner', input$ppi_fear_covariates), 'yes', 'no')
      deconv_choice = ifelse(input$ppi_fear_deconvolution == 'Yes', 'yes', 'no')
      robust_choice = ifelse(input$ppi_fear_robust == 'Yes', 'yes', 'no')
      tstat_choice = ifelse(input$ppi_fear_tstat == 'T-Stat', 'yes', 'no')
      exclude_choice = ifelse(input$ppi_fear_exclude == 'Yes', 'yes', 'no')
      random_slopes_choice = ifelse(grepl('Slopes', input$ppi_fear_randomEffects), 'no', 'yes')
      
      ppi_decision_frame_fear_mod = ppi_decision_frame_fear_mod[ppi_decision_frame_fear_mod[pfc_choice] == 'yes', ]
      
      ppi_decision_frame_fear_mod = dplyr::filter(ppi_decision_frame_fear_mod, 
                                             quadratic == quadratic_choice,
                                             ctrl_block == ctrl_block_choice,
                                             ctrl_scanner == ctrl_scanner_choice,
                                             robust == robust_choice, 
                                             tstat == tstat_choice,
                                             exclude_prev == exclude_choice,
                                             random_slopes == random_slopes_choice,
                                             deconvolution == deconv_choice)
      
      
      # remove layers for median model error bar + point
      ppi_sca_fear$sca_top$layers[[6]] = NULL
      ppi_sca_fear$sca_top$layers[[5]] = NULL
      
      print(nrow(ppi_decision_frame_fear_mod))
      if (nrow(ppi_decision_frame_fear_mod) ==1){
        left_plot_ppi_fear = ppi_sca_fear$sca_top + 
          geom_point(data = ppi_decision_frame_fear_mod, aes(x = rank, y = estimate), size = 3, color = 'black') +
          geom_errorbar(data = ppi_decision_frame_fear_mod, aes(x = rank, y = estimate, ymin = lower, ymax = upper), width = 0, color = 'black') +
          labs(x = 'Models ranked by age-related change coef')
        
        
        ppi_raw_data_fear_f = dplyr::filter(ppi_raw_data_fear, deconvolution == deconv_choice, tstat == tstat_choice)
        ppi_raw_data_fear_f = ppi_raw_data_fear_f[ppi_raw_data_fear_f[pfc_choice] == 'yes', ]
        
        if (exclude_choice == 'yes'){
          ppi_raw_data_fear_f = dplyr::filter(ppi_raw_data_fear_f, prev_studied == 'no')
        }
        
        
        ppi_preds_fear_mod = dplyr::filter(ppi_preds_fear, 
                                           quadratic == quadratic_choice,
                                           ctrl_block == ctrl_block_choice,
                                           ctrl_scanner == ctrl_scanner_choice,
                                           robust == robust_choice, 
                                           tstat == tstat_choice,
                                           exclude_prev == exclude_choice,
                                           random_slopes == random_slopes_choice,
                                           deconvolution == deconv_choice)
        
        ppi_preds_fear_mod = ppi_preds_fear_mod[ppi_preds_fear_mod[pfc_choice] == 'yes', ]
        
        pred_plot_ppi_fear = ppi_preds_fear_mod %>%
          ggplot(data = ., aes(x = age, y = Estimate)) +
          geom_point(data = ppi_raw_data_fear_f, aes(x = Age, y = ppi), alpha = .5) +
          geom_line(data = ppi_raw_data_fear_f, aes(x = Age, y = ppi, group = Subject), alpha = .2) +
          geom_hline(yintercept = 0, lty = 2) +
          geom_ribbon(aes(ymin = Q2.5, ymax = Q97.5), alpha = .3) +
          geom_line(lwd = 2) +
          theme_classic() + 
          labs(x = 'Age', y = 'Estimated Amyg-mPFC PPI')
      } else{
        # plots if user selects combination of specs that don't exist
        left_plot_ppi_fear = ppi_sca_fear$sca_top + labs(x = 'Models ranked by age-related change coef')
        pred_plot_ppi_fear = ppi_raw_data_fear %>%
          ggplot(data = ., aes(x = Age, y = ppi)) +
          theme_classic() +
          ylim(-3, 3) +
          labs(x = 'Age', y = 'Estimated Amyg-mPFC PPI') +
          annotate(geom="text", x=0, y=0, label="No models of this specification!",
                   color="red")
      }
      
      
      cowplot::plot_grid(left_plot_ppi_fear, pred_plot_ppi_fear, labels = c('Coefficients for all models', 'Selected model predictions'))
    })
    
    # neutral > baseline ppi plot ------------------------------------------------
    output$plot_ppi_neutral = renderPlot({
      ppi_decision_frame_neutral_mod = ppi_sca_neut$sca_decision_frame
      ppi_decision_frame_neutral_mod[ppi_decision_frame_neutral_mod == '|'] = 'yes'
      
      ppi_decision_frame_neutral_mod[is.na(ppi_decision_frame_neutral_mod)] = 'no'
      
      quadratic_choice = ifelse(input$ppi_neutral_modelType == 'Quadratic', 'yes', 'no')
      pfc_choice = case_when(input$ppi_neutral_mpfc_roi == 'mPFC 1' ~ 'mpfc1',
                             input$ppi_neutral_mpfc_roi == 'mPFC 2' ~ 'mpfc2',
                             input$ppi_neutral_mpfc_roi == 'mPFC 3' ~ 'mpfc3',
                             input$ppi_neutral_mpfc_roi == 'large vmPFC' ~ 'mpfc_big')
      ctrl_block_choice = ifelse(grepl('Block', input$ppi_neutral_covariates), 'yes', 'no')
      ctrl_scanner_choice =  ifelse(grepl('Scanner', input$ppi_neutral_covariates), 'yes', 'no')
      deconv_choice = ifelse(input$ppi_neutral_deconvolution == 'Yes', 'yes', 'no')
      robust_choice = ifelse(input$ppi_neutral_robust == 'Yes', 'yes', 'no')
      tstat_choice = ifelse(input$ppi_neutral_tstat == 'T-Stat', 'yes', 'no')
      exclude_choice = ifelse(input$ppi_neutral_exclude == 'Yes', 'yes', 'no')
      random_slopes_choice = ifelse(grepl('Slopes', input$ppi_neutral_randomEffects), 'no', 'yes')
      
      ppi_decision_frame_neutral_mod = ppi_decision_frame_neutral_mod[ppi_decision_frame_neutral_mod[pfc_choice] == 'yes', ]
      
      ppi_decision_frame_neutral_mod = dplyr::filter(ppi_decision_frame_neutral_mod, 
                                                  quadratic == quadratic_choice,
                                                  ctrl_block == ctrl_block_choice,
                                                  ctrl_scanner == ctrl_scanner_choice,
                                                  robust == robust_choice, 
                                                  tstat == tstat_choice,
                                                  exclude_prev == exclude_choice,
                                                  random_slopes == random_slopes_choice,
                                                  deconvolution == deconv_choice)
      
      
      # remove layers for median model error bar + point
      ppi_sca_neut$sca_top$layers[[6]] = NULL
      ppi_sca_neut$sca_top$layers[[5]] = NULL
      
      print(nrow(ppi_decision_frame_neutral_mod))
      if (nrow(ppi_decision_frame_neutral_mod) ==1){
        left_plot_ppi_neutral = ppi_sca_neut$sca_top + 
          geom_point(data = ppi_decision_frame_neutral_mod, aes(x = rank, y = estimate), size = 3, color = 'black') +
          geom_errorbar(data = ppi_decision_frame_neutral_mod, aes(x = rank, y = estimate, ymin = lower, ymax = upper), width = 0, color = 'black') +
          labs(x = 'Models ranked by age-related change coef')
        
        
        ppi_raw_data_neutral_f = dplyr::filter(ppi_raw_data_neutral, deconvolution == deconv_choice, tstat == tstat_choice)
        ppi_raw_data_neutral_f = ppi_raw_data_neutral_f[ppi_raw_data_neutral_f[pfc_choice] == 'yes', ]
        
        if (exclude_choice == 'yes'){
          ppi_raw_data_neutral_f = dplyr::filter(ppi_raw_data_neutral_f, prev_studied == 'no')
        }
        
        
        ppi_preds_neutral_mod = dplyr::filter(ppi_preds_neutral, 
                                           quadratic == quadratic_choice,
                                           ctrl_block == ctrl_block_choice,
                                           ctrl_scanner == ctrl_scanner_choice,
                                           robust == robust_choice, 
                                           tstat == tstat_choice,
                                           exclude_prev == exclude_choice,
                                           random_slopes == random_slopes_choice,
                                           deconvolution == deconv_choice)
        
        ppi_preds_neutral_mod = ppi_preds_neutral_mod[ppi_preds_neutral_mod[pfc_choice] == 'yes', ]
        
        pred_plot_ppi_neutral = ppi_preds_neutral_mod %>%
          ggplot(data = ., aes(x = age, y = Estimate)) +
          geom_point(data = ppi_raw_data_neutral_f, aes(x = Age, y = ppi), alpha = .5) +
          geom_line(data = ppi_raw_data_neutral_f, aes(x = Age, y = ppi, group = Subject), alpha = .2) +
          geom_hline(yintercept = 0, lty = 2) +
          geom_ribbon(aes(ymin = Q2.5, ymax = Q97.5), alpha = .3) +
          geom_line(lwd = 2) +
          theme_classic() + 
          labs(x = 'Age', y = 'Estimated Amyg-mPFC PPI')
      } else{
        # plots if user selects combination of specs that don't exist
        left_plot_ppi_neutral = ppi_sca_neut$sca_top + labs(x = 'Models ranked by age-related change coef')
        pred_plot_ppi_neutral = ppi_raw_data_neutral %>%
          ggplot(data = ., aes(x = Age, y = ppi)) +
          theme_classic() +
          ylim(-3, 3) +
          labs(x = 'Age', y = 'Estimated Amyg-mPFC PPI') +
          annotate(geom="text", x=0, y=0, label="No models of this specification!",
                   color="red")
      }
      
      
      cowplot::plot_grid(left_plot_ppi_neutral, pred_plot_ppi_neutral, labels = c('Coefficients for all models', 'Selected model predictions'))
    })
    
    # fear > neutral ppi plot ------------------------------------------------
    output$plot_ppi_fear_minus_neutral = renderPlot({
      ppi_decision_frame_fear_minus_neutral_mod = ppi_sca_fear_minus_neut$sca_decision_frame
      ppi_decision_frame_fear_minus_neutral_mod[ppi_decision_frame_fear_minus_neutral_mod == '|'] = 'yes'
      
      ppi_decision_frame_fear_minus_neutral_mod[is.na(ppi_decision_frame_fear_minus_neutral_mod)] = 'no'
      
      quadratic_choice = ifelse(input$ppi_fear_minus_neutral_modelType == 'Quadratic', 'yes', 'no')
      pfc_choice = case_when(input$ppi_fear_minus_neutral_mpfc_roi == 'mPFC 1' ~ 'mpfc1',
                             input$ppi_fear_minus_neutral_mpfc_roi == 'mPFC 2' ~ 'mpfc2',
                             input$ppi_fear_minus_neutral_mpfc_roi == 'mPFC 3' ~ 'mpfc3',
                             input$ppi_fear_minus_neutral_mpfc_roi == 'large vmPFC' ~ 'mpfc_big')
      ctrl_block_choice = ifelse(grepl('Block', input$ppi_fear_minus_neutral_covariates), 'yes', 'no')
      ctrl_scanner_choice =  ifelse(grepl('Scanner', input$ppi_fear_minus_neutral_covariates), 'yes', 'no')
      deconv_choice = ifelse(input$ppi_fear_minus_neutral_deconvolution == 'Yes', 'yes', 'no')
      robust_choice = ifelse(input$ppi_fear_minus_neutral_robust == 'Yes', 'yes', 'no')
      tstat_choice = ifelse(input$ppi_fear_minus_neutral_tstat == 'T-Stat', 'yes', 'no')
      exclude_choice = ifelse(input$ppi_fear_minus_neutral_exclude == 'Yes', 'yes', 'no')
      random_slopes_choice = ifelse(grepl('Slopes', input$ppi_fear_minus_neutral_randomEffects), 'no', 'yes')
      
      ppi_decision_frame_fear_minus_neutral_mod = ppi_decision_frame_fear_minus_neutral_mod[ppi_decision_frame_fear_minus_neutral_mod[pfc_choice] == 'yes', ]
      
      ppi_decision_frame_fear_minus_neutral_mod = dplyr::filter(ppi_decision_frame_fear_minus_neutral_mod, 
                                                     quadratic == quadratic_choice,
                                                     ctrl_block == ctrl_block_choice,
                                                     ctrl_scanner == ctrl_scanner_choice,
                                                     robust == robust_choice, 
                                                     tstat == tstat_choice,
                                                     exclude_prev == exclude_choice,
                                                     random_slopes == random_slopes_choice,
                                                     deconvolution == deconv_choice)
      
      
      # remove layers for median model error bar + point
      ppi_sca_fear_minus_neut$sca_top$layers[[6]] = NULL
      ppi_sca_fear_minus_neut$sca_top$layers[[5]] = NULL
      
      print(nrow(ppi_decision_frame_fear_minus_neutral_mod))
      if (nrow(ppi_decision_frame_fear_minus_neutral_mod) ==1){
        left_plot_ppi_fear_minus_neutral = ppi_sca_fear_minus_neut$sca_top + 
          geom_point(data = ppi_decision_frame_fear_minus_neutral_mod, aes(x = rank, y = estimate), size = 3, color = 'black') +
          geom_errorbar(data = ppi_decision_frame_fear_minus_neutral_mod, aes(x = rank, y = estimate, ymin = lower, ymax = upper), width = 0, color = 'black') +
          labs(x = 'Models ranked by age-related change coef')
        
        
        ppi_raw_data_fear_minus_neutral_f = dplyr::filter(ppi_raw_data_fear_minus_neutral, deconvolution == deconv_choice, tstat == tstat_choice)
        ppi_raw_data_fear_minus_neutral_f = ppi_raw_data_fear_minus_neutral_f[ppi_raw_data_fear_minus_neutral_f[pfc_choice] == 'yes', ]
        
        if (exclude_choice == 'yes'){
          ppi_raw_data_fear_minus_neutral_f = dplyr::filter(ppi_raw_data_fear_minus_neutral_f, prev_studied == 'no')
        }
        
        
        ppi_preds_fear_minus_neutral_mod = dplyr::filter(ppi_preds_fear_minus_neutral, 
                                              quadratic == quadratic_choice,
                                              ctrl_block == ctrl_block_choice,
                                              ctrl_scanner == ctrl_scanner_choice,
                                              robust == robust_choice, 
                                              tstat == tstat_choice,
                                              exclude_prev == exclude_choice,
                                              random_slopes == random_slopes_choice,
                                              deconvolution == deconv_choice)
        
        ppi_preds_fear_minus_neutral_mod = ppi_preds_fear_minus_neutral_mod[ppi_preds_fear_minus_neutral_mod[pfc_choice] == 'yes', ]
        
        pred_plot_ppi_fear_minus_neutral = ppi_preds_fear_minus_neutral_mod %>%
          ggplot(data = ., aes(x = age, y = Estimate)) +
          geom_point(data = ppi_raw_data_fear_minus_neutral_f, aes(x = Age, y = ppi), alpha = .5) +
          geom_line(data = ppi_raw_data_fear_minus_neutral_f, aes(x = Age, y = ppi, group = Subject), alpha = .2) +
          geom_hline(yintercept = 0, lty = 2) +
          geom_ribbon(aes(ymin = Q2.5, ymax = Q97.5), alpha = .3) +
          geom_line(lwd = 2) +
          theme_classic() + 
          labs(x = 'Age', y = 'Estimated Amyg-mPFC PPI')
      } else{
        # plots if user selects combination of specs that don't exist
        left_plot_ppi_fear_minus_neutral = ppi_sca_fear_minus_neut$sca_top + labs(x = 'Models ranked by age-related change coef')
        pred_plot_ppi_fear_minus_neutral = ppi_raw_data_fear_minus_neutral %>%
          ggplot(data = ., aes(x = Age, y = ppi)) +
          theme_classic() +
          ylim(-3, 3) +
          labs(x = 'Age', y = 'Estimated Amyg-mPFC PPI') +
          annotate(geom="text", x=0, y=0, label="No models of this specification!",
                   color="red")
      }
      
      
      cowplot::plot_grid(left_plot_ppi_fear_minus_neutral, pred_plot_ppi_fear_minus_neutral, labels = c('Coefficients for all models', 'Selected model predictions'))
    })
  

    
    # fear bsc plot ------------------------------------------------
    output$plot_bsc_fear = renderPlot({
      bsc_decision_frame_fear_mod = dplyr::filter(bsc_decision_frame, contrast == 'fear')
      
      bsc_decision_frame_fear_mod[bsc_decision_frame_fear_mod == '|'] = 'yes'
      
      bsc_decision_frame_fear_mod[is.na(bsc_decision_frame_fear_mod)] = 'no'
      
      quadratic_choice = ifelse(input$bsc_fear_modelType == 'Quadratic', 'yes', 'no')
      pfc_choice = case_when(input$bsc_fear_mpfc_roi == 'mPFC 1' ~ 'mpfc1',
                             input$bsc_fear_mpfc_roi == 'mPFC 2' ~ 'mpfc2',
                             input$bsc_fear_mpfc_roi == 'mPFC 3' ~ 'mpfc3',
                             input$bsc_fear_mpfc_roi == 'large vmPFC' ~ 'mpfc_big')
      
      
      amyg_choice = case_when(
        input$bsc_fear_amyg_roi == 'Harvard Oxford - Bilateral' ~ 'amyg_bilateral',
        input$bsc_fear_amyg_roi == 'Harvard Oxford - Left' ~ 'amyg_left',
        input$bsc_fear_amyg_roi == 'Harvard Oxford - Right' ~ 'amyg_right'
      )
      
      ctrl_block_choice = ifelse(grepl('Block', input$bsc_fear_covariates), 'yes', 'no')
      ctrl_scanner_choice =  ifelse(grepl('Scanner', input$bsc_fear_covariates), 'yes', 'no')
      gsr_choice = ifelse(input$bsc_fear_gsr == 'Yes', 'yes', 'no')
      random_slopes_choice = ifelse(grepl('Slopes', input$bsc_fear_randomEffects), 'no', 'yes')
      
      # pick amyg & mPFC ROI
      bsc_decision_frame_fear_mod = bsc_decision_frame_fear_mod[bsc_decision_frame_fear_mod[pfc_choice] == 'yes', ]
      bsc_decision_frame_fear_mod = bsc_decision_frame_fear_mod[bsc_decision_frame_fear_mod[amyg_choice] == 'yes', ]
      
      
      bsc_decision_frame_fear_mod = dplyr::filter(bsc_decision_frame_fear_mod, 
                                                  quadratic == quadratic_choice,
                                                  ctrl_block == ctrl_block_choice,
                                                  ctrl_scanner == ctrl_scanner_choice,
                                                  random_slopes == random_slopes_choice,
                                                  gsr == gsr_choice)
      
      
      # remove layers for median model error bar + point
      fear_bsc_sca$sca_top$layers[[6]] = NULL
      fear_bsc_sca$sca_top$layers[[5]] = NULL
      
      print(nrow(bsc_decision_frame_fear_mod))
      if (nrow(bsc_decision_frame_fear_mod) ==1){
        left_plot_bsc_fear = fear_bsc_sca$sca_top + 
          geom_point(data = bsc_decision_frame_fear_mod, aes(x = rank, y = estimate), size = 3, color = 'black') +
          geom_errorbar(data = bsc_decision_frame_fear_mod, aes(x = rank, y = estimate, ymin = lower, ymax = upper), width = 0, color = 'black') +
          labs(x = 'Models ranked by age-related change coef')
        
        
        bsc_raw_data_fear_f = dplyr::filter(bsc_raw_data_fear, gsr == gsr_choice)
        bsc_raw_data_fear_f = bsc_raw_data_fear_f[bsc_raw_data_fear_f[pfc_choice] == 'yes', ]
        bsc_raw_data_fear_f = bsc_raw_data_fear_f[bsc_raw_data_fear_f[amyg_choice] == 'yes', ]

        
        bsc_preds_fear_mod = dplyr::filter(bsc_preds, 
                                           contrast == 'fear',
                                           quadratic == quadratic_choice,
                                           ctrl_block == ctrl_block_choice,
                                           ctrl_scanner == ctrl_scanner_choice,
                                           random_slopes == random_slopes_choice,
                                           gsr == gsr_choice)
        
        bsc_preds_fear_mod = bsc_preds_fear_mod[bsc_preds_fear_mod[pfc_choice] == 'yes', ]
        bsc_preds_fear_mod = bsc_preds_fear_mod[bsc_preds_fear_mod[amyg_choice] == 'yes', ]
        
        pred_plot_bsc_fear = bsc_preds_fear_mod %>%
          ggplot(data = ., aes(x = age, y = Estimate)) +
          geom_point(data = bsc_raw_data_fear_f, aes(x = Age, y = bsc), alpha = .5) +
          geom_line(data = bsc_raw_data_fear_f, aes(x = Age, y = bsc, group = Subject), alpha = .2) +
          geom_hline(yintercept = 0, lty = 2) +
          geom_ribbon(aes(ymin = Q2.5, ymax = Q97.5), alpha = .3) +
          geom_line(lwd = 2) +
          theme_classic() + 
          labs(x = 'Age', y = 'Estimated Amyg-mPFC BSC')
      } else{
        # plots if user selects combination of specs that don't exist
        left_plot_bsc_fear = fear_bsc_sca$sca_top + labs(x = 'Models ranked by age-related change coef')
        pred_plot_bsc_fear = bsc_raw_data_fear %>%
          ggplot(data = ., aes(x = Age, y = bsc)) +
          theme_classic() +
          ylim(-3, 3) +
          labs(x = 'Age', y = 'Estimated Amyg-mPFC BSC') +
          annotate(geom="text", x=0, y=0, label="No models of this specification!",
                   color="red")
      }
      
      
      cowplot::plot_grid(left_plot_bsc_fear, pred_plot_bsc_fear, labels = c('Coefficients for all models', 'Selected model predictions'))
    })
    
    # neutral bsc plot ------------------------------------------------
    output$plot_bsc_neutral = renderPlot({
      bsc_decision_frame_neutral_mod = dplyr::filter(bsc_decision_frame, contrast == 'neutral')
      
      bsc_decision_frame_neutral_mod[bsc_decision_frame_neutral_mod == '|'] = 'yes'
      
      bsc_decision_frame_neutral_mod[is.na(bsc_decision_frame_neutral_mod)] = 'no'
      
      quadratic_choice = ifelse(input$bsc_neutral_modelType == 'Quadratic', 'yes', 'no')
      pfc_choice = case_when(input$bsc_neutral_mpfc_roi == 'mPFC 1' ~ 'mpfc1',
                             input$bsc_neutral_mpfc_roi == 'mPFC 2' ~ 'mpfc2',
                             input$bsc_neutral_mpfc_roi == 'mPFC 3' ~ 'mpfc3',
                             input$bsc_neutral_mpfc_roi == 'large vmPFC' ~ 'mpfc_big')
      
      
      amyg_choice = case_when(
        input$bsc_neutral_amyg_roi == 'Harvard Oxford - Bilateral' ~ 'amyg_bilateral',
        input$bsc_neutral_amyg_roi == 'Harvard Oxford - Left' ~ 'amyg_left',
        input$bsc_neutral_amyg_roi == 'Harvard Oxford - Right' ~ 'amyg_right'
      )
      
      ctrl_block_choice = ifelse(grepl('Block', input$bsc_neutral_covariates), 'yes', 'no')
      ctrl_scanner_choice =  ifelse(grepl('Scanner', input$bsc_neutral_covariates), 'yes', 'no')
      gsr_choice = ifelse(input$bsc_neutral_gsr == 'Yes', 'yes', 'no')
      random_slopes_choice = ifelse(grepl('Slopes', input$bsc_neutral_randomEffects), 'no', 'yes')
      
      # pick amyg & mPFC ROI
      bsc_decision_frame_neutral_mod = bsc_decision_frame_neutral_mod[bsc_decision_frame_neutral_mod[pfc_choice] == 'yes', ]
      bsc_decision_frame_neutral_mod = bsc_decision_frame_neutral_mod[bsc_decision_frame_neutral_mod[amyg_choice] == 'yes', ]
      
      
      bsc_decision_frame_neutral_mod = dplyr::filter(bsc_decision_frame_neutral_mod, 
                                                  quadratic == quadratic_choice,
                                                  ctrl_block == ctrl_block_choice,
                                                  ctrl_scanner == ctrl_scanner_choice,
                                                  random_slopes == random_slopes_choice,
                                                  gsr == gsr_choice)
      
      
      # remove layers for median model error bar + point
      neut_bsc_sca$sca_top$layers[[6]] = NULL
      neut_bsc_sca$sca_top$layers[[5]] = NULL
      
      print(nrow(bsc_decision_frame_neutral_mod))
      if (nrow(bsc_decision_frame_neutral_mod) ==1){
        left_plot_bsc_neutral = neut_bsc_sca$sca_top + 
          geom_point(data = bsc_decision_frame_neutral_mod, aes(x = rank, y = estimate), size = 3, color = 'black') +
          geom_errorbar(data = bsc_decision_frame_neutral_mod, aes(x = rank, y = estimate, ymin = lower, ymax = upper), width = 0, color = 'black') +
          labs(x = 'Models ranked by age-related change coef')
        
        
        bsc_raw_data_neutral_f = dplyr::filter(bsc_raw_data_neutral, gsr == gsr_choice)
        bsc_raw_data_neutral_f = bsc_raw_data_neutral_f[bsc_raw_data_neutral_f[pfc_choice] == 'yes', ]
        bsc_raw_data_neutral_f = bsc_raw_data_neutral_f[bsc_raw_data_neutral_f[amyg_choice] == 'yes', ]
        
        
        bsc_preds_neutral_mod = dplyr::filter(bsc_preds, 
                                           contrast == 'neutral',
                                           quadratic == quadratic_choice,
                                           ctrl_block == ctrl_block_choice,
                                           ctrl_scanner == ctrl_scanner_choice,
                                           random_slopes == random_slopes_choice,
                                           gsr == gsr_choice)
        
        bsc_preds_neutral_mod = bsc_preds_neutral_mod[bsc_preds_neutral_mod[pfc_choice] == 'yes', ]
        bsc_preds_neutral_mod = bsc_preds_neutral_mod[bsc_preds_neutral_mod[amyg_choice] == 'yes', ]
        
        pred_plot_bsc_neutral = bsc_preds_neutral_mod %>%
          ggplot(data = ., aes(x = age, y = Estimate)) +
          geom_point(data = bsc_raw_data_neutral_f, aes(x = Age, y = bsc), alpha = .5) +
          geom_line(data = bsc_raw_data_neutral_f, aes(x = Age, y = bsc, group = Subject), alpha = .2) +
          geom_hline(yintercept = 0, lty = 2) +
          geom_ribbon(aes(ymin = Q2.5, ymax = Q97.5), alpha = .3) +
          geom_line(lwd = 2) +
          theme_classic() + 
          labs(x = 'Age', y = 'Estimated Amyg-mPFC BSC')
      } else{
        # plots if user selects combination of specs that don't exist
        left_plot_bsc_neutral = neut_bsc_sca$sca_top + labs(x = 'Models ranked by age-related change coef')
        pred_plot_bsc_neutral = bsc_raw_data_neutral %>%
          ggplot(data = ., aes(x = Age, y = bsc)) +
          theme_classic() +
          ylim(-3, 3) +
          labs(x = 'Age', y = 'Estimated Amyg-mPFC BSC') +
          annotate(geom="text", x=0, y=0, label="No models of this specification!",
                   color="red")
      }
      
      
      cowplot::plot_grid(left_plot_bsc_neutral, pred_plot_bsc_neutral, labels = c('Coefficients for all models', 'Selected model predictions'))
    })
    
    
    # fear > neutral bsc plot ------------------------------------------------
    output$plot_bsc_fear_minus_neutral = renderPlot({
      bsc_decision_frame_fear_minus_neutral_mod = dplyr::filter(bsc_decision_frame, contrast == 'fear_minus_neutral')
      
      bsc_decision_frame_fear_minus_neutral_mod[bsc_decision_frame_fear_minus_neutral_mod == '|'] = 'yes'
      
      bsc_decision_frame_fear_minus_neutral_mod[is.na(bsc_decision_frame_fear_minus_neutral_mod)] = 'no'
      
      quadratic_choice = ifelse(input$bsc_fear_minus_neutral_modelType == 'Quadratic', 'yes', 'no')
      pfc_choice = case_when(input$bsc_fear_minus_neutral_mpfc_roi == 'mPFC 1' ~ 'mpfc1',
                             input$bsc_fear_minus_neutral_mpfc_roi == 'mPFC 2' ~ 'mpfc2',
                             input$bsc_fear_minus_neutral_mpfc_roi == 'mPFC 3' ~ 'mpfc3',
                             input$bsc_fear_minus_neutral_mpfc_roi == 'large vmPFC' ~ 'mpfc_big')
      
      
      amyg_choice = case_when(
        input$bsc_fear_minus_neutral_amyg_roi == 'Harvard Oxford - Bilateral' ~ 'amyg_bilateral',
        input$bsc_fear_minus_neutral_amyg_roi == 'Harvard Oxford - Left' ~ 'amyg_left',
        input$bsc_fear_minus_neutral_amyg_roi == 'Harvard Oxford - Right' ~ 'amyg_right'
      )
      
      ctrl_block_choice = ifelse(grepl('Block', input$bsc_fear_minus_neutral_covariates), 'yes', 'no')
      ctrl_scanner_choice =  ifelse(grepl('Scanner', input$bsc_fear_minus_neutral_covariates), 'yes', 'no')
      gsr_choice = ifelse(input$bsc_fear_minus_neutral_gsr == 'Yes', 'yes', 'no')
      random_slopes_choice = ifelse(grepl('Slopes', input$bsc_fear_minus_neutral_randomEffects), 'no', 'yes')
      
      # pick amyg & mPFC ROI
      bsc_decision_frame_fear_minus_neutral_mod = bsc_decision_frame_fear_minus_neutral_mod[bsc_decision_frame_fear_minus_neutral_mod[pfc_choice] == 'yes', ]
      bsc_decision_frame_fear_minus_neutral_mod = bsc_decision_frame_fear_minus_neutral_mod[bsc_decision_frame_fear_minus_neutral_mod[amyg_choice] == 'yes', ]
      
      
      bsc_decision_frame_fear_minus_neutral_mod = dplyr::filter(bsc_decision_frame_fear_minus_neutral_mod, 
                                                     quadratic == quadratic_choice,
                                                     ctrl_block == ctrl_block_choice,
                                                     ctrl_scanner == ctrl_scanner_choice,
                                                     random_slopes == random_slopes_choice,
                                                     gsr == gsr_choice)
      
      
      # remove layers for median model error bar + point
      fear_minus_neut_bsc_sca$sca_top$layers[[6]] = NULL
      fear_minus_neut_bsc_sca$sca_top$layers[[5]] = NULL
      
      print(nrow(bsc_decision_frame_fear_minus_neutral_mod))
      if (nrow(bsc_decision_frame_fear_minus_neutral_mod) ==1){
        left_plot_bsc_fear_minus_neutral = fear_minus_neut_bsc_sca$sca_top + 
          geom_point(data = bsc_decision_frame_fear_minus_neutral_mod, aes(x = rank, y = estimate), size = 3, color = 'black') +
          geom_errorbar(data = bsc_decision_frame_fear_minus_neutral_mod, aes(x = rank, y = estimate, ymin = lower, ymax = upper), width = 0, color = 'black') +
          labs(x = 'Models ranked by age-related change coef')
        
        
        bsc_raw_data_fear_minus_neutral_f = dplyr::filter(bsc_raw_data_fear_minus_neutral, gsr == gsr_choice)
        bsc_raw_data_fear_minus_neutral_f = bsc_raw_data_fear_minus_neutral_f[bsc_raw_data_fear_minus_neutral_f[pfc_choice] == 'yes', ]
        bsc_raw_data_fear_minus_neutral_f = bsc_raw_data_fear_minus_neutral_f[bsc_raw_data_fear_minus_neutral_f[amyg_choice] == 'yes', ]
        
        
        bsc_preds_fear_minus_neutral_mod = dplyr::filter(bsc_preds, 
                                              contrast == 'fear_minus_neutral',
                                              quadratic == quadratic_choice,
                                              ctrl_block == ctrl_block_choice,
                                              ctrl_scanner == ctrl_scanner_choice,
                                              random_slopes == random_slopes_choice,
                                              gsr == gsr_choice)
        
        bsc_preds_fear_minus_neutral_mod = bsc_preds_fear_minus_neutral_mod[bsc_preds_fear_minus_neutral_mod[pfc_choice] == 'yes', ]
        bsc_preds_fear_minus_neutral_mod = bsc_preds_fear_minus_neutral_mod[bsc_preds_fear_minus_neutral_mod[amyg_choice] == 'yes', ]
        
        pred_plot_bsc_fear_minus_neutral = bsc_preds_fear_minus_neutral_mod %>%
          ggplot(data = ., aes(x = age, y = Estimate)) +
          geom_point(data = bsc_raw_data_fear_minus_neutral_f, aes(x = Age, y = bsc), alpha = .5) +
          geom_line(data = bsc_raw_data_fear_minus_neutral_f, aes(x = Age, y = bsc, group = Subject), alpha = .2) +
          geom_hline(yintercept = 0, lty = 2) +
          geom_ribbon(aes(ymin = Q2.5, ymax = Q97.5), alpha = .3) +
          geom_line(lwd = 2) +
          theme_classic() + 
          labs(x = 'Age', y = 'Estimated Amyg-mPFC BSC')
      } else{
        # plots if user selects combination of specs that don't exist
        left_plot_bsc_fear_minus_neutral = fear_minus_neut_bsc_sca$sca_top + labs(x = 'Models ranked by age-related change coef')
        pred_plot_bsc_fear_minus_neutral = bsc_raw_data_fear_minus_neutral %>%
          ggplot(data = ., aes(x = Age, y = bsc)) +
          theme_classic() +
          ylim(-3, 3) +
          labs(x = 'Age', y = 'Estimated Amyg-mPFC BSC') +
          annotate(geom="text", x=0, y=0, label="No models of this specification!",
                   color="red")
      }
      
      
      cowplot::plot_grid(left_plot_bsc_fear_minus_neutral, pred_plot_bsc_fear_minus_neutral, labels = c('Coefficients for all models', 'Selected model predictions'))
    })
    
    
    
# close out server side ---------------------------------------------------

    
})
shinyApp(ui = ui, server = server, options=list(height=700))