'''
	Prepares the receptor & ligand by first removing all the water molecules from
	the protein's structure, 
	then adds only the polar hydrogens,
	then exports the resulting structure 
	both ligand and receptor files should now be converted into .pdbqt files.
'''
#adds charges to the receptor and the ligand
#import pdb, exports pdbqt
#to be used with linux-vina.sh

import os
import sys
import math
import numpy
import argparse
import itertools

#sys.path.insert(0,"/Documents/pymol/bin")

import __main__
__main__.pymol_argv = [ 'pymol', '-qc'] # Quiet and no GUI

import sys, time, os
import pymol

pymol.finish_launching()

def receptor(filename):
	pymol.cmd.load(filename)
	pymol.cmd.remove('resn HOH')
	pymol.cmd.h_add(selection='acceptors or donors')
	pymol.cmd.save('protein.pdb')
	os.system('babel protein.pdb temp.pdbqt -xh')
	os.system('grep ATOM temp.pdbqt > receptor.pdbqt')
	os.remove('temp.pdbqt')
	os.remove('protein.pdb')

def ligand(filename):
	pymol.cmd.load(filename)
	pymol.cmd.remove('resn HOH')
	pymol.cmd.h_add(selection='acceptors or donors')
	pymol.cmd.save('ligandTemp.pdb')
	os.system('babel ligandTemp.pdb temp2.pdbqt -xh')
	os.system('grep ATOM temp2.pdbqt > ligand.pdbqt')
	os.remove('temp2.pdbqt')
	os.remove('ligandTemp.pdb')

parser = argparse.ArgumentParser(description='Prep ligands for AutoDock Vina')
parser.add_argument('-r',
					'--receptor',
					nargs='+',
					help='Prep and convert protein receptor from PDB to PDBQT')
parser.add_argument('-l',
					'--ligand',
					nargs='+',
					help='Prep and convert protein receptor from PDB to PDBQT')
args = parser.parse_args()

def main():
	if args.receptor:
		receptor(sys.argv[2])
	if args.ligand:
		ligand(sys.argv[2])

if __name__ == '__main__': main()

