# Compute voxel-wise similarity between gPPI pipelines using AFNI 3ddot
# Author: Paul A. Bloom


import os
import glob
import subprocess
import pandas as pd

# data path
dirpath = '/danl/SB/Investigators/PaulCompileTGNG/data/'

# extension for afni gPPI stats folder
afni_ext = 'model/fear/24motion.feat/gppi_afni_style_seed_harvardoxfordsubcortical_bilateralamyg.feat/reg_standard/stats'
fsl_ext = 'model/fear/24motion.feat/gppi_fsl_style_seed_harvardoxfordsubcortical_bilateralamyg.feat/reg_standard/stats'

# masks to use
brain_mask = '/danl/SB/Investigators/PaulCompileTGNG/mri_scripts/Structural/mni_2mm_brain_mask.nii.gz'
mpfc1 = '/danl/SB/Investigators/PaulCompileTGNG/mri_scripts/Structural/mni2mmSpace/mPFC_sphere_5mm_mni2mm.nii.gz'
mpfc2 = '/danl/SB/Investigators/PaulCompileTGNG/mri_scripts/Structural/mni2mmSpace/mPFC_sphere_5mm_anterior_mni2mm.nii.gz'
mpfc3 = '/danl/SB/Investigators/PaulCompileTGNG/mri_scripts/Structural/mni2mmSpace/mPFC_sphere_5mm_anterior_down_mni2mm.nii.gz'
mpfc_big = '/danl/SB/Investigators/PaulCompileTGNG/mri_scripts/Structural/mni2mmSpace/vmpfc_trimmed_prob.5_mni2mm.nii.gz'


# get participant list
subs = glob.glob(f'{dirpath}*')
subs.sort()

d_list = []

# capture command-line output
def get_similarity(cmd):
		result = subprocess.run(cmd.split(' '), stdout=subprocess.PIPE)
		result_str = result.stdout.decode('utf-8').split(' ')[-1].strip()
		return((result_str))


# Loop through all participants, calculate similarity for each contrast and ROI
for sub in subs:
	subid = sub.split('/')[-1]

	# get image paths
	fsl_fear_ppi_tstat = f'{dirpath}/{subid}/{fsl_ext}/tstat9.nii.gz'
	afni_fear_ppi_tstat = f'{dirpath}/{subid}/{afni_ext}/tstat9.nii.gz'

	fsl_neutral_ppi_tstat = f'{dirpath}/{subid}/{fsl_ext}/tstat10.nii.gz'
	afni_neutral_ppi_tstat = f'{dirpath}/{subid}/{afni_ext}/tstat10.nii.gz'

	fsl_fear_minus_neutral_ppi_tstat = f'{dirpath}/{subid}/{fsl_ext}/tstat11.nii.gz'
	afni_fear_minus_neutral_ppi_tstat = f'{dirpath}/{subid}/{afni_ext}/tstat11.nii.gz'

	# delineate commands 
	cmd_fear_whole = f'3ddot -mask {brain_mask} {fsl_fear_ppi_tstat} {afni_fear_ppi_tstat}'
	cmd_neut_whole = f'3ddot -mask {brain_mask} {fsl_neutral_ppi_tstat} {afni_neutral_ppi_tstat}'
	cmd_fear_minus_neut_whole = f'3ddot -mask {brain_mask} {fsl_fear_minus_neutral_ppi_tstat} {afni_fear_minus_neutral_ppi_tstat}'

	cmd_fear_mpfc1 = f'3ddot -mask {mpfc1} {fsl_fear_ppi_tstat} {afni_fear_ppi_tstat}'
	cmd_neut_mpfc1 = f'3ddot -mask {mpfc1} {fsl_neutral_ppi_tstat} {afni_neutral_ppi_tstat}'
	cmd_fear_minus_neut_mpfc1 = f'3ddot -mask {mpfc1} {fsl_fear_minus_neutral_ppi_tstat} {afni_fear_minus_neutral_ppi_tstat}'

	cmd_fear_mpfc2 = f'3ddot -mask {mpfc2} {fsl_fear_ppi_tstat} {afni_fear_ppi_tstat}'
	cmd_neut_mpfc2 = f'3ddot -mask {mpfc2} {fsl_neutral_ppi_tstat} {afni_neutral_ppi_tstat}'
	cmd_fear_minus_neut_mpfc2 = f'3ddot -mask {mpfc2} {fsl_fear_minus_neutral_ppi_tstat} {afni_fear_minus_neutral_ppi_tstat}'

	cmd_fear_mpfc3 = f'3ddot -mask {mpfc3} {fsl_fear_ppi_tstat} {afni_fear_ppi_tstat}'
	cmd_neut_mpfc3 = f'3ddot -mask {mpfc3} {fsl_neutral_ppi_tstat} {afni_neutral_ppi_tstat}'
	cmd_fear_minus_neut_mpfc3 = f'3ddot -mask {mpfc3} {fsl_fear_minus_neutral_ppi_tstat} {afni_fear_minus_neutral_ppi_tstat}'

	cmd_fear_mpfc_big = f'3ddot -mask {mpfc_big} {fsl_fear_ppi_tstat} {afni_fear_ppi_tstat}'
	cmd_neut_mpfc_big = f'3ddot -mask {mpfc_big} {fsl_neutral_ppi_tstat} {afni_neutral_ppi_tstat}'
	cmd_fear_minus_neut_mpfc_big = f'3ddot -mask {mpfc_big} {fsl_fear_minus_neutral_ppi_tstat} {afni_fear_minus_neutral_ppi_tstat}'

	# pull similarity values into a dictionary for each scan
	sub_dict = {'subid': subid,
				'fear_whole':get_similarity(cmd_fear_whole),
				'neut_whole':get_similarity(cmd_neut_whole),
				'fear_minus_neut_whole': get_similarity(cmd_fear_minus_neut_whole),
				'fear_mpfc1':get_similarity(cmd_fear_mpfc1),
				'neut_mpfc1':get_similarity(cmd_neut_mpfc1),
				'fear_minus_neut_mpfc1': get_similarity(cmd_fear_minus_neut_mpfc1),
				'fear_mpfc2':get_similarity(cmd_fear_mpfc2),
				'neut_mpfc2':get_similarity(cmd_neut_mpfc2),
				'fear_minus_neut_mpfc2': get_similarity(cmd_fear_minus_neut_mpfc2),
				'fear_mpfc3':get_similarity(cmd_fear_mpfc3),
				'neut_mpfc3':get_similarity(cmd_neut_mpfc3),
				'fear_minus_neut_mpfc3': get_similarity(cmd_fear_minus_neut_mpfc3),
				'fear_mpfc_big':get_similarity(cmd_fear_mpfc_big),
				'neut_mpfc_big':get_similarity(cmd_neut_mpfc_big),
				'fear_minus_neut_mpfc_big': get_similarity(cmd_fear_minus_neut_mpfc_big)}


	# append info fro all scans together
	d_list.append(sub_dict)
	print(sub_dict)

# compile dataframe and save to csv
df = pd.DataFrame(d_list)
df.to_csv('ppi_similarities.csv', index = False)

