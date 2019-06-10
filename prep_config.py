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

#sys.path.insert(0,"/Documents/pymol/bin")

import __main__
__main__.pymol_argv = [ 'pymol', '-qc'] # Quiet and no GUI

import pymol
from pymol import cmd
from pymol import stored

pymol.finish_launching()

def config(ca_coords):
    with open(ca_coords, 'r') as coord_file:
        #count_line = len(coord_file.readlines(  ))
        for line in coord_file:
            line_list = list(line.split())
            #print(line_list)
            chain_id = str(line_list[0])
            conf_name = chain_id + "_conf.txt"
            coord_list = line_list[1:]
            #print(conf_name)
            with open(conf_name, 'w') as file:
                file.write("receptor = %s_receptor-rigid.pdbqt\n" % chain_id)
                file.write("ligand = ligand.pdbqt\n")
                file.write("flex = %s_receptor-flex.pdbqt\n\n" % chain_id)
                file.write("out = %s_out.pdbqt\n" % chain_id)
                file.write("log = %s_log.txt\n" % chain_id)
                file.write("center_x = %s\ncenter_y = %s\ncenter_z = %s\n\n" % tuple(coord_list))
                file.write("size_x = 30\nsize_y = 30\nsize_z = 30\n\nnum_modes = 10")

#def myfunc(resi,resn,name):
#    print('%s`%s/%s' % (resn ,resi, name))

#myspace = {'myfunc': myfunc}
#cmd.iterate('(br. sel)', 'myfunc(resi,resn,name)', space=myspace)
#cmd.iterate('(br. sel)', 'resi, resn'), list.append(resi,resn)

parser = argparse.ArgumentParser(description='Get vina config files for list of CA atoms eg CA_coords.txt')
parser.add_argument('-c', '--ca_coords', required=True, nargs='+')
args = parser.parse_args()

def main():
	if args.ca_coords:
		config(sys.argv[2]) # first argument is the file name, second is -l, need the third element

if __name__ == '__main__': 
    main()