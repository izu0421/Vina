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

length_x = 0

def GridSizeCenter(receptor):
  # Get the atoms for the receptor & store in numpy
  bioparser = PDBParser()
  #A_coordinates = np.array([])
  #assume 1 model (iteration of whole protein), but allows multiple chains
  with open(receptor, 'r') as infile:
    #get a parser i.e. interpreter for PDB files 
    receptor_structure = bioparser.get_structure("protein_structure", infile)
    for model in receptor_structure:
        for chain in model:
            xmin_chain = 999999999.0
            xmax_chain = -xmin_chain
            ymin_chain = 999999999.0
            ymax_chain = 0.0
            zmin_chain = 999999999.0
            zmax_chain = 0.0
            count = 0
            for residue in chain:
                for atom in residue:
                  #print(atom.get_vector().get_array())
                  #A_coordinates = np.append(A_coordinates, atom.get_coord(), axis=0)
                  #print (type(atom.get_coord()))
                  x_coord,y_coord,z_coord = atom.get_coord()
                  #count += 1
                  #if count == 1:
                  #  xmin_chain = x_coord
                  if x_coord < xmin_chain: xmin_chain = x_coord
                  if x_coord > xmax_chain: xmax_chain = x_coord
                  if y_coord < ymin_chain: ymin_chain = y_coord
                  if y_coord > ymax_chain: ymax_chain = y_coord
                  if z_coord < zmin_chain: zmin_chain = z_coord
                  if z_coord > zmax_chain: zmax_chain = z_coord 
                  #print(x_coord,y_coord,z_coord)
            length_x = round(xmax_chain - xmin_chain)
            length_y = round(ymax_chain - ymin_chain)
            length_z = round(zmax_chain - zmin_chain)
            #print "min, max x, width = ",xmin_chain, xmax_chain, length_x
            #now that I obtained the "box size of the protein," I need to find the center of the box
            #center_x = round(xmax_chain-(length_x/2))
            #center_y = round(ymax_chain-(length_y/2))
            #center_z = round(zmax_chain-(length_z/2))
            #box_string = "Box(" + str(center_x) + "," + str(center_y) + "," + str(center_z) + "," + str(length_x) + "," + str(length_y) + "," + str(length_z) + ")"
            #print box_string
            #tested this with drawgridbox.py and it seems correct
            #print (center_x)
            #, ",", center_y, ",", center_z, ",", length_x, ",", length_y, ",", length_z
            # # the ultimate goal is to make PBS files to dock for entire protein 
            # # the docking box size will be < 27000 for optimal docking 
            #volume = length_x * length_y * length_z
            # 30^3 = 27000, so I will dock with 20^3
            dock_radius = 25
            sep_radius = dock_radius - 6
            #assume that the ligand is smaller than 6A
            dock_number_x = int(math.ceil(length_x/sep_radius))
            dock_number_y = int(math.ceil(length_y/sep_radius))
            dock_number_z = int(math.ceil(length_z/sep_radius))
            #print dock_number_x * dock_number_y * dock_number_z
            parameter_list_x=[]
            param_x = xmin_chain
            param_y = ymin_chain
            param_z = zmin_chain
            x=0
            while x < dock_number_x:
              parameter_list_x.append(param_x)
              param_x = round(param_x + sep_radius)
              x = x + 1
            y = 0
            parameter_list_y = []
            while y < dock_number_y:
              parameter_list_y.append(param_y)
              param_y = round(param_y + sep_radius)
              y = y + 1
            z = 0
            parameter_list_z = []
            while z < dock_number_z:
              parameter_list_z.append(param_z)
              param_z = round(param_z + sep_radius)
              z = z + 1
            #print parameter_list_x, parameter_list_y, parameter_list_z
            #parameter_list = [parameter_list_x, parameter_list_y, parameter_list_z]
            #all_parameters = list(itertools.product(*parameter_list))
            #print all_parameters; len = 80 
            count = 0
            for ix in range(0,len(parameter_list_x)):
              for iy in range(0,len(parameter_list_y)):
                for iz in range(0,len(parameter_list_z)):
                  count +=1 
                  filename = "abinitio" + str(count) + ".txt"
                  #print(str(parameter_list_x[ix]),str(parameter_list_y[iy]),str(parameter_list_z[iz]))
                  file = open(filename, "w")
                  file.write("receptor = receptor_rigid.pdbqt\nligand = ligand.pdbqt\nflex = receptor_flex.pdbqt\n\n")
                  file.write("out = %iout.pdbqt\n" % count)
                  file.write("log = %i_log.txt\n" % count)
                  file.write("center_x = %7.3f\ncenter_y = %7.3f\ncenter_z = %7.3f\n\n" % (parameter_list_x[ix],parameter_list_y[iy],parameter_list_z[iz]))
                  file.write("size_x = 25\nsize_y = 25\nsize_z = 25\n\nexhaustiveness = 10\nnum_modes = 3")
                  file.close


'''            
            with open('dock.sh', 'w') as dock:
              dock.write('#!/bin/bash\n\n')
              nonlocal volume
              print volume
'''
parser = argparse.ArgumentParser(description='Get the size of the receptor')
parser.add_argument('-r', '--receptor', required=True, nargs='+')
args = parser.parse_args()

def main():
	if args.receptor:
		GridSizeCenter(sys.argv[2]) # first argument is the file name, second is -l, need the third element

if __name__ == '__main__': 
    main()
# this .py file needs to be run as main