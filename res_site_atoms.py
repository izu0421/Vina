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

def ResSite(res_site, res_name):
    cmd.load(filename = "R.pdb", object = "receptor") #this works
    site_name = "resn " + str(''.join(res_name)) + " and resi " + str(''.join(res_site))
    #print(site_name)
    cmd.select("res_site", selection = site_name)
    #cmd.select('all_flex_res', 'receptor within 4.0 of res_site')
    cmd.save(filename = 'CA_res_atoms.pdb', selection = 'res_site')
    #cmd.save(filename = 'flex_res.pdb', selection = 'all_flex_res')

#def myfunc(resi,resn,name):
#    print('%s`%s/%s' % (resn ,resi, name))

#myspace = {'myfunc': myfunc}
#cmd.iterate('(br. sel)', 'myfunc(resi,resn,name)', space=myspace)
#cmd.iterate('(br. sel)', 'resi, resn'), list.append(resi,resn)

parser = argparse.ArgumentParser(description='Get receptor residues at 4A of a particular site')
parser.add_argument('-s', '--res_site', required=True, nargs='+')
parser.add_argument('-n', '--res_name', required=True, nargs='+')
args = parser.parse_args()

if __name__ == '__main__': 
    ResSite(args.res_site, args.res_name)