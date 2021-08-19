# This script extracts the design.mat file for fear/happy runs into a .txt file

import glob
import os
import sys
import subprocess
import pandas as pd
import numpy as np


# find all feat directories to set this up for
feardirs = glob.glob("/danl/SB/PaulCompileTGNG/data/*/model/fear/24motion.feat/gppi_fsl_style_seed_harvardoxfordsubcortical_bilateralamyg.feat")
happydirs = glob.glob("/danl/SB/PaulCompileTGNG/data/*/model/happy/24motion.feat/gppi_fsl_style_seed_harvardoxfordsubcortical_bilateralamyg.feat")
subdirs = feardirs + happydirs

# loop for each feat directory
# dir = specific feat directory
# subnum = subject number (SBXXX)
for dir in list(subdirs):
	print(dir)
	os.system('Vest2Text %s/design.mat %s/design.txt'%(dir, dir))