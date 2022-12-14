import numpy as np
import pandas as pd
import argparse

parser=argparse.ArgumentParser()
parser.add_argument('weightsfile', type=str, 
                    help='''Path to the prscs output''')
parser.add_argument('--out', type=str, 
                    help='''Path to the outfile''')
args=parser.parse_args()

dat = pd.read_csv(
    args.weightsfile,
    sep = "\t",
    header = None
)

dat['varid'] = dat[0].map(str) + ':' + dat[2].map(str)


dat.to_csv(
    args.out,
    index = False, header = False, na_rep = '.', sep = "\t"
)