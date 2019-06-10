### use pymol to select & output the residues at 4A distance of a residue location###
#run with python2
#input: receptor + residue id
#assumes that the receptor is called R.pdb

import os
import sys
import math
import numpy
import argparse
import itertools
from Bio.PDB import PDBParser
#sys.path.insert(0,"/Documents/pymol/bin")

import __main__
__main__.pymol_argv = [ 'pymol', '-qc'] # Quiet and no GUI

import pymol
from pymol import cmd
from pymol import stored

pymol.finish_launching()

def FlexRes(flex_ca):
    ca = (str(''.join(flex_ca)))
    with open(ca, 'r') as file:
        content = file.read()
        file_list = content.split()
        #print(file_list)
        chain_id = file_list[4]
        resn_id = file_list[3]
        resi_id = file_list[5]
        #atom_id = file_list[1]
        select_name = "chain " + chain_id + " and resn " + resn_id + " and resi " + resi_id
    #print(select_name)
    cmd.load(filename = "R.pdb", object = "receptor")
    cmd.select('site', select_name)
    out_name = str(chain_id) + "_flexres.pdb"
    cmd.select('flex_res', 'receptor within 6.0 of site')
    cmd.save(filename = out_name, selection = 'flex_res')
    
    #cmd.save(filename = 'flex_res.pdb', selection = 'all_flex_res')

#def myfunc(resi,resn,name):
#    print('%s`%s/%s' % (resn ,resi, name))

#myspace = {'myfunc': myfunc}
#cmd.iterate('(br. sel)', 'myfunc(resi,resn,name)', space=myspace)
#cmd.iterate('(br. sel)', 'resi, resn'), list.append(resi,resn)

parser = argparse.ArgumentParser(description='Get receptor residues at 4A of a particular site')
parser.add_argument('-f', '--flex_ca', required=True, nargs='+')
args = parser.parse_args()

if __name__ == '__main__': 
    FlexRes(args.flex_ca)