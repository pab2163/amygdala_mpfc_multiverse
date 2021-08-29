#!/bin/bash
#SBATCH --account=psych
#SBATCH --job-name=highpass
#SBATCH --time=11:55:00
#SBATCH --mail-type=ALL
#SBATCH -c 4
#SBATCH --mem-per-cpu=6gb 

module load anaconda/3-5.1
python highpass.py