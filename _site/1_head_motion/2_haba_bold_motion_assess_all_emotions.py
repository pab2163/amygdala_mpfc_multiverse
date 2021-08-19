#!/usr/bin/python
# script from Mumford Brain stats to assess Motion in BOLD data
# updated by MVT in Jan 2018 and PAB Feb 13, 2018

# DO THIS BEFORE YOU PREPROCESS YOUR DATA!
# this gets Motion information on each subject for each run. 
# makes an output in the SB/PaulCompileTGNG/data/SBxxx/BOLD/motion_assess directories where you can find very useful information! 

import glob
import os
import sys
import subprocess

path = '/rigel/psych/users/pab2163/data/'
 
# get the paths for each BOLD.nii file 
bold_files = glob.glob('%s/*/BOLD/*/*.nii.gz'%(path))
print('The bold files are:')
print (bold_files)


# loop through each directory for each bold.nii file - this is just going to show me my BOLD files
for cur_bold in list(bold_files): # Subset bold_files with list indexing to do smaller batches
    print('current bold file in python loop is ')
    print(cur_bold)
    # Store directory name
    cur_dir = os.path.dirname(cur_bold)
    print('Current directory is' + cur_dir)
     # get current bold file
    cur_bold_no_nii = cur_bold
    
    # Assessing motion using FSL_motion_outliers function
    # if os.path.isdir("%s/motion_assess/"%(cur_dir))==False:
    os.system("mkdir %s/motion_assess"%(cur_dir))
    print('making motion assess dir')
      # lots of options: fd = framewise displacement 
      # threshold = setting to a value of 0.9mm which is from the Siegel 2014 paper! 
      # confound.txt file = what you can put into the design matrix 
      # this will generate the column of 1 and 0 for the frames to remove = 1 
      # -p = plot 
      # -v = verbose mode which spits out a lot of information 
      # this will generate a motion_assess folder within the BOLD directory
    print('Submitting sbatch for %s')%(cur_bold_no_nii)
    os.system("sbatch  2b_submit_moco_haba.sh %s %s"%(cur_bold_no_nii, cur_dir))

