#! /bin/bash
#need to use run chmod +x linux-vina.sh
#file example: 1e7b.pdb (human serum albumin)

#purpose: with ligand + receptor in pdb file formats, do rigid docking
#the flexible docking while setting the residues identified in rigid docking 
#as flexible 
#input: ligand + receptor
#output: 
###rigid docking: docking sites 
###flexible docking: residues moved (by vina_split) & accurate docking sites

###Need .py files 
#prepare_receptor4.py
#prepare_ligand4.py
#ligand_site.py 
#prepare_flexreceptor4.py

#need to install numpy
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

# get the atoms of the receptor
# user input receptor 

echo "enter the receptor file name: (name only, excluding the .pdb extension)"
read receptor_name
receptorPDB=$receptor_name".pdb"
grep ATOM $receptorPDB > R.pdb 
#get first chain
awk '$5=="A"' R.pdb > RA.pdb

#use the python file to add charges to the receptor and the ligand
echo 'enter the ligand name without the extension' 
read ligand_name 
ligandPDB="${ligand_name}.pdb"
python2 prepare_receptor4.py -r RA.pdb -o receptor.pdbqt
#gets a receptor.pdbqt file
rm R.pdb
rm RA.pdb
echo 'finished preparing the receptor'
python2 prepare_ligand4.py -l $ligandPDB -o ligand.pdbqt
echo 'finished preparing the ligand'
#gets a ligand file as ligand.pdbqt

### run rigid docking ###

#grid box for creating a grid box file: center(0,0,0) size(120,120,120)
#first create a directory for the docking files 
directory_rigid="${ligand_name}-${receptor_name}-RigidDock"
mkdir $directory_rigid
cp receptor.pdbqt $directory_rigid
cp ligand.pdbqt $directory_rigid
cp ligand_site.py $directory_rigid
cd $directory_rigid

#100 exhaustiveness & 20 binding modes for entire protein
vina --receptor receptor.pdbqt --ligand ligand.pdbqt --center_x 0 --center_y 0 --center_z 0 --size_x 120 --size_y 120 --size_z 120 --out ligand-out.pdbqt --log ligand-log.txt --exhaustiveness 100 --num_modes 20

mkdir rigidOut
cp ligand-out.pdbqt rigidOut
cd rigidOut
vina_split --input ligand-out.pdbqt --ligand output
rm ligand-out.pdbqt
cd ..
#the --ligand command sets the prefix

for file in rigidOut/*.pdbqt
do 
    python2 ligand_site.py -l $file
done 

# this gets all binding site atoms as .txt output in .txt files
#in the directory_name directory 

#need to sort & combine txt files for flex residues
#first try to set all as flexible residues 

#### Set flexible residues 
# hydrogens need to be added for flexible residues
#-s     specification for flex residues" 
#       Use underscores to separate residue names:"
#       ARG8_ILE84  "
#       Use commas to separate 'full names' which uniquely identify residues:"
#       hsg1:A:ARG8_ILE84,hsg1:B:THR4 "
#       [syntax is molname:chainid:resname]"
#separate using underscore 

cd rigidOut
cat *.txt > flexres.txt
awk '{print $4,$6}' flexres.txt > flexres0.txt
rm flexres.txt
#delete repeated residues
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

cd ..
cd ..
directory_flex="${ligand_name}-${receptor_name}-FlexDock"
mkdir $directory_flex
cp receptor.pdbqt $directory_flex
cp ligand.pdbqt $directory_flex
cp prepare_flexreceptor4.py $directory_flex
cd $directory_flex

python2 prepare_flexreceptor4.py -r receptor.pdbqt -s $residues

vina --receptor receptor_rigid.pdbqt --flex receptor_flex.pdbqt --ligand ligand.pdbqt --center_x 0 --center_y 0 --center_z 0 --size_x 120 --size_y 120 --size_z 120 --out ligand-out.pdbqt --log ligand-log.txt --exhaustiveness 700 --num_modes 20

#now identifed the residues at the binding site using flexible residues --> 300 exhaustiveness 

# 1. label the rigid residues on pymol
# 2. get a file that compare the flexible residues to not flex to experimental

### prepare residue files (experimental, from http://www.jbc.org/content/275/49/38731/T4.expansion.html) 
#can apply the same process for propofol 