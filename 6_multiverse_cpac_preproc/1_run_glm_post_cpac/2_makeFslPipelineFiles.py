#!/usr/bin/python

# import these specific packages that we will need later
import os
import glob
import sys
import pandas as pd 
import numpy as np
import re


# Define the subject directories for each run
subdirs = glob.glob('../../../data/*')
fslTemplates = glob.glob('templates/fsl/*.fsf')

# Set up a folder for each pipeline to dump fsf files for each subject
for pipeline in list(fslTemplates):
  pipelineName = pipeline.split('/')[2][:-4]
  os.system('mkdir sub_fsfs/%s'%(pipelineName))


# Turn off post-stats
noPostStats = 'set fmri(poststats_yn) 0'

# This to be replaced for haba versions
habanero_path= '/rigel/psych/users/pab2163/'
fsl_path='/rigel/psych/app/fsl/'

# for each subject
for dir in list(subdirs):
  splitdir = dir.split('/')
  subnum = splitdir[4]
  os.system('mkdir output/%s'%(subnum)) # set up output directory for each subject
  for template in list(fslTemplates):
    pipelineName = template.split('/')[2][:-4]
    print('Making .fsf for: ', subnum, ' ', template) 
    #Define what replacements to make
    replacements = {'SUBNUM':subnum, 'PIPELINE': pipelineName, '/danl/SB/PaulCompileTGNG/':habanero_path, '/usr/share/fsl/':fsl_path, 'set fmri(poststats_yn) 1':noPostStats}

    # get your template as the input here 
    with open(template) as infile: 
        # outfile = useable fsf file that is being created for every subject and every run 
        with open("/danl/SB/PaulCompileTGNG/mri_scripts/cpacPipelines/glm/sub_fsfs/%s/%s.fsf"%(pipelineName, subnum), 'w') as outfile:
            for line in infile:
              # This code will make new fsf files that replace all of the wild cards we made above!  
              for src, target in replacements.items():
                line = line.replace(src, target)
              outfile.write(line)