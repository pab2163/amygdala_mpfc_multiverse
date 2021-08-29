import glob
import os
import os.path
import sys
import subprocess
import pandas as pd
import numpy as np

thresh = .9

# remove these before writing (because script appends)
os.system('rm scansNoFD.txt')
os.system('rm scansNoNuisance.txt')


# Function for making the the confound file for TRs about motion threshold cutoff --these are downweighted to 0 in the GLM
def createConfound1Scan(subid):
    inFile = '../../cpacPreproc/cpacTesting2/output/pipeline_analysis_testing/' + str(subid) + '_' + str(subid) + '/frame_wise_displacement_power/_scan_rest/FD.1D'
    if os.path.isfile(inFile):
        fd = pd.read_csv(inFile, header = None)
        for index, row in fd.iterrows():
            if fd.iloc[index,0] > thresh:
                newCol = np.zeros(len(fd))
                newCol[index] = 1
                newCol = pd.Series(newCol).rename(str(index))
                fd = fd.join(newCol)
        # Only write a file if there are indeed TRs meeting motion threshold
        if fd.shape[1] >= 2:
            fd = fd.drop(0, axis =1 )
            outFile = 'confoundFilesFear/' + str(subid) + '_' + str(thresh) + '_confound.txt'
            fd.to_csv(outFile, index=False, header=False, sep='\t', encoding='utf-8')
    else:
        os.system('echo %s >> scansNoFD.txt'%(subid))


# Function for making the full regressors file
# nuisanceType can take values of either 'wmCsf18' or 'standard6'
def mergeConfoundsNuisance(subid, nuisanceType):
    # Load nuisance file from cpac
    if os.path.isdir('../../cpacPreproc/cpacTesting2/output/pipeline_analysis_testing_nuisance/' + str(subid) + '_' + str(subid)):
        if nuisanceType == 'wmCsf18':
            nuisanceFile = '../../cpacPreproc/cpacTesting2/output/pipeline_analysis_testing_nuisance/' + str(subid) + '_' + str(subid) + '/functional_nuisance_regressors/_scan_rest/_selector_WM-2mmE-M_CSF-2mmE-M_M-DB/nuisance_regressors.1D'
        elif nuisanceType == 'standard6':
            nuisanceFile = '../../cpacPreproc/cpacTesting2/output/pipeline_analysis_testing_nuisance/' + str(subid) + '_' + str(subid) + '/functional_nuisance_regressors/_scan_rest/_selector_M/nuisance_regressors.1D'
        nuisance = pd.read_csv(nuisanceFile, sep = '\t', header = 2)
        # If there are confound TRs to regress out, merge those to nuisance file
        if os.path.isfile('confoundFilesFear/' + str(subid) + '_' + str(thresh) + '_confound.txt'):
            confounds = pd.read_csv('confoundFilesFear/' + str(subid) + '_' + str(thresh) + '_confound.txt', header = None, sep = '\t')
            allConfounds = pd.concat([confounds, nuisance], axis = 1)
        else:
            allConfounds = nuisance

        # Write out file
        outFile = 'nuisanceGLMFilesFear/' + subid + '_' + str(thresh) + '_' + nuisanceType + 'nuisancePlusConfounds.txt'
        allConfounds.to_csv(outFile, index=False, header=False, sep='\t', encoding='utf-8')
    else:
        os.system('echo %s >> scansNoNuisance.txt'%(subid))


# Run the functions for each scan

path = '../../../data/*'
scans = glob.glob(path)

for scan in list(scans):
    name = scan.split('/')[4]
    print(name)
    createConfound1Scan(subid =name)
    mergeConfoundsNuisance(subid = name, nuisanceType = 'wmCsf18')
    mergeConfoundsNuisance(subid = name, nuisanceType = 'standard6')