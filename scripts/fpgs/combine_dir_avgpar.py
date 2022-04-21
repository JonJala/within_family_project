'''
This script combines the PGS effects 
created from fpgs. It takes the direct
effect pgi of the proband and the avg parental
pgi for the parents and outputs
the resultant dataframe
'''

import numpy as np
import pandas as pd
import argparse

parser=argparse.ArgumentParser()
parser.add_argument('--direff', type=str, help='File with direct effect PGI', 
                    default = "/var/genetics/proj/within_family/within_family_project/processed/fpgs/direct_ea.pgs.txt")
parser.add_argument('--avgpar_eff', type=str, help='File with Average Parental effect PGI',
                    default = "/var/genetics/proj/within_family/within_family_project/processed/fpgs/avgparental_ea.pgs.txt")
parser.add_argument('--out_prefix', type=str, help='File with Average Parental effect PGI',
                    default = "/var/genetics/proj/within_family/within_family_project/processed/fpgs/dir_avgparental_ea.pgs")
args=parser.parse_args()

dir_pgi = pd.read_csv(
    args.direff,
    delim_whitespace = True
)

avgpar_pgi = pd.read_csv(
    args.avgpar_eff,
    delim_whitespace = True
)

dir_pgi = dir_pgi[["FID", "IID", "proband"]]
avgpar_pgi = avgpar_pgi[["FID", "IID", "paternal", "maternal"]]

datout = pd.merge(dir_pgi, avgpar_pgi, how = "inner", on = ["FID", "IID"])

datout.to_csv(
    args.out_prefix + ".txt",
    sep = " ",
    index = False
)