datain='../../data/'
dataout_docker='/bids_dataset'
dataconfig='data_config_new.yml'
for sub in $(ls $datain);do

    # you may need to change those two lines to match your anat and func file path. In this example folder, I have $datain/subject/anat.nii.gz:
    func=$datain'/'$sub'/BOLD/fear/'$sub'_tgng_fear_bold.nii.gz'
    anat=$datain'/'$sub'/anatomy/mprage_deoblique.nii.gz'

    echo $anat 
    if [[ -f $anat ]] && [[ -f $func ]];then

        echo '- anat: '$dataout_docker'/'$sub'/anatomy/mprage_deoblique.nii.gz' >> $dataconfig
        echo '  creds_path: null' >> $dataconfig
        echo '  func: ' >> $dataconfig
        echo '    rest:' >> $dataconfig
        echo '      scan: '$dataout_docker'/'$sub'/BOLD/fear/'$sub'_tgng_fear_bold.nii.gz' >> $dataconfig
        echo '  subject_id: '"'"$sub"'" >> $dataconfig
        echo '  unique_id: '"'"$sub"'" >> $dataconfig

    fi
done

