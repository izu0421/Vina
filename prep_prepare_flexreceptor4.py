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

def FlexRes(flex_res):
    res_pdb_file = (str(''.join(flex_res)))
    #print(res_pdb_file)
    chain_name, filetype = res_pdb_file.split("_")
    #print(chain_name)
    with open(res_pdb_file, 'r') as file:
        res_list = []
        #print(content)
        for line in file:
            line_list = line.split()
            end = line_list[0]
            if end == 'END':
                break
            resn_id = line_list[3]
            chain_id = line_list[4]
            #print(resn_id)
            resi_id = line_list[5]
            #atom_id = line_list[1]
            append_res = "receptor:" + str(chain_id) + ":" + str(resn_id) + str(resi_id)
            #print(append_res)
            res_list.append(append_res)
        res_set = set(res_list)
        res_list_uniq = list(res_set)
        res_out = str(','.join(res_list_uniq))
        output_filename = str(chain_name) + "_receptor.txt"
        #print(res_out)
        with open(output_filename, 'w') as outfile:
            outfile.write(res_out)

    
    #cmd.save(filename = 'flex_res.pdb', selection = 'all_flex_res')

#def myfunc(resi,resn,name):
#    print('%s`%s/%s' % (resn ,resi, name))

#myspace = {'myfunc': myfunc}
#cmd.iterate('(br. sel)', 'myfunc(resi,resn,name)', space=myspace)
#cmd.iterate('(br. sel)', 'resi, resn'), list.append(resi,resn)

parser = argparse.ArgumentParser(description='Prepare flex receptors and ligand')
parser.add_argument('-f', '--flex_res', required=True, nargs='+')
args = parser.parse_args()

if __name__ == '__main__': 
    FlexRes(args.flex_res)