# Extracts ppi betas for all masks not labeled STRUCTSPACE in the masks folder
# Takes user input on commandline for the name of the model folder --- for example 'may25_2018.feat'
# Also takes user input for the ppi model: ppi_fsl_style.feat
# Author: PAB
# Date: June 12, 2018

import glob
import os
import os.path
import sys
import subprocess
import fnmatch


path = '/danl/SB/PaulCompileTGNG/data'

model = sys.argv[1]
ppiModel = sys.argv[2]

# get the bold directories for each TGNG subject
featdirs = glob.glob('%s/*/model/fearNeutModel/%s'%(path, model))

numDirs = len(featdirs)
print('Found ' + str(numDirs) + ' feat directories with name: ' + model)

for cur_dir in list(featdirs):
	print(cur_dir)
	os.system('mkdir %s/%s/ppi_fsl_roi/'%(cur_dir, ppiModel))

	#just mpfc masks for now
	masks = glob.glob('%s/../../../BOLD/masks/%s/*anterior.nii.gz'%(cur_dir, model)) + glob.glob('%s/../../../BOLD/masks/%s/*anterior_down.nii.gz'%(cur_dir, model)) + glob.glob('%s/../../../BOLD/masks/%s/*mm.nii.gz'%(cur_dir, model))
	


	for mask in list(masks): # For each mask
		if 'STRUCTSPACE' not in mask:
			splitmask= mask.split('/')
			maskname = splitmask[15]
			#print(mask)
			#print(maskname)
			for num in range(8,10): # For contrasts 8-9
				print(num)
				
				#Get tstat mean of that mask
				os.system('fslmeants -i %s/%s/stats/tstat%s.nii.gz -m %s -o %s/%s/ppi_fsl_roi/cope%s_tstat_%s.txt'%(cur_dir, ppiModel, num, mask, cur_dir, ppiModel, num, maskname[:-7]))

				#Get cope mean of that mask
				os.system('fslmeants -i %s/%s/stats/cope%s.nii.gz -m %s -o %s/%s/ppi_fsl_roi/cope%s_%s.txt'%(cur_dir, ppiModel, num, mask, cur_dir, ppiModel, num,maskname[:-7]))

		else:
			print('Not doing anything with structural mask %s'%(mask))


