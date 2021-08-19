#!/bin/sh

#SBATCH --account=psych
#SBATCH --job-name=featglm
#SBATCH -c 4
#SBATCH --time=4:00:00
#SBATCH --mem-per-cpu=4gb

n=$1

echo "Now I am going to start level 1 processing for ${n}"


feat $n

echo "finished level1 processing for ${n}. WOOHOO!"
