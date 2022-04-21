import numpy as np
import pandas as pd
import h5py
import glob
import itertools as it
from functools import reduce
import datetime as dt
import re


# complementary bases
COMPLEMENT = {'A': 'T', 'T': 'A', 'C': 'G', 'G': 'C'}
# bases
BASES = COMPLEMENT.keys()
# true iff strand ambiguous
STRAND_AMBIGUOUS = {''.join(x): x[0] == COMPLEMENT[x[1]]
                    for x in it.product(BASES, BASES)
                    if x[0] != x[1]}
# SNPS we want to keep (pairs of alleles)
VALID_SNPS = {x for x in map(lambda y: ''.join(y), it.product(BASES, BASES))
              if x[0] != x[1] and not STRAND_AMBIGUOUS[x]}
# T iff SNP 1 has the same alleles as SNP 2 (allowing for strand or ref allele flip).
MATCH_ALLELES = {x for x in map(lambda y: ''.join(y), it.product(VALID_SNPS, VALID_SNPS))
                 # strand and ref match
                 if ((x[0] == x[2]) and (x[1] == x[3])) or
                 # ref match, strand flip
                 ((x[0] == COMPLEMENT[x[2]]) and (x[1] == COMPLEMENT[x[3]])) or
                 # ref flip, strand match
                 ((x[0] == x[3]) and (x[1] == x[2])) or
                 ((x[0] == COMPLEMENT[x[3]]) and (x[1] == COMPLEMENT[x[2]]))}  # strand and ref flip
# T iff SNP 1 has the same alleles as SNP 2 w/ ref allele flip.
FLIP_ALLELES = {''.join(x):
                ((x[0] == x[3]) and (x[1] == x[2])) or  # strand match
                # strand flip
                ((x[0] == COMPLEMENT[x[3]]) and (x[1] == COMPLEMENT[x[2]]))
                for x in MATCH_ALLELES}



def return_rsid(file, chr_pos, bp_pos, rsid_pos, filesep):
    '''
    Given a bim file, return a pandas dataframe of rsids
    '''
    bimfile = pd.read_csv(file, sep = filesep,
                          header = None)
    
    bimfile = bimfile.loc[:, [chr_pos, bp_pos, rsid_pos]]
    bimfile = bimfile.rename(columns = {rsid_pos : "rsid", bp_pos : "BP", chr_pos : "CHR"})
    
    return bimfile

def parse_chr(args, file):

    print("Trying to parse chromosome number from file.")
    filenames = args.datapath
    chrpos = filenames.index("*")
    chromosome = file[chrpos:chrpos+2]
    chromosome = re.findall('\d+', chromosome)[0]

    print("Chromosome parsed as: ", chromosome)

    return chromosome

def decode_byte(x):
    '''
    Decodes numpy byte array into an array of strings.
    '''

    if x.dtype.type is np.bytes_:
        xout = np.char.decode(x)
    else:
        xout = x

    return xout

def read_hdf5(args, printinfo = True):
    # == Reading in data == #
    if printinfo:
        print("Reading in Data")
        
    # reading in  data
    filenames = args.datapath
    files = glob.glob(filenames)

    file = files[0]
    if printinfo:
        print("Reading in file: ", file)
    hf = h5py.File(file, 'r')

        
    # getting estimated effects
    estimate_cols = hf['estimate_cols'][()].flatten()
    estimate_cols = [e.decode().replace('_', '') for e in estimate_cols]
    estimated_effects = '_'.join(estimate_cols)

    metadata = hf.get(args.bim)[()]
    if args.bim_chromosome == 99:
        chromosome = parse_chr(args, file)
        chromosome = np.repeat(chromosome, metadata.shape[0])
    else:
        chromosome = metadata[:, args.bim_chromosome]
    bp = metadata[:, args.bim_bp]
    if args.rsid_readfrombim is not None:
        snp = np.zeros(bp.shape[0])
    else:
        snp = metadata[:, args.bim_rsid]
    A1 = metadata[:, args.bim_a1]
    A2 = metadata[:, args.bim_a2]
    theta  = hf.get(args.estimate)[()]
    se  = hf.get(args.estimate_ses)[()]
    S = hf.get(args.estimate_covariance)[()]
    f = hf.get(args.freqs)[()]

    # normalizing S
    sigma2 = hf.get(args.sigma2)[()]
    tau = hf.get(args.tau)[()]
    phvar = sigma2+sigma2/tau
    
    hf.close()

    if len(files) > 1:
        for file in files[1:]:
            if printinfo:
                print("Reading in file: ", file)
            hf = h5py.File(file, 'r')
            metadata = hf.get(args.bim)[()]
            if args.bim_chromosome == 99:
                chromosome_file = parse_chr(args, file)
                chromosome_file = np.repeat(chromosome_file, metadata.shape[0])
            else:
                chromosome_file = metadata[:, args.bim_chromosome]
            bp_file = metadata[:, args.bim_bp]
            if args.rsid_readfrombim is not None:
                snp_file = np.zeros(bp_file.shape[0])
            else:
                snp_file = metadata[:, args.bim_rsid]
            A1_file = metadata[:, args.bim_a1]
            A2_file = metadata[:, args.bim_a2]
            theta_file  = hf.get(args.estimate)[()]
            se_file  = hf.get(args.estimate_ses)[()]
            S_file = hf.get(args.estimate_covariance)[()]
            f_file = hf.get(args.freqs)[()]

            chromosome = np.append(chromosome, chromosome_file, axis = 0)
            snp = np.append(snp, snp_file, axis = 0)
            bp = np.append(bp, bp_file, axis = 0)
            A1 = np.append(A1, A1_file, axis = 0)
            A2 = np.append(A2, A2_file, axis = 0)
            theta = np.append(theta, theta_file, axis = 0)
            se = np.append(se, se_file, axis = 0)
            S = np.append(S, S_file, axis = 0)
            f = np.append(f, f_file, axis = 0)
            hf.close()

    if args.phvar is not None:
        phvar = args.phvar

    # Constructing dataframe of data
    zdata = pd.DataFrame({'CHR' : decode_byte(chromosome).astype(float).astype(int),
                        'SNP' : decode_byte(snp).astype(str),
                        'BP' : decode_byte(bp).astype(float).astype(int),
                        "f" : f,
                        "A1" : decode_byte(A1).astype(str),
                        "A2" : decode_byte(A2).astype(str),
                        'theta' : theta.tolist(),
                        'se' : se.tolist(),
                        "S" : S.tolist(),
                        "phvar" : phvar,
                        'estimated_effects' : estimated_effects})
    

    
    if args.rsid_readfrombim is not None:
        
        print("Getting RSIDs from bim files...")
        rsid_parts = args.rsid_readfrombim.split(",")
        rsidfiles = rsid_parts[0]
        chr_pos = int(rsid_parts[1])
        bppos = int(rsid_parts[2])
        rsidpos = int(rsid_parts[3])
        file_sep = str(rsid_parts[4])
        
        rsidfiles = glob.glob(rsidfiles)
        snps = pd.DataFrame(columns = ["CHR", "BP", "rsid"])
        for file in rsidfiles:
            snp_i = return_rsid(file, chr_pos, bppos, rsidpos, file_sep)
            snps = snps.append(snp_i, ignore_index = True)
        
        snps = snps.drop_duplicates(subset=['CHR', 'BP'])
        print(f"Shape before merging with bim {zdata.shape}")
        zdata = zdata.merge(snps, how = "inner", on = ['CHR', 'BP'])
        print(f"Shape after merging with bim {zdata.shape}")
        goodlookingrsids = zdata['rsid'].str.startswith("rs").sum()
        print(f"RSIDs which look reasonable: {goodlookingrsids} i.e {(goodlookingrsids * 100)/zdata.shape[0]} percent of SNPs.")
        zdata = zdata.rename(columns = {"SNP" : "SNP_old"})
        zdata = zdata.rename(columns = {"rsid" : "SNP"})
    
    return zdata


def read_txt(args):
    
    dfin = pd.read_csv(args.datapath, delim_whitespace = True)
    N = dfin.shape[0]

    if args.effects is None:
        beta_effects = [c for c in dfin.columns if c.endswith("Beta")]
        effect_list = [c[0:-5] for c in beta_effects]
    else:
        effect_list = args.effects.split("_")
        effect_list = ["avg_parental" if (x == "averageparental" or x == "avgparental") else x for x in effect_list]
    

    theta = np.zeros((N, len(effect_list)))
    se = np.zeros((N, len(effect_list)))
    S = np.zeros((N, len(effect_list), len(effect_list)))
    for i, effect in enumerate(effect_list):
        
        theta[:, i] = np.array(dfin[effect + '_Beta'].tolist())
        se[:, i] = np.array((dfin[effect + "_SE"]).tolist())
        S[:, i, i] = np.array((dfin[effect + "_SE"]**2).tolist())
    
    if len(effect_list) > 1:
        
        if f'r_direct_{effect_list[1]}' in dfin:
            cov = dfin[effect_list[0] + "_SE"] * dfin[f'{effect_list[1]}_SE'] * dfin[f'r_direct_{effect_list[1]}']
        elif f'{effect_list[1]}_Cov' in dfin:
            cov = dfin[f'{effect_list[1]}_Cov']
        else:
            cov = dfin[f'{effect_list[0]}_{effect_list[1]}_Cov']
            
        S[:, 0, 1] = np.array(cov.tolist())
        S[:, 1, 0] = np.array(cov.tolist())

    if args.phvar is not None:
        phvar = args.phvar
    else:
        phvar = 2 * dfin['direct_N'] * dfin['freq'] * (1 - dfin['freq']) * S[:, 0, 0]
        phvar = phvar[0]

    zdata = pd.DataFrame({'CHR' : dfin['chromosome'].astype(int),
                    'SNP' : dfin['SNP'].astype(str),
                    'BP' : dfin['pos'].astype(int),
                    "f" : dfin['freq'],
                    "A1" : dfin['A1'].astype(str),
                    "A2" : dfin['A2'].astype(str),
                    'theta' : theta.tolist(),
                    'se' : se.tolist(),
                    "S" : S.tolist(),
                    "phvar" : phvar})
    
    if args.rsid_readfrombim is not None:

        rsid_parts = args.rsid_readfrombim.split(",")
        rsidfiles = rsid_parts[0]
        chr_pos = int(rsid_parts[1])
        bppos = int(rsid_parts[2])
        rsidpos = int(rsid_parts[3])
        file_sep = str(rsid_parts[4])
        
        rsidfiles = glob.glob(rsidfiles)
        snps = pd.DataFrame(columns = ["BP", "rsid"])
        for file in rsidfiles:
            snp_i = return_rsid(file, chr_pos, bppos, rsidpos, file_sep)
            snps = snps.append(snp_i, ignore_index = True)
        
        snps = snps.drop_duplicates(subset=['BP'])
        zdata = zdata.merge(snps, how = "left", on = "BP")
        zdata = zdata.rename(columns = {"SNP" : "SNP_old"})
        zdata = zdata.rename(columns = {"rsid" : "SNP"})


    effects = [effect.replace("_", "") for effect in effect_list]
    effects = '_'.join(effects)
    zdata['estimated_effects'] = effects
    
    return zdata



def read_file(args, printinfo = True):

    '''
    Reads files from args.

    Also outputs a dictionary of A matrices

    Note: A variable called `dims` is created.
    `dims` is a measure of the number of effects
    a given SNP x Cohort has. If a cohort has estimated
    direct, paternal and maternal effects `dims` will be 3.
    This is given by the number of columns in the A matrix
    provided.
    '''


    # what kind of file is it
    reader = args.datapath.split(".")[-1]
    print(f"Type of file: {reader}")

    if reader == "hdf5":
        zdata = read_hdf5(args, printinfo)
    elif reader == "txt" or reader == "sumstats":
        zdata = read_txt(args)
    else: 
        print("There was no recognized extension format. Assuming input is txt")
        zdata = read_txt(args)

    return zdata