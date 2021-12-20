'''
Format gwas data for use in sbayesr
'''


import numpy as np
import pandas as pd
import argparse


if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('datapath', type=str, 
                        help='''Path to meta analyzed output''')
    parser.add_argument('--effecttype', type = str, default = 'dir', help = '''
    Which effect type do you want to output. Can be dir, paternal, maternal, population, avgparental''')
    parser.add_argument('--nmin', type=int, default=5000, help='''What is the N cutoff you want''')
    parser.add_argument('--median-n', action='store_true', default=False, help='''Instead of the N cutoff use the median N as cutoff''')
    parser.add_argument('--outpath', type = str, help = "Where to store data")
    parser.add_argument('--mincohorts', type=int, default=5, help='''What is the n_cohort cutoff you want. ''')
    args = parser.parse_args()

    print("Formatting meta analysis sumstats...")
    
    dat = pd.read_csv(
        args.datapath,
        delim_whitespace=True
    )

    NINIT = dat.shape[0]
    print(f"Observations read in: {NINIT}")

    e = args.effecttype
    dat = dat[['SNP', 'A1', 'A2', 'freq', f'{e}_Beta', f'{e}_SE', f'{e}_pval', f'{e}_N', 'n_cohorts']]

    dat = dat.drop_duplicates(subset = 'SNP').reset_index(drop = True)
    print(dat.head())

    hm3 = pd.read_csv("/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist", delim_whitespace=True)
    dat = dat[dat['SNP'].isin(hm3.SNP)].reset_index(drop = True)
    NHM3 = dat.shape[0]
    print(f"Observations after filtering for HM3 SNPs: {NHM3}")

    if args.median_n:
        print(f"Median N is {dat[f'{e}_N'].median()}")
        dat = dat.loc[dat[f'{e}_N'] > dat[f'{e}_N'].median(),].reset_index(drop = True)
    else:
        dat = dat.loc[dat[f'{e}_N'] > args.nmin,].reset_index(drop = True)

    NEFFN = dat.shape[0]
    print(f"Observations after filtering for minimum effective N: {NEFFN}")

    # dat = dat.loc[dat['n_cohorts'] >= args.mincohorts, ].reset_index(drop = True)
    # NEND = dat.shape[0]
    
    # print(f"Observations after filtering for minimum n_cohort: {NEND}")

    dat = dat[['SNP', 'A1', 'A2', 'freq', f'{e}_Beta', f'{e}_SE', f'{e}_pval', f'{e}_N']]

    dat.to_csv(
        args.outpath,
        sep = ' ',
        index = False
    )