#!/usr/bin/python
# Author: PAB
# Date: July 24, 2018
# This script will generate design.fsf for PPI for each scan for the given feat template, level1 feat directory, and ppi style
# Takes 3 arguments:
  # 1: directory name -- what your feat directories at output will be named and what the folder containing the .fsf scripts will be named
  # 2: path to template script
  # 3: ppi style ('fsl', 'afni', or 'afni_no_deconvolve')

## NOTE: depending on where you intend to run all the fsf scripts, a lot of the paths will change! 
# This script is currently set up to run them on Habanero, so if that is not desired then the replacement section will need to be edited


# import these specific packages that we will need later
import os
import glob
import sys


# Set this to the directory all of the sub### directories live in
directoryNames = sys.argv[1]

# Set this to the template .fsf you want to use
featTemplate = sys.argv[2]

# style afni or fsl
ppiStyle = sys.argv[3]

# seed file
seedROI = sys.argv[4]

#1st level feat directory
featLev1 = sys.argv[5]

# The directory to  dump all the fsf files
fsfdir="/danl/SB/PaulCompileTGNG/mri_scripts/7_ppi_fsl/sub_fsfs/%s/"%(directoryNames)

# It's okay to keep this in here--- if the directory already exists it won't do anything
os.system('mkdir %s'%(fsfdir))


# Get all the paths!  Note, this won't do anything special to omit bad subjects
# also useful when subjects don't have the same number of runs! 
feardirs = glob.glob("/danl/SB/PaulCompileTGNG/data/*/model/fear")
happydirs = glob.glob("/danl/SB/PaulCompileTGNG/data/*/model/happy")
subdirs = feardirs + happydirs
print(subdirs)

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
  print('Making .fsf for: ', subnum, runType) 
  
  # Define what replacements to make
  # note: for habanero version, we are also changing the paths to the data and FSL!
  replacements = {'SUBNUM':subnum, 'SEED_TS': seedROI, 'EMOTION':runType, '/danl/SB/PaulCompileTGNG/':habanero_path, '/usr/share/fsl/': fsl_path, 'MODEL_DIR':featLev1, 'set fmri(thresh) 3':'set fmri(thresh) 0'}


  # get your template as the input here 
  with open(featTemplate) as infile: 
  # outfile = useable fsf file that is being created for every subject and every run 
    if ppiStyle == 'afni':
      with open("/danl/SB/PaulCompileTGNG/mri_scripts/7_ppi_fsl/sub_fsfs/%s/%s_%s_afni_style_ppi.fsf"%(directoryNames, subnum, runType), 'w') as outfile:
          for line in infile:
            # This code will make new fsf files that replace all of the wild cards we made above!  
            for src, target in replacements.items():
              line = line.replace(src, target)
            outfile.write(line)

    ## CONDITIONALS DEPENDING ON THE TYPE OF PPI RUN -- these lines below are specific to experimenting with different PPI methods!
    # If you only want to run one type of PPI, you could take these out

    # -------------------------------------------------------------------------------------------------------------------------------

    # Afni with no deconvolution
    elif ppiStyle == 'afni_no_deconvolve':
      with open("/danl/SB/PaulCompileTGNG/mri_scripts/7_ppi_fsl/sub_fsfs/%s/%s_%s_afni_no_deconvolve_ppi.fsf"%(directoryNames, subnum, runType), 'w') as outfile:
          for line in infile:
            for src, target in replacements.items():
              line = line.replace(src, target)
            outfile.write(line)
    # FSL style
    elif ppiStyle == 'fsl':
      with open("/danl/SB/PaulCompileTGNG/mri_scripts/7_ppi_fsl/sub_fsfs/%s/%s_%s_fsl_style_ppi.fsf"%(directoryNames, subnum, runType), 'w') as outfile:
          for line in infile:
            for src, target in replacements.items():
              line = line.replace(src, target)
            outfile.write(line)






