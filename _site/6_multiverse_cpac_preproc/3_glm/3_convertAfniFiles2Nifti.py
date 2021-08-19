#!/usr/bin/python

# import these specific packages that we will need later
import os
import glob
import sys
import re


# Define the subject directories for each run
subdirs = glob.glob('../../../data/*')
afniPipelines = glob.glob('templates/afni/*.sh')

# submig glm job for each subject for each pipeline
for dir in list(subdirs):
  splitdir = dir.split('/')
  subnum = splitdir[4]
  for pipeline in list(afniPipelines):
    pipelineName = pipeline.split('/')[2][:-3]

    # Define the directory path
    dir = '/danl/SB/Investigators/PaulCompileTGNG/mri_scripts/cpacPipelines/glm/output/' + subnum + '/' + pipelineName

    # Define paths to input sub-briks
    inFearCoef = dir + '/stats_FearRun+orig.BRIK[5]'
    inFearTstat = dir + '/stats_FearRun+orig.BRIKK[6]'
    inNeutralCoef = dir + '/stats_FearRun+orig.BRIK[7]'
    inNeutralTstat = dir + '/stats_FearRun+orig.BRIK[8]'
    inFearMinusNeutralCoef = dir + '/stats_FearRun+orig.BRIK[9]'
    inFearMinusNeutralTstat = dir + '/stats_FearRun+orig.BRIK[10]'

    # Define paths to output niftis
    outFearCoef = dir + '/fearCoef'
    outFearTstat = dir + '/fearTstat'
    outNeutralCoef = dir + '/neutCoef'
    outNeutralTstat = dir + '/neutTstat'
    outFearMinusNeutralCoef = dir + '/fearMinusNeutralCoef'
    outFearMinusNeutralTstat = dir + '/fearMinusNeutralTstat'

    # If files exist, convert!
    if os.path.isfile((dir + '/stats_FearRun+orig.BRIK')):
        print('Converting afni2nifti for %s %s'%(subnum, pipelineName))
        os.system('3dAFNItoNIFTI -prefix %s %s'%(outFearCoef, inFearCoef))
        os.system('3dAFNItoNIFTI -prefix %s %s'%(outFearTstat, inFearTstat))
        os.system('3dAFNItoNIFTI -prefix %s %s'%(outNeutralCoef, inNeutralCoef))
        os.system('3dAFNItoNIFTI -prefix %s %s'%(outNeutralTstat, inNeutralTstat))
        os.system('3dAFNItoNIFTI -prefix %s %s'%(outFearMinusNeutralCoef, inFearMinusNeutralCoef))
        os.system('3dAFNItoNIFTI -prefix %s %s'%(outFearMinusNeutralTstat, inFearMinusNeutralTstat))

        #Then compress
        os.system('gzip -f %s.nii'%(outFearCoef))
        os.system('gzip -f %s.nii'%(outFearTstat))
        os.system('gzip -f %s.nii'%(outNeutralCoef))
        os.system('gzip -f %s.nii'%(outNeutralTstat))
        os.system('gzip -f %s.nii'%(outFearMinusNeutralCoef))
        os.system('gzip -f %s.nii'%(outFearMinusNeutralTstat))

        # Remove uncompressed files
        os.system('rm %s.nii'%(outFearCoef))
        os.system('rm %s.nii'%(outFearTstat))
        os.system('rm %s.nii'%(outNeutralCoef))
        os.system('rm %s.nii'%(outNeutralTstat))
        os.system('rm %s.nii'%(outFearMinusNeutralCoef))
        os.system('rm %s.nii'%(outFearMinusNeutralTstat))       
    else:
        print(dir + ' does not exist!')