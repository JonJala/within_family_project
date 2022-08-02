import numpy as np
import pandas as pd
import argparse

parser=argparse.ArgumentParser()
parser.add_argument('phenofile',type=str,help='Phenotype file location')
parser.add_argument('--sep',type=str,help='Separator for phenotype file', default = " ")
parser.add_argument('--compression',type=str,help='Compression for phenotype file', default = "infer")
parser.add_argument('--iid',type=str,help='Name of IID column', default = "IID")
parser.add_argument('--fid',type=str,help='Name of FID column', default = None)
parser.add_argument('--phenocol',type=str,help='Name of phenotype column', default = "phenotype")
parser.add_argument('--outprefix',type=str,help='Output prefix. Will add .pheno to the end', default = ".")
parser.add_argument('--keep-na', action='store_true', default = False, help = "Should we keep the NA values")
parser.add_argument('--subsample', type=str, help='''List of individuals you want to subsample''', default = None)
parser.add_argument('--binary', type=str, default='0', help='''Is pheno a binary phenotype''')
args=parser.parse_args()

if args.sep == 'delim_whitespace':
    dat = pd.read_csv(args.phenofile, delim_whitespace=True, compression = args.compression)
else:
    dat = pd.read_csv(args.phenofile, delimiter = args.sep, compression = args.compression)


if args.phenocol == "hdl":
    args.phenocol = "HDL"
elif args.phenocol == "cognition":
    args.phenocol = "cog"
elif args.phenocol == "ea":
    args.phenocol = "cog" # read from cog column (mcs verbal activity score)

if args.fid is not None:
    dat = dat[[args.fid, args.iid, args.phenocol]]
    dat = dat.rename(columns = {args.iid : 'IID', args.fid : 'FID'})
else:
    # combine fid and iid
    dat = dat[[args.iid, args.phenocol]]
    dat[args.iid] = dat[args.iid].astype(str) + "_" + dat[args.iid].astype(str)
    dat['FID'] = dat[args.iid]
    dat = dat[['FID', args.iid, args.phenocol]]
    dat = dat.rename(columns = {args.iid : 'IID'})

if args.binary != '1':
    dat[args.phenocol] = dat[args.phenocol]/dat[args.phenocol].std()


if not args.keep_na:
    dat = dat.dropna()
    print("Number of observations after dropping NAs: ", dat.shape[0])

if args.subsample is not None:
    subsample = pd.read_csv(args.subsample, delim_whitespace=True, names = ['IID', 'FID'])
    dat = pd.merge(dat, subsample, on = ['FID', 'IID'], how = 'inner')


print("Number of observations: ", dat.shape[0])
print(dat.head())

dat.to_csv(args.outprefix + ".pheno", sep = " ", na_rep = ".", index = False, header = False)

