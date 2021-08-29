#highpass BOLD data before GLM

import glob
import os
import os.path
import sys
import subprocess
import pandas as pd
import numpy as np

# Function to highpass filter a single subject. Makes a new file with an additional _highpass tag in the name
def highpass(subid):
    # Load nuisance file from cpac
    if os.path.isdir('../../cpacPreproc/cpac_multiverse/output/pipeline_analysis_testing/' + str(subid) + '_' + str(subid)):
        source = '../../cpacPreproc/cpac_multiverse/output/pipeline_analysis_testing/' + str(subid) + '_' + str(subid) + '/functional_to_standard/_scan_rest/' + str(subid) + '_tgng_fear_bold_calc_tshift_resample_volreg_calc_maths_antswarp.nii.gz'
        output = '../../cpacPreproc/cpac_multiverse/output/pipeline_analysis_testing/' + str(subid) + '_' + str(subid) + '/functional_to_standard/_scan_rest/' + str(subid) + '_tgng_fear_bold_calc_tshift_resample_volreg_calc_maths_antswarp_highpass.nii.gz'
        tempMean = '../../cpacPreproc/cpac_multiverse/output/pipeline_analysis_testing/' + str(subid) + '_' + str(subid) + '/functional_to_standard/_scan_rest/tempMean.nii.gz'
        if not os.path.isfile(output):
            os.system('/rigel/psych/app/fsl/bin/fslmaths %s -Tmean %s'%(source, tempMean))
            os.system('/rigel/psych/app/fsl/bin/fslmaths %s -bptf 25.0 -1 -add %s %s'%(source, tempMean, output))
            os.system('rm %s'%(tempMean))



# Highpass all scans
path = '../../../data/*'
scans = glob.glob(path)

for scan in list(scans):
    name = scan.split('/')[4]
    print(name)
    highpass(subid =name)