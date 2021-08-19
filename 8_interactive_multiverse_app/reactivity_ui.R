reactivity_ui = navbarMenu(
  'Amygdala Reactivity',
  tabPanel(
    'Fear Faces > Baseline',
    inputPanel(
      selectInput(
        "modelType",
        label = "Group Model Polynomial Degree",
        choices = c('Linear', 'Quadratic')
      ),
      selectInput(
        'amyg_roi',
        label = 'Amygdala ROI',
        choices = c(
          'Harvard Oxford - Bilateral',
          'Harvard Oxford - Right',
          'Harvard Oxford - Left',
          'Harvard Oxford - Bilateral (Low Signal)',
          'Harvard Oxford - Right (Low Signal)',
          'Harvard Oxford - Left (Low Signal)',
          'Harvard Oxford - Bilateral (High Signal)',
          'Harvard Oxford - Right (High Signal)',
          'Harvard Oxford - Left (High Signal)',
          'Native Space - Bilateral',
          'Native Space - Right',
          'Native Space - Left'
        )
      ),
      selectInput(
        "tstat",
        label = "Estimate Type",
        choices = c('T-Stat', 'Beta')
      ),
      selectInput("exclude", label = "Exclude Prev. Scans?",
                  choices = c('No', 'Yes')),
      selectInput(
        "hrf",
        label = "HRF",
        choices = c('2 Gamma (FSL pipelines only)', '1 Gamma')
      ),
      selectInput(
        'frequency_flt',
        label = 'Timeseries Detrending',
        choices = c(
          'Highpass Filter (.01hz)',
          'Quadradic Detrending (AFNI pipelines only)'
        )
      ),
      selectInput(
        "covariates",
        label = "Covariates",
        choices = c(
          'Motion Only',
          'Motion + Scanner',
          'Motion + Block',
          'Motion + Scanner + Block'
        )
      ),
      selectInput(
        "glm_software",
        label = "GLM Software",
        choices = c('FSL', 'AFNI')
      ),
      selectInput(
        "motion_reg",
        label = "Motion Regressors",
        choices = c('6', '18 + White Matter + CSF', '24 (FSL Pipelines Only)')
      ),
      selectInput('robust', label = 'Robust Regression',
                  choices = c('Yes', 'No')),
      selectInput(
        "randomEffects",
        label = "Random Effects",
        choices = c('Intercepts Only', 'Slopes + Intercepts'),
        selected = 'Slopes + Intercepts'
      )
    ),
    mainPanel(plotOutput("plot_reactivity_fear"),
              tags$div(tags$b('Left:'), 'specification curve of age-related change in fear > baseline amygdala reactivity. Points represent estimated linear age-related change and lines are corresponding 95% posterior intervals. Models are ordered by age-related change estimates. Color indicates sign of beta estimates and whether respective posterior intervals include 0 (red = negative excluding 0; blue = negative including 0, green = positive including 0). The black point and error bar represents the model specification selected from the dropdown menus above.',
                tags$b('Right:'),'
                participant-level data and model predictions for age-related related change in amygdala reactivity for the selected specification. Points represent participant-level estimates, and the thick lines with shaded area represent model predictions and 95% posterior intervals.'),
              width = '100%')
  ),
  tabPanel(
    'Neutral Faces > Baseline',
    inputPanel(
      selectInput(
        "neut_modelType",
        label = "Group Model Polynomial Degree",
        choices = c('Linear', 'Quadratic')
      ),
      selectInput(
        'neut_amyg_roi',
        label = 'Amygdala ROI',
        choices = c(
          'Harvard Oxford - Bilateral',
          'Harvard Oxford - Right',
          'Harvard Oxford - Left',
          'Harvard Oxford - Bilateral (Low Signal)',
          'Harvard Oxford - Right (Low Signal)',
          'Harvard Oxford - Left (Low Signal)',
          'Harvard Oxford - Bilateral (High Signal)',
          'Harvard Oxford - Right (High Signal)',
          'Harvard Oxford - Left (High Signal)',
          'Native Space - Bilateral',
          'Native Space - Right',
          'Native Space - Left'
        )
      ),
      selectInput(
        "neut_tstat",
        label = "Estimate Type",
        choices = c('T-Stat', 'Beta')
      ),
      selectInput("neut_exclude", label = "Exclude Prev. Scans?",
                  choices = c('No', 'Yes')),
      selectInput(
        "neut_hrf",
        label = "HRF",
        choices = c('2 Gamma (FSL pipelines only)', '1 Gamma')
      ),
      selectInput(
        'neut_frequency_flt',
        label = 'Timeseries Detrending',
        choices = c(
          'Highpass Filter (.01hz)',
          'Quadradic Detrending (AFNI pipelines only)'
        )
      ),
      selectInput(
        "neut_covariates",
        label = "Covariates",
        choices = c(
          'Motion Only',
          'Motion + Scanner',
          'Motion + Block',
          'Motion + Scanner + Block'
        )
      ),
      selectInput(
        "neut_glm_software",
        label = "GLM Software",
        choices = c('FSL', 'AFNI')
      ),
      selectInput(
        "neut_motion_reg",
        label = "Motion Regressors",
        choices = c('6', '18 + White Matter + CSF', '24 (FSL Pipelines Only)')
      ),
      selectInput('neut_robust', label = 'Robust Regression',
                  choices = c('Yes', 'No')),
      selectInput(
        "neut_randomEffects",
        label = "Random Effects",
        choices = c('Intercepts Only', 'Slopes + Intercepts'),
        selected = 'Slopes + Intercepts'
      )
    ),
    mainPanel(plotOutput("plot_reactivity_neut"),
              tags$div(tags$b('Left:'), 'specification curve of age-related change in neutral > baseline amygdala reactivity. Points represent estimated linear age-related change and lines are corresponding 95% posterior intervals. Models are ordered by age-related change estimates. Color indicates sign of beta estimates and whether respective posterior intervals include 0 (red = negative excluding 0; blue = negative including 0, green = positive including 0). The black point and error bar represents the model specification selected from the dropdown menus above.',
                       tags$b('Right:'),'
                participant-level data and model predictions for age-related related change in amygdala reactivity for the selected specification. Points represent participant-level estimates, and the thick lines with shaded area represent model predictions and 95% posterior intervals.'),
              width = '100%')
  ),
  tabPanel(
    'Fear Faces > Neutral Faces',
    inputPanel(
      selectInput(
        "fear_minus_neut_modelType",
        label = "Group Model Polynomial Degree",
        choices = c('Linear', 'Quadratic')
      ),
      selectInput(
        'fear_minus_neut_amyg_roi',
        label = 'Amygdala ROI',
        choices = c(
          'Harvard Oxford - Bilateral',
          'Harvard Oxford - Right',
          'Harvard Oxford - Left',
          'Harvard Oxford - Bilateral (Low Signal)',
          'Harvard Oxford - Right (Low Signal)',
          'Harvard Oxford - Left (Low Signal)',
          'Harvard Oxford - Bilateral (High Signal)',
          'Harvard Oxford - Right (High Signal)',
          'Harvard Oxford - Left (High Signal)',
          'Native Space - Bilateral',
          'Native Space - Right',
          'Native Space - Left'
        )
      ),
      selectInput(
        "fear_minus_neut_tstat",
        label = "Estimate Type",
        choices = c('T-Stat', 'Beta')
      ),
      selectInput("fear_minus_neut_exclude", label = "Exclude Prev. Scans?",
                  choices = c('No', 'Yes')),
      selectInput(
        "fear_minus_neut_hrf",
        label = "HRF",
        choices = c('2 Gamma (FSL pipelines only)', '1 Gamma')
      ),
      selectInput(
        'fear_minus_neut_frequency_flt',
        label = 'Timeseries Detrending',
        choices = c(
          'Highpass Filter (.01hz)',
          'Quadradic Detrending (AFNI pipelines only)'
        )
      ),
      selectInput(
        "fear_minus_neut_covariates",
        label = "Covariates",
        choices = c(
          'Motion Only',
          'Motion + Scanner',
          'Motion + Block',
          'Motion + Scanner + Block'
        )
      ),
      selectInput(
        "fear_minus_neut_glm_software",
        label = "GLM Software",
        choices = c('FSL', 'AFNI')
      ),
      selectInput(
        "fear_minus_neut_motion_reg",
        label = "Motion Regressors",
        choices = c('6', '18 + White Matter + CSF', '24 (FSL Pipelines Only)')
      ),
      selectInput('fear_minus_neut_robust', label = 'Robust Regression',
                  choices = c('Yes', 'No')),
      selectInput(
        "fear_minus_neut_randomEffects",
        label = "Random Effects",
        choices = c('Intercepts Only', 'Slopes + Intercepts'),
        selected = 'Slopes + Intercepts'
      )
    ),
    mainPanel(plotOutput("plot_reactivity_fear_minus_neut"),
              tags$div(tags$b('Left:'), 'specification curve of age-related change in fear > neutral amygdala reactivity. Points represent estimated linear age-related change and lines are corresponding 95% posterior intervals. Models are ordered by age-related change estimates. Color indicates sign of beta estimates and whether respective posterior intervals include 0 (red = negative excluding 0; blue = negative including 0, green = positive including 0). The black point and error bar represents the model specification selected from the dropdown menus above.',
                       tags$b('Right:'),'
                participant-level data and model predictions for age-related related change in amygdala reactivity for the selected specification. Points represent participant-level estimates, and the thick lines with shaded area represent model predictions and 95% posterior intervals.'),
              width = '100%')
  )
)
