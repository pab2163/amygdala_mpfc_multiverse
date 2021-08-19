#!/bin/sh

#SBATCH --account=psych
#SBATCH --job-name=sb_tgng_featlev1
#SBATCH -c 4
#SBATCH --time=11:55:00
#SBATCH --mem-per-cpu=4gb

n=$1

echo "Now I am going to start level 1 processing for ${n}"


feat $n

echo "finished level1 processing for ${n}. WOOHOO!"
