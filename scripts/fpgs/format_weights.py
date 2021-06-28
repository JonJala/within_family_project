import numpy as np
import pandas as pd
import argparse

parser=argparse.ArgumentParser()
parser.add_argument('weightfile',type=str,help='Weight File')
parser.add_argument('--sep',type=str,help='Seperator for weight file', default = ",")
parser.add_argument('--compression',type=str,help='Weight file compression', default = "infer")
parser.add_argument('--outfileprefix',type=str,help='Outfile prefix. Will add .txt at the end')
parser.add_argument('--sid-as-chrpos', action='store_true', default = False, help = '''Will make the sid columns a combination of
chromosome and position''')
parser.add_argument("--chr",  type=str, help="chr column name for sumstats", default = "chrom")
parser.add_argument("--pos",  type=str, help="BP column name for sumstats", default = "pos")
parser.add_argument("--rsid",  type=str, help="rsid column name for sumstats", default = "sid")
parser.add_argument("--a1",  type=str, help="A1 column name for sumstats", default = "nt1")
parser.add_argument("--a2",  type=str, help="A2 column name for sumstats", default = "nt2")
parser.add_argument("--beta",  type=str, help="A2 column name for sumstats", default = "ldpred_beta")
args=parser.parse_args()

wts = pd.read_csv(args.weightfile, delimiter = args.sep, compression = args.compression)
wts = wts[[args.chr, args.pos, args.rsid, args.a1, args.a2, args.beta]]

if args.sid_as_chrpos:
    wts[args.rsid] = wts[args.chr].astype(str) + ":" + wts[args.pos].astype(str)

wts.to_csv(args.outfileprefix + ".txt", sep = " ", na_rep='.', index = False)