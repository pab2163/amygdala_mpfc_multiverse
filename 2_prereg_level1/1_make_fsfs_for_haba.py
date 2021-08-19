#!/usr/bin/python
# Mumford Brain stats script for generating lev1 feat script(.fsf) for each run for each subject
# Michelle updated for effort task on Jan 12 2018 
# Paul updated this again for SB TGNG all emotions November 26 2018
# This script will generate  design.fsf for each subject for each wave set up to run on Habanero
# Takes 2 arguments:
  # 1: directory name -- what your feat directories at output will be named and what the folder containing the .fsf scripts will be named
  # 2: path to template script


### ALSO, this script is set up to make some preproc corrections (at the end) for select SB scans


# import these specific packages that we will need later
import os
import glob
import sys
import pandas as pd 
import numpy as np
import re


# Set this to the directory all of the sub### directories live in
directoryNames = sys.argv[1]

# Set this to the template .fsf you want to use
featTemplate = sys.argv[2]

# trialwise or no?
trials = sys.argv[3]

if trials == 'trialwise':
  trialwise = True
else:
  trialwise = False


# The directory to  dump all the fsf files
fsfdir="/danl/SB/PaulCompileTGNG/mri_scripts/3_level1/sub_fsfs_all_emotions/%s/"%(directoryNames)

# It's okay to keep this in here--- if the directory already exists it won't do anything
os.system('mkdir %s'%(fsfdir))

# Get dataframe and filter only for scans with fewer than 40 censored TRs
subsFrame = pd.read_csv('../2_motion/subsAllEmotionsForLev1.csv')


# Define the subject directories for each run
subdirs = '/danl/SB/PaulCompileTGNG/data/' + subsFrame['name'] + '/BOLD/' + subsFrame['runType']

# Turn off post-stats
noPostStats = 'set fmri(poststats_yn) 0'

# This to be replaced for haba versions
habanero_path= '/rigel/psych/users/pab2163/'
fsl_path='/rigel/psych/app/fsl/'

# This loop goes through each subject directory generated above and generates an .fsf script for each subject with the replacements specified below
for dir in list(subdirs):
  splitdir = dir.split('/')

  # YOU WILL NEED TO EDIT THIS TO GRAB SUBJECT NUMBER ID FROM YOUR BOLD PATH 
  subnum = splitdir[5]
  runType = splitdir[7]

  #  YOU WILL ALSO NEED TO EDIT THIS TO GRAB THE RUN NUMBER FROM YOUR BOLD PATH(1,2,3)
  print('Making .fsf for: ', subnum, ' ', runType) 
  

  #Define what replacements to make
  #note: for habanero version, we are also changing the paths to the data and FSL!
  replacements = {'SUBNUM':subnum, 'fear': runType, 'Fear': runType, 'EMOTION': runType, '/danl/SB/PaulCompileTGNG/':habanero_path, '/usr/share/fsl/':fsl_path, 'set fmri(poststats_yn) 1':noPostStats}


  # get your template as the input here 
  with open(featTemplate) as infile: 
    if (trialwise == True):
      # outfile = useable fsf file that is being created for every subject and every run 
      with open("/danl/SB/PaulCompileTGNG/mri_scripts/3_level1/sub_fsfs_all_emotions/%s/%s_%s_trialwise_lev1.fsf"%(directoryNames, subnum, runType), 'w') as outfile:
          for line in infile:
            # This code will make new fsf files that replace all of the wild cards we made above!  
            for src, target in replacements.items():
     
              line = line.replace(src, target)
            outfile.write(line)

    else: 
    # outfile = useable fsf file that is being created for every subject and every run 
      with open("/danl/SB/PaulCompileTGNG/mri_scripts/3_level1/sub_fsfs_all_emotions/%s/%s_%s_lev1.fsf"%(directoryNames, subnum, runType), 'w') as outfile:
          for line in infile:
            # This code will make new fsf files that replace all of the wild cards we made above!  
            for src, target in replacements.items():
     
              line = line.replace(src, target)
            outfile.write(line)



# #************************************************************************************************************************************************
allFSF = glob.glob('/danl/SB/PaulCompileTGNG/mri_scripts/3_level1/sub_fsfs_all_emotions/%s/*.fsf'%(directoryNames))

print('SPECIAL FSF EDITS BELOW')

for fsf in list(allFSF):
  # SB028 -- no BBR/no nonlinear registration
  if(re.search('SB028', fsf) != None and re.search('SB028_fu', fsf) == None):
    print(fsf)
    f = open(fsf, 'r')
    filedata = f.read()
    f.close()
    newdata = filedata.replace('BBR', '6')
    newdata = newdata.replace('set fmri(regstandard_nonlinear_yn) 1', 'set fmri(regstandard_nonlinear_yn) 0')
    f = open(fsf, 'w')
    f.write(newdata)
    f.close()
  # SB029_fu2 -- no nonlinear
  if(re.search('SB029_fu2', fsf) != None):
    print(fsf)
    f = open(fsf, 'r')
    filedata = f.read()
    f.close()
    newdata = filedata.replace('set fmri(regstandard_nonlinear_yn) 1', 'set fmri(regstandard_nonlinear_yn) 0')
    f = open(fsf, 'w')
    f.write(newdata)
    f.close()
  # SB102 -- no BBR/no nonlinear registration
  if(re.search('SB102', fsf) != None and re.search('SB102_fu', fsf) == None):
    print(fsf)
    f = open(fsf, 'r')
    filedata = f.read()
    f.close()
    newdata = filedata.replace('BBR', '6')
    newdata = newdata.replace('set fmri(regstandard_nonlinear_yn) 1', 'set fmri(regstandard_nonlinear_yn) 0')
    f = open(fsf, 'w')
    f.write(newdata)
    f.close()
  # SB131_fu2 -- no nonlinear
  if(re.search('SB131_fu2', fsf) != None):
    print(fsf)
    f = open(fsf, 'r')
    filedata = f.read()
    f.close()
    newdata = filedata.replace('set fmri(regstandard_nonlinear_yn) 1', 'set fmri(regstandard_nonlinear_yn) 0')
    f = open(fsf, 'w')
    f.write(newdata)
    f.close()



