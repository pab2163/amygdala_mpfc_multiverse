#!/usr/bin/python

# import these specific packages that we will need later
import os
import glob
import sys
import re


# Define the subject directories for each run
subdirs = glob.glob('../../../data/*')
fslTemplates = glob.glob('templates/fsl/*.fsf')

# submig glm job for each subject for each pipeline
for dir in list(subdirs):
  splitdir = dir.split('/')
  subnum = splitdir[4]
  for template in list(fslTemplates):
    pipelineName = template.split('/')[2][:-4]
    systemMessage = 'sbatch -o %s_%s_%%j.out -e %s_%s_%%j.err run_fsl_level1.sh sub_fsfs/%s/%s.fsf'%(subnum, pipelineName, subnum, pipelineName, pipelineName, subnum)
    os.system(systemMessage)