# Pulls each individual beta for trials into a dataframe for chosen regions used for analysis of change in reactivity across trials
# Paul A. Bloom 
# March 25, 2020

import sys
import os
import glob
import pandas as pd 
import nilearn
from nilearn import image
import numpy as np
from itertools import combinations
import re 
import scipy


# Make subject list, and define masks #####


# find all subjects, get just subject IDs
subs = glob.glob('../../data/*')
for i in range(len(subs)):
    subs[i] = subs[i].split('/')[3]
    
# put subjects in a dictionary    
d = {'name': subs}

# three amygdala masks
ho_amyg_bilateral = '/danl/SB/Investigators/PaulCompileTGNG/mri_scripts/Structural/mni2mmSpace/harvardoxfordsubcortical_bilateralamyg_2mm.nii.gz'
ho_amyg_right = '/danl/SB/Investigators/PaulCompileTGNG/mri_scripts/Structural/mni2mmSpace/harvardoxfordsubcortical_rightamyg.nii.gz_mni2mm.nii.gz'
ho_amyg_left = '/danl/SB/Investigators/PaulCompileTGNG/mri_scripts/Structural/mni2mmSpace/harvardoxfordsubcortical_leftamyg.nii.gz_mni2mm.nii.gz'

# load mask images
bilateralAmygHOmask = image.load_img(ho_amyg_bilateral).get_fdata()
rightAmygHOmask = image.load_img(ho_amyg_right).get_fdata()
leftAmygHOmask = image.load_img(ho_amyg_left).get_fdata()


# Define function to get slopes
# Returns mean timeseries of betas, and slope using spearman's correlation
def getBetas(copeDir, name, emotion, mask):
    # Load in the 4d image of 24 betas
    emotImgPath = copeDir + '/' + name + '_reg' + emotion + 'Betas.nii.gz'
    emotImg = image.load_img(emotImgPath).get_fdata()

    # mask it with each roi
    roi1 = emotImg[mask == 1]

    # get the time series vector of averaged betas across each roi
    meanTimeSeries = np.mean(roi1, axis = 0)
    
    # pull amyg timeseries vector
    trials = np.arange(1, len(meanTimeSeries) + 1)

    # use spearman's correlation to account for betas possibly being skewed
    # slope is 'habituation'??
    habitSlope = scipy.stats.spearmanr(meanTimeSeries, trials)[0]
    
    
    return(meanTimeSeries, habitSlope)


# # Function for getting betas from all trials
# For this one, the only input is the directory where subject level cope images (registered to MNI) are
# Returns an output dataframe of each trial for each subject

def getAllTrials(copeDir):
    # data frame of all runs in feat
    subFrame = pd.read_csv('../QA/allEmotionsFeatComplete.csv')
    subFrame = subFrame[subFrame['runType'] == 'fear']
    
    
    #pull in slopes for eachs subject
    for index, row in subFrame.iterrows():
        print(index)
        try:
            fear_betas_bilateral = getBetas(copeDir = copeDir, name = row['name'], emotion = 'Fear',mask = bilateralAmygHOmask)
            neut_betas_bilateral = getBetas(copeDir = copeDir, name = row['name'], emotion = 'Neut',mask = bilateralAmygHOmask)
            fear_betas_right = getBetas(copeDir = copeDir, name = row['name'], emotion = 'Fear',mask = rightAmygHOmask)
            neut_betas_right = getBetas(copeDir = copeDir, name = row['name'], emotion = 'Neut',mask = rightAmygHOmask)
            fear_betas_left= getBetas(copeDir = copeDir, name = row['name'], emotion = 'Fear',mask = leftAmygHOmask)
            neut_betas_left = getBetas(copeDir = copeDir, name = row['name'], emotion = 'Neut',mask = leftAmygHOmask)            
            
            # subject-level dataframe of betas for each trial
            miniDf = pd.DataFrame({
                'fear_betas_bilateral':fear_betas_bilateral[0],
                'neut_betas_bilateral': neut_betas_bilateral[0],
                'fear_betas_right':fear_betas_right[0],
                'neut_betas_right': neut_betas_right[0],
                'fear_betas_left':fear_betas_left[0],
                'neut_betas_left': neut_betas_left[0],
                'trial': np.arange(1, len(fear_betas_bilateral[0]) + 1)
            })
            miniDf['name'] = row['name']
            
            # put them together for all subjects
            if index == 1:
                output = miniDf
            else:
                output = pd.concat([output, miniDf])
        except:
            print('error')
    # return output dataframe
    return(output)


# Save trial-level betas
allBetas = getAllTrials('betaSeriesCopesReg')
allBetas.to_csv('allAmygBetas.csv')

allBetasGlobalSignal = getAllTrials('betaSeriesCopesGlobalSignalSubtract')
allBetasGlobalSignal.to_csv('allAmygBetas_global_signal.csv')