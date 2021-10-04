import numpy as np
import pandas as pd
import datetime as dt
import json
import argparse
import glob

from easyqc_parsedata import *

def process_dat(dat, effects):

    '''
    Typically input file's theta, S and se
    columns are numpy arrays

    This unpacks it and adds it back into the dataframe
    '''

    datout = dat.copy()
    datout = datout.drop(columns = ['theta', 'S', 'se'])

    theta_vec = np.array(dat['theta'].tolist())
    S_vec = np.array(dat['S'].tolist())
    se_vec = np.array(dat['se'].tolist())

    effects = effects.split(",")
    
    for idx, effect in enumerate(effects):
        theta_tmp = theta_vec[:, idx]
        datout[f'theta_{effect}'] = theta_tmp

        S_tmp = S_vec[:, idx, idx]
        datout[f'S_{effect}'] = S_tmp

        se_tmp = se_vec[:, idx]
        datout[f'se_{effect}'] = se_tmp

    return datout




if __name__ == '__main__':
    
    # Parse arguments
    parser = argparse.ArgumentParser()
    parser.add_argument('datapath', type=str, 
                        help='''Path to raw data. * symbol is wildcard
                        if extension is hdf5 then it reads as such, otherwise
                        it assumes it is a txt file delimited by spaces or tabs''')
    parser.add_argument('--effects', type = str, default = 'direct,paternal,maternal',
    help = '''
    What are the effect names in the dataset inputted. Seperated by commas
    ''')
    
    parser.add_argument('--outprefix', default = "", type = str, help = "Output prefix")
    parser.add_argument('-maf', '--maf-thresh', dest = "maf", type = float, default = 0.01,
    help = """The threshold of minor allele frequency. All SNPs below this threshold
    are dropped.""")
    parser.add_argument('-A', '--Amat', default = "1.0 0.0 0.0;0.0 1.0 0.0;0.0 0.0 1.0", type = str, 
    help = "A matrix which tells us how the effects are transformed.")

    # variable names
    parser.add_argument('-bim', default = "bim", type = str, help = "Name of bim column")
    parser.add_argument('-bim_chromosome', default = 0, type = int, help = "Column index of Chromosome in BIM variable")
    parser.add_argument('-bim_rsid', default = 1, type = int, help = "Column index of SNPID (RSID) in BIM variable")

    parser.add_argument('--rsid_readfrombim', type = str, 
                        help = '''Needs to be a comma seperated string of filename, BP-position, SNP-position, seperator.
                        If provided the variable bim_snp wont be used instead rsid's will be read
                        from the provided file set.''')
    parser.add_argument('-bim_bp', default = 2, type = int, help = "Column index of BP in BIM variable")
    parser.add_argument('-bim_a1', default = 3, type = int, help = "Column index of Chromosome in A1 variable")
    parser.add_argument('-bim_a2', default = 4, type = int, help = "Column index of Chromosome in A2 variable")

    parser.add_argument('-estimate', default = "estimate", type = str, help = "Name of estimate column")
    parser.add_argument('-estimate_ses', default = "estimate_ses", type = str, help = "Name of estimate_ses column")
    parser.add_argument('-N', default = "N_L", type = str, help = "Name of N column")
    parser.add_argument('-estimate_covariance', default = "estimate_covariance", type = str, help = "Name of estimate_covariance column")
    parser.add_argument('-freqs', default = "freqs", type = str, help = "Name of freqs column")

    parser.add_argument('-sigma2', default = "sigma2", type = str, help = "Name of sigma2 column")
    parser.add_argument('-tau', default = "tau", type = str, help = "Name of tau column")



    args = parser.parse_args()


    # parsing
    dat = read_file(args)
    dat = process_dat(dat, args.effects)
    
    with open(f"{args.outprefix}clean.ecf", "a") as f:
        f.write("#### EasyQC-script to perform study-level and meta-level QC\n")
        f.write("#### 0. Setup:\n")
        f.write(f'''DEFINE   --pathOut {args.outprefix}
                --strMissing NA
                --strSeparator WHITESPACE
                --acolIn SNP;chromosome;pos;A1;A2;beta;SE;P;freq;N
                --acolInClasses character;numeric;numeric;character;character;numeric;numeric;numeric;numeric;numeric
    --acolNewName rsID;CHR;POS;EFFECT_ALLELE;OTHER_ALLELE;BETA;SE;PVAL;EAF;N''')





    