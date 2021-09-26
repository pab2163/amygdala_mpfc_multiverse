#!/usr/bin/python
# script to control flow to loop through scans and submit CPAC preproc jobs
# Author: PAB 
# Date: April 22, 2019

import glob
import os
import sys
import subprocess

# Make directories
os.system('mkdir /rigel/psych/users/pab2163/mri_scripts/cpacPreproc/cpacTesting2')
os.system('mkdir /rigel/psych/users/pab2163/mri_scripts/cpacPreproc/scratch')

# Get the number of participants so we know how many CPAC jobs to index/run
scans = glob.glob('../../data/*')
numScans = len(scans)
print(numScans)


# Call slurm script and submit cpac jobs by index
for idx in range(0, numScans):
	print(idx)

	jobSubmitMessage = ("sbatch -o %s_%%j.out -e %s_%%j.err runCpac1Subject.sh %s"%(idx, idx, idx))
	os.system(jobSubmitMessage)



