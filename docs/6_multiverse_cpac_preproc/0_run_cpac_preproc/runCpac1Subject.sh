#!/bin/bash
#SBATCH --account=psych
#SBATCH --job-name=CPAC-1Sub
#SBATCH --time=8:00:00
#SBATCH --mail-type=ALL
#SBATCH --constraint=docker
#SBATCH -c 8
#SBATCH --mem-per-cpu=6gb 

index=$1


module load singularity


singularity run \
-B /rigel/psych/users/pab2163/data:/bids_dataset \
-B /rigel/psych/users/pab2163/mri_scripts/cpacPreproc/cpacTesting2:/outputs \
-B /rigel/psych/users/pab2163/mri_scripts/cpacPreproc/configs:/configs \
-B /rigel/psych/users/pab2163/mri_scripts/cpacPreproc/scratch:/scratch \
/rigel/psych/app/cpac/fcpindi_c-pac_latest-2019-04-02-4c454af5b8ff.img /bids_dataset /outputs participant --participant_ndx $index --n_cpus 8 --pipeline_file /configs/customPipelineSB.yaml --data_config_file /configs/dataConfigFear.yaml --skip_bids_validator
