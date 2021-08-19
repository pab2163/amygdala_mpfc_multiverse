#!/bin/tcsh
# Author: Paul A. Bloom
# Date: April 29, 2019

# cd into directory to find subjects
cd /danl/SB/PaulCompileTGNG/mri_scripts/cpacPipelines/glm/output/

# loop for all subjects
foreach subid (*)
	echo ${subid}
	# Make script executable
	chmod 775 *
	 
	cd /danl/SB/PaulCompileTGNG/mri_scripts/cpacPipelines/glm/templates/afni
	# Path to input functional brain
	set inputFunc=/danl/SB/PaulCompileTGNG/mri_scripts/cpacPreproc/cpacTesting2/output/pipeline_analysis_testing/${subid}_${subid}/functional_to_standard/_scan_rest/${subid}_tgng_fear_bold_calc_tshift_resample_volreg_calc_maths_antswarp.nii.gz

	# Path to fear/neutral stim times
	set fearTimes=/danl/SB/PaulCompileTGNG/mri_scripts/cpacPipelines/stimFiles/afni/${subid}_fearRun_fearOnsets.txt
	set neutralTimes=/danl/SB/PaulCompileTGNG/mri_scripts/cpacPipelines/stimFiles/afni/${subid}_fearRun_neutOnsets.txt

	# Path to nuisance regressors
	set nuisanceFile=/danl/SB/PaulCompileTGNG/mri_scripts/cpacPipelines/motionConfounds/nuisanceGLMFilesFear/${subid}_0.9_standard6nuisancePlusConfounds.txt

	# Path to output directory
	set outDir=/danl/SB/PaulCompileTGNG/mri_scripts/cpacPipelines/glm/output/${subid}/6_afni_6motion_regOutConfounds_quadratic_1G_no_errors/

	# Run if input functional brain file exists
	if (-f ${inputFunc}) then
		# Run if the pipeline hasn't already been run
		if (! -d ${outDir}) then
			echo ${subid}
			# Run the GLM!
			3dDeconvolve -input ${inputFunc} \
					-bucket ${outDir}stats_FearRun \
					-fitts ${outDir}Gamfitts_FearRun \
					-cbucket ${outDir}GamCbucket_FearRun \
					-tout \
					-nobout \
					-num_stimts 2 -global_times \
					-stim_times 1 ${fearTimes} 'GAM' -stim_label 1 Fear \
					-stim_times 2 ${neutralTimes} 'GAM' -stim_label 2 Neutral \
					-polort 2 \
					-legendre \
					-ortvec ${nuisanceFile} nuisance \
					-num_glt 4 \
					-gltsym 'SYM: Fear' -glt_label 1 Fear \
					-gltsym 'SYM: Neutral' -glt_label 2 Neutral \
					-gltsym 'SYM: Fear -Neutral' -glt_label 3 Fear-Neutral \
					-gltsym 'SYM: Fear Neutral' -glt_label 4 AllFaces || ${subid} >> afniCrashLogPipeline6.txt
		else 
			echo ${subid} 'already exists!'
		endif
	else
		# If func brain doesn't exist
		echo ${subid}
		echo ${subid} >> noBrainDataPipeline6.txt
	endif 

end
		
		
