#!/bin/python

#Get the size of the receptor
#input: original receptor file, with chain A only, no waters etc
# all steps before pdb > pdbqt 
# outputs .txt config files for autodock vina input 
#run with python2
#need to install biopython! 
# pip install biopython
# pip install biopython --upgrade

import os
import re
import subprocess
import sys
import math
import numpy as np
import argparse
import itertools
import operator
from Bio.PDB import * #imports all 

#sys.path.insert(0,"/Documents/pymol/bin")

import __main__
__main__.pymol_argv = [ 'pymol', '-qc'] # Quiet and no GUI

import pymol
from pymol import cmd
from pymol import stored

pymol.finish_launching()

def resn_resi(receptor):
    structure = PDBParser().get_structure('structure', receptor)
    model = structure[0]
    chain = model['A']
    with open('flexres.txt', 'w') as file:
        for i in chain.get_residues():
            resName = i.get_resname()
            resID = i.get_id()      
            file.write("%s%s_" % (resName, resID))

parser = argparse.ArgumentParser(description='Get the size of the receptor')
parser.add_argument('-r', '--receptor', required=True, nargs='+')
args = parser.parse_args()

def main():
	if args.receptor:
		resn_resi(sys.argv[2]) # first argument is the file name, second is -l, need the third element

if __name__ == '__main__': 
    main()
# this .py file needs to be run as main