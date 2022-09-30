'''
This script combines the PGS effects 
created from fpgs. It combines proband,
maternal and paternal effects into
one dataframe and outputs it.
'''

import numpy as np
import pandas as pd
import argparse

parser=argparse.ArgumentParser()
parser.add_argument('--df1', type=str, help='File with direct effect PGI', 
                    default = "/var/genetics/proj/within_family/within_family_project/processed/fpgs/direct_ea.pgs.txt")
parser.add_argument('--df2', type=str, help='File with Average Parental effect PGI',
                    default = "/var/genetics/proj/within_family/within_family_project/processed/fpgs/avgparental_ea.pgs.txt")
parser.add_argument('--out_prefix', type=str, help='File with Average Parental effect PGI',
                    default = "/var/genetics/proj/within_family/within_family_project/processed/fpgs/dir_avgparental_ea.pgs")
args=parser.parse_args()

dir_pgi = pd.read_csv(
    args.df1,
    delim_whitespace = True
)

avgpar_pgi = pd.read_csv(
    args.df2,
    delim_whitespace = True
)

df1 = dir_pgi[["FID", "IID", "proband", "paternal", "maternal"]]
df2 = avgpar_pgi[["FID", "IID", "proband", "paternal", "maternal"]]

datout = pd.merge(df1, df2, how = "inner", on = ["FID", "IID"])

datout.to_csv(
    args.out_prefix + ".txt",
    sep = " ",
    index = False
)