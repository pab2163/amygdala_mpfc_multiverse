# For all scans, run 48 single-trial feat models
# launch 1 slurm job for each .fsf file in the directory (each one is a feat job)


for scan in fsf/*
	do
		sbatch run_single_trial_model_haba.sh $scan 
	done




