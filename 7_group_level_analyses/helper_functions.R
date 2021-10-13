# Function to turn outliers above num_sds into NAs
na_outliers = function(column, num_sds){
  column_mean = mean(column, na.rm = TRUE)
  column_sd = sd(column, na.rm = TRUE)
  upr_bound = column_mean + num_sds*column_sd
  lwr_bound = column_mean - num_sds*column_sd
  num_removed = (column > upr_bound | column < lwr_bound)
  print(paste('Making',sum(num_removed, na.rm = TRUE), 'data points NA'))
  column[column > upr_bound | column < lwr_bound] = NA
  return(column)
}

# GeomFlatViolin() --------------------------------------------------------
#https://www.rdocumentation.org/packages/PupillometryR/versions/0.0.2/topics/geom_flat_violin

# Not my function, but putting it here in case the github link breaks
GeomFlatViolin <-
  ggproto("GeomFlatViolin", Geom,
          setup_data = function(data, params) {
            data$width <- data$width %||%
              params$width %||% (resolution(data$x, FALSE) * 0.9)
            
            # ymin, ymax, xmin, and xmax define the bounding rectangle for each group
            data %>%
              group_by(group) %>%
              mutate(ymin = min(y),
                     ymax = max(y),
                     xmin = x,
                     xmax = x + width / 2)
            
          },
          
          draw_group = function(data, panel_scales, coord) {
            # Find the points for the line to go all the way around
            data <- transform(data, xminv = x,
                              xmaxv = x + violinwidth * (xmax - x))
            
            # Make sure it's sorted properly to draw the outline
            newdata <- rbind(plyr::arrange(transform(data, x = xminv), y),
                             plyr::arrange(transform(data, x = xmaxv), -y))
            
            # Close the polygon: set first and last point the same
            # Needed for coord_polar and such
            newdata <- rbind(newdata, newdata[1,])
            
            ggplot2:::ggname("geom_flat_violin", GeomPolygon$draw_panel(newdata, panel_scales, coord))
          },
          
          draw_key = draw_key_polygon,
          
          default_aes = aes(weight = 1, colour = "grey20", fill = "white", size = 0.5,
                            alpha = NA, linetype = "solid"),
          
          required_aes = c("x", "y")
  )

geom_flat_violin <- function(mapping = NULL, data = NULL, stat = "ydensity",
                             position = "dodge", trim = TRUE, scale = "area",
                             show.legend = NA, inherit.aes = TRUE, ...) {
  layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomFlatViolin,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      trim = trim,
      scale = scale,
      ...
    )
  )
}


# SCA Plot Function -------------------------------------------------------
make_sca_plot = function(coefs, 
                         fork_list, 
                         contrast_type, 
                         plot_title,
                         y_label, 
                         term_choice){
  sca_decision_frame = coefs %>%
    dplyr::filter(term == term_choice) %>%
    dplyr::arrange(estimate) %>%
    mutate(., rank = 1:nrow(.),
           tstat = ifelse(grepl('tstat', pipeline), '|', NA),
           quadratic = ifelse(grepl('Quadratic', model_type), '|', NA),
           random_slopes = ifelse(grepl('NoRandomSlopes', model_type), '|', NA),
           ctrl_scanner = ifelse(grepl('Scanner', model_type), '|', NA),
           ctrl_block = ifelse(grepl('Block', model_type), '|', NA),
           exclude_prev = ifelse(grepl('Exclude', model_type), '|', NA),
           amyg_right = ifelse(grepl('right', tolower(pipeline)), '|', NA),
           amyg_left = ifelse(grepl('left', tolower(pipeline)), '|', NA),
           amyg_bilateral = ifelse(grepl('bilateral', tolower(pipeline)), '|', NA),
           amyg_low_sig = ifelse(grepl('low', tolower(pipeline)), '|', NA),
           amyg_high_sig = ifelse(grepl('high', tolower(pipeline)), '|', NA),
           native_space = ifelse(grepl('native', pipeline), '|', NA),
           glm_fsl= ifelse((grepl('og', pipeline) | grepl('fsl', pipeline)), NA, '|'),
           motion_reg6 = case_when(
             grepl('fsl_1', pipeline) ~ '|',
             grepl('fsl_3', pipeline) ~ '|',
             grepl('afni_5', pipeline) ~ '|',
             grepl('afni_6', pipeline) ~ '|'),
           motion_reg18 = case_when(
             grepl('fsl_2', pipeline) ~ '|',
             grepl('fsl_4', pipeline) ~ '|',
             grepl('afni_7', pipeline) ~ '|',
             grepl('afni_7', pipeline) ~ '|'),
           motion_reg24 = ifelse(grepl('og', pipeline), '|', NA),
           hrf_2gamma = case_when(
             grepl('fsl_1', pipeline) ~ '|',
             grepl('fsl_2', pipeline) ~ '|',
             grepl('og', pipeline) ~ '|'),
           highpass = case_when(
             grepl('afni_6', pipeline) ~ '|',
             grepl('afni_8', pipeline) ~ '|'),
           overlap_0 = case_when(
             conf.low < 0 & conf.high < 0 ~ 'neg_y',
             conf.low < 0 & estimate < 0 & conf.high > 0 ~ 'neg_n',
             conf.low < 0 & estimate > 0 & conf.high > 0 ~ 'pos_n',
             conf.low  > 0 & conf.high > 0 ~ 'pos_y',
           ))
  
  # median model
  median_model_frame = sca_decision_frame %>%
    summarise(estimate = median(estimate), conf.low = median(conf.low), conf.high = median(conf.high), rank= median(rank))
  
  sca_decision_frame$overlap_0 = factor(sca_decision_frame$overlap_0, levels = c("neg_y", "neg_n", "pos_n", "pos_y"))
  
  
  sca_decision_frame_long = sca_decision_frame %>%
    tidyr::gather(key = 'fork', value = 'choice', all_of(fork_list)) %>%
    mutate(decisiontype = case_when(
      grepl('amyg', fork) ~ 'Amygdala\n Roi',
      fork == 'native_space' ~ 'Amygdala\n Roi',
      fork %in% c('quadratic', 'random_slopes', 'ctrl_scanner','ctrl_block', 'exclude_prev', 'robust') ~ 'Group-Level\nModel',
      fork %in% c('motion_reg6', 'motion_reg18', 'motion_reg24', 'highpass', 'hrf_2gamma', 
                  'glm_fsl', 'tstat') ~ 'Subject-Level\nModel'
    ))
  
  # get average rank of each pipeline by beta estimate
  sca_decision_frame_long_ranks = sca_decision_frame_long %>%
    dplyr::filter(choice == '|') %>%
    dplyr::group_by(fork) %>%
    summarise(mean_rank = -1*mean(rank))
  
  # join ranks with decision frame
  sca_decision_frame_long = left_join(sca_decision_frame_long, sca_decision_frame_long_ranks)
  
  # rename variables to be human-interpretable
  sca_decision_frame_long$fork  = dplyr::recode(sca_decision_frame_long$fork, 'tstat' = 'use tstats (vs. beta estimates)',
                                                'hrf_2gamma' = '2gamma hrf (vs. 1gamma)',
                                                'highpass' = 'quadratic detrending (vs. highpass)',
                                                'native_space' = 'native space (vs. mni space)',
                                                'glm_fsl' = 'glm in afni (vs. glm in fsl)',
                                                'exclude_prev' = 'exclude previously analyzed participants',
                                                'quadratic' = 'quadratic age term (vs. none)',
                                                'random_slopes' = 'random intercepts only (vs. random slopes)',
                                                'ctrl_block' = 'covariate for task block',
                                                'ctrl_scanner' = 'covariate for scanner used',
                                                'amyg_right' = 'right amygdala',
                                                'amyg_left' =  'left amygdala',
                                                'amyg_bilateral' = 'bilateral amygdala',
                                                'amyg_high_sig' = 'median-split voxels for high signal',
                                                'amyg_low_sig' = 'median-split voxels for low signal',
                                                'motion_reg24' = '24 motion regs (preregistered pipeline)',
                                                'motion_reg18' = '18 motion regs + WM + CSF',
                                                'motion_reg6' = '6 motion regs',
                                                'robust' = 'robust regression (vs. gaussian likelihood)')
  
  sca_decision_frame_long$fork_ordered = reorder(sca_decision_frame_long$fork,  sca_decision_frame_long$mean_rank)
  
  # color palette to code the following:
  # blue = negative, distinct from 0
  # red = negative, not distinct from 0
  # green = positive, not distinct from 0
  # purple = positive, distinct from 0
  if('neg_y' %in% sca_decision_frame$overlap_0){
    my_colors <- RColorBrewer::brewer.pal(4, "Set1")[1:4]
  }else if('neg_n' %in% sca_decision_frame$overlap_0){
    my_colors <- RColorBrewer::brewer.pal(4, "Set1")[2:4]
  }else if('pos_n' %in% sca_decision_frame$overlap_0){
    my_colors <- RColorBrewer::brewer.pal(4, "Set1")[3:4]
  }else{
    my_colors <- RColorBrewer::brewer.pal(4, "Set1")[4:4]
  }
  
  # recode overlap 0 markings for informative legend
  sca_decision_frame$overlap_0 = dplyr::recode(sca_decision_frame$overlap_0,
                                               'neg_y' = '-, 95% PI excluding 0',
                                               'neg_n' = '-, 95% PI including 0',
                                               'pos_n' = '+, 95% PI including 0',
                                               'pos_y' = '+, 95% PI excluding 0')
  
  # If intercept SCA, all group-level models are the same
  if (term_choice == '(Intercept)'){
    sca_decision_frame_long = sca_decision_frame_long %>% dplyr::filter(decisiontype != 'Group-Level\nModel') 
  }
  
  # summary for lower plot
  decision_summary = sca_decision_frame_long %>% 
    group_by(decisiontype, choice, fork, fork_ordered) %>%
    summarise(n = n(), median_rank = median(rank), lwr_rank = quantile(rank, .25), upr_rank = quantile(rank, .75)) %>%
    dplyr::filter(choice =='|')
  
  
  sca_top = ggplot(sca_decision_frame, aes(x = rank, y = estimate, color = overlap_0)) +
    geom_hline(yintercept = 0, lty = 1, color = 'black') +
    geom_hline(yintercept = median(sca_decision_frame$estimate), color = 'black', lty = 2) +
    geom_point(alpha = .5) + 
    geom_errorbar(aes(ymin = conf.low, ymax = conf.high), width = 0, lwd = .15, alpha = .5) +
    geom_point(data = median_model_frame,aes(x = rank, y = estimate), color = 'black') +
    geom_errorbar(data = median_model_frame,aes(x = rank, y = estimate, ymin = conf.low, ymax = conf.high), color = 'black') +
    labs(x = '', y = y_label) +
    theme_classic() +
    theme(legend.position = 'top', legend.title = element_blank()) +
    scale_color_manual(values = my_colors)
  
  sca_bottom = ggplot(sca_decision_frame_long, aes(x = rank, y = fork_ordered, color = overlap_0)) +
    geom_text(aes(label = choice), alpha = .4) +
    labs(x = "Analysis specifications ranked by beta estimates", y = "Decision Points") + 
    theme_bw() + 
    theme(legend.title = element_text(size = 10),
          legend.text = element_text(size = 8),
          axis.text = element_text(color = "black", size = 8),
          legend.position = "none",
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          strip.text.y = element_text(size = 8)) +
    scale_color_manual(values = my_colors) +
    facet_grid(rows = vars(decisiontype), drop = TRUE, scales = 'free_y', space = 'free_y') +
    geom_point(data = decision_summary, aes(x = median_rank, y = fork_ordered), color = 'black') +
    geom_errorbarh(data = decision_summary, aes(x = median_rank, y = fork_ordered, xmin = lwr_rank, xmax = upr_rank), color = 'black')
  
  sca_panel = cowplot::plot_grid(sca_top, sca_bottom, ncol = 1, align = "v", axis = 'lr', labels = c('A', 'B'))
  
  return(list('sca_decision_frame' = sca_decision_frame, 
              'sca_decision_frame_long' = sca_decision_frame_long,
              'sca_top' = sca_top,
              'sca_bottom' = sca_bottom,
              'sca_panel' = sca_panel))
}


# PPI sca plot
make_ppi_sca_plot = function(coefs, 
                         fork_list, 
                         contrast_type, 
                         plot_title,
                         y_label, 
                         term_choice){
  sca_decision_frame = coefs %>%
    dplyr::filter(term == term_choice) %>%
    dplyr::arrange(estimate) %>%
    mutate(., rank = 1:nrow(.),
           tstat = ifelse(grepl('tstat', pipeline), '|', NA),
           quadratic = ifelse(grepl('Quadratic', model_type), '|', NA),
           random_slopes = ifelse(grepl('NoRandomSlopes', model_type), '|', NA),
           ctrl_scanner = ifelse(grepl('Scanner', model_type), '|', NA),
           ctrl_block = ifelse(grepl('Block', model_type), '|', NA),
           exclude_prev = ifelse(grepl('Exclude', model_type), '|', NA),
           deconvolution = ifelse(grepl('no_deconv', pipeline), NA, '|'),
           robust = ifelse(robust == 'yes', '|', NA),
           mpfc1 = ifelse(grepl('mpfc1', pipeline), '|', NA),
           mpfc2 = ifelse(grepl('mpfc2', pipeline), '|', NA),
           mpfc3 = ifelse(grepl('mpfc3', pipeline), '|', NA),
           mpfc_big = ifelse(grepl('vmpfc', pipeline), '|', NA),
           overlap_0 = case_when(
             lower < 0 & upper < 0 ~ 'neg_y',
             lower < 0 & estimate < 0 & upper > 0 ~ 'neg_n',
             lower < 0 & estimate > 0 & upper > 0 ~ 'pos_n',
             lower  > 0 & upper > 0 ~ 'pos_y',
           ))
  
  # median model
  median_model_frame = sca_decision_frame %>%
    summarise(estimate = median(estimate), lower = median(lower), upper = median(upper), rank= median(rank))
  
  sca_decision_frame$overlap_0 = factor(sca_decision_frame$overlap_0, levels = c("neg_y", "neg_n", "pos_n", "pos_y"))
  
  sca_decision_frame_long = sca_decision_frame %>%
    tidyr::gather(key = 'fork', value = 'choice', all_of(fork_list)) %>%
    mutate(decisiontype = case_when(
      grepl('mpfc', fork) ~ 'mPFC Roi',
      fork %in% c('quadratic', 'random_slopes', 'ctrl_scanner','ctrl_block', 'exclude_prev', 'robust') ~ 'Group-Level\nModel',
      fork %in% c('deconvolution','tstat') ~ 'Subject\nLevel'
    ))
  
  # get average rank of each pipeline by beta estimate
  sca_decision_frame_long_ranks = sca_decision_frame_long %>%
    dplyr::filter(choice == '|') %>%
    dplyr::group_by(fork) %>%
    summarise(mean_rank = -1*mean(rank))
  
  # join ranks with decision frame
  sca_decision_frame_long = left_join(sca_decision_frame_long, sca_decision_frame_long_ranks)
  
  # rename variables to be human-interpretable
  sca_decision_frame_long$fork  = dplyr::recode(sca_decision_frame_long$fork, 'tstat' = 'use tstats (vs. beta estimates)',
                                                'exclude_prev' = 'exclude previously analyzed participants',
                                                'quadratic' = 'quadratic age term (vs. none)',
                                                'random_slopes' = 'random intercepts only (vs. random slopes)',
                                                'ctrl_block' = 'covariate for task block',
                                                'ctrl_scanner' = 'covariate for scanner used',
                                                'deconvolution' = 'deconvolution step (vs. none)',
                                                'mpfc1' = 'mPFC roi #1',
                                                'mpfc2' = 'mPFC roi #2',
                                                'mpfc3' = 'mPFC roi #3',
                                                'mpfc_big' = 'large vmPFC roi',
                                                'prereg_pipeline' = 'preregistered preproc pipeline',
                                                'robust' = 'robust regression (vs. gaussian likelihood)')
  
  sca_decision_frame_long$fork_ordered = reorder(sca_decision_frame_long$fork,  sca_decision_frame_long$mean_rank)
  
  # color palette to code the following:
  # blue = negative, distinct from 0
  # red = negative, not distinct from 0
  # green = positive, not distinct from 0
  # purple = positive, distinct from 0
  if('neg_y' %in% sca_decision_frame$overlap_0){
    my_colors <- RColorBrewer::brewer.pal(4, "Set1")[1:4]
  }else if('neg_n' %in% sca_decision_frame$overlap_0){
    my_colors <- RColorBrewer::brewer.pal(4, "Set1")[2:4]
  }else if('pos_n' %in% sca_decision_frame$overlap_0){
    my_colors <- RColorBrewer::brewer.pal(4, "Set1")[3:4]
  }else{
    my_colors <- RColorBrewer::brewer.pal(4, "Set1")[4:4]
  }
  
  # recode overlap 0 markings for informative legend
  sca_decision_frame$overlap_0 = dplyr::recode(sca_decision_frame$overlap_0,
                                               'neg_y' = '-, 95% PI excluding 0',
                                               'neg_n' = '-, 95% PI including 0',
                                               'pos_n' = '+, 95% PI including 0',
                                               'pos_y' = '+, 95% PI excluding 0')
  
  # summary for lower plot
  decision_summary = sca_decision_frame_long %>% 
    group_by(decisiontype, choice, fork, fork_ordered) %>%
    summarise(n = n(), median_rank = median(rank), lwr_rank = quantile(rank, .25), upr_rank = quantile(rank, .75)) %>%
    dplyr::filter(choice =='|')
  
  sca_top = ggplot(sca_decision_frame, aes(x = rank, y = estimate, color = overlap_0)) +
    geom_hline(yintercept = 0, lty = 1, color = 'black') +
    geom_hline(yintercept = median(sca_decision_frame$estimate), color = 'black', lty = 2) +
    geom_point(alpha = .5) + 
    geom_errorbar(aes(ymin = lower, ymax = upper), width = 0, lwd = .15, alpha = .7) +
    geom_point(data = median_model_frame,aes(x = rank, y = estimate), color = 'black') +
    geom_errorbar(data = median_model_frame,aes(x = rank, y = estimate, ymin = lower, ymax = upper), color = 'black') +
    labs(x = '', y = y_label) +
    theme_classic() +
    theme(legend.position = 'top', legend.title = element_blank()) +
    scale_color_manual(values = my_colors)
  
  sca_bottom = ggplot(sca_decision_frame_long, aes(x = rank, y = fork_ordered, color = overlap_0)) +
    geom_text(aes(label = choice), alpha = .7) +
    labs(x = "Analysis specifications ranked by beta estimates", y = "Decision Points") + 
    theme_bw() + 
    theme(legend.title = element_text(size = 10),
          legend.text = element_text(size = 8),
          axis.text = element_text(color = "black", size = 8),
          legend.position = "none",
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          strip.text.y = element_text(size = 8)) +
    scale_color_manual(values = my_colors) +
    facet_grid(rows = vars(decisiontype), drop = TRUE, scales = 'free_y', space = 'free_y') +
    geom_point(data = decision_summary, aes(x = median_rank, y = fork_ordered), color = 'black') +
    geom_errorbarh(data = decision_summary, aes(x = median_rank, y = fork_ordered, xmin = lwr_rank, xmax = upr_rank), color = 'black')
  
  sca_panel = cowplot::plot_grid(sca_top, sca_bottom, ncol = 1, align = "v", axis = 'lr', labels = c('C', 'D'))
  cowplot::save_plot(sca_panel, filename = paste0('plots/ppi/', contrast_type, '_amyg_ppi_sca.png'), 
                     base_height = 6, base_width = 10)
  
  return(list('sca_decision_frame' = sca_decision_frame, 
              'sca_decision_frame_long' = sca_decision_frame_long,
              'sca_top' = sca_top,
              'sca_bottom' = sca_bottom,
              'sca_panel' = sca_panel))
}

# BSC sca plot
make_bsc_sca_plot = function(coefs, 
                             fork_list, 
                             contrast_type, 
                             plot_title,
                             y_label, 
                             term_choice){
  sca_decision_frame = coefs %>%
    dplyr::filter(term == term_choice) %>%
    dplyr::arrange(estimate) %>%
    mutate(., rank = 1:nrow(.),
           amyg_left = ifelse(grepl('left', pipeline), '|', NA),
           amyg_right = ifelse(grepl('right', pipeline), '|', NA),
           amyg_bilateral = ifelse(grepl('bilateral', pipeline), '|', NA),
           quadratic = ifelse(grepl('Quadratic', model_type), '|', NA),
           random_slopes = ifelse(grepl('NoRandomSlopes', model_type), '|', NA),
           ctrl_scanner = ifelse(grepl('Scanner', model_type), '|', NA),
           ctrl_block = ifelse(grepl('Block', model_type), '|', NA),
           gsr = ifelse(grepl('no_gsr', pipeline), NA, '|'),
           mpfc1 = ifelse(grepl('mpfc1', pipeline), '|', NA),
           mpfc2 = ifelse(grepl('mpfc2', pipeline), '|', NA),
           mpfc3 = ifelse(grepl('mpfc3', pipeline), '|', NA),
           mpfc_big = ifelse(grepl('vmpfc', pipeline), '|', NA),
           overlap_0 = case_when(
             lower < 0 & upper < 0 ~ 'neg_y',
             lower < 0 & estimate < 0 & upper > 0 ~ 'neg_n',
             lower < 0 & estimate > 0 & upper > 0 ~ 'pos_n',
             lower  > 0 & upper > 0 ~ 'pos_y',
           ))
  
  
  
  # median model
  median_model_frame = sca_decision_frame %>%
    summarise(estimate = median(estimate), lower = median(lower), upper = median(upper), rank= median(rank))
  
  sca_decision_frame$overlap_0 = factor(sca_decision_frame$overlap_0, levels = c("neg_y", "neg_n", "pos_n", "pos_y"))
  
  
  sca_decision_frame_long = sca_decision_frame %>%
    tidyr::gather(key = 'fork', value = 'choice', all_of(fork_list)) %>%
    mutate(decisiontype = case_when(
      grepl('mpfc', fork) ~ 'mPFC ROI',
      fork %in% c('quadratic', 'random_slopes', 'ctrl_scanner','ctrl_block') ~ 'Group-Level\nModel',
      fork == 'gsr' ~ 'GSS',
      grepl('amyg', fork) ~ 'amyg ROI'
    ))
  
  # get average rank of each pipeline by beta estimate
  sca_decision_frame_long_ranks = sca_decision_frame_long %>%
    dplyr::filter(choice == '|') %>%
    dplyr::group_by(fork) %>%
    summarise(mean_rank = -1*mean(rank))
  
  # join ranks with decision frame
  sca_decision_frame_long = left_join(sca_decision_frame_long, sca_decision_frame_long_ranks)
  
  # rename variables to be human-interpretable
  sca_decision_frame_long$fork  = dplyr::recode(sca_decision_frame_long$fork,
                                                'quadratic' = 'quadratic age term (vs. none)',
                                                'random_slopes' = 'random intercepts only (vs. random slopes)',
                                                'ctrl_block' = 'covariate for task block',
                                                'ctrl_scanner' = 'covariate for scanner used',
                                                'gsr' = 'global signal correction (vs. none)',
                                                'mpfc1' = 'mPFC roi #1',
                                                'mpfc2' = 'mPFC roi #2',
                                                'mpfc3' = 'mPFC roi #3',
                                                'mpfc_big' = 'large vmPFC roi')
  
  sca_decision_frame_long$fork_ordered = reorder(sca_decision_frame_long$fork,  sca_decision_frame_long$mean_rank)
  
  # color palette to code the following:
  # blue = negative, distinct from 0
  # red = negative, not distinct from 0
  # green = positive, not distinct from 0
  # purple = positive, distinct from 0
  if('neg_y' %in% sca_decision_frame$overlap_0){
    my_colors <- RColorBrewer::brewer.pal(4, "Set1")[1:4]
  }else if('neg_n' %in% sca_decision_frame$overlap_0){
    my_colors <- RColorBrewer::brewer.pal(4, "Set1")[2:4]
  }else if('pos_n' %in% sca_decision_frame$overlap_0){
    my_colors <- RColorBrewer::brewer.pal(4, "Set1")[3:4]
  }else{
    my_colors <- RColorBrewer::brewer.pal(4, "Set1")[4:4]
  }
  
  # recode overlap 0 markings for informative legend
  sca_decision_frame$overlap_0 = dplyr::recode(sca_decision_frame$overlap_0,
                                               'neg_y' = '-, 95% PI excluding 0',
                                               'neg_n' = '-, 95% PI including 0',
                                               'pos_n' = '+, 95% PI including 0',
                                               'pos_y' = '+, 95% PI excluding 0')
  
  # summary for lower plot
  decision_summary = sca_decision_frame_long %>% 
    group_by(decisiontype, choice, fork, fork_ordered) %>%
    summarise(n = n(), median_rank = median(rank), lwr_rank = quantile(rank, .25), upr_rank = quantile(rank, .75)) %>%
    dplyr::filter(choice =='|')
  
  sca_top = ggplot(sca_decision_frame, aes(x = rank, y = estimate, color = overlap_0)) +
    geom_hline(yintercept = 0, lty = 1, color = 'black') +
    geom_hline(yintercept = median(sca_decision_frame$estimate), color = 'black', lty = 2) +
    geom_point(alpha = .7) + 
    geom_errorbar(aes(ymin = lower, ymax = upper), width = 0, lwd = .25, alpha = .9) +
    geom_point(data = median_model_frame,aes(x = rank, y = estimate), color = 'black') +
    geom_errorbar(data = median_model_frame,aes(x = rank, y = estimate, ymin = lower, ymax = upper), color = 'black') +
    labs(x = '', y = y_label) +
    theme_classic() +
    theme(legend.position = 'top', legend.title = element_blank()) +
    scale_color_manual(values = my_colors)
  
  sca_bottom = ggplot(sca_decision_frame_long, aes(x = rank, y = fork_ordered, color = overlap_0)) +
    geom_text(aes(label = choice), alpha = .7) +
    labs(x = "Analysis specifications ranked by beta estimates", y = "Decision Points") + 
    theme_bw() + 
    theme(legend.title = element_text(size = 10),
          legend.text = element_text(size = 8),
          axis.text = element_text(color = "black", size = 8),
          legend.position = "none",
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          strip.text.y = element_text(size = 6)) +
    scale_color_manual(values = my_colors) +
    facet_grid(rows = vars(decisiontype), drop = TRUE, scales = 'free_y', space = 'free_y') +
    geom_point(data = decision_summary, aes(x = median_rank, y = fork_ordered), color = 'black') +
    geom_errorbarh(data = decision_summary, aes(x = median_rank, y = fork_ordered, xmin = lwr_rank, xmax = upr_rank), color = 'black')
  
  sca_panel = cowplot::plot_grid(sca_top, sca_bottom, ncol = 1, align = "v", axis = 'lr')
  cowplot::save_plot(sca_panel, filename = paste0('plots/bsc/', contrast_type, '_amyg_pfc_bsc_sca.png'), 
                     base_height = 6, base_width = 10)
  
  return(list('sca_decision_frame' = sca_decision_frame, 
              'sca_decision_frame_long' = sca_decision_frame_long,
              'sca_top' = sca_top,
              'sca_bottom' = sca_bottom,
              'sca_panel' = sca_panel))
}


# Make Decision Plot ------------------------------------------------------
make_decision_plot = function(sca_frame, fork_list, contrast_type, plot_title){
  
  # make robust variale coding consistent with others
  sca_frame = dplyr::mutate(sca_frame, robust = ifelse(robust =='', NA, robust))
  
  sca_frame[is.na(sca_frame)] <- 0
  sca_frame[sca_frame == '|'] <- 1
  
  meta_model = stan_glm(data = sca_frame, estimate ~ tstat + quadratic + 
                          random_slopes + ctrl_scanner + ctrl_block + exclude_prev + robust + 
                          amyg_right + amyg_left + amyg_high_sig + amyg_low_sig + 
                          native_space + 
                          motion_reg6 + motion_reg18 + 
                          hrf_2gamma +
                          highpass, cores = 4, chains = 4)
  
  model_summary = broom.mixed::tidy(meta_model)
  
  fork_fx = brms::posterior_samples(meta_model, pars = fork_list) %>%
    mutate(., index = 1:nrow(.)) %>%
    tidyr::gather(., key = 'fork', value = 'effect', -index) %>%
    mutate(., fork = gsub('.{1}$', '', fork)) %>%
    mutate(decisiontype = case_when(
      grepl('amyg', fork) ~ 'Amygdala\n Roi',
      fork == 'native_space' ~ 'Amygdala\n Roi',
      fork %in% c('quadratic', 'random_slopes', 'ctrl_scanner','ctrl_block', 'exclude_prev', 'robust') ~ 'Group-Level\nModel',
      fork %in% c('motion_reg6', 'motion_reg18', 'motion_reg24', 'highpass', 'hrf_2gamma', 
                  'prereg_pipeline', 'glm_fsl', 'tstat') ~ 'Subject-Level\nModel'
    ))
  
  fork_fx$fork  = dplyr::recode(fork_fx$fork, 'tstat' = 'use tstats (vs. beta estimates)',
                                'hrf_2gamma' = '2gamma hrf (vs. 1gamma)',
                                'highpass' = 'quadratic detrending (vs. highpass)',
                                'native_space' = 'native space (vs. mni space)',
                                'glm_fsl' = 'glm in afni (vs. glm in fsl)',
                                'exclude_prev' = 'exclude previously analyzed participants (vs. include)',
                                'quadratic' = 'quadratic age term (vs. none)',
                                'random_slopes' = 'random intercepts only (vs. random slopes)',
                                'ctrl_block' = 'covariate for task block (vs. none)',
                                'ctrl_scanner' = 'covariate for scanner used (vs. none)',
                                'amyg_right' = 'right amygdala (vs. bilateral)',
                                'amyg_left' =  'left amygdala (vs. bilateral)',
                                'amyg_high_sig' = 'median-split voxels for high signal (vs. no split)',
                                'amyg_low_sig' = 'median-split voxels for low signal (vs. no split)',
                                'motion_reg18' = '18 motion regressors + WM + CSF (vs. 24)',
                                'motion_reg6' = '6 motion regressors (vs. 24)',
                                'robust' = 'robust regression (vs. gaussian likelihood)')
  
  
  fork_fx = fork_fx %>%
    group_by(fork) %>%
    mutate(mean_effect = -1*mean(effect))
  
  fork_fx$fork_ordered = reorder(fork_fx$fork,  fork_fx$mean_effect)
  
  fork_fx_summary = fork_fx %>%
    group_by(fork_ordered, decisiontype) %>%
    summarise(median = median(effect),
              lwr_95 = quantile(effect, probs = .025),
              upr_95 = quantile(effect, probs = .975))
  
  # Make the plot
  decision_plot = ggplot(data = fork_fx, aes(x = fork_ordered, y = effect, fill = decisiontype)) +
    geom_hline(yintercept = 0, lty = 2) +
    geom_flat_violin(color = NA) +
    geom_point(data = fork_fx_summary, aes(x = fork_ordered, y = median)) +
    geom_errorbar(data = fork_fx_summary, aes(x = fork_ordered, y = median, ymin = lwr_95, ymax = upr_95), width = 0) +
    theme_bw() +
    coord_flip() +
    theme(legend.position = 'none') +
    labs(y = 'Difference in age-related change estimate relative to alternative choice\nConditional on all other decision points', 
         x = 'Analysis Choice',
         title = plot_title) +
    facet_grid(rows = vars(decisiontype), drop = TRUE, scales = 'free_y', space = 'free_y')
  
  decision_plot
  
  ggsave(decision_plot, file = paste0('plots/reactivity/', contrast_type, '_fork_effects.pdf'), width = 8, height = 5)
  
  return(list('model_summary' = model_summary,
              'decision_plot' = decision_plot))
}