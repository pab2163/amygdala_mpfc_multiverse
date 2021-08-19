#!/usr/bin/python
# script to control flow to loop through subjects and submit Feat jobs!
# Author: PAB 
# Date: November 26, 2018

# This script takes one user input -- the text file from which to read fsf files to submit to haba to run

import glob
import os
import sys
import subprocess

# take in the name of a list of runs
textFile = sys.argv[1]

# import saved list of subjects to preprocess
runsToProc = [line.rstrip('\n') for line in open(textFile)]

# loop through and submit via sbatch
for ii in range(0,len(runsToProc)):
		run = os.path.split(runsToProc[ii])[1][:-4]
		print(run)

		jobSubmitMessage = ("sbatch -o %s_%%j.out -e %s_%%j.err run_level1_haba.sh %s"%(run, run, runsToProc[ii]))
		os.system(jobSubmitMessage)



