#!/usr/bin/python
# Script that loops through subjects in the original SB structure to convert dicom files to nifti
# Nifti files are output to SB/PaulCompileTGNG/
# PAB 
# Date: Feb 13, 2018

import glob
import os
import sys
import subprocess


# Open subject names file and runs file, and put into lists
subNames = [line.rstrip('\n') for line in open('names_update.txt')]
subRuns = [line.rstrip('\n') for line in open('runs_update.txt')]


if len(subNames) == len(subRuns):
	print('Subject runs should match! Good to go')
	
	# Loop through all subjects (or just custom)
	for jj in xrange(0,len(subRuns)):

		# Set directory for that subject using subNames and subRuns
		direct = '/danl/SB/' + subNames[jj] + '/tgng/' + subRuns[jj] + '/'
		

		#
		fileDest = '/danl/SB/PaulCompileTGNG/data/' + subNames[jj] + '/BOLD/' + subNames[jj] + '_tgng_fear_only_bold.nii.gz'
		
		# Only run dicom2nifti for subjects that haven't been run already
		foo = os.path.exists(fileDest)
		if not foo:

		# Run dicom2nifti conversion for that subject and save in PaulCompileTGNG structure
			os.system("dcm2niix -z y -f " + subNames[jj] + "_tgng_fear_only_bold " + "-o /danl/SB/PaulCompileTGNG/data/" + subNames[jj] + "/BOLD " + direct + "/001")

		# Print out which subjects finished conversion! 
			print('Just finished dcm2nifti conversion for: ' + subNames[jj])
		
		# Try again with different file name starter for differently named dicom files
		if not foo:

		# Run dicom2nifti conversion for that subject and save in PaulCompileTGNG structure
			os.system("dcm2niix -z y -f " + subNames[jj] + "_tgng_fear_only_bold " + "-o /danl/SB/PaulCompileTGNG/data/" + subNames[jj] + "/BOLD " + direct + "1")

		# Print out which subjects finished conversion! 
			print('2ND ROUND!!! Just finished dcm2nifti conversion for: ' + subNames[jj])


		
		# Try again with different file name starter for differently named dicom files
		if not foo:

		# Run dicom2nifti conversion for that subject and save in PaulCompileTGNG structure
			os.system("dcm2niix -z y -f " + subNames[jj] + "_tgng_fear_only_bold " + "-o /danl/SB/PaulCompileTGNG/data/" + subNames[jj] + "/BOLD " + direct + "000001.dcm")

		# Print out which subjects finished conversion! 
			print('3RD ROUND!!! Just finished dcm2nifti conversion for: ' + subNames[jj])



		# If that nifti already exists, say so!
		else:
			print('Nifti already exists for ' + subNames[jj])
else:
	print('Subject runs might not match! Check source .txt files! ')



