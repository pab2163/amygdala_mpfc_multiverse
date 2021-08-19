# Define the shiny UI
bsc_ui = navbarMenu('Amygdala-mPFC BSC Connectivity',
                tabPanel('Fear', 
                         inputPanel(
                           selectInput(
                             'bsc_fear_amyg_roi',
                             label = 'Amygdala ROI',
                             choices = c(
                               'Harvard Oxford - Bilateral',
                               'Harvard Oxford - Right',
                               'Harvard Oxford - Left')
                           ),
                           selectInput('bsc_fear_modelType', label = 'Group Model Polynomial Degree',
                                       choices = c('Linear', 'Quadratic')),
                           selectInput('bsc_fear_mpfc_roi', label = 'mPFC ROI',
                                       choices = c('mPFC 1',
                                                   'mPFC 2',
                                                   'mPFC 3',
                                                   'large vmPFC')),
                           selectInput('bsc_fear_gsr', label = 'Global Signal Correction',
                                       choices = c('Yes', 'No'), selected = 'No'),
                           selectInput('bsc_fear_randomEffects', label = 'Random Effects',
                                       choices = c('Intercepts Only', 'Slopes + Intercepts'), selected = 'Slopes + Intercepts'),
                           selectInput('bsc_fear_covariates', label = 'Covariates',
                                       choices = c('Motion Only', 'Motion + Scanner', 
                                                   'Motion + Block', 'Motion + Scanner + Block'))
                         ),
                         mainPanel(plotOutput('plot_bsc_fear'), 
                                   tags$div(tags$b('Left:'), 'Specification curve of age-related change in amygdala-mPFC beta series connectivity for fear faces. Points represent estimated linear age-related change and lines are corresponding 95% posterior intervals. Models are ordered by age-related change estimates, and the dotted line represents the median estimate across all specifications. Color indicates sign of beta estimates and whether respective posterior intervals include 0 (blue = negative including 0, green = positive including 0, purple = positive excluding 0). The black point and error bar represents the model specification selected from the dropdown menus above.',
                                            tags$b('Right:'),'
                participant-level data and model predictions for age-related related change in amygdala-mPFC BSC for the selected specification. Points represent participant-level estimates, and the thick lines with shaded area represent model predictions and 95% posterior intervals.'),
                                   width = '100%',
                                   tags$a(
                                     href="https://osf.io/f53sj/", 
                                     tags$img(src="https://mfr.osf.io/export?url=https://osf.io/f53sj/?direct%26mode=render%26action=download%26public_file=True&initialWidth=737&childId=mfrIframe&parentTitle=OSF+%7C+pfc_crop_2.png&parentUrl=https://osf.io/f53sj/&format=2400x2400.jpeg", 
                                              title="mPFC ROIs", 
                                              width="600",
                                              height="200",
                                              align='center')))
                ),
                tabPanel('Neutral', 
                         inputPanel(
                           selectInput(
                             'bsc_neutral_amyg_roi',
                             label = 'Amygdala ROI',
                             choices = c(
                               'Harvard Oxford - Bilateral',
                               'Harvard Oxford - Right',
                               'Harvard Oxford - Left')
                           ),
                           selectInput('bsc_neutral_modelType', label = 'Group Model Polynomial Degree',
                                       choices = c('Linear', 'Quadratic')),
                           selectInput('bsc_neutral_mpfc_roi', label = 'mPFC ROI',
                                       choices = c('mPFC 1',
                                                   'mPFC 2',
                                                   'mPFC 3',
                                                   'large vmPFC')),
                           selectInput('bsc_neutral_gsr', label = 'Global Signal Correction',
                                       choices = c('Yes', 'No'), selected = 'No'),
                           selectInput('bsc_neutral_randomEffects', label = 'Random Effects',
                                       choices = c('Intercepts Only', 'Slopes + Intercepts'), selected = 'Slopes + Intercepts'),
                           selectInput('bsc_neutral_covariates', label = 'Covariates',
                                       choices = c('Motion Only', 'Motion + Scanner', 
                                                   'Motion + Block', 'Motion + Scanner + Block'))
                         ),
                         mainPanel(plotOutput('plot_bsc_neutral'), 
                                   tags$div(tags$b('Left:'), 'Specification curve of age-related change in amygdala-mPFC beta series connectivity for neutral faces. Points represent estimated linear age-related change and lines are corresponding 95% posterior intervals. Models are ordered by age-related change estimates, and the dotted line represents the median estimate across all specifications. Color indicates sign of beta estimates and whether respective posterior intervals include 0 (blue = negative including 0, green = positive including 0, purple = positive excluding 0). The black point and error bar represents the model specification selected from the dropdown menus above.',
                                            tags$b('Right:'),'
                participant-level data and model predictions for age-related related change in amygdala-mPFC BSC for the selected specification. Points represent participant-level estimates, and the thick lines with shaded area represent model predictions and 95% posterior intervals.'),
                                   width = '100%',
                                   tags$a(
                                     href="https://osf.io/f53sj/", 
                                     tags$img(src="https://mfr.osf.io/export?url=https://osf.io/f53sj/?direct%26mode=render%26action=download%26public_file=True&initialWidth=737&childId=mfrIframe&parentTitle=OSF+%7C+pfc_crop_2.png&parentUrl=https://osf.io/f53sj/&format=2400x2400.jpeg", 
                                              title="mPFC ROIs", 
                                              width="600",
                                              height="200",
                                              align='center')))
                ),
                tabPanel('Fear > Neutral', 
                         inputPanel(
                           selectInput(
                             'bsc_fear_minus_neutral_amyg_roi',
                             label = 'Amygdala ROI',
                             choices = c(
                               'Harvard Oxford - Bilateral',
                               'Harvard Oxford - Right',
                               'Harvard Oxford - Left')
                           ),
                           selectInput('bsc_fear_minus_neutral_modelType', label = 'Group Model Polynomial Degree',
                                       choices = c('Linear', 'Quadratic')),
                           selectInput('bsc_fear_minus_neutral_mpfc_roi', label = 'mPFC ROI',
                                       choices = c('mPFC 1',
                                                   'mPFC 2',
                                                   'mPFC 3',
                                                   'large vmPFC')),
                           selectInput('bsc_fear_minus_neutral_gsr', label = 'Global Signal Correction',
                                       choices = c('Yes', 'No'), selected = 'No'),
                           selectInput('bsc_fear_minus_neutral_randomEffects', label = 'Random Effects',
                                       choices = c('Intercepts Only', 'Slopes + Intercepts'), selected = 'Slopes + Intercepts'),
                           selectInput('bsc_fear_minus_neutral_covariates', label = 'Covariates',
                                       choices = c('Motion Only', 'Motion + Scanner', 
                                                   'Motion + Block', 'Motion + Scanner + Block'))
                         ),
                         mainPanel(plotOutput('plot_bsc_fear_minus_neutral'), 
                                   tags$div(tags$b('Left:'), 'Specification curve of age-related change in amygdala-mPFC beta series connectivity for fear faces > neutral faces. Points represent estimated linear age-related change and lines are corresponding 95% posterior intervals. Models are ordered by age-related change estimates, and the dotted line represents the median estimate across all specifications. Color indicates sign of beta estimates and whether respective posterior intervals include 0 (blue = negative including 0, green = positive including 0, purple = positive excluding 0). The black point and error bar represents the model specification selected from the dropdown menus above.',
                                            tags$b('Right:'),'
                participant-level data and model predictions for age-related related change in amygdala-mPFC BSC for the selected specification. Points represent participant-level estimates, and the thick lines with shaded area represent model predictions and 95% posterior intervals.'),
                                   width = '100%',
                                   tags$a(
                                     href="https://osf.io/f53sj/", 
                                     tags$img(src="https://mfr.osf.io/export?url=https://osf.io/f53sj/?direct%26mode=render%26action=download%26public_file=True&initialWidth=737&childId=mfrIframe&parentTitle=OSF+%7C+pfc_crop_2.png&parentUrl=https://osf.io/f53sj/&format=2400x2400.jpeg", 
                                              title="mPFC ROIs", 
                                              width="600",
                                              height="200",
                                              align='center')))
                ))
