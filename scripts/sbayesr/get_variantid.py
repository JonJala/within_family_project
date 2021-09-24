import numpy as np
import pandas as pd
import argparse

parser=argparse.ArgumentParser()
parser.add_argument('weightsfile', type=str, 
                    help='''Path to the sbayesr output''')
parser.add_argument('--out', type=str, 
                    help='''Path to the outfile''')
args=parser.parse_args()

dat = pd.read_csv(
    args.weightsfile,
    delim_whitespace = True
)

dat['varid'] = dat['Chrom'].map(str) + ':' + dat['Position'].map(str)

dat.to_csv(
    args.out,
    index = False, na_rep = '.', sep = "\t"
)