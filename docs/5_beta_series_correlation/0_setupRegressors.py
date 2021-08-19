# Sets up trialwise stimulus timing files for use in LSS beta series models
# Paul A. Bloom

import glob
import os


# Glob all scans
scanlist = glob.glob('../../data/SB*')

# Do this for each scan
for scanPath in list(scanlist):
	
	# Determine stim file paths
	name = scanPath.split('/')[3]
	print(name)
	fearStims = scanPath + '/model/fear/' + name + '_fearOnsets.txt'
	neutStims = scanPath + '/model/fear/' + name + '_neutOnsets.txt'

	# If stimfiles are there
	if os.path.isfile(fearStims) and os.path.isfile(neutStims):

		# make directory for new onset files
		onsetDir = '../../data/' + name + '/model/fear/betaSeriesOnsets'
		os.system('mkdir %s'%(onsetDir))


		# For each trialnum (1-24), make 4 files
		# 1: fear# (single trial)
		# 2: neut# (single trial)
		# 3: all trials except for fear#
		# 4: all trials except for neut#
		for ii in range(1, 25, 1):
			# pull out just the ii'th fear/neutral trials, put them in their own files
			makeFearTrialMessage = 'cat ' + fearStims + ' | head -n ' + str(ii)+ ' | tail -n 1 > %s/FearTrial%s.txt'%(onsetDir, str(ii))
			makeNeutTrialMessage = 'cat ' + neutStims + ' | head -n ' + str(ii)+ ' | tail -n 1 > %s/NeutTrial%s.txt'%(onsetDir, str(ii))

			# concatenate all fear + neutral trials, remove ii'th one, then sort in order of time 
			allTrialsMinusFearMessage = 'cat ' + fearStims + ' ' + neutStims + " | sed '%sd' | sort -n >  %s/allMinusFear%s.txt"%(ii, onsetDir, str(ii))
			allTrialsMinusNeutMessage = 'cat ' + neutStims + ' ' + fearStims + " | sed '%sd' | sort -n >  %s/allMinusNeut%s.txt"%(ii, onsetDir, str(ii))

			# run the above
			os.system(makeFearTrialMessage)
			os.system(makeNeutTrialMessage)
			os.system(allTrialsMinusFearMessage)
			os.system(allTrialsMinusNeutMessage)
