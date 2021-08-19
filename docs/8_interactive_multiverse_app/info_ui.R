info_ui = navbarMenu('Info',
                     tabPanel('How to use this tool',
                              h2('How to use this tool:'),
                              p('This is an interactive data visualization tool for several of the analyses from Bloom et al. 2021 
                                       on age-related changes in amygdala reactivity and amygdala-mPFC connectivity in an accelerated longitudinal 
                                cohort of participants ages 4-22 years old.'),
                              p(strong('To get started'), 'select a tab above for an analysis', 
                                       em('(age-related changes in amygdala reactivity, gPPI amygdala-mPFC functional connectivity, 
                                       or BSC amygdala-mPFC functional connectivity).'), 
                                ' Then, from the dropdown menu select the contrast you would like to explore', 
                                em('(for example Fear Faces > Baseline)')),
                              br(),
                              p('Each page will allow you to select specifications for the chosen analysis and contrast and view the estimated linear age-related change for that specification,
                                relative to all other specifications (left side). You can also see the fitted model predictions for that 
                                given specification overlaid on data points for each scan (right). ', strong('Note:'), ' for reasons of computational feasibility 
                                we could not run all combinations of analysis forks. You may notice that no specifications exists for certain combinations 
                                (for example, we only ran GLMs with 24 motion regressors for FSL pipelines).'),
                              h2('What can this tool show?'),
                              p('Because we ran so many analyses specifications, it is quite difficult to provide detailed information on the results of any one
                                specification in static form (without creating hundreds/thousands of pages of figures and tables,
                                and nobody wants to have to sort through that!). So, we made this interactive visualization to allow for exploration of individual analysis specifications in more detail.
                                It can also be informative to toggle one particular choice on/off (for a striking example, try age-related change in fear > baseline gPPI analyses with versus without deconvolution).'),
                              h2('What is a multiverse anyway? What is a specification curve?'),
                              p('A ', strong('multiverse analysis'),' is an analytical tool that helps provide an understanding of whether study results hinge on decisions made during the analysis process. Briefly, a multiverse analysis means that one identifies a set of analyses methods that are all theoretically justified, ', 
                                em('then conducts all of these analysis "specifications" in parallel.'), 
                                'Then, a ', strong('specification curve'), 'can be used for visualization of all of the different analysis specifications at once, as well as statistical inference.'),
                              p('The specification curve analyses here were particularly inspired by work from', 
                                a(href='https://dcosme.github.io/specification-curves/SCA_tutorial_inferential', 'Dani Cosme, '), 'and ',
                                a(href='https://www.amyorben.com/pdf/2019_orbenprzybylski_nhb.pdf', 'Amy Orben.'),
                                ), 
                              'See more background on the statistics', a(href = 'https://www.nature.com/articles/s41562-020-0912-z', 'here'), ' and ',
                              a(href = 'https://journals.sagepub.com/doi/10.1177/1745691616658637', 'here'),
                              'as well as ', a(href = 'https://github.com/masurp/specr', 'specr, '), 'a nice R package for running specification curve analyses'),
                     tabPanel('Manuscript Information', 
                              tags$div("Study procedures, analysis methods, and more information about the data shown here can be found in",
                                       tags$a(href="https://danlab.psychology.columbia.edu/", 
                                              "this preprint manuscript"), 
                                       "(Bloom, VanTiegham, Gabard-Durnam, Gee, Flannery, Caldera, Goff, Telzer, 
                                       Humphreys, Fareri, Algharazi, Bolger, Aly, & Tottenham, 2021).",
                                       tags$br(),
                                       tags$br()),
                              tags$div("The data shown here were collected by the Tottenham Laboratory at UCLA from 2009-2015. Info and materials are also available via",
                                      tags$a(href="https://osf.io/hvdmx/", "OSF"))
                              ),
                     tabPanel('Contact info', 
                              tags$div("Questions or comments? Feel free to email paul.bloom@columbia.edu or visit the",
                              tags$a(href="https://danlab.psychology.columbia.edu/", 
                                     "Tottenham Lab Website")),
                              tags$a(
                                href="https://danlab.psychology.columbia.edu/", 
                                tags$img(src="https://pbs.twimg.com/profile_images/776060754898354177/C1AkpCyE_400x400.jpg", 
                                         title="DANLAB Columbia Logo", 
                                         width="200",
                                         height="200"))
                     )
                     )
