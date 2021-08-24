#!/usr/bin/python
# script to control flow to loop through subjects and run FEAT ppi jobs on habanero
# Author: PAB 
# Date: July 9, 2018


import glob
import os
import sys
import subprocess



# import saved list of subjects to preprocess
#subsToProc = [line.rstrip('\n') for line in open('level1Sublist.txt')]
ppiScripts = glob.glob('/rigel/psych/users/pab2163/mri_scripts/7_ppi_fsl/sub_fsfs/*')


for featFile in list(ppiScripts):
	print(featFile)
	jobSubmitMessage = ("sbatch -o %s_%%j.out -e %s_%%j.err run_ppi_fsl.sh %s"%(featFile, featFile, featFile))
	os.system(jobSubmitMessage)

