#! /bin/bash

#PBS -l walltime=48:00:00
#PBS -l select=1:ncpus=32:mem=80GB

cd $PBS_O_WORKDIR

module load anaconda3/personal
source activate autodock_env
module load vina

date        > output.log
for conf_file in config_files/*.txt
do 
    vina --config $conf_file --exhaustiveness 100 --cpu 32
done
date        >> output.log