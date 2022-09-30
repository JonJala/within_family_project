'''
Sum scores for individuals we have scores computed by chromosome
'''


import numpy as np
import pandas as pd
import argparse
from glob import glob


if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('datapath', type=str, 
                        help='''Path to meta analyzed output. Globbed''')
    parser.add_argument('--outprefix', type=str, 
                        help='''Where to store final file''')
    args = parser.parse_args()

    files = glob(args.datapath)
    dat = pd.read_csv(files[0], delim_whitespace=True)
    dat = dat[['#FID', 'IID', f'SCORE1_SUM']]
    dat = dat.rename(columns = {'SCORE1_SUM' : f'SCORE_1'})

    for file in files[1:]:
        dat_tmp = pd.read_csv(file, delim_whitespace=True)
        dat_tmp = dat_tmp.rename(columns = {'SCORE1_SUM' : f'SCORE_{file}'})
        dat_tmp = dat_tmp[['#FID', 'IID', f'SCORE_{file}']]
        dat = dat.merge(dat_tmp, how='outer', on=['#FID', 'IID'])

    score_cols = [c for c in dat.columns if c.startswith('SCORE_')]

    dat['SCORE'] = dat[score_cols].sum(axis=1)
    dat = dat[['#FID', 'IID', 'SCORE']]
    dat = dat.rename(columns = {'#FID' : 'FID'})

    print(dat.head())

    dat.to_csv(args.outprefix, sep=' ', na_rep='nan', index=False)

