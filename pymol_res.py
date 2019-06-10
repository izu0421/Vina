#python script that selects residues from text file for pymol 

# imput files should be expresiduesfinal.txt and flexrescolumn.txt

######################### NOTE ################
'''
should aim to make args for all types of scripts
'''

#!/usr/bin/python
import os
import re
import sys
import math
import numpy
import argparse

from pymol import stored
from pymol import cmd
import pymol
import string
import __main__
__main__.pymol_argv = [ 'pymol', '-qc'] # Quiet and no GUI
pymol.finish_launching()

def SiteID(receptor):
    cmd.load(receptor, 'receptor')
    cmd.hide()
    cmd.bg_color("white")# white background
    cmd.show("mesh")
    cmd.color("cyan")

# first ppen the experimentally obtained residues as E
E=open('expresiduesfinal.txt','r')
Econtents = E.read()#.split()
Eresidues_string = Econtents.replace("\n",",")
E.close()
Eresi_string_cap = re.sub('[A-Z]', '',Eresidues_string)
Eresi_string_final = re.sub('[a-z]', '',Eresi_string_cap)
cmd.select('residues', 'resi %s' % str(Eresi_string_final))
cmd.show("surface", "residues")
cmd.color("red", "residues")

## get the in silico rigid docking residues S
#currently need to be run separately 
R=open('rigiddockingres100.txt','r')
Rcontents = R.read()#.split()
Rresidues_string = Rcontents.replace("\n",",")
R.close()

Rresi_string_cap = re.sub('[A-Z]', '',Rresidues_string)
Rresi_string_final = re.sub('[a-z]', '',Rresi_string_cap)
cmd.select('residues', 'resi %s' % str(Rresi_string_final))
cmd.show("surface", "residues")
cmd.color("red", "residues")

## get the in silico FLEX docking residues F
#currently need to be run separately 
F=open('flexdockingres300.txt','r')
Fcontents = F.read()#.split()
Fresidues_string = Fcontents.replace("\n",",")
F.close()
Fresi_string_cap = re.sub('[A-Z]', '',Fresidues_string)
Fresi_string_final = re.sub('[a-z]', '',Fresi_string_cap)

cmd.select('residues', 'resi %s' % str(Fresi_string_final))
cmd.show("surface", "residues")
cmd.color("red", "residues")

F=open('flexdockingres600.txt','r')
Fcontents = F.read()#.split()
Fresidues_string = Fcontents.replace("\n",",")
F.close()
Fresi_string_cap = re.sub('[A-Z]', '',Fresidues_string)
Fresi_string_final = re.sub('[a-z]', '',Fresi_string_cap)

cmd.select('residues', 'resi %s' % str(Fresi_string_final))
cmd.show("surface", "residues")
cmd.color("red", "residues")

parser = argparse.ArgumentParser(description='label the residues in pymol')
parser.add_argument('-r', '--receptor', required=True, nargs='+')
args = parser.parse_args()

def main():
	if args.receptor:
		SiteID(sys.argv[2]) # first argument is the file name, second is -l, need the third element

if __name__ == '__main__': 
    main()