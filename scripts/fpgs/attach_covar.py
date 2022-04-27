import numpy as np
import pandas as pd
import argparse

parser=argparse.ArgumentParser()
parser.add_argument('pgifile',type=str,help='PGI (score) file')
parser.add_argument('--covariates',type=str,help='Covariates File')
parser.add_argument('--keepeffect',type=str, default=None, help='''Which col to keep. If none everything is kept. All covariates
are always attached''')
parser.add_argument('--outprefix',type=str,default = "", help='Outfile will be appneded with .pgs.txt')
args=parser.parse_args()


dat = pd.read_csv(args.pgifile, delim_whitespace=True)
if args.keepeffect is not None:
    dat = dat[['FID', 'IID', args.keepeffect]]
    
covar = pd.read_csv(args.covariates, delim_whitespace=True)
covar = covar.drop(columns = 'FID')
dat = pd.merge(dat, covar, on = ['IID'], how = 'inner')
print(dat.head())

dat.to_csv(args.outprefix + ".pgs.txt", sep = " ", na_rep = ".", index = False)

