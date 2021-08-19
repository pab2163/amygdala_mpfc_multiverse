#!/bin/sh


#SBATCH --account=psych
#SBATCH --job-name=tgng_moco
#SBATCH -c 4
#SBATCH --time=11:55:00
#SBATCH --mem-per-cpu=4gb

boldFile=$1
curDir=$2

echo "Starting motion correction"
echo "bold file is ${boldFile}"
echo "current directory is ${curDir}"

fsl_motion_outliers -i $boldFile  -o " ${curDir}/motion_assess/confound.txt" --fd --thresh=.9 -s "${curDir}/motion_assess/framewiseDisplacement.txt"  -p "${curDir}/motion_assess/fd_plot" -v > "${curDir}/motion_assess/outlier_output.txt"

