#!/usr/bin/python
# script to control flow to loop through subjects and run FEAT registration/level1 Jobs 
# Author: PAB 
# Date: November 26, 2018

# Takes 1 command line argument: the folder containing the fsf files to fun


import glob
import os
import sys
import subprocess
import pandas as pd 
import numpy as np 


# This specifies which pipeline to run (i.e. 24motion_no_errors)
directoryName = sys.argv[1]

# import saved list of subjects to preprocess
#subsToProc = [line.rstrip('\n') for line in open('level1Sublist.txt')]
subsFrame = pd.read_csv('../2_motion/subsConcatForLev1.csv')

subsFrame['runList'] = np.nan

# Loop through the data frame of subjects 
for index, row in subsFrame.iterrows():
	fsfFile = 'sub_fsfs_concat/%s/%s_concat_lev1.fsf'%(directoryName, row['name'])
	subsFrame.loc[index, 'runList']= fsfFile
	print(fsfFile)

	# Currently conda envs/pandas not working on haba but if I can get that working
	submitMessage = "sbatch -o %s_%%j.out -e %s_%%j.err run_level1_haba.sh %s"%(row['name'], row['name'], fsfFile)
	print(submitMessage)
	os.system(jobSubmitMessage)

print('Done!')
subsFrame['runList'].to_csv('runListConcat.txt', index = False)


