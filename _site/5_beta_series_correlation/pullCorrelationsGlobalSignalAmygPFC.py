# This script takes the means across all betas in the brain to make sure that we're getting similar results from the LSS model as the fear/neut condition average models

import sys
import os
import glob
import pandas as pd 
import nilearn
from nilearn import image
import numpy as np
from itertools import combinations
import re 

subs = glob.glob('../../data/*')
for i in range(len(subs)):
    subs[i] = subs[i].split('/')[3]
d = {'name': subs}

mpfcLarge = '/danl/SB/Investigators/PaulCompileTGNG/mri_scripts/Structural/mni2mmSpace/vmpfc_trimmed_prob.5_mni2mm.nii.gz'
mpfcSphereOrig = '/danl/SB/Investigators/PaulCompileTGNG/mri_scripts/Structural/mni2mmSpace/mPFC_sphere_5mm_mni2mm.nii.gz'
mpfcSphereAnterior = '/danl/SB/Investigators/PaulCompileTGNG/mri_scripts/Structural/mni2mmSpace/mPFC_sphere_5mm_anterior_mni2mm.nii.gz'
mpfcSphereAnteriorDown = '/danl/SB/Investigators/PaulCompileTGNG/mri_scripts/Structural/mni2mmSpace/mPFC_sphere_5mm_anterior_down_mni2mm.nii.gz'
ho_amyg_bilateral = '/danl/SB/Investigators/PaulCompileTGNG/mri_scripts/Structural/mni2mmSpace/harvardoxfordsubcortical_bilateralamyg_2mm.nii.gz'
ho_amyg_right = '/danl/SB/Investigators/PaulCompileTGNG/mri_scripts/Structural/mni2mmSpace/harvardoxfordsubcortical_rightamyg.nii.gz_mni2mm.nii.gz'
ho_amyg_left = '/danl/SB/Investigators/PaulCompileTGNG/mri_scripts/Structural/mni2mmSpace/harvardoxfordsubcortical_leftamyg.nii.gz_mni2mm.nii.gz'

maskNames = [mpfcLarge, mpfcSphereOrig, mpfcSphereAnterior, mpfcSphereAnteriorDown, ho_amyg_bilateral, ho_amyg_right, ho_amyg_left]
masks = [mpfcLarge, mpfcSphereOrig, mpfcSphereAnterior, mpfcSphereAnteriorDown, ho_amyg_bilateral, ho_amyg_right, ho_amyg_left]


for index, mask in enumerate(masks):
    masks[index] = image.load_img(mask).get_fdata()
    maskNames[index] = maskNames[index].split('/')[8]


def getCorrelation(name, emotion, mask1, mask2):
    # Load in the 4d image of 24 betas
    emotImgPath = 'betaSeriesCopesGlobalSignalSubtract/' + name + '_reg' + emotion + 'Betas.nii.gz'
    emotImg = image.load_img(emotImgPath).get_fdata()

    # mask it with each roi
    roi1 = emotImg[mask1 == 1]
    roi2 = emotImg[mask2 == 1]

    # get the time series vector of averaged betas across each roi
    meanTimeSeries1 = np.mean(roi1, axis = 0)
    meanTimeSeries2 = np.mean(roi2, axis = 0)

    # correlate the two timeseries vectors using Pearson correlation
    betaSeriesCor = np.corrcoef(meanTimeSeries1, meanTimeSeries2)
    return(betaSeriesCor[0,1])

def getAllCorrelations(condition):
    df = pd.DataFrame(data = d)

    # Make list of pairwise tuples of masks to correlate
    combsList = (list(combinations(range(len(maskNames)), 2)))

    # Name dataframe columns/change names in the combination list to have ROIs
    for i in range(len(combsList)):
        df[str(combsList[i])] = np.nan
        combsList[i] = maskNames[combsList[i][0]] + '_' + maskNames[combsList[i][1]]

    # For each scan, pull correlations between each pair of masks
    for index, row in df.iterrows():
        print(index)
        if os.path.isfile('betaSeriesCopesGlobalSignalSubtract/' + row['name'] + '_regFearBetas.nii.gz'):
            for i in df.columns[1:]:
                pos1 = int(re.findall(r'\d+', i.split(',')[0])[0])
                pos2 = int(re.findall(r'\d+', i.split(',')[1])[0])
                df.loc[index, i] = getCorrelation(name = row['name'], emotion = condition, mask1 = masks[pos1], mask2 = masks[pos2])
        
    # rename to be interpretable as regions
    combsList.insert(0, 'name')
    df.columns = combsList
    
    # write to csv and return
    df.to_csv('betaSeriesGlobalSignalAmygPFC_' + condition + '.csv', index = False)
    return(df)


# Run the functions!
getAllCorrelations(sys.argv[1])

