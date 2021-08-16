import os
import glob


subs = glob.glob('../../data/*')
os.system('mkdir betaSeriesCopes')

for sub in list(subs):
	featDirs = glob.glob(sub + '/model/fear/singleTrialModels/*')
	numDirs = len(featDirs)

	scan = sub.split('/')[3]
	print(scan)

	copeFear = []
	copeNeut = []

	if numDirs == 48:
		for ii in range(1, 25, 1):
			copeFear.append(sub + '/model/fear/singleTrialModels/Fear_' + str(ii) + '.feat/stats/cope1.nii.gz')
			copeNeut.append(sub + '/model/fear/singleTrialModels/Neut_' + str(ii) + '.feat/stats/cope1.nii.gz')
			

		joinedFear = ' '.join(copeFear)
		joinedNeut = ' '.join(copeNeut)
		os.system('fslmerge -t betaSeriesCopes/' + scan + '_fearBetas ' + joinedFear)
		os.system('fslmerge -t betaSeriesCopes/' + scan + '_neutBetas ' + joinedNeut)		
		

