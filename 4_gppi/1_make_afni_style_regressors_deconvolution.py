# Paul Bloom
# December 12, 2018
# This script is used to generate regressors for PPI in 'afni style' 
# Regressors where the seed timeseries is 'deconvolved', multiplied by psychological regressor, then reconvolved
# This script requires existing extracted timeseries for the ROI of interest (amygdala here) and stim timing files
# NOTE: no upsampling done here
# Takes 1 command line argument: the ROI of interest for which the seed timeseries has already been extracted (havardoxford_subcortical_bilateral)

import glob
import os
import sys
import subprocess
import pandas as pd
import numpy as np

roi = sys.argv[1]

# find all feat directories to set this up for
feardirs = glob.glob("/danl/SB/PaulCompileTGNG/data/*/model/fear/24motion.feat")
happydirs = glob.glob("/danl/SB/PaulCompileTGNG/data/*/model/happy/24motion.feat")
subdirs = feardirs + happydirs


# loop for each feat directory
# dir = specific feat directory
# subnum = subject number (SBXXX)
for dir in list(subdirs):
	if(os.path.isfile('%s/design.mat'%(dir))): # only run this for subjects with a level1 run
		print(dir)
		splitdir = dir.split('/')
		subnum = splitdir[5]
		runType = splitdir[7]

		# make afni ppi regressors directory within FSL level1 directory
		dir_afni = '%s/afni_ppi_regressors'%(dir)
		os.system('mkdir %s'%(dir_afni))

		# Get the timecourse already extracted from FSL 
		os.system('cp %s/timecourses/%s.txt %s/seed_%s.1D'%(dir, roi, dir_afni, roi))

		# Detrend the timeseries 
		os.system("3dDetrend -polort 2 -prefix %s/seed_%s %s/seed_%s.1D\\'"%(dir_afni, roi, dir_afni, roi))

		# Transpose % convert time series to .txt file for FSL
		os.system("1dtranspose %s/seed_%s.1D > %s/seed_%s_ts.1D"%(dir_afni, roi, dir_afni, roi))
		os.system('cat %s/seed_%s_ts.1D > %s/seed_%s_ts.txt'%(dir_afni, roi, dir_afni, roi))

		# Make a GAMMA HRF here
		os.system('waver -dt 2 -GAM -inline 1@1 > %s/GammaHR.1D'%(dir_afni))

		# This is the deconvolution step. The last 2 numbers are model optimization/penalization params. We can play around with these
		os.system("3dTfitter -RHS %s/seed_%s_ts.1D -FALTUNG %s/GammaHR.1D %s/seed_%s_deconvolved 012 0"%(dir_afni, roi, dir_afni, dir_afni, roi))


		#### TIMINGS  ---------------
		# read in stim timing file, output to .1D file for afni
		# pandas/numpy hackyness
		emotStimsFSL = pd.read_table('/danl/SB/PaulCompileTGNG/data/%s/model/%s/%s_%sOnsets.txt'%(subnum, runType, subnum, runType), sep=' ', header = None)
		flots = list(emotStimsFSL.iloc[:,0:1].values)
		flots = map(float,flots)
		nums = [ '%.2f' % elem for elem in flots ]
		nums = " ".join(map(str, nums))
		os.system('echo "%s" > %s/%s_times.1D'%(nums, dir_afni, runType))

		# same with neutral faces
		neutStimsFSL = pd.read_table('/danl/SB/PaulCompileTGNG/data/%s/model/%s/%s_neutOnsets.txt'%(subnum, runType, subnum), sep=' ', header = None)
		flots = list(neutStimsFSL.iloc[:,0:1].values)
		flots = map(float,flots)
		nums = [ '%.2f' % elem for elem in flots ]
		nums = " ".join(map(str, nums))
		os.system('echo "%s" > %s/neut_times.1D'%(nums, dir_afni))

		# Use afni timing tool to get stim times into AFNI format (a 1 or 0 for each TR to indicate if stim occurred during that TR or not)
		# run_len and TR are in seconds
		# min_frac is the trickiest part -- the minimum fraction of a TR at which a stim is said to have occurred. 
		#For example, .05 at a TR of 2s means the 100ms of the stim must be inside any given TR to be marked as a 1. 
		os.system('timing_tool.py -timing %s/%s_times.1D -tr 2 -stim_dur .350 -min_frac .05 -run_len 260 -timing_to_1D %s/%s_afni_times.1D'%(dir_afni, runType, dir_afni, runType)) #fear
		os.system('timing_tool.py -timing %s/neut_times.1D -tr 2 -stim_dur .350 -min_frac .05 -run_len 260 -timing_to_1D %s/neut_afni_times.1D'%(dir_afni, dir_afni)) #neutral


		#### -----------------------


		### Make interaction regressors by multiplying deconvolved seed timeseries and the stime times just generated
		os.system("1deval -a %s/seed_%s_deconvolved.1D\\' -b %s/%s_afni_times.1D -expr 'a*b' > %s/inter%s_%s.1D"%(dir_afni, roi, dir_afni, runType, dir_afni, runType, roi)) #fear
		os.system("1deval -a %s/seed_%s_deconvolved.1D\\' -b %s/neut_afni_times.1D -expr 'a*b' > %s/interNeut_%s.1D"%(dir_afni, roi, dir_afni, dir_afni, roi)) #neutral


		# Scale to 1, cut off by # of study TRs, reconvolve with HR
		os.system('waver -GAM -peak 1 -TR 2 -input %s/inter%s_%s.1D -numout 130 > %s/inter%sScaled_%s.txt'%(dir_afni, runType, roi, dir_afni, runType, roi)) #fear
		os.system('waver -GAM -peak 1 -TR 2 -input %s/interNeut_%s.1D -numout 130 > %s/interNeutScaled_%s.txt'%(dir_afni, roi, dir_afni, roi)) #neutral
	else:
		print('NO LEVEL1 FOR ' + dir)



