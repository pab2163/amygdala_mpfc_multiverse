# Author: Paul A. Bloom
# Date: May 25, 2019

# Model behavior on fear run in comps/adults
# Use hierarchical nested models (runs nested within subjects) to estimate accuracy, hit rates, false alarm rates, and RTs to hits over age

library(tidyverse)
library(brms)


# Data Cleaning -----------------------------------------------------------
# Load in all emotions
load('master_behav.rda')

# only look at fear happy -- make a unique coding for each face type
masterFearHappy = dplyr::filter(masterFearHappy, Procedure.Block. != 'BlockProcNeutSad') %>%
  mutate(emotCode = case_when(
    grepl('Neut', emotion) & Procedure.Block. == 'BlockProcNeutFear' ~ 'neutralFearBlock',
    grepl('Neut', emotion) & Procedure.Block. == 'BlockProcNeutralHap' ~ 'neutralHappyBlock',
    grepl('Fear', emotion) ~ 'fear',
    grepl('Hap', emotion) ~ 'happy'
  ),
  # code accuracy based on hits/correct rejects/false alarms/misses
  acc = case_when(
    tr_result == 'hit' |  tr_result == 'corr_reject' ~ 1,
    tr_result == 'false_alarm' |  tr_result == 'miss' ~ 0
  ))


# filter just comps/adults for fear faces
fear = dplyr::filter(masterFearHappy, group == 'Comp' | group == 'Adult', 
                     Procedure.Block. == 'BlockProcNeutFear',
                     Running.Trial. != 'FixList2') %>%
  mutate(name = paste0('SB', Subject, '_w', wave)) # not the same as traditional but should be fine for the sake of the model

# Center age so 0 in the model is age 5 here (intercept will representa a 5 year-old)
fear$ageCenterAt5 = fear$Age -5


# Model Accuracy 
fearModelAccuracy = brm(data = fear, acc ~ ageCenterAt5 + (ageCenterAt5|Subject/name), family = bernoulli(link = 'logit'), cores = 4)



# Model False Alarms ------------------------------------------------------

# take only trials that were either corr_rejects or false alamrs: participants were not supposed to go for fear faces
fearTrials = filter(fear, tr_result == 'false_alarm' | tr_result == 'corr_reject') %>%
  mutate(falseAlarm = ifelse(tr_result == 'false_alarm', 1, 0))

fearModelFalseAlarms = brm(data = fearTrials, falseAlarm ~ ageCenterAt5 + (ageCenterAt5|Subject/name), family = bernoulli(link = 'logit'), cores = 4)

# Model Hits --------------------------------------------------------------
# take only trials that were either hits or misses: participants supposed to go for neutral faces
neutTrials = filter(fear, tr_result == 'hit' | tr_result == 'miss') %>%
  mutate(hit = ifelse(tr_result == 'hit', 1, 0))


fearModelHits= brm(data = neutTrials, hit ~ ageCenterAt5 + (ageCenterAt5|Subject/name), family = bernoulli(link = 'logit'), cores = 4)


# Model RTs ---------------------------------------------------------------
goTrials = filter(fear, face.RT > 0, tr_result == 'hit')


# Use linear regression estimate RT function
fearModelRT = brm(data = goTrials, face.RT ~ ageCenterAt5 + (ageCenterAt5|Subject/name), cores = 4)

# Use linear regression with quadratic term to estimate RT function
fearModelRT2 = brm(data = goTrials, face.RT ~ poly(ageCenterAt5,2, raw = TRUE) + (ageCenterAt5|Subject/name), cores = 4)

# Use linear regression with quadratic + cubic terms to estimate RT function
fearModelRT3 = brm(data = goTrials, face.RT ~ poly(ageCenterAt5,3, raw = TRUE) + (ageCenterAt5|Subject/name), cores = 4)

# Save model objects using compression
save(fearModelAccuracy, fearModelFalseAlarms, fearModelHits, fearModelRT, fearModelRT2, fearModelRT3, file = 'fearModelsComps.rda', compress = 'xz')
