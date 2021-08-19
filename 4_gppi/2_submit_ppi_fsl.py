#!/usr/bin/python
# script to control flow to loop through subjects and run FEAT ppi jobs on habanero
# Takes two arguments 1) model directory name (6motion_no_errors.feat) 2) ppiStyle -- either 'fsl_style' or 'afni_style', or 'afni_no_deconvolve'
# Author: PAB 
# Date: July 9, 2018


import glob
import os
import sys
import subprocess

# input for which directory of level1 to use
directoryNames = sys.argv[1]

# import saved list of subjects to preprocess
#subsToProc = [line.rstrip('\n') for line in open('level1Sublist.txt')]
ppiScripts = glob.glob('/rigel/psych/users/pab2163/mri_scripts/7_ppi_fsl/sub_fsfs/%s/*'%(directoryNames))


for featFile in list(ppiScripts):
	print(featFile)
	jobSubmitMessage = ("sbatch -o %s_%%j.out -e %s_%%j.err run_ppi_fsl.sh %s"%(featFile, featFile, featFile))
	os.system(jobSubmitMessage)

