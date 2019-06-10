#! /bin/bash

#example file: 6hug 
#purpose: dock on the GABA receptor (rigid only)
#input: ligand + receptor
#output: 
###rigid docking: docking sites 

###Need .py files 
#prepare_receptor4.py
#prepare_ligand4.py
#prepare_flexreceptor4.py
#res_site_config_286.py

#need to install numpy
#sudo apt-get install python-pip 
#sudo apt-get install python3-pip
#sudo pip install numpy==1.8 
#sudo apt-get install autodocktools
#sudo apt-get install openbabel 
#sudo apt-get install pymol
#sudo apt-get install autogrid
#sudo apt-get install autodockvina

# get the atoms of the receptor
# user input receptor 

echo "enter the receptor (GABA) file name, excluding the .pdb extension"
read receptor_name
receptorPDB=$receptor_name".pdb"

#use the python file to add charges to the receptor and the ligand
echo 'enter the ligand name without the extension' 
ligand_name=propofol
ligandPDB="${ligand_name}.pdb"

echo 'putative binding residue eg HIS, MET'
read res_name
#=MET

echo 'putative binding site eg 267, 286' 
read res_site
#=286

#res_py_input="resi ${res_site} and resn ${res_name}"

main_dir="${ligand_name}_${receptor_name}_${res_name}${res_site}"
mkdir $main_dir
cp *.pdb $main_dir
cp *.py $main_dir
cp hpc* $main_dir
cd $main_dir

grep ATOM $receptorPDB > R.pdb 
#python res_site_atoms_286.py -s $res_py_input
python res_site_atoms.py -s $res_site -n $res_name
#outputs: CA_res_atoms.pdb AND flex_res.pdb which contains the residues that should be made flexible
#update :outputs only CA_res_atoms.pdb

grep ATOM CA_res_atoms.pdb | grep CA > CA.pdb
#locations of those atoms are at columns 7, 8, 9
awk '{print $5,$7,$8,$9}' CA.pdb > CA_coords.txt

# CA.pdb = list of CA atoms

mkdir prep_files
split -l 1 CA.pdb -d
mv x0* prep_files
#flex_res_CA.py: for each line CA, get the residues beside them
#out_name = str(chain_id) + "_flexres.pdb"

for CA_files in prep_files/*
do
    python flex_res_CA.py -f $CA_files
done
#out_name = str(chain_id) + "_flexres.pdb"

for res_pdb in ./*_flexres.pdb
do 
    python prep_prepare_flexreceptor4.py -f $res_pdb
done
#outputs: output_filename = str(chain_name) + "_receptor.txt"

mv *_flexres.pdb prep_files #this order needs to be conserved
mv *_receptor.txt prep_files

#prepare ligand + receptor
python2 prepare_ligand4.py -l $ligandPDB -o ligand.pdbqt
python2 prepare_receptor4.py -r R.pdb -o receptor.pdbqt

for res_text in prep_files/*_receptor.txt
do 
    residues=$(<$res_text)
    #echo $residues
    basename="${res_text%%.*}"
    rigid_name="${basename}-rigid.pdbqt"
    flex_name="${basename}-flex.pdbqt"
    python2 prepare_flexreceptor4.py -r receptor.pdbqt -s $residues -g $rigid_name  -x $flex_name
done
#outputs: "${basename}-rigid.pdbqt" and "${basename}-flex.pdbqt"
#note hyphen not underscore

mkdir run_files
#gets a receptor.pdbqt

#mk conf files 
python prep_config.py -c CA_coords.txt
#outputs: conf_name = chain_id + "_conf.txt"
mv *_conf.txt run_files

rm R.pdb CA.pdb CA_res_atoms.pdb CA_coords.txt

mv prep_files/*-rigid.pdbqt .
mv prep_files/*-flex.pdbqt .

#run vina, --cpu 10
#for conf_file in run_files/*.txt
#do 
#    vina --config $conf_file --exhaustiveness 10
#done

#mv prep_files/*-rigid.pdbqt run_files
#mv prep_files/*-flex.pdbqt run_files
#mkdir output_files
#mv *_log.txt output_files
#mv *_out.pdbqt output_files