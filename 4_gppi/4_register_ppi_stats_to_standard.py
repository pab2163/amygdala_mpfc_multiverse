# register ppi statistical image to standard space before pulling betas/tstats for amygdala-mPFC PPI

import nilearn
from nilearn import image
from nilearn import plotting
import matplotlib.pyplot as plt
import os
import pandas as pd
import numpy as np
import glob
import re

# data frame of all runs in feat
subFrame = pd.read_csv('../QA/allEmotionsFeatComplete.csv')
subFrame = subFrame[subFrame['runType'] != 'sad']


def registerPPI2Std(name, runType, ppiDir):
    ref = '../../data/%s/model/%s/24motion.feat/reg/standard.nii.gz'%(name, runType)
    premat = '../../data/%s/model/%s/24motion.feat/reg/example_func2highres.mat'%(name, runType)
    warp = '../../data/%s/model/%s/24motion.feat/reg/highres2standard_warp'%(name, runType)
    
    print(name)
    os.system('mkdir ../../data/%s/model/%s/24motion.feat/%s/reg_standard'%(name, runType, ppiDir))
    os.system('mkdir ../../data/%s/model/%s/24motion.feat/%s/reg_standard/stats'%(name, runType, ppiDir))
    
    
    for ii in range(1,12): # for each tstat1 - tstat11
        inputTstat = '../../data/%s/model/%s/24motion.feat/%s/stats/tstat%s.nii.gz'%(name,runType, ppiDir, ii)
        outputTstat = '../../data/%s/model/%s/24motion.feat/%s/reg_standard/stats/tstat%s.nii.gz'%(name,runType, ppiDir, ii)
        
        inputCope = '../../data/%s/model/%s/24motion.feat/%s/stats/cope%s.nii.gz'%(name,runType, ppiDir, ii)
        outputCope = '../../data/%s/model/%s/24motion.feat/%s/reg_standard/stats/cope%s.nii.gz'%(name,runType, ppiDir, ii)
        
        inputVarcope = '../../data/%s/model/%s/24motion.feat/%s/stats/varcope%s.nii.gz'%(name,runType, ppiDir, ii)
        outputVarcope = '../../data/%s/model/%s/24motion.feat/%s/reg_standard/stats/varcope%s.nii.gz'%(name,runType, ppiDir, ii)
        
        # Use fsl to warp to standard
        tstatMessage = '/usr/local/fsl/bin/applywarp --ref=%s --in=%s '%(ref, inputTstat) + '--out=%s --warp=%s '%(outputTstat, warp) + '--premat=%s --interp=trilinear'%(premat)
        copeMessage = '/usr/local/fsl/bin/applywarp --ref=%s --in=%s '%(ref, inputCope) + '--out=%s --warp=%s '%(outputCope, warp) + '--premat=%s --interp=trilinear'%(premat)
        varcopeMessage = '/usr/local/fsl/bin/applywarp --ref=%s --in=%s '%(ref, inputVarcope) + '--out=%s --warp=%s '%(outputVarcope, warp) + '--premat=%s --interp=trilinear'%(premat)     

        os.system(tstatMessage)
        os.system(copeMessage)
        os.system(varcopeMessage)


for index, row in subFrame.iterrows():
    registerPPI2Std(row['name'], row['runType'], 'gppi_deconv_seed_harvardoxfordsubcortical_bilateralamyg.feat')   
    registerPPI2Std(row['name'], row['runType'], 'gppi_no_deconvseed_harvardoxfordsubcortical_bilateralamyg.feat')   

