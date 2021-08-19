#!/usr/bin/env python
# coding: utf-8
# This script pulls estimates (coefs & tstats) for each of the 8 pipelines (after GLM) for each of 9 amygdala ROIs based on the Harvard-Oxford Atlas
# Author: Paul A. Bloom
# Date: December 16, 2019

import nilearn
from nilearn import image
from nilearn import plotting
import matplotlib.pyplot as plt
import os
import pandas as pd
import numpy as np
import glob
import re


if not os.path.isfile('allHO_Amyg_FSL_Copes_Neutral.csv'):
    # Set paths to statmaps from FSL pipelines
    scans = glob.glob('/danl/SB/Investigators/PaulCompileTGNG/data/*')
    fslTemplates = glob.glob('/danl/SB/Investigators/PaulCompileTGNG/mri_scripts/cpacPipelines/glm/templates/fsl/*.fsf')

    for index, dir in enumerate(scans):
        scans[index] = dir.split('/')[6]
        
    for index, dir in enumerate(fslTemplates):
        fslTemplates[index] = dir.split('/')[10][:-4]


    ## Create functions for pulling mean beta estimates for each ROI for each subject
    def getRoiStatFSL(subject,pipeline, roi, contrastNum, imageType):
        maskDat = roi.get_fdata()
        maskDat = maskDat.flatten()

        # Pull for the emotional face and neutral face cope for each run
        emotImg = '/danl/SB/Investigators/PaulCompileTGNG/mri_scripts/cpacPipelines/glm/output/' + subject + '/' + pipeline + '/stats/' + imageType + str(contrastNum) + '.nii.gz'
        emotCope = image.load_img(emotImg)
        emotCope = emotCope.get_fdata()
        emotCope = emotCope.flatten()
        
        # Mask the cope images and filter based on mask == 1, then take means      
        maskedEmotCope = emotCope[maskDat == 1]
        meanEmotCope = np.mean(maskedEmotCope)
        
        # return array of [emotion, neutral]
        return(meanEmotCope)

    # FSL COEF # -----------------------------------------------------------------------------------
    # # Set up dataframe
    outDf = pd.DataFrame(index = range(0,len(scans)))
    outDf['name'] = scans
    outDf = outDf.sort_values('name')

    # Compile list of ROIs and name columns accordingly
    roiList = glob.glob('/danl/SB/Investigators/PaulCompileTGNG/mri_scripts/4_roi_analysis/multiverseAmygROIs/amygMultiverseROIs_HO/*.nii.gz')
    for ii, region in enumerate(roiList):
        for template in fslTemplates:
            regionNameMean = str(template) + '__' + region.split('/')[9][:-7]
            outDf[regionNameMean] = np.nan


    # ## Loop through all subjects, all ROIs, to pull mean betas/tstats into dataframe
    for index, row in outDf.iterrows():
        print(row['name'])
        for columnName in list(outDf.columns[1:]):
            try:
                roiPath = '/danl/SB/Investigators/PaulCompileTGNG/mri_scripts/4_roi_analysis/multiverseAmygROIs/amygMultiverseROIs_HO/' + str(columnName).split('__', 1)[1] + '.nii.gz'            
                outDf.loc[index, columnName] = getRoiStatFSL(subject = row['name'], pipeline = str(columnName).split('__')[0] + '.feat', roi = image.load_img(roiPath), contrastNum = 2, imageType = 'cope')
            except:
                print('ERROR!!')
    outDf.to_csv('allHO_Amyg_FSL_Copes_Neutral.csv', index = False)




    # FSL Tstat # -----------------------------------------------------------------------------------

    # Reset the dataframe for outputs
    outDf = pd.DataFrame(index = range(0,len(scans)))
    outDf['name'] = scans
    outDf = outDf.sort_values('name')


    # Compile list of ROIs and name columns accordingly
    roiList = glob.glob('/danl/SB/Investigators/PaulCompileTGNG/mri_scripts/4_roi_analysis/multiverseAmygROIs/amygMultiverseROIs_HO/*.nii.gz')
    for ii, region in enumerate(roiList):
        for template in fslTemplates:
            regionNameMean = str(template) + '__' + region.split('/')[9][:-7]
            outDf[regionNameMean] = np.nan

    # ## Loop through all subjects, all ROIs, to pull mean betas/tstats into dataframe
    for index, row in outDf.iterrows():
        print(row['name'])
        for columnName in list(outDf.columns[1:]):
            try:
                roiPath = '/danl/SB/Investigators/PaulCompileTGNG/mri_scripts/4_roi_analysis/multiverseAmygROIs/amygMultiverseROIs_HO/' + str(columnName).split('__', 1)[1] + '.nii.gz'            
                outDf.loc[index, columnName] = getRoiStatFSL(subject = row['name'], pipeline = str(columnName).split('__')[0] + '.feat', roi = image.load_img(roiPath), contrastNum = 2, imageType = 'tstat')
            except:
                print('ERROR!!')
    outDf.to_csv('allHO_Amyg_FSL_Tstats_Neutral.csv', index = False)

else:
    print('FSL already done!')

#### AFNI SECTION ####  -------------------------------------------------------
if not os.path.isfile('allHO_Amyg_AFNI_Copes_Neutral.csv'):

    # Function for pulling stats from AFNI glms
    def getRoiStatAFNI(subject,pipeline, roi, contrastNum, imageType):
        maskDat = roi.get_fdata()
        maskDat = maskDat.flatten()

        # Pull for the emotional face and neutral face cope for each run
        emotImg = '/danl/SB/Investigators/PaulCompileTGNG/mri_scripts/cpacPipelines/glm/output/' + subject + '/' + pipeline + '/' + imageType + '.nii.gz'
        emotCope = image.load_img(emotImg)
        emotCope = emotCope.get_fdata()
        emotCope = emotCope.flatten()
        
        # Mask the cope images and filter based on mask == 1, then take means      
        maskedEmotCope = emotCope[maskDat == 1]
        meanEmotCope = np.mean(maskedEmotCope)
        
        # return array of [emotion, neutral]
        return(meanEmotCope)

    # Set paths to statmaps for AFNI pipelines
    scans = glob.glob('/danl/SB/Investigators/PaulCompileTGNG/data/*')
    afniTemplates = glob.glob('/danl/SB/Investigators/PaulCompileTGNG/mri_scripts/cpacPipelines/glm/templates/afni/*.sh')

    for index, dir in enumerate(scans):
        scans[index] = dir.split('/')[6]
        
    for index, dir in enumerate(afniTemplates):
        afniTemplates[index] = dir.split('/')[10][:-3]


    # AFNI COEF # -----------------------------------------------------------------------------------
    outDf = pd.DataFrame(index = range(0,len(scans)))
    outDf['name'] = scans
    outDf = outDf.sort_values('name')

    # Compile list of ROIs and name columns accordingly
    roiList = glob.glob('/danl/SB/Investigators/PaulCompileTGNG/mri_scripts/4_roi_analysis/multiverseAmygROIs/amygMultiverseROIs_HO/*.nii.gz')
    for ii, region in enumerate(roiList):
        for template in afniTemplates:
            regionNameMean = str(template) + '__' + region.split('/')[9][:-7]
            outDf[regionNameMean] = np.nan

    for index, row in outDf.iterrows():
        print(row['name'])
        for columnName in list(outDf.columns[1:]):
            try:
                roiPath = '/danl/SB/Investigators/PaulCompileTGNG/mri_scripts/4_roi_analysis/multiverseAmygROIs/amygMultiverseROIs_HO/' + str(columnName).split('__', 1)[1] + '.nii.gz'            
                outDf.loc[index, columnName] = getRoiStatAFNI(subject = row['name'], pipeline = str(columnName).split('__')[0], roi = image.load_img(roiPath), contrastNum = 1, imageType = 'neutCoef')
            except:
                print('ERROR!!')
    outDf.to_csv('allHO_Amyg_AFNI_Coefs_Neutral.csv', index = False)

    # AFNI Tstat # -----------------------------------------------------------------------------------
    outDf = pd.DataFrame(index = range(0,len(scans)))
    outDf['name'] = scans
    outDf = outDf.sort_values('name')


    # Compile list of ROIs and name columns accordingly
    roiList = glob.glob('/danl/SB/Investigators/PaulCompileTGNG/mri_scripts/4_roi_analysis/multiverseAmygROIs/amygMultiverseROIs_HO/*.nii.gz')
    for ii, region in enumerate(roiList):
        for template in afniTemplates:
            regionNameMean = str(template) + '__' + region.split('/')[9][:-7]
            outDf[regionNameMean] = np.nan

    for index, row in outDf.iterrows():
        print(row['name'])
        for columnName in list(outDf.columns[1:]):
            try:
                roiPath = '/danl/SB/Investigators/PaulCompileTGNG/mri_scripts/4_roi_analysis/multiverseAmygROIs/amygMultiverseROIs_HO/' + str(columnName).split('__', 1)[1] + '.nii.gz'            
                outDf.loc[index, columnName] = getRoiStatAFNI(subject = row['name'], pipeline = str(columnName).split('__')[0], roi = image.load_img(roiPath), contrastNum = 1, imageType = 'neutTstat')
            except:
                print('ERROR!!')
    outDf.to_csv('allHO_Amyg_AFNI_Tstats_Neutral.csv', index = False)
else:
    print('AFNI already done!')