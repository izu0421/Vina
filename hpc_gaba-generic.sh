#! /bin/bash

#PBS -l walltime=08:00:00
#PBS -l select=1:ncpus=32:mem=40GB

cd $PBS_O_WORKDIR

module load anaconda3/personal
source activate autodock_env
module load vina

date        > output.log
for conf_file in run_files/*.txt
do 
    vina --config $conf_file --exhaustiveness 32 --cpu 32
done
date        >> output.log

mv *-rigid.pdbqt run_files
mv *-flex.pdbqt run_files

mkdir output_files
mv *_log.txt output_files
mv *_out.pdbqt output_files