import numpy as np
import pandas as pd
import h5py
import glob
import itertools as it
from functools import reduce
from numba import njit
import datetime as dt
from fastmode import *
from df_helpers import *
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



def reverse_nest_dicts(nested_dict):
    '''
    Reverses order of nested dictionary
    '''
    reverse_nest_dict = {}
    for k, v in nested_dict.items():
        for k2, v2 in v.items():
            try:
                reverse_nest_dict[k2][k] = v2
            except KeyError:
                reverse_nest_dict[k2] = { k : v2 }
    return reverse_nest_dict

def atleast2d_col(x):
    '''
    x: np.array
    out : np.array

    Makes x atleast 2 dimensional. 
    But empty axis is added at the end.
    This is opposed to np.atleast_2d which
    adds it at the begining.
    For example if x is 1d with shape (N,).
    This will make it (N,1). np.atleast_2d
    would make it (1, N)
    '''

    if x.ndim == 1:
        xout = x[..., None]
    else:
        xout = x

    return xout


def df_mode(df, columns):
    
    dfmode = df[columns].mode(axis="columns")[0]
     
    return dfmode


@logdf
def allele_plus_alleleconsensus(df, columns, allele_consensus_name = 'allele_consensus'):
    '''
    Merges the reference allele column
    with the given allele column.
    This is to check for allele flipping.
    '''
    
    cohort_names = [cols.split('_')[-1] for cols in columns]
    for i in range(len(columns)):
        df[f'allele_merge_{cohort_names[i]}'] = df[allele_consensus_name] + df[columns[i]]
        
    return df


@logdf
def maf_filter(df, maf):
    
    # dropping obs based on MAF
    df = df[df['f'] >=  maf/100.0]
    df = df[df['f'] <= 1-(maf/100.0)]
    
    return df


@logdf
def filter_bad_alleles(df, a1 = "A1", a2 = "A2"):
    '''Remove bad variants (mismatched alleles, non-SNPs, strand ambiguous).'''
    
    alleles = df[a1] + df[a2]
    idx = alleles.apply(lambda y: y in VALID_SNPS)
    df = df[idx]
    
    return df


@logdf
def combine_allele_cols(df, a1, a2):
    
    df['alleles'] = df[a1] + df[a2]
    
    return df


@logdf
def clean_colnames(df, dataname, on_pos = True):
    
    if on_pos:
        df = df.add_suffix(f"_{dataname}").rename(columns = {f"cptid_{dataname}" : 'cptid'})
        df = df.drop_duplicates(subset=['cptid'])
    else:
        df = df.add_suffix(f"_{dataname}").rename(columns = {f"SNP_{dataname}" : "SNP"})
        df = df.drop_duplicates(subset='SNP')

    
    return df


@logdf
def make_array_cols_nas(df, col_name_pattern, dim = 0):

    '''
    Properly formats NA values for columns of a dataframe
    which are missing. For exampple if each observation
    has an m by n array, the proper missing value here
    should be an m by n matrix of np.nans.

    df : pandas dataframe
    col_name_pattern : string indicating all the
    columns to be used. All columns with names starting
    with this string will be read
    '''
    vector_columns = [col for col in df if col.startswith(col_name_pattern)]
    
    for vector_column in vector_columns:

        # vect = np.array(df[vector_column].values.tolist())
        ii = pd.isna(df[vector_column]).values
        if np.sum(~ii) > 0:
            example_vec = np.array(df.loc[~ii, vector_column].values[0])
            nan_mat = np.zeros_like(example_vec)
            nan_mat[:] = np.nan
        else:
            shape = (2) if dim == 0 else (2,2)
            nan_mat = np.zeros(shape)
            nan_mat[:] = np.nan

        df.loc[ii, vector_column] = df.loc[ii, vector_column].apply(lambda x: nan_mat)

    return df



@logdf
def merging_data(df_list, jointype = "outer", on_pos = True):
    
    if on_pos:
        df_merged = reduce(lambda left,right: pd.merge(left, right, 
                                              on = ["cptid"],
                                              how = jointype
                                              ),
                    df_list)
    else:
        df_merged = reduce(lambda left,right: pd.merge(left, right, 
                                                on = "SNP",
                                                how = jointype
                                                ),
                    df_list)


    return df_merged



def df_mode(df, columns):
    
    dfmode = df[columns].mode(axis="columns")[0]
     
    return dfmode

def df_fastmode(df, columns):

    dfmode = calc_str_mode(df[columns])
     
    return dfmode



def _filter_alleles_matches(alleles):
    '''
    Identifies good variants (variants exluding mismatched alleles, non-SNPs, strand ambiguous).
    Returns valid indexes. (Note: These are the indexes you probably
    want to keep!)
    '''
    ii = alleles.apply(lambda y: y in MATCH_ALLELES)

    # drop all NaNs as well
    ii_na = alleles.notna()
    ii = ii & ii_na
    
    return ii

@logdf
def filter_allele_matches(df, alleles, theta, S, drop = False):
    '''
    Takes out observations where alleles
    aren't right. 
    
    If `drop` is set to False (default behavior),
    the observations arent actually dropped.
    Instead the theta, and S values are made into
    NA matrices

    If `drop` is True the observations/SNPs are
    dropped.
    '''
    
    ii = _filter_alleles_matches(df[alleles])
    initobs = df.shape[0]
    num_invalid = initobs - ii.sum()
    print(f"Number of invalid SNPS: {num_invalid}")

    # replace the appropriate nans
    if not drop:
        theta_shape = np.array(df[theta].dropna().iloc[0]).shape
        theta_nan_mat = np.empty(theta_shape)
        theta_nan_mat[:] = np.nan

        S_shape = np.array(df[S].dropna().iloc[0]).shape
        S_nan_mat = np.empty(S_shape)
        S_nan_mat[:] = np.nan
        
        cohort = alleles.split("_")[-1]
        cohort_cols = [c for c in df.columns if c.endswith(cohort)]
        
        df.loc[~ii, cohort_cols] = None
        df.loc[~ii, theta] = df.loc[~ii, theta].apply(lambda x: theta_nan_mat)
        df.loc[~ii, S] = df.loc[~ii, S].apply(lambda x: S_nan_mat)
    elif drop:
        print("Dropping bad SNPs (instead of making the matrices NAN)")
        df = df.loc[ii]
    

    df = df.reset_index(drop = True)

    return df
    

def _align_alleles(z, f, alleles):
    '''Align Z1 and Z2 to same choice of ref allele (allowing for strand flip).'''
    
    z = np.array(z.tolist())
    f = np.array(f.tolist())
    flip_idx = np.array(alleles.apply(lambda y: FLIP_ALLELES[y] if pd.notna(y) else False).tolist(), dtype = bool)
    nflip = flip_idx.sum()
    print(f"Number of alleles flipped {nflip}")
    # flip z
    mult = (-1) ** flip_idx
    if z.ndim == 1:
        z = z * mult
    else:
        z = z * mult[:, None]

    # flip f
    f[flip_idx] = 1.0 - f[flip_idx]

    return z, f

@logdf
def align_alleles(df, zname, f, alleles, chunksize = 1_000_000):
    '''
    Aligns effect sizes (znames) and frequency (f)
    if alleles need flipping

    Note that the original z and f are replaced by
    the flipped values.
    '''
    
    z = np.array(df[zname].tolist())
    assert z.shape[0] == df[alleles].shape[0] 
    assert z.shape[0] == df[f].shape[0] 
    N = z.shape[0]
    steps = np.arange(0, z.shape[0], step = chunksize)
    steps = np.hstack((steps, N))
    zout = np.zeros_like(z)
    fout = np.zeros(N)

    for i in range(len(steps) - 1):
        zout[steps[i]:(steps[i+1])], fout[steps[i]:(steps[i+1])] = _align_alleles(z[steps[i]:(steps[i+1])] , 
                                                        df[f][steps[i]:(steps[i+1])],
                                                        df[alleles][steps[i]:(steps[i+1])])
        
    zout = pd.Series(zout.tolist())
    fout = pd.Series(fout.tolist())
    df[zname] = zout
    df[f] = fout
        
    return df


@logdf
def filter_and_align(df, cohorts, drop = False):
    '''
    Drops ambiguous alleles and
    aligns effects if alleles are flipped
    '''
    
    dfout = begin_pipeline(df)
    
    for cohort in cohorts:
        dfout = filter_allele_matches(dfout, f'allele_merge_{cohort}', f'theta_{cohort}', f'S_{cohort}', drop = drop)
        dfout = align_alleles(dfout, f'theta_{cohort}', f'f_{cohort}', f'allele_merge_{cohort}')
        
    return dfout

@logdf
def combine_cols(df, colname, cols, na_replace = None):
    '''
    Combines all the columns of the cohorts. Should be used for
    something like SNPs or Chromosomes to get one identifier
    for these. 

    The function is naive and chooses the first non na
    column to be the finalized column

    df : dataframe
    colname : final column name
    cols : list of col names to combine
    na_replace : values which we should consider as NAs
    '''

    
    lencols = len(cols)
    
    # initialize with empty column
    df[colname] = np.NaN

    if na_replace is not None:
        df[cols] = df[cols].replace(na_replace, np.NaN)

    for i in range(lencols):
        df.loc[df[colname].isna(), colname] = df[cols[i]]
        
    return df


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
    filenames = args['path2file']
    chrpos = filenames.index("*")
    chromosome = file[chrpos:chrpos+2]
    chromosome = re.findall('\d+', chromosome)[0]

    print("Chromosome parsed as: ", chromosome)

    return chromosome

def read_hdf5(args, printinfo = True):
    # == Reading in data == #
    if printinfo:
        print("Reading in Data")
        
    # reading in  data
    filenames = args['path2file']
    files = glob.glob(filenames)

    file = files[0]
    if printinfo:
        print("Reading in file: ", file)
    hf = h5py.File(file, 'r')
    metadata = hf.get(args['bim'])[()]
    if 'bim_chromosome' in args:
        chromosome = metadata[:, args['bim_chromosome']]
    else:
        chromosome = parse_chr(args, file)
        chromosome = np.repeat(chromosome, metadata.shape[0])
    bp = metadata[:, args['bim_bp']]
    if args['rsid_readfrombim'] != '':
        snp = np.zeros(bp.shape[0])
    else:
        snp = metadata[:, args['bim_rsid']]
    A1 = metadata[:, args['bim_a1']]
    A2 = metadata[:, args['bim_a2']]
    theta  = hf.get(args['estimate'])[()]
    se  = hf.get(args['estimate_ses'])[()]
    S = hf.get(args['estimate_covariance'])[()]
    f = hf.get(args['freqs'])[()]

    # normalizing S
    sigma2 = hf.get(args['sigma2'])[()]
    tau = hf.get(args['tau'])[()]
    phvar = sigma2+sigma2/tau
    
    hf.close()

    if len(files) > 1:
        for file in files[1:]:
            if printinfo:
                print("Reading in file: ", file)
            hf = h5py.File(file, 'r')
            metadata = hf.get(args['bim'])[()]
            if 'bim_chromosome' in args:
                chromosome_file = metadata[:, args['bim_chromosome']]
            else:
                chromosome_file = parse_chr(args, file)
                chromosome_file = np.repeat(chromosome_file, metadata.shape[0])
            bp_file = metadata[:, args['bim_bp']]
            if args['rsid_readfrombim'] != '':
                snp_file = np.zeros(bp_file.shape[0])
            else:
                snp_file = metadata[:, args['bim_rsid']]
            A1_file = metadata[:, args['bim_a1']]
            A2_file = metadata[:, args['bim_a2']]
            theta_file  = hf.get(args['estimate'])[()]
            se_file  = hf.get(args['estimate_ses'])[()]
            S_file = hf.get(args['estimate_covariance'])[()]
            f_file = hf.get(args['freqs'])[()]

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

            
    # Constructing dataframe of data
    zdata = pd.DataFrame({'CHR' : chromosome.astype(int),
                        'SNP' : snp.astype(str),
                        'BP' : bp.astype(int),
                        "f" : f,
                        "A1" : A1.astype(str),
                        "A2" : A2.astype(str),
                        'theta' : theta.tolist(),
                        'se' : se.tolist(),
                        "S" : S.tolist(),
                        "phvar" : phvar})
    
    
    if args['rsid_readfrombim'] != '':
        

        print("Getting RSIDs from bim files...")
        rsid_parts = args['rsid_readfrombim'].split(",")
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
        print(f"Shape before merging with bim {zdata.shape}")
        goodlookingrsids = zdata['rsid'].str.startswith("rs").sum()
        print(f"RSIDs which look reasonable: {goodlookingrsids} i.e {(goodlookingrsids * 100)/zdata.shape[0]} percent of SNPs.")
        zdata = zdata.rename(columns = {"SNP" : "SNP_old"})
        zdata = zdata.rename(columns = {"rsid" : "SNP"})

    
    return zdata


def read_txt(args):

    
    dfin = pd.read_csv(args['path2file'], delim_whitespace = True)
    N = dfin.shape[0]
    
    if 'effects' in args:
        effect_list = args["effects"].split("_")
        effect_list = ["averageparental" if (x == "averageparental" or x == "avgparental") else x for x in effect_list]
    else:
        beta_effects = [c for c in dfin.columns if c.startswith("theta")]
        effect_list = [c[6:] for c in beta_effects]
        effect_list = ["averageparental" if (x == "averageparental" or x == "avgparental") else x for x in effect_list]
    
    if len(effect_list) > 3:
        effect_list.remove('population')
        effect_list.remove('averageparental')

    theta = np.zeros((N, len(effect_list)))
    se = np.zeros((N, len(effect_list)))
    S = np.zeros((N, len(effect_list), len(effect_list)))

    for i, effect in enumerate(effect_list):
        
        theta[:, i] = np.array(dfin['theta_' + effect].tolist())
        se[:, i] = np.array((dfin['se_' + effect]).tolist())
        S[:, i, i] = np.array((dfin['se_' + effect]**2).tolist())
    
    if len(effect_list) == 2:

        cov = dfin['se_' + effect_list[0]] * dfin[f'se_{effect_list[1]}'] * dfin[f'rg_direct_{effect_list[1]}']
            
        S[:, 0, 1] = np.array(cov.tolist())
        S[:, 1, 0] = np.array(cov.tolist())
    
    elif len(effect_list) == 3:

        cov_dir_eff1 = dfin[f'se_{effect_list[0]}'] * dfin[f'se_{effect_list[1]}'] * dfin[f'rg_direct_{effect_list[1]}']
        cov_dir_eff2 = dfin[f'se_{effect_list[0]}'] * dfin[f'se_{effect_list[2]}'] * dfin[f'rg_direct_{effect_list[2]}']

        r_eff1_eff2_name = f'rg_{effect_list[1]}_{effect_list[2]}' if f'rg_{effect_list[1]}_{effect_list[2]}' in dfin else f'rg_{effect_list[2]}_{effect_list[1]}'
        cov_eff1_eff2 = dfin[f'se_{effect_list[1]}'] * dfin[f'se_{effect_list[2]}'] * dfin[r_eff1_eff2_name]


        S[:, 0, 1] = np.array(cov_dir_eff1.tolist())
        S[:, 1, 0] = np.array(cov_dir_eff1.tolist())

        S[:, 0, 2] = np.array(cov_dir_eff2.tolist())
        S[:, 2, 0] = np.array(cov_dir_eff2.tolist())

        S[:, 1, 2] = np.array(cov_eff1_eff2.tolist())
        S[:, 2, 1] = np.array(cov_eff1_eff2.tolist())

    
    zdata = pd.DataFrame({'cptid' : dfin['cptid'],
                    'CHR' : dfin['CHR'].astype(int),
                    'SNP' : dfin['SNP'].astype(str),
                    'BP' : dfin['BP'].astype(int),
                    "f" : dfin['f'],
                    "A1" : dfin['A1'].astype(str),
                    "A2" : dfin['A2'].astype(str),
                    'theta' : theta.tolist(),
                    'se' : se.tolist(),
                    "S" : S.tolist(),
                    "phvar" : args['phvar'],
                    'effects' : '_'.join(effect_list)})
                    
    
    if 'rsid_readfrombim' in args:

        rsid_parts = args['rsid_readfrombim'].split(",")
        rsidfiles = rsid_parts[0]
        bppos = int(rsid_parts[1])
        rsidpos = int(rsid_parts[2])
        file_sep = str(rsid_parts[3])
        
        rsidfiles = glob.glob(rsidfiles)
        snps = pd.DataFrame(columns = ["BP", "rsid"])
        for file in rsidfiles:
            snp_i = return_rsid(file, bppos, rsidpos, file_sep)
            snps = snps.append(snp_i, ignore_index = True)
        
        snps = snps.drop_duplicates(subset=['BP'])
        zdata = zdata.merge(snps, how = "left", on = "BP")
        zdata = zdata.rename(columns = {"SNP" : "SNP_old"})
        zdata = zdata.rename(columns = {"rsid" : "SNP"})


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
    reader = args['path2file'].split(".")[-1]
    print(f"Type of file: {reader}")

    if reader == "hdf5":
        zdata = read_hdf5(args, printinfo)
    elif reader == "txt" or reader == "sumstats" or reader == "gz":
        zdata = read_txt(args)
    else: 
        print("There was no recognized extension format. Assuming input is txt")
        zdata = read_txt(args)

    return zdata


def read_from_json(df_args, args):
    df_dict = {}
    for cohort in df_args.keys():
        print(f"Reading file for: {cohort}")
        df_in = read_file(df_args[cohort], printinfo = False)
        df_in = (df_in
         .pipe(begin_pipeline)
         .pipe(combine_allele_cols, "A1", "A2")
         .pipe(clean_colnames, cohort, args.on_pos)
        )

        df_dict[cohort] = df_in
        print("============================")
    
    
    return df_dict


    
# == Working with arrays == #


def transform_estimates(fromest,
                        toest,
                        S, theta):

    '''
    Transforms theta (can also be z) and S data into
    the required format from a given format
    like direct + average parental to direct + population

    possible effects:
    - full - refers to (direct, maternal effect, paternal effect) 
    - direct_averageparental - refers to (direct, average_parental)
    - direct_population - refers to (direct, population)
    - population - refers to (population)
    '''

    # preprocess some input possibilities
    if fromest == "direct_maternal_paternal" or fromest == "direct_paternal_maternal":
        fromest = "full"
    if toest == "direct_maternal_paternal" or toest == "direct_paternal_maternal":
        toest = "full"
    if fromest == "direct_avgparental" or fromest == "direct_avgNTC":
        fromest = "direct_averageparental"

    if fromest == toest:
        pass
    elif fromest == "full" and toest == "direct_population":
        print("Converting from full to direct + Population")

        # == keeping direct effect and population effect == #
        tmatrix = np.array([[1.0, 1.0],
                            [0.0, 0.5],
                            [0.0, 0.5]])
        Sdir = np.empty((len(S), 2, 2))
        for i in range(len(S)):
            Sdir[i] = tmatrix.T @ S[i] @ tmatrix

        S = Sdir.reshape((len(S), 2, 2))
        theta = theta @ tmatrix
        theta = theta.reshape((theta.shape[0], 2))
    
    elif fromest == "full" and toest == "direct_averageparental":

        print("Converting from full to direct + average parental")

        # == Combining indirect effects to make V a 2x2 matrix == #
        tmatrix = np.array([[1.0, 0.0],
                            [0.0, 0.5],
                            [0.0, 0.5]])
        Sdir = np.empty((len(S), 2, 2))
        for i in range(len(S)):
            Sdir[i] = tmatrix.T @ S[i] @ tmatrix
        S = Sdir.reshape((len(S), 2, 2))
        theta = theta @ tmatrix
        theta = theta.reshape((theta.shape[0], 2))
    
    elif fromest == "direct_averageparental" and toest == "direct_population":

        print("Converting from direct + average parental to direct + population")

        tmatrix = np.array([[1.0, 1.0],
                            [0.0, 1.0]])
        
        Sdir = tmatrix.T @ S @ tmatrix

        S = Sdir.reshape((len(S), 2, 2))
        theta = theta @ tmatrix
        theta = theta.reshape((theta.shape[0], 2))
    
    elif fromest == "direct_population" and toest == "direct_averageparental":
        print("Converting from population to average parental")

        tmatrix = np.array([[1.0, -1.0],
                            [0.0, 1.0]])
        Sdir = np.empty((len(S), 2, 2))
        for i in range(len(S)):
            Sdir[i] = tmatrix.T @ S[i] @ tmatrix

        S = Sdir.reshape((len(S), 2, 2))
        theta = theta @ tmatrix
        theta = theta.reshape((theta.shape[0], 2))
    elif (fromest == "full" and toest == "full_averageparental_population") | (fromest == "full" and toest == "direct_paternal_maternal_averageparental_population"):
        print("Converting from full to full + average parental  + population")

        tmatrix = np.array([[1.0, 0.0, 0.0, 0.0, 1.0],
                            [0.0, 1.0, 0.0, 0.5, 0.5],
                            [0.0, 0.0, 1.0, 0.5, 0.5]])
        Sdir = np.empty((len(S), 5, 5))
        for i in range(len(S)):
            Sdir[i] = tmatrix.T @ S[i] @ tmatrix
        S = Sdir.reshape((len(S), 5, 5))
        theta = theta @ tmatrix
        theta = theta.reshape((theta.shape[0], 5))
    elif (fromest == "direct_population" and toest == "full_averageparental_population") | (fromest == "direct_population" and toest == "direct_paternal_maternal_averageparental_population"):

        print("Converting from direct population to full + average parental + population")

        tmatrix = np.array([[1.0, np.nan, np.nan, -1.0, 0.0],
                            [0.0, np.nan, np.nan, 1.0, 1.0]])
        Sdir = np.empty((len(S), 5, 5))
        for i in range(len(S)):
            Sdir[i] = tmatrix.T @ S[i] @ tmatrix

        S = Sdir.reshape((len(S), 5, 5))
        theta = np.atleast_2d(theta @ tmatrix)
        theta = theta.reshape((theta.shape[0], 5))

    elif (fromest == "direct_averageparental" and toest == "full_averageparental_population") | (fromest == "direct_averageparental" and toest == "direct_paternal_maternal_averageparental_population"):

        print("Converting from direct population to full + average parental + population")

        tmatrix = np.array([[1.0, np.nan, np.nan, 0.0, 1.0],
                            [0.0, np.nan, np.nan, 1.0, 1.0]])
        Sdir = np.empty((len(S), 5, 5))
        for i in range(len(S)):
            Sdir[i] = tmatrix.T @ S[i] @ tmatrix
        S = Sdir.reshape((len(S), 5, 5))
        theta = theta @ tmatrix
        theta = theta.reshape((theta.shape[0], 5))
    else:
        print("Warning: The given parameters hasn't been converted.")


    return S, theta

@njit(cache = True)
def theta2z_core(theta, S):
    '''
    Transforms vector of theta values
    into z values based on S
    '''

    zval = np.empty_like(theta)
    for i in range(theta.shape[0]):
        if ~np.all(S[i] == 0):
            Dmat = makeDmat(S[i])
            zval[i, :] = Dmat @ theta[i, :]
        else:
            zval[i, :] = np.nan

    return zval

def theta2z(theta, S):
    '''
    Wrapper for theta2z.
    Converts NaNs to 0s first
    then converts NaNs back
    '''
    theta_nan_idx = np.isnan(theta)
    theta_0 = np.nan_to_num(theta)
    S_0 = np.nan_to_num(S, nan = 1.0)

    zval = theta2z_core(theta_0, S_0)
    zval[theta_nan_idx] = np.nan

    return zval


# @njit
# def makeDmat(S):
#     '''
#     Makes D matrix = M [[1/sigma_1, 0], [0, 1/sigma_2]]
#     '''

#     sigma1 = np.sqrt(S[0, 0])
#     sigma2 = np.sqrt(S[1, 1])
    
#     Dmat = np.array([[1/sigma1, 0], 
#                     [0, 1/sigma2]])
    
#     return Dmat

@njit(cache = True)
def makeDmat(S):
    '''
    Makes D matrix =  [[1/sigma_1, 0], [0, 1/sigma_2]]
    '''
    ndims = S.shape[0]
    assert ndims == S.shape[1]

    Dmat = np.zeros(ndims)
    Dmat = np.diag(Dmat)

    for idx in range(ndims):
        sigma_tmp = np.sqrt(S[idx, idx])
        
        Dmat[idx, idx] = 1/sigma_tmp
    
    return Dmat

def get_rg(sigma12, sigma1, sigma2):

    '''
    Given vector of covariances, and standard
    deviations, get rg out
    '''
    
    rg = sigma12/(sigma1 * sigma2)

    return rg

def extract_vector(df, estimatename):

    '''
    df : pandas dataframe
    estimatename: list of strings

    assumes string in `estimatenames` follows
    `{estimate_type}_{cohort}`.

    extracts all the columns in `df` whos name starts
    with the strings in `estimatename`. Then outputs a 
    dictionary of vectors with names as `cohorts`.
    '''

    vector_dict = {}
    cols = [col for col in df.columns if col.startswith(estimatename)]
    cohort_names = [col.split('_')[-1] for col in df.columns if col.startswith(estimatename)]
    
    for i, c in enumerate(cols):
        vector = np.array(df[c].tolist())
        vector_dict[cohort_names[i]] = vector
        
    return vector_dict


def get_firstvalue_dict(input_dict):
    
    dict_out = {}
    
    for cohort in input_dict:
        input_vec = input_dict[cohort]
        input_vec = atleast2d_col(input_vec)

        scalar_out = input_vec[~np.any(np.isnan(input_vec),  tuple(range(1, input_vec.ndim)))]
        scalar_out = scalar_out[0] if scalar_out.shape[0] > 0 else np.nan

        dict_out[cohort] = scalar_out
        
    return dict_out


def transform_estimates_dict(theta_dict, S_dict, args):

    '''
    Doesnt work now
    '''
    
    assert theta_dict.keys() == S_dict.keys()
    
    theta_out = {}
    S_out = {}
    
    for cohort in theta_dict:
        S_adj, theta_adj = transform_estimates(args[cohort]['effect_transform'], S_dict[cohort], theta_dict[cohort])
        S_out[cohort] = S_adj
        theta_out[cohort] = theta_adj
    
    
    return theta_out, S_out
        
    


def nan_to_num_dict(*args):
    '''
    MOdifies arguments in place
    to replace nan's and infinities with 0s
    '''
    for arg in args:
        for cohort in arg:
            arg[cohort] = np.nan_to_num(arg[cohort], posinf = 0.0, neginf = 0.0)
            


def clean_snps(*varlist, df, idname):
    
    '''
    indexes vars with clean SNP names if
    required
    '''
    
    varlist_out = []
    ii = np.all(df[idname].notna(), axis = 1)
    
    if ii.sum() > 0.0:
        for var in varlist:
            varout = var[ii]
            varlist_out.append(varout)
            
        dfout = df.copy()
        dfout = dfout.dropna(subset = idname)
    else:
        varlist_out = list(varlist)
        
    varlist_out.append(dfout)

    return varlist_out




# == Outputting data == #

def encode_str_array(x):
    """
    Encode a unicode array as an ascii array
    """
    x_shape = x.shape
    x = x.flatten()
    x_out = np.array([str(y).encode('ascii') for y in x])
    return x_out.reshape(x_shape)


def write_txt_output(chrom, snp_ids, pos, alleles, outprefix, alpha, alpha_cov, sigma2, tau, freqs):
    outbim = np.column_stack((chrom, snp_ids, pos, alleles,np.round(freqs,3)))
    header = ['chromosome','SNP','pos','A1','A2','freq']
    # Which effects to estimate
    effects = ['direct']
    if sib:
        effects.append('sib')
    if not parsum:
        effects += ['paternal','maternal']
    effects += ['avg_parental','population']
    effects = np.array(effects)
    if not parsum:
        paternal_index = np.where(effects=='paternal')[0][0]
        maternal_index = np.where(effects=='maternal')[0][0]
    avg_par_index = np.where(effects=='avg_parental')[0][0]
    population_index = avg_par_index+1
    # Get transform matrix
    A = np.zeros((len(effects),alpha.shape[1]))
    A[0:alpha.shape[1],0:alpha.shape[1]] = np.identity(alpha.shape[1])
    if not parsum:
        A[alpha.shape[1]:(alpha.shape[1]+2), :] = 0.5
        A[alpha.shape[1], 0] = 0
        A[alpha.shape[1]+1, 0] = 1
    else:
        A[alpha.shape[1], :] = 1
    # Transform effects
    alpha = alpha.dot(A.T)
    alpha_ses_out = np.zeros((alpha.shape[0],A.shape[0]))
    corrs = ['r_direct_avg_parental','r_direct_population']
    if sib:
        corrs.append('r_direct_sib')
    if not parsum:
        corrs.append('r_paternal_maternal')
    ncor = len(corrs)
    alpha_corr_out = np.zeros((alpha.shape[0],ncor))
    for i in range(alpha_cov.shape[0]):
        alpha_cov_i = A.dot(alpha_cov[i,:,:].dot(A.T))
        alpha_ses_out[i,:] = np.sqrt(np.diag(alpha_cov_i))
        # Direct to average parental
        alpha_corr_out[i,0] = alpha_cov_i[0,avg_par_index]/(alpha_ses_out[i,0]*alpha_ses_out[i,avg_par_index])
        # Direct to population
        alpha_corr_out[i,1] = alpha_cov_i[0,population_index]/(alpha_ses_out[i,0]*alpha_ses_out[i,population_index])
        # Direct to sib
        if sib:
            alpha_corr_out[i,2] = alpha_cov_i[0,1]/(alpha_ses_out[i,0]*alpha_ses_out[i,1])
        # Paternal to maternal
        if not parsum:
            alpha_corr_out[i,ncor-1] = alpha_cov_i[paternal_index,maternal_index]/(alpha_ses_out[i,maternal_index]*alpha_ses_out[i,paternal_index])
    # Create output array
    vy = (1+1/tau)*sigma2
    outstack = [outbim]
    for i in range(len(effects)):
        outstack.append(outarray_effect(alpha[:,i],alpha_ses_out[:,i],freqs,vy))
        header += [effects[i]+'_N',effects[i]+'_Beta',effects[i]+'_SE',effects[i]+'_Z',effects[i]+'_log10_P']
    outstack.append(np.round(alpha_corr_out,6))
    header += corrs
    # Output array
    outarray = np.row_stack((np.array(header),np.column_stack(outstack)))
    print('Writing text output to '+outprefix+'.sumstats.gz')
    np.savetxt(outprefix+'.sumstats.gz',outarray,fmt='%s')


def write_output(chrom, snp_ids, pos, alleles, outprefix, alpha, alpha_ses, alpha_cov, sigma2, tau, freqs):
    """
    Write fitted SNP effects and other parameters to output HDF5 file.
    """
    print('Writing output to ' + outprefix + '.sumstats.hdf5')
    with h5py.File(outprefix+'.sumstats.hdf5', 'w') as outfile:
        outbim = np.column_stack((chrom,snp_ids,pos,alleles))
        outfile['bim'] = encode_str_array(outbim)
        X_length = 5
        outcols = ['direct']
        outfile.create_dataset('estimate_covariance', (snp_ids.shape[0], X_length, X_length), dtype='f', chunks=True,
                               compression='gzip', compression_opts=9)
        outfile.create_dataset('estimate', (snp_ids.shape[0], X_length), dtype='f', chunks=True, compression='gzip',
                               compression_opts=9)
        outfile.create_dataset('estimate_ses', (snp_ids.shape[0], X_length), dtype='f', chunks=True, compression='gzip',
                               compression_opts=9)
        outfile['estimate'][:] = alpha
        outfile['estimate_cols'] = encode_str_array(np.array(outcols))
        outfile['estimate_ses'][:] = alpha_ses
        outfile['estimate_covariance'][:] = alpha_cov
        outfile['sigma2'] = sigma2
        outfile['tau'] = tau
        outfile['freqs'] = freqs

