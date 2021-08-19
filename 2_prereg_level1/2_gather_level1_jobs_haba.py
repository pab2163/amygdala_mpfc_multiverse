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
subsFrame = pd.read_csv('../2_motion/subsAllEmotionsForLev1.csv')

subsFrame['runList'] = np.nan

# Loop through the data frame of subjects 
for index, row in subsFrame.iterrows():
	fsfFile = 'sub_fsfs_all_emotions/%s/%s_%s_lev1.fsf'%(directoryName, row['name'], row['runType'])
	subsFrame.loc[index, 'runList']= fsfFile
	print(fsfFile)

	#submitMessage = "sbatch -o %s_%%j.out -e %s_%%j.err run_level1_haba.sh %s"%((row['name']+row['runType']), (row['name']+row['runType']), fsfFile)
	#print(submitMessage)
	#os.system(jobSubmitMessage)

print('Done!')
subsFrame['runList'].to_csv('runListAllEmotions.txt', index = False)


