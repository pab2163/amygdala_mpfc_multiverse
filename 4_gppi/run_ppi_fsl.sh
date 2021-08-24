#!/bin/sh

#SBATCH --account=psych
#SBATCH --job-name=sb_tgng_ppi
#SBATCH -c 4
#SBATCH --time=11:55:00
#SBATCH --mem-per-cpu=4gb

# This is the script on habanero that actually runs each job
# The python script 3_submit_ppi_feat_jobs.py calls this for each job

n=$1

echo "Now I am going to start level 1 processing for ${n}"


feat $n

echo "finished ppi for ${n}. WOHOO!"
