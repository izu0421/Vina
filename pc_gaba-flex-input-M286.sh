#! /bin/bash

#example file: 6a96 

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
receptor_name=6a96
receptorPDB=$receptor_name".pdb"

#use the python file to add charges to the receptor and the ligand
echo 'enter the ligand name without the extension' 
ligand_name=propofol
ligandPDB="${ligand_name}.pdb"

echo 'putative binding residue eg GLU, MET'
res_name=MET

echo 'putative binding site eg 267, 286' 
res_site=286

#res_py_input="resi ${res_site} and resn ${res_name}"

main_dir="${ligand_name}_${receptor_name}_${res_name}${res_site}"
mkdir $main_dir
cp *.pdb $main_dir
cp *.py $main_dir
cd $main_dir

grep ATOM $receptorPDB > R.pdb 
#python res_site_atoms_286.py -s $res_py_input
python res_site_atoms.py -s $res_site -n $res_name
#outputs: CA_res_atoms.pdb AND flex_res.pdb which contains the residues that should be made flexible

grep ATOM CA_res_atoms.pdb | grep CA > CA.pdb
#locations of those atoms are at columns 7, 8, 9
awk '{print $7,$8,$9}' CA.pdb > CA_coords.txt
rm CA.pdb

mkdir config_files
python gaba_config.py -c CA_coords.txt

mv *multi_conf.txt config_files

awk '{print $4,$6}' flex_res.pdb > flexres0.txt
uniq flexres0.txt flexres1.txt
rm flexres0.txt
#delete space 
cat flexres1.txt | tr -d " \t\r"  > flexres2.txt
rm flexres1.txt
#remove empty rows 
sed -i '/^$/d' flexres2.txt
sort flexres2.txt > flexres3.txt
uniq flexres3.txt > flexrescolumn.txt
tr '\n' '_' < flexrescolumn.txt > flexresfinal.txt
rm flexres2.txt
rm flexres3.txt
#looks like: LEU198_SER202_TRP214_VAL344_LEU347_ILE388_ASN391
residues=$(<flexresfinal.txt)

python2 prepare_receptor4.py -r R.pdb -o receptor.pdbqt
#gets a receptor.pdbqt file
rm R.pdb
#echo 'finished preparing the receptor'
python2 prepare_ligand4.py -l $ligandPDB -o ligand.pdbqt
#echo 'finished preparing the ligand'
#gets a ligand file as ligand.pdbqt
python2 prepare_flexreceptor4.py -r receptor.pdbqt -s $residues

#run vina
#for conf_file in config_files/*.txt
#do 
#    vina --config $conf_file --exhaustiveness 100 --cpu 32
#done