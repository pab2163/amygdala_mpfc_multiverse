import os
import subprocess
import pandas as pd 

df = pd.read_csv('../2_motion/motionInfoAllEmotions.csv')

df = df[df['runType'] == 'fear']
df = df[['name']]

df_neut = df.copy()
df_fear_minus_neut = df.copy()


##### FEAR ####
# Use fslmeants to pull tstats/beta estimates for each native space ROI
for index, row in df.iterrows():
	# FREESURFER
	try:
		# tstats
		df.loc[index, 'og_native_amyg_bilateral_tstat'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/tstat1.nii.gz -m ../../data/%s/BOLD/masks/freesurfer_bilateral_amyg.nii.gz'%(row['name'], row['name']),shell = True))
		df.loc[index, 'og_native_amyg_right_tstat'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/tstat1.nii.gz -m ../../data/%s/BOLD/masks/freesurfer_right_amyg.nii.gz'%(row['name'], row['name']),shell = True))
		df.loc[index, 'og_native_amyg_left_tstat'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/tstat1.nii.gz -m ../../data/%s/BOLD/masks/freesurfer_left_amyg.nii.gz'%(row['name'], row['name']),shell = True))
		# betas
		df.loc[index, 'og_native_amyg_bilateral_beta'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/cope1.nii.gz -m ../../data/%s/BOLD/masks/freesurfer_bilateral_amyg.nii.gz'%(row['name'], row['name']),shell = True))
		df.loc[index, 'og_native_amyg_right_beta'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/cope1.nii.gz -m ../../data/%s/BOLD/masks/freesurfer_right_amyg.nii.gz'%(row['name'], row['name']),shell = True))
		df.loc[index, 'og_native_amyg_left_beta'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/cope1.nii.gz -m ../../data/%s/BOLD/masks/freesurfer_left_amyg.nii.gz'%(row['name'], row['name']),shell = True))
	except:
		print('error with freesurfer')

	# Harvard-Oxford
	try:
		# tstats
		df.loc[index, 'og_ho_amyg_bilateral_tstat'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/tstat1.nii.gz -m ../../data/%s/BOLD/masks/harvardoxfordsubcortical_bilateralamyg.nii.gz'%(row['name'], row['name']),shell = True))
		df.loc[index, 'og_ho_amyg_right_tstat'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/tstat1.nii.gz -m ../../data/%s/BOLD/masks/harvardoxfordsubcortical_rightamyg.nii.gz'%(row['name'], row['name']),shell = True))
		df.loc[index, 'og_ho_amyg_left_tstat'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/tstat1.nii.gz -m ../../data/%s/BOLD/masks/harvardoxfordsubcortical_leftamyg.nii.gz'%(row['name'], row['name']),shell = True))
		# betas
		df.loc[index, 'og_ho_amyg_bilateral_beta'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/cope1.nii.gz -m ../../data/%s/BOLD/masks/harvardoxfordsubcortical_bilateralamyg.nii.gz'%(row['name'], row['name']),shell = True))
		df.loc[index, 'og_ho_amyg_right_beta'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/cope1.nii.gz -m ../../data/%s/BOLD/masks/harvardoxfordsubcortical_rightamyg.nii.gz'%(row['name'], row['name']),shell = True))
		df.loc[index, 'og_ho_amyg_left_beta'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/cope1.nii.gz -m ../../data/%s/BOLD/masks/harvardoxfordsubcortical_leftamyg.nii.gz'%(row['name'], row['name']),shell = True))
	except:
		print('error with ho')

df.to_csv('native_space_amyg_reactivity_fear.csv', index = False)

##### NEUTRAL ####
# Use fslmeants to pull tstats/beta estimates for each native space ROI
for index, row in df_neut.iterrows():
	# FREESURFER
	try:
		# tstats
		df_neut.loc[index, 'og_native_amyg_bilateral_tstat'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/tstat2.nii.gz -m ../../data/%s/BOLD/masks/freesurfer_bilateral_amyg.nii.gz'%(row['name'], row['name']),shell = True))
		df_neut.loc[index, 'og_native_amyg_right_tstat'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/tstat2.nii.gz -m ../../data/%s/BOLD/masks/freesurfer_right_amyg.nii.gz'%(row['name'], row['name']),shell = True))
		df_neut.loc[index, 'og_native_amyg_left_tstat'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/tstat2.nii.gz -m ../../data/%s/BOLD/masks/freesurfer_left_amyg.nii.gz'%(row['name'], row['name']),shell = True))
		# betas
		df_neut.loc[index, 'og_native_amyg_bilateral_beta'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/cope2.nii.gz -m ../../data/%s/BOLD/masks/freesurfer_bilateral_amyg.nii.gz'%(row['name'], row['name']),shell = True))
		df_neut.loc[index, 'og_native_amyg_right_beta'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/cope2.nii.gz -m ../../data/%s/BOLD/masks/freesurfer_right_amyg.nii.gz'%(row['name'], row['name']),shell = True))
		df_neut.loc[index, 'og_native_amyg_left_beta'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/cope2.nii.gz -m ../../data/%s/BOLD/masks/freesurfer_left_amyg.nii.gz'%(row['name'], row['name']),shell = True))
	except:
		print('error with freesurfer')

	# Harvard-Oxford
	try:
		# tstats
		df_neut.loc[index, 'og_ho_amyg_bilateral_tstat'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/tstat2.nii.gz -m ../../data/%s/BOLD/masks/harvardoxfordsubcortical_bilateralamyg.nii.gz'%(row['name'], row['name']),shell = True))
		df_neut.loc[index, 'og_ho_amyg_right_tstat'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/tstat2.nii.gz -m ../../data/%s/BOLD/masks/harvardoxfordsubcortical_rightamyg.nii.gz'%(row['name'], row['name']),shell = True))
		df_neut.loc[index, 'og_ho_amyg_left_tstat'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/tstat2.nii.gz -m ../../data/%s/BOLD/masks/harvardoxfordsubcortical_leftamyg.nii.gz'%(row['name'], row['name']),shell = True))
		# betas
		df_neut.loc[index, 'og_ho_amyg_bilateral_beta'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/cope2.nii.gz -m ../../data/%s/BOLD/masks/harvardoxfordsubcortical_bilateralamyg.nii.gz'%(row['name'], row['name']),shell = True))
		df_neut.loc[index, 'og_ho_amyg_right_beta'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/cope2.nii.gz -m ../../data/%s/BOLD/masks/harvardoxfordsubcortical_rightamyg.nii.gz'%(row['name'], row['name']),shell = True))
		df_neut.loc[index, 'og_ho_amyg_left_beta'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/cope2.nii.gz -m ../../data/%s/BOLD/masks/harvardoxfordsubcortical_leftamyg.nii.gz'%(row['name'], row['name']),shell = True))
	except:
		print('error with ho')

df_neut.to_csv('native_space_amyg_reactivity_neutral.csv', index = False)

##### FEAR - NEUTRAL ####
# Use fslmeants to pull tstats/beta estimates for each native space ROI
for index, row in df_fear_minus_neut.iterrows():
	# FREESURFER
	try:
		# tstats
		df_fear_minus_neut.loc[index, 'og_native_amyg_bilateral_tstat'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/tstat3.nii.gz -m ../../data/%s/BOLD/masks/freesurfer_bilateral_amyg.nii.gz'%(row['name'], row['name']),shell = True))
		df_fear_minus_neut.loc[index, 'og_native_amyg_right_tstat'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/tstat3.nii.gz -m ../../data/%s/BOLD/masks/freesurfer_right_amyg.nii.gz'%(row['name'], row['name']),shell = True))
		df_fear_minus_neut.loc[index, 'og_native_amyg_left_tstat'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/tstat3.nii.gz -m ../../data/%s/BOLD/masks/freesurfer_left_amyg.nii.gz'%(row['name'], row['name']),shell = True))
		# betas
		df_fear_minus_neut.loc[index, 'og_native_amyg_bilateral_beta'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/cope3.nii.gz -m ../../data/%s/BOLD/masks/freesurfer_bilateral_amyg.nii.gz'%(row['name'], row['name']),shell = True))
		df_fear_minus_neut.loc[index, 'og_native_amyg_right_beta'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/cope3.nii.gz -m ../../data/%s/BOLD/masks/freesurfer_right_amyg.nii.gz'%(row['name'], row['name']),shell = True))
		df_fear_minus_neut.loc[index, 'og_native_amyg_left_beta'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/cope3.nii.gz -m ../../data/%s/BOLD/masks/freesurfer_left_amyg.nii.gz'%(row['name'], row['name']),shell = True))
	except:
		print('error with freesurfer')

	# Harvard-Oxford
	try:
		# tstats
		df_fear_minus_neut.loc[index, 'og_ho_amyg_bilateral_tstat'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/tstat3.nii.gz -m ../../data/%s/BOLD/masks/harvardoxfordsubcortical_bilateralamyg.nii.gz'%(row['name'], row['name']),shell = True))
		df_fear_minus_neut.loc[index, 'og_ho_amyg_right_tstat'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/tstat3.nii.gz -m ../../data/%s/BOLD/masks/harvardoxfordsubcortical_rightamyg.nii.gz'%(row['name'], row['name']),shell = True))
		df_fear_minus_neut.loc[index, 'og_ho_amyg_left_tstat'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/tstat3.nii.gz -m ../../data/%s/BOLD/masks/harvardoxfordsubcortical_leftamyg.nii.gz'%(row['name'], row['name']),shell = True))
		# betas
		df_fear_minus_neut.loc[index, 'og_ho_amyg_bilateral_beta'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/cope3.nii.gz -m ../../data/%s/BOLD/masks/harvardoxfordsubcortical_bilateralamyg.nii.gz'%(row['name'], row['name']),shell = True))
		df_fear_minus_neut.loc[index, 'og_ho_amyg_right_beta'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/cope3.nii.gz -m ../../data/%s/BOLD/masks/harvardoxfordsubcortical_rightamyg.nii.gz'%(row['name'], row['name']),shell = True))
		df_fear_minus_neut.loc[index, 'og_ho_amyg_left_beta'] = float(subprocess.check_output('fslmeants -i ../../data/%s/model/fear/24motion.feat/stats/cope3.nii.gz -m ../../data/%s/BOLD/masks/harvardoxfordsubcortical_leftamyg.nii.gz'%(row['name'], row['name']),shell = True))
	except:
		print('error with ho')

df_fear_minus_neut.to_csv('native_space_amyg_reactivity_fear_minus_neutral.csv', index = False)