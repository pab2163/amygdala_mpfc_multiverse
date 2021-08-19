#!/bin/sh

#SBATCH --account=psych
#SBATCH --job-name=sb_tgng_single_trial_model
#SBATCH -c 4
#SBATCH --time=11:55:00
#SBATCH --mem-per-cpu=4gb

n=$1

echo "Now I am going to run single trial model for ${n}"

for fsf in $n/*
    do
        # based on each fsf, get subject and trial #
        sub=$(echo $fsf | cut -d/ -f 2)
        num=$(echo $fsf | cut -d/ -f 3 | rev | cut -d'_' -f -2 | rev | cut -d'.' -f 1)
        dirPath=../../data/$sub/model/fear/singleTrialModels/$num.feat

        # If the tstat image already exists
        if test -f $dirPath/stats/tstat1.nii.gz; then
            echo $dirPath finished 
            
        # if the tstat image did not exist
        else
            # delete that directory
            echo $dirPath rerunning
            rm -rf $dirPath
            
            # run feat job
            feat $fsf

            # delete extra files
            rm ../../data/*/model/fear/singleTrialModels/*/rendered*
            rm ../../data/*/model/fear/singleTrialModels/*/cluster*
            rm ../../data/*/model/fear/singleTrialModels/*/thresh*
            rm ../../data/*/model/fear/singleTrialModels/*/*.png
            rm ../../data/*/model/fear/singleTrialModels/*/stats/pe*
            rm ../../data/*/model/fear/singleTrialModels/*/*.ppm
            rm ../../data/*/model/fear/singleTrialModels/*/*.trg
        fi
    done

echo "finished level1 processing for ${n}. WOOHOO!"
