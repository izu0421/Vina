### extact the A chain 
### exteact the respective ligand
#run with python2

import os
import sys
import math
import numpy
import argparse
import itertools
import __main__
__main__.pymol_argv = [ 'pymol', '-qc'] # Quiet and no GUI
import pymol
from pymol import cmd
from pymol import stored

pymol.finish_launching()

def extract(receptor):
    cmd.load(filename = receptor, object = "receptor")
    cmd.remove('resn HOH') #remove waters
    cmd.select("sel", selection = "chain A")
    # this also seem to extract the ligands that are bound to chain A
    # as well as chain A 
    input_name, input_extension = os.path.splitext(sys.argv[2])
    out_name_protein_AHet = input_name + "_A_het" + input_extension
    out_name_protein = input_name + "_A" + input_extension
    out_name_het = input_name + "_het" + input_extension
    out_name_residues = input_name + "_residues" + ".txt"
    cmd.save(filename = out_name_protein_AHet, selection = 'sel')
    cmd.delete('all')
    cmd.load(filename = out_name_protein_AHet, object = "receptor")
    cmd.extract(name = 'ligand', selection = 'hetatm')
    cmd.save(filename = out_name_het, selection = 'ligand')
    cmd.select("residues", selection = "receptor within 4.0 of ligand")
    cmd.save(filename = out_name_residues, selection = 'residues')
    cmd.save(filename = out_name_protein, selection = "receptor")
    os.remove(out_name_protein_AHet)

parser = argparse.ArgumentParser(des1cription='extract chain A, hetatm and ligand site')
parser.add_argument('-r', '--receptor', required=True, nargs='+')
args = parser.parse_args()

def main():
	if args.receptor:
		extract(sys.argv[2]) # first argument is the file name, second is -l, need the third element

if __name__ == '__main__': 
    main()