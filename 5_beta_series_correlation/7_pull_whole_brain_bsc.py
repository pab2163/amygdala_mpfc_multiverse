'''
Get beta series correlations between all combinations of Harvard-Oxford atlas ROI masks
Functions run for beta series images with vs. without global signal correction

Author: Paul Bloom

'''

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

# All masks in the harvard-oxford cortical + subcortical atlases
maskPaths = glob.glob('../Parcellations/harvardOx/*.nii.gz')

masks = ['none'] * len(maskPaths)
for counter, maskPath in enumerate(maskPaths):
    masks[counter] = image.load_img(maskPath)
    masks[counter] = masks[counter].get_fdata()
    masks[counter] = masks[counter].flatten()

maskPaths



def getCorrelation(name, emotion, mask1, mask2, gss):
     # Load in the 4d image of 24 betas
    if gss:
        emotImgPath = 'betaSeriesCopesGlobalSignalSubtract/' + name + '_reg' + emotion + 'Betas.nii.gz'
    else:
        emotImgPath = 'betaSeriesCopes/' + name + '_reg' + emotion + 'Betas.nii.gz'
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

# for each scan, get beta series correlations between all pairwise combinations of masks
def getAllCorrelations(condition, gss):
    df = pd.DataFrame(data = d)

    # Make list of pairwise tuples of masks to correlate
    combsList = (list(combinations(range(len(maskNames)), 2)))

    # Name dataframe columns/change names in the combination list to have ROIs
    for i in range(len(combsList)):
        df[str(combsList[i])] = np.nan
        combsList[i] = maskNames[combsList[i][0]] + '_' + maskNames[combsList[i][1]]

    # For each scan, pull correlations between each pair of maks
    for index, row in df.iterrows():
        print(index)
        if os.path.isfile('betaSeriesCopesReg/' + row['name'] + '_regFearBetas.nii.gz'):
            for i in df.columns[1:]:
                pos1 = int(re.findall(r'\d+', i.split(',')[0])[0])
                pos2 = int(re.findall(r'\d+', i.split(',')[1])[0])
                df.loc[index, i] = getCorrelation(name = row['name'], emotion = condition, mask1 = masks[pos1], mask2 = masks[pos2], gss = gss)
        
    # rename to be interpretable as regions
    combsList.insert(0, 'name')
    df.columns = combsList
    
    # write to csv and return
    if gss:
        df.to_csv('betaSeries_global_signal_ho_' + condition + '.csv', index = False)
    else:
        df.to_csv('betaSeries_no_global_signal_ho_' + condition + '.csv', index = False)
    return(df)


# Run the functions!
getAllCorrelations(condition = 'fear', gss = True)
getAllCorrelations(condition = 'fear', gss = False)
getAllCorrelations(condition = 'neutral', gss = True)
getAllCorrelations(condition = 'neutral', gss = False)

