import numpy as np
import pandas as pd
import argparse

parser=argparse.ArgumentParser()
parser.add_argument('phenofile',type=str,help='Phenotype file location')
parser.add_argument('--sep',type=str,help='Seperator for phenotype file', default = " ")
parser.add_argument('--compression',type=str,help='Compression for phenotype file', default = "infer")
parser.add_argument('--iid',type=str,help='Name of IID column', default = "IID")
parser.add_argument('--fid',type=str,help='Name of FID column', default = "FID")
parser.add_argument('--phenocol',type=str,help='Name of phenotype column', default = "phenotype")
parser.add_argument('--outprefix',type=str,help='Output prefix. Will add .pheno to the end', default = ".")
parser.add_argument('--keep-na', action='store_true', default = False, help = "Should we keep the NA values")
args=parser.parse_args()


dat = pd.read_csv(args.phenofile, delimiter = args.sep, compression = args.compression)
dat = dat[[args.fid, args.iid, args.phenocol]]

print("Number of observations: ", dat.shape[0])
if not args.keep_na:
    
    dat = dat.dropna()
    print("Number of observations after dropping NAs: ", dat.shape[0])

dat.to_csv(args.outprefix + ".pheno", sep = " ", na_rep = ".", index = False, header = False)

