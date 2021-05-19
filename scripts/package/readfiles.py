from os import truncate
import numpy as np
import pandas as pd
import h5py
import glob
import json

from df_helpers import *
from parsedata import *


def return_rsid(file, bp_pos, rsid_pos, filesep):
    '''
    Given a bim file, return a numpy array of rsids
    '''
    bimfile = pd.read_csv(file, sep = filesep,
                          header = None)
    
    bimfile = bimfile.loc[:, [bp_pos, rsid_pos]]
    bimfile = bimfile.rename(columns = {rsid_pos : "rsid", bp_pos : "BP"})
    
    return bimfile


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
    chromosome = metadata[:, args['bim_chromosome']]
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
            chromosome_file = metadata[:, args['bim_chromosome']]
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