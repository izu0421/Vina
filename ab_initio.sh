#!/bin/bash 
#dock protein ab initio, full protein, without previous knowledge 

###Need .py files 
#prepare_receptor4.py
#prepare_ligand4.py
#ligand_site.py 
#prepare_flexreceptor4.py
# vina_config.py 

#need to install numpy
#sudo apt install screen
#sudo apt-get install python-pip
#sudo apt-get install python3-pip
#sudo apt-get install python3 python3-pip
#pip3 install Image
#sudo pip install numpy==1.8 
#sudo apt-get install autodocktools
#sudo apt-get install openbabel 
#sudo apt-get install pymol
#sudo apt-get install autogrid
#sudo apt-get install autodockvina

echo "enter the receptor file name: (name only, excluding the .pdb extension)"
read receptor_name
receptorPDB=$receptor_name".pdb"
grep ATOM $receptorPDB > R.pdb 
#get first chain
awk '$5=="A"' R.pdb > RA.pdb
rm R.pdb


#use the python file to add charges to the receptor and the ligand
echo 'enter the ligand name without the extension' 
read ligand_name 
ligandPDB="${ligand_name}.pdb"

python2 prepare_ligand4.py -l $ligandPDB -o ligand.pdbqt
python2 prepare_receptor4.py -r RA.pdb -o receptor.pdbqt

main_dir_name="${ligand_name}_${receptor_name}_abinitio"
mkdir $main_dir_name 
mv *.pdbqt $main_dir_name
cp *.py $main_dir_name
mv RA.pdb $main_dir_name
cd $main_dir_name

config_dir_name="${ligand_name}-${receptor_name}-config"
mkdir $config_dir_name 
python vina_config.py -r RA.pdb
mv *.txt $config_dir_name

#this gets all the config files
#now I need to obtain the residues I will set as flexbible. 
# I may try to set all residues as flexible

python prep_flexres.py -r RA.pdb
rm RA.pdb
#outputs flexres.txt
#use sed to modify files, sed -i = modify in file
# the "s" = substitute and "g" = global 
sed -i "s/(' ', //g" flexres.txt
sed -i "s/, ' ')//g" flexres.txt
residues=$(<flexres.txt)
rm flexres.txt

python2 prepare_flexreceptor4.py -r receptor.pdbqt -s $residues

for file in $config_dir_name/*.txt
do
    vina --config $file
done