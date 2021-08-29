# Register 4D BOLD beta series files to standard space for each scan

import os
import glob


subs = glob.glob('../../data/*')


for sub in list(subs):
    #print(sub)
    name = sub.split('/')[3]

    ref = '../../data/%s/model/fear/24motion.feat/reg/standard.nii.gz'%(name)
    premat = '../../data/%s/model/fear/24motion.feat/reg/example_func2highres.mat'%(name)
    warp = '../../data/%s/model/fear/24motion.feat/reg/highres2standard_warp'%(name)

    fearInput = 'betaSeriesCopes/' + name + '_fearBetas.nii.gz'
    neutInput = 'betaSeriesCopes/' + name + '_neutBetas.nii.gz'

    os.system('mkdir betaSeriesCopesReg')
    fearOutput = 'betaSeriesCopesReg/' + name + '_regFearBetas.nii.gz'
    neutOutput = 'betaSeriesCopesReg/' + name + '_regNeutBetas.nii.gz'


    if os.path.isfile(fearInput) and os.path.isfile(neutInput):
        if os.path.isfile(ref):
            fearMessage = '/usr/local/fsl/bin/applywarp --ref=%s --in=%s '%(ref, fearInput) + '--out=%s --warp=%s '%(fearOutput, warp) + '--premat=%s --interp=trilinear'%(premat)
            neutMessage = '/usr/local/fsl/bin/applywarp --ref=%s --in=%s '%(ref, neutInput) + '--out=%s --warp=%s '%(neutOutput, warp) + '--premat=%s --interp=trilinear'%(premat)

            os.system(fearMessage)
            os.system(neutMessage)
