'''
Format fgwas data for use in prscs and create validation.bim file
'''


import numpy as np
import pandas as pd
import argparse
from scipy.stats import chi2


if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('datapath', type=str, 
                        help='''Path to meta analyzed output''')
    parser.add_argument('--effecttype', type = str, default = 'dir', help = '''
    Which effect type do you want to output. Can be dir, paternal, maternal, population, avgparental''')
    parser.add_argument('--outpath', type = str, help = "Where to store data")
    parser.add_argument('--bimout', type = str, help = "Where to save validation.bim file")
    args = parser.parse_args()

    print("Formatting meta analysis sumstats...")
    
    dat = pd.read_csv(
        args.datapath,
        delim_whitespace=True
    )

    NINIT = dat.shape[0]
    print(f"Observations read in: {NINIT}")

    e = args.effecttype
    dat[[f'{e}_pval']] = chi2.sf(dat[[f'{e}_Z']]**2, df=1)
    dat = dat[['SNP', 'A1', 'A2', f'{e}_Beta', f'{e}_pval']]
    dat.rename(columns={f'{e}_Beta': 'BETA', f'{e}_pval': 'P'}, inplace = True)
    dat = dat.drop_duplicates(subset = 'SNP').reset_index(drop = True)
    print(dat.head())

    dat.to_csv(
        args.outpath,
        sep = ' ',
        index = False
    )

    ## create validation.bim file
    # .bim format:
    # A text file with no header line, and one line per variant with the following six fields:
    # Chromosome code (either an integer, or 'X'/'Y'/'XY'/'MT'; '0' indicates unknown) or name
    # Variant identifier
    # Position in morgans or centimorgans (safe to use dummy value of '0')
    # Base-pair coordinate (1-based; limited to 231-2)
    # Allele 1 (corresponding to clear bits in .bed; usually minor)
    # Allele 2 (corresponding to set bits in .bed; usually major)

    bim = pd.read_csv(
        args.datapath,
        delim_whitespace=True
    )

    bim = bim[['chromosome', 'SNP', 'pos', 'A1', 'A2']]
    bim['position'] = 0
    bim = bim[['chromosome', 'SNP', 'position', 'pos', 'A1', 'A2']]
    
    bim.to_csv(
        args.bimout,
        sep = ' ',
        index = False,
        header = False
    )






