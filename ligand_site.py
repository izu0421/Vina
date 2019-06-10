### use pymol to select & output the residues at 4A distance of the ligand###
#run with python2
#the only argument is ligand
#assumes that the receptor is called receptor.pdbqt.
#python ligand_site.py -l ligand_name.pdbqt

import os
import sys
import math
import numpy
import argparse
import itertools

#sys.path.insert(0,"/Documents/pymol/bin")

import __main__
__main__.pymol_argv = [ 'pymol', '-qc'] # Quiet and no GUI

import pymol
from pymol import cmd
from pymol import stored

pymol.finish_launching()

def LigandSite(ligand):
    cmd.load(filename = "receptor.pdbqt", object = "receptor") #this works
    cmd.load(ligand, "ligand") #this works
    cmd.select("sel", selection = "receptor within 4.0 of ligand")
    input_name, input_extension = os.path.splitext(sys.argv[2])
    out_name = input_name + "-out" +".txt"
    cmd.save(filename = out_name, selection = 'sel')
#def myfunc(resi,resn,name):
#    print('%s`%s/%s' % (resn ,resi, name))

#myspace = {'myfunc': myfunc}
#cmd.iterate('(br. sel)', 'myfunc(resi,resn,name)', space=myspace)
#cmd.iterate('(br. sel)', 'resi, resn'), list.append(resi,resn)

parser = argparse.ArgumentParser(description='Get residues at 4A of ligand')
parser.add_argument('-l', '--ligand', required=True, nargs='+')
args = parser.parse_args()

def main():
	if args.ligand:
		LigandSite(sys.argv[2]) # first argument is the file name, second is -l, need the third element

if __name__ == '__main__': 
    main()