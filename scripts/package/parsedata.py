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
def clean_SNPs(df, dataname):
    
    df = df.add_suffix(f"_{dataname}").rename(columns = {f"SNP_{dataname}" : "SNP"})
    df = df.drop_duplicates(subset=['SNP'])
    
    return df


@logdf
def make_array_cols(df, thetacol, Scol):
    
    theta_arr = np.array(df[thetacol].dropna().tolist())
    theta_shape = np.array(theta_arr[0]).shape
    nan_mat = np.empty(theta_shape)
    nan_mat[:] = np.nan
    
    df[thetacol] = df[thetacol].apply(lambda d: nan_mat if np.all(np.isnan(d)) else d)
    
    S_arr = np.array(df[Scol].dropna().tolist())
    S_shape = np.array(S_arr[0]).shape
    nan_mat = np.empty(S_shape)
    nan_mat[:] = np.nan
    
    df[Scol] = df[Scol].apply(lambda d: nan_mat if np.all(np.isnan(d)) else d)
    
    return df



@logdf
def merging_data(df_list):
    
    df_merged = reduce(lambda left,right: pd.merge(left, right, 
                                              on = "SNP",
                                              how = "outer"
                                              ),
                  df_list)
    
    return df_merged



def df_mode(df, columns):
    
    dfmode = df[columns].mode(axis="columns")[0]
     
    return dfmode

def df_fastmode(df, columns):
    
    # dfmode = df[columns].mode(axis="columns")[0]
    dfmode = calc_str_mode(df[columns])
     
    return dfmode



def _filter_alleles_matches(alleles):
    '''Remove bad variants (mismatched alleles, non-SNPs, strand ambiguous).'''
    ii = alleles.apply(lambda y: y in MATCH_ALLELES)

    # drop all NaNs as well
    ii_na = alleles.notna()
    ii = ii & ii_na
    
    return ii

@logdf
def filter_allele_matches(df, alleles, theta, S):
    '''
    Takes out observations where alleles
    aren't right. The observations arent actually dropped.
    Instead the theta, and S values are made into
    NA matrices
    '''
    
    ii = _filter_alleles_matches(df[alleles])
    
    # replace the appropriate nans
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
    df = df.reset_index(drop = True)
    
    return df
    

def _align_alleles(z, f, alleles):
    '''Align Z1 and Z2 to same choice of ref allele (allowing for strand flip).'''
    
    z = np.array(z.tolist())
    f = np.array(f.tolist())
    flip_idx = np.array(alleles.apply(lambda y: FLIP_ALLELES[y] if pd.notna(y) else False).tolist(), dtype = bool)
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
def filter_and_align(df, cohorts):
    '''
    Drops ambiguous alleles and
    aligns effects if alleles are flipped
    '''
    
    dfout = begin_pipeline(df)
    
    for cohort in cohorts:
        dfout = filter_allele_matches(dfout, f'allele_merge_{cohort}', f'theta_{cohort}', f'S_{cohort}')
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


def return_rsid(file, bp_pos, rsid_pos, filesep):
    '''
    Given a bim file, return a numpy array of rsids
    '''
    bimfile = pd.read_csv(file, sep = filesep,
                          header = None)
    
    bimfile = bimfile.loc[:, [bp_pos, rsid_pos]]
    bimfile = bimfile.rename(columns = {rsid_pos : "rsid", bp_pos : "BP"})
    
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


def read_txt(args):
    
    indirect_effect = args['txt_effectin']
    dfin = pd.read_csv(args['path2file'], delim_whitespace = True)
    N = dfin.shape[0]
    
    theta = np.zeros((N, 2))
    theta[:, 0] = np.array(dfin["direct_Beta"].tolist())
    theta[:, 1] = np.array(dfin[f'{indirect_effect}_Beta'].tolist())   
    
    
    se = np.zeros((N, 2))
    se[:, 0] = np.array((dfin["direct_SE"]).tolist())
    se[:, 1] = np.array((dfin[f'{indirect_effect}_SE']).tolist()) 
    
    S = np.zeros((N, 2, 2))
    S[:, 0, 0] = np.array((dfin["direct_SE"]**2).tolist())
    S[:, 1, 1] = np.array((dfin[f'{indirect_effect}_SE']**2).tolist()) 
    
    cov = dfin["direct_SE"] * dfin[f'{indirect_effect}_SE'] * dfin[f'r_direct_{indirect_effect}']
    S[:, 0, 1] = np.array(cov.tolist()) 
    
    zdata = pd.DataFrame({'CHR' : dfin['chromosome'].astype(int),
                    'SNP' : dfin['SNP'].astype(str),
                    'BP' : dfin['pos'].astype(int),
                    "f" : dfin['freq'],
                    "A1" : dfin['A1'].astype(str),
                    "A2" : dfin['A2'].astype(str),
                    'theta' : theta.tolist(),
                    'se' : se.tolist(),
                    "S" : S.tolist(),
                    "phvar" : 1.0})
    
    if args['rsid_readfrombim'] != '':

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

    # what kind of file is it
    reader = args['path2file'].split(".")[-1]
    print(f"Type of file: {reader}")

    if reader == "hdf5":
        zdata = read_hdf5(args, printinfo)
    elif reader == "txt":
        zdata = read_txt(args)
    else:
        raise Exception("Input file extension should either be hdf5 or txt")

    #adding A matrix
    Amat = args['Amat']
    Amat = np.array(np.matrix(Amat))
    N = zdata.shape[0]
    Amatarray = np.array(Amat.tolist() * N).reshape(N, Amat.shape[0], Amat.shape[1])
    zdata['amat'] = Amatarray.tolist()

    return zdata


def read_from_json(df_args):
    df_dict = {}
    for cohort in df_args.keys():
        print(f"Reading file for: {cohort}")
        df_in = read_file(df_args[cohort], printinfo = False)
        df_in = (df_in
         .pipe(begin_pipeline)
         .pipe(combine_allele_cols, "A1", "A2")
         .pipe(filter_bad_alleles, "A1", "A2")
         .pipe(maf_filter, df_args[cohort]['maf'])
         .pipe(clean_SNPs, cohort)
        )

        df_dict[cohort] = df_in
        print("============================")
    
    return df_dict



@logdf
def merging_data(df_list):
    
    df_merged = reduce(lambda left,right: pd.merge(left, right, 
                                              on = "SNP",
                                              how = "outer"
                                              ),
                  df_list)
    
    return df_merged
    
# == Working with arrays == #

def transform_estimates(effect_estimated,
                        S, theta):
    '''
    Transforms theta (can also be z) and S data into
    the required format
    Format types can be:
    - population (1 dimensional)
    - direct_plus_averageparental (2 dimensional)
    - direct_plus_population (2 dimensional)
    - full - passes estiamtes as is
    '''


    if effect_estimated == "population":
        
        print("Converting from full to population")

        Sdir = np.empty(len(S))
        for i in range(len(S)):
            Sdir[i] = np.array([[1.0, 0.5, 0.5]]) @ S[i] @ np.array([[1.0, 0.5, 0.5]]).T

        S = Sdir.reshape((len(S), 1, 1))
        theta = theta @ np.array([1.0, 0.5, 0.5])
        theta = theta.reshape((theta.shape[0], 1))
    elif effect_estimated == "direct_plus_averageparental":

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
    elif effect_estimated == "direct_plus_population":

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
    elif effect_estimated == "full":
        print("Not converting to anything")
        pass
    elif effect_estimated == "avgparental_to_population":

        print("Converting from average parental to population")

        tmatrix = np.array([[1.0, 1.0],
                            [0.0, 1.0]])
        
        Sdir = tmatrix.T @ S @ tmatrix

        S = Sdir.reshape((len(S), 2, 2))
        theta = theta @ tmatrix
        theta = theta.reshape((theta.shape[0], 2))
    elif effect_estimated == "population_to_avgparental":

        print("Converting from population to average parental")

        tmatrix = np.array([[1.0, -1.0],
                            [0.0, 1.0]])
        Sdir = np.empty((len(S), 2, 2))
        for i in range(len(S)):
            Sdir[i] = tmatrix.T @ S[i] @ tmatrix

        S = Sdir.reshape((len(S), 2, 2))
        theta = theta @ tmatrix
        theta = theta.reshape((theta.shape[0], 2))
    else:
        print("Warning: The given parameters hasn't been converted.")

    return S, theta



@njit(cache = True)
def theta2z(theta, S):
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

@njit
def makeDmat(S):
    '''
    Makes D matrix = M [[1/sigma_1, 0], [0, 1/sigma_2]]
    '''

    sigma1 = np.sqrt(S[0, 0])
    sigma2 = np.sqrt(S[1, 1])
    
    Dmat = np.array([[1/sigma1, 0], 
                    [0, 1/sigma2]])
    
    return Dmat


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


def get_phvar_scalar(phvar_dict):
    
    phvar_out = {}
    
    for cohort in phvar_dict:
        phvar_vector = phvar_dict[cohort]
        phvar_scalar = phvar_vector[~np.isnan(phvar_vector)][0]

        phvar_out[cohort] = phvar_scalar
        
    return phvar_out


def transform_estimates_dict(theta_dict, S_dict, args):
    
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
            


def clean_snps(*varlist, df, snpname):
    
    '''
    indexes vars with clean SNP names if
    required
    '''
    
    varlist_out = []
    ii = df[snpname].notna()
    
    if ii.sum() > 0.0:
        for var in varlist:
            varout = var[ii]
            varlist_out.append(varout)
            
        dfout = df.copy()
        dfout = dfout.dropna(subset = [snpname])
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
        X_length = 2
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