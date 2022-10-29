'''
This script makes a mask with the average signal in each amygdala voxel across all runs (from all participants)
Requires mean functional images for each run in standard space
'''

import glob
import os

# glob the registered mean functional images
meanFuncs= glob.glob('../../../data/*/model/fear/24motion.feat/reg_standard/mean_func.nii.gz')
joinedScans = ' '.join(meanFuncs)

# merge into one 'timeseries'
os.system('fslmerge -t images/mergedMeanFuncs ' + joinedScans)

# Make mean and std images
os.system('fslmaths images/mergedMeanFuncs.nii.gz -Tmean images/meanSignal.nii.gz')
os.system('fslmaths images/mergedMeanFuncs.nii.gz -Tstd images/sdSignal.nii.gz')

# Mask amygdala
os.system('fslmaths images/meanSignal.nii.gz -mas ../../Structural/mni2mmSpace/harvardoxfordsubcortical_bilateralamyg_2mm.nii.gz images/meanSignalAmygMask.nii.gz')
os.system('fslmaths images/sdSignal.nii.gz -mas ../../Structural/mni2mmSpace/harvardoxfordsubcortical_bilateralamyg_2mm.nii.gz images/sdSignalAmygMask.nii.gz')
