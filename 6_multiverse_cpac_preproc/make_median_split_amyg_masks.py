import pandas as pd
import os

# get median value of amygdala signal in group-level, save to txt file
os.system('fslstats images/meanSignalAmygMask.nii.gz -P 50 > images/medianAmygSignal.txt')

# import median value of the amygala signal (there is probably a more efficient way to do this, I know...)
df = pd.read_csv('images/medianAmygSignal.txt', header = None)
medianVal = df.iloc[0,0]

# binarize masks above/below median
os.system('fslmaths images/meanSignalAmygMask.nii.gz -thr %s -bin images/bilateralAmygHighSignal'%(int(medianVal)))
os.system('fslmaths images/meanSignalAmygMask.nii.gz -uthr %s -bin images/bilateralAmygLowSignal'%(int(medianVal)))

# Make left/right for high signal and low signal masks
os.system('fslmaths images/bilateralAmygHighSignal.nii.gz -roi 45 91 0 -1 0 -1 0 -1 images/leftAmygHighSignal')
os.system('fslmaths images/bilateralAmygLowSignal.nii.gz -roi 45 91 0 -1 0 -1 0 -1 images/leftAmygLowSignal')
os.system('fslmaths images/bilateralAmygHighSignal.nii.gz -roi 0 45 0 -1 0 -1 0 -1 images/rightAmygHighSignal')
os.system('fslmaths images/bilateralAmygLowSignal.nii.gz -roi 0 45 0 -1 0 -1 0 -1 images/rightAmygLowSignal')

# Regular right/left
os.system('fslmaths ../../Structural/mni2mmSpace/harvardoxfordsubcortical_bilateralamyg_2mm.nii.gz -roi 45 91 0 -1 0 -1 0 -1 images/leftAmyg')
os.system('fslmaths ../../Structural/mni2mmSpace/harvardoxfordsubcortical_bilateralamyg_2mm.nii.gz -roi 0 45 0 -1 0 -1 0 -1 images/rightAmyg')

