#! /bin/bash
#need to use run chmod +x linux-vina.sh
#file example: 1e7b.pdb (human serum albumin)

#purpose: autodock rigid docking of exhaustiveness = 100 to find the possible binding sites

#vina and vina_split must be installed: sudo apt-get install autodockvina
#need to install numpy
#sudo apt-get install python-pip
#sudo apt-get install python3-pip
#sudo pip install numpy==1.8 
#sudo pip install numpy
#sudo apt-get install autodocktools
#sudo apt-get install openbabel 
#sudo apt-get install pymol
#sudo apt-get install autogrid

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
directory_name="${ligand_name}-${receptor_name}-docking"
mkdir $directory_name
mv receptor.pdbqt $directory_name
mv ligand.pdbqt $directory_name
mv ligand_site.py $directory_name
cd $directory_name

vina --receptor receptor.pdbqt --ligand ligand.pdbqt --center_x 0 --center_y 0 --center_z 0 --size_x 120 --size_y 120 --size_z 120 --out ligand-out.pdbqt --log ligand-log.txt --exhaustiveness 100 --num_modes 20

vina_split --input ligand-out.pdbqt --ligand output
#the --ligand command sets the prefix

mkdir outputfiles 
cp *.pdbqt outputfiles
cd outputfiles 
rm ligand.pdbqt
rm receptor.pdbqt
cd ..

for file in outputfiles/*.pdbqt
do 
    python2 ligand_site.py -l $file
done 

# this gets all binding site atoms as .txt output in .txt files
#in the outputfiles directory 

#need to sort & combine txt files for flex residues
#first try to set all as flexible residues 
cat *.txt > flexres.txt
awk '{print $4,$6}' flexres.txt > flexres0.txt
rm flexres.txt
#remove empty rows
uniq flexres0.txt flexres1.txt
rm flexres0.txt
#delete space 
cat flexres1.txt | tr -d " \t\r"  > flexres2.txt
rm flexres1.txt
#remove empty rows 
sed -i '/^$/d' flexres2.txt

#### Set flexible residues 
# hydrogens need to be added for flexible residues
#-s     specification for flex residues" 
#       Use underscores to separate residue names:"
#       ARG8_ILE84  "
#       Use commas to separate 'full names' which uniquely identify residues:"
#       hsg1:A:ARG8_ILE84,hsg1:B:THR4 "
#       [syntax is molname:chainid:resname]"
#separate using underscore 

sort flexres2.txt > flexres3.txt
uniq flexres3.txt > flexrescolumn.txt
tr '\n' '_' < flexrescolumn.txt > flexresfinal.txt
rm flexres2.txt
rm flexres3.txt
#test with LEU198_SER202_TRP214_VAL344_LEU347_ILE388_ASN391
residues=$(<flexresfinal.txt)
python2 prepare_flexreceptor4.py -r receptor.pdbqt -s $residues

vina --receptor receptor_rigid.pdbqt --flex receptor_flex.pdbqt --ligand ligand.pdbqt --center_x 0 --center_y 0 --center_z 0 --size_x 120 --size_y 120 --size_z 120 --out ligand-out.pdbqt --log ligand-log.txt --exhaustiveness 100 --num_modes 20

#now identifed the residues at the binding site using flexible residues --> 300 exhaustiveness 

# 1. label the rigid residues on pymol
# 2. get a file that compare the flexible residues to not flex to experimental

### prepare residue files (experimental, from http://www.jbc.org/content/275/49/38731/T4.expansion.html) 
#can apply the same prcess for propofol 

awk '{$1=$2=$3=""; print $0}' expresidues.txt > expresidues0.txt #delete first 3 columns

tr ', ' '\n' < expresidues0.txt > expresidues1.txt # delete formatting 
sed 's/-//' expresidues1.txt > expresidues2.txt # change to correct formatting
sed -i '/^$/d' expresidues2.txt #delete empty rows 
sort expresidues2.txt > expresidues3.txt
uniq expresidues3.txt > expresiduesfinal.txt
rm expresidues0.txt
rm expresidues1.txt
rm expresidues2.txt
rm expresidues3.txt
# the file containing the experimental residues is expresiduesfinal.txt
# the file flexrescolumn.txt contains the residues identified in the rigid docking, exhaus. = 100 

#use comm to compare both files 
#requires file to be sorted 
#       -1     suppress lines unique to FILE1
#       -2     suppress lines unique to FILE2
#       -3     suppress lines that appear in both files

#comm <(sort expresiduesfinal.txt) <(sort flexrescolumn.txt) > flex-exp-comp.txt
# count lines wc -l file 
#experimental = 56 
#rigid docking = 31

#### run separately 
#in the folder containing the exhaustiveness = 300, flexible residues 

vina_split --input ligand-out.pdbqt --ligand output
#the --ligand command sets the prefix

mkdir outputfiles 
cp *.pdbqt outputfiles
cd outputfiles 
rm ligand.pdbqt
rm receptor_flex.pdbqt
rm receptor_rigid.pdbqt
rm ligand-out.pdbqt
# manually delete ligand_out_flex.pdbqt files

for file in outputfiles/*.pdbqt
do 
    python2 ligand_site.py -l $file
done 

# this gets all binding site atoms as .txt output in .txt files
#in the outputfiles directory 

#need to sort & combine txt files for flex residues
#first try to set all as flexible residues 
cd outputfiles
cat *.txt > flexres.txt
awk '{print $4,$6}' flexres.txt > flexres0.txt
rm flexres.txt
#remove empty rows
uniq flexres0.txt flexres1.txt
rm flexres0.txt
#delete space 
cat flexres1.txt | tr -d " \t\r"  > flexres2.txt
rm flexres1.txt
#remove empty rows 
sed -i '/^$/d' flexres2.txt
sort flexres2.txt > flexres3.txt
uniq flexres3.txt > flexdockingres.txt
rm flexres3.txt
rm flexres2.txt