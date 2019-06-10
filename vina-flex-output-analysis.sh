#!/bin/bash
#manipulate the file obtained from flexible docking 
#for analysis 
# input files = receptor.pdbqt

# what is needed is: 
# file containing the dissociation constants, root mean squared distances 
# the locations of the binding sites
# how those location compare to that of the experimental ones  

#require: ligand-out.pdbqt (default input), 

mkdir analysis
cp ligand-out.pdbqt receptor.pdbqt analysis
cd analysis
vina_split --input ligand-out.pdbqt --ligand lig_out --flex flex_out
rm ligand-out.pdbqt

mkdir ligands
mkdir flexed_res
mv flex_out* flexed_res
mv lig_out* ligands

for file in ligands/*.pdbqt
do 
    python2 ligand_site.py -l $file
done 

# this gets all binding site atoms as .txt output in .txt files
#in the outputfiles directory 

#need to sort & combine txt files for flex residues
#first try to set all as flexible residues 
cd ligands
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
uniq flexres3.txt > flexdockingres_out.txt
rm flexres3.txt
rm flexres2.txt

cd ..
mv flexdockingres_out.txt .
cp ligands/*01* .

#gets list of ligand sites. 
