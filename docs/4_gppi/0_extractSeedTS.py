
# Extracts timecourse from a given input ROI
# IMPORTANTLY: the ROI must be in MNI sampled at 2mm
# To run this script, preprocessing (or the full level1) must be run for each scan so that there is preprocessed BOLD data to extract the TS from
# Author: PAB
# Date: December 17, 2018

import glob
import os
import os.path
import sys
import subprocess

path = '/danl/SB/PaulCompileTGNG/data'

# specifies 1st level model
model = sys.argv[1]

# specify which mask
maskName = sys.argv[2]

# get the bold directories for each TGNG subject
featdirs = glob.glob('%s/*/model/*/%s'%(path, model))

# check how many feat directories in the file structure exist
numDirs = len(featdirs)
print('Found ' + str(numDirs) + ' feat directories with name: ' + model)


# for each feat directory pull 
	# 1) the seed timeseries from that region in std space
	# 2) the preprocessed BOLD (filtered_func)
# then use fslmeants to extract average timeseries from the bold data using that mask


for cur_dir in list(featdirs):
	print(cur_dir)
	os.system('mkdir %s/timecourses'%(cur_dir))

	splitdir = cur_dir.split('/')
	runType = splitdir[7]
	subnum = splitdir[5]
	mask = '/danl/SB/PaulCompileTGNG/data/%s/BOLD/%s/masks/24motion.feat/%s'%(subnum, runType, maskName)
	filtered_func = '%s/filtered_func_data.nii.gz'%(cur_dir)
	output = '%s/timecourses/%s.txt'%(cur_dir, maskName)
	os.system('fslmeants -i %s -o %s -m  %s'%(filtered_func, output, mask))
	print('extracted timeseries for %s'%(cur_dir))

print('DONE!!')