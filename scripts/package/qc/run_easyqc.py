import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import datetime as dt
import json
import argparse
import glob
from numba import njit
import tempfile
import os
import subprocess

from easyqc_parsedata import *

import sys
sys.path.append("/var/genetics/proj/within_family/within_family_project/scripts/package")
from parsedata import transform_estimates

def make_folder(foldername):
    '''
    Check if folder exists. If it does, then
    the function doesn't do anything.
    If it doesn't it creates the folder
    '''

    if not os.path.exists(foldername):
        print(f"Creating folder: {foldername}")
        os.makedirs(foldername)

@njit(cache = True)
def correlation_from_covariance(covariance):

    v = np.sqrt(np.diag(covariance))
    outer_v = np.outer(v, v)
    correlation = covariance / outer_v

    covflat = covariance.ravel()
    corflat = correlation.ravel()
    cov0idx = np.abs(covflat) < 1e-6
    corflat[cov0idx] = 0

    return correlation

@njit(cache = True)
def convert_S_to_corr(Smat):
    
    n = Smat.shape[0]
    corrmat = np.zeros_like(Smat)
    
    for i in range(n):
        corrmat[i, :, :] = correlation_from_covariance(Smat[i, :, :])
        
    return corrmat

@njit
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

def get_rg_pairs(effects):

    '''
    Get pairs of effects relevant for sampling correlations
    '''

    # store rg's

    if len(effects) == 3:
        rgpairs = [(effects[0], effects[1]), (effects[0], effects[2]), (effects[1], effects[2])]
    elif len(effects) == 5:
        rgpairs = [
            (effects[0], effects[1]), 
            (effects[0], effects[2]), 
            (effects[1], effects[2]),
            (effects[0], 'averageparental'),
            (effects[0], 'population')
            ]
    elif len(effects) == 2:
        rgpairs = [(effects[0], effects[1])]
    else:
        rgpairs = []
        print("There's probably only one effect passed in!")

    return rgpairs
    
def get_effect_list(effects):

    '''
    Converts from shortform notations for effect names 
    to full form so that the program can keep track of the names
    '''

    if effects == "full":
        effects_out = "direct,paternal,maternal"
    elif effects == "full_averageparental_population":
        effects_out = "direct,paternal,maternal,averageparental,population"
    elif effects == "direct_averageparental" or effects == "direct_avgparental" :
        effects_out = "direct,averageparental"
    elif effects == "direct_population":
        effects_out = "direct,population"
    else:
        print("Didn't get what the effects meant!")

    return effects_out

def read_hwe(args):
    '''
    Read all teh hwe files and output
    one single pandas dataframe
    '''


    hwepath = args.hwe
    hwefiles = glob.glob(hwepath)
    hwedat = pd.DataFrame(columns = ["SNP", "P"])
    for hwefile in hwefiles:
        dattmp = pd.read_csv(
            hwefile,
            usecols = ["SNP", "P"],
            delim_whitespace = True
        )
        hwedat = hwedat.append(dattmp, ignore_index=True)
    
    hwedat = hwedat.rename(columns = {"P" : "hwe_p"})
    return hwedat
    

def read_info(args):

    '''
    Read imputation quality data
    and output a dataframe
    '''

    infopath = args.info
    infofiles = glob.glob(infopath)
    infodat = pd.DataFrame(columns = ["SNP", "Rsq", "AvgCall"])

    for infofile in infofiles:
        dattmp = pd.read_csv(
            infofile,
            usecols = ["SNP", "Rsq", "AvgCall"],
            delim_whitespace = True
        )

        infodat = infodat.append(dattmp, ignore_index=True)

    infodat = infodat.rename(
        columns = {"Rsq" : "info_r2",
                "AvgCall" : "callrate"}
    )
    return infodat


def process_dat(dat, args):

    '''
    Typically input file's theta, S and se
    columns are numpy arrays

    This unpacks it and adds it back into the dataframe
    '''

    datout = dat.copy()
    datout = datout.drop(columns = ['theta', 'S', 'se'])

    phvar = dat.loc[~pd.isna(dat['phvar']), 'phvar'][0]
    theta_vec = np.array(dat['theta'].tolist())
    S_vec = np.array(dat['S'].tolist())


    # normalize cols by phenotypic variance
    if not args.binary:
        theta_vec = theta_vec * 1/np.sqrt(phvar)
        S_vec = S_vec * 1/(phvar)
    else:
        theta_vec = theta_vec * 1/phvar
        S_vec = S_vec * 1/(phvar ** 2)

    effects = dat['estimated_effects'][0]

    if args.toest is not None:
        S_vec, theta_vec = transform_estimates( 
            effects,
            args.toest,
            S_vec, theta_vec
        )
        effects = args.toest


    corr_vec = convert_S_to_corr(S_vec)
    z_vec = theta2z(theta_vec, S_vec)

    effects = effects.split("_")
    
    for idx, effect in enumerate(effects):
        theta_tmp = theta_vec[:, idx]
        datout[f'theta_{effect}'] = theta_tmp

        se_tmp = np.sqrt(S_vec[:, idx, idx])
        datout[f'se_{effect}'] = se_tmp

        z_tmp = z_vec[:, idx]
        datout[f'z_{effect}'] = z_tmp

    # store rg's
    effectset = effects if args.toest is None else args.toest.split('_')
    rgpairs = get_rg_pairs(effectset)

    if len(rgpairs) > 0:
        for pair in rgpairs:
            idx1 = effectset.index(pair[0])
            idx2 = effectset.index(pair[1])

            corr_tmp = corr_vec[:, idx1, idx2]
            datout[f'rg_{pair[0]}_{pair[1]}'] = corr_tmp

    # read and merge hwe
    if args.hwe is not None:
        hwe = read_hwe(args)
        datout = pd.merge(datout, hwe, on = "SNP", how = 'inner')
        print(f"Shape after merging with hwe: {datout.shape}")
    if args.info is not None:
        info = read_info(args)
        datout = pd.merge(datout, info, on = "SNP", how = 'inner')
        print(f"Shape after merging with info: {datout.shape}")

    if args.cptid:
        print('The cptid option has been passed. HRC will be used to read in the rsids.')
        # get rsid from hrc
        hrc = pd.read_csv(
            "/var/genetics/ukb/linner/EA3/EasyQC_HRC/EASYQC.RSMID.MAPFILE.HRC.chr1_22_X.txt",
            delim_whitespace = True,
            dtype = {"rsmid" : str, "chr" : str, "pos" : np.int64}
        )

        hrc = hrc.loc[hrc["chr"] != "X"]
        hrc["chr"] = hrc["chr"].map(int)

        print(f'Number of observations before merging with HRC: {datout.shape[0]}')
        datout = pd.merge(
            datout, 
            hrc, 
            left_on = ["CHR", "BP"], 
            right_on = ["chr", "pos"],
            how = "inner"
        )
        print(f'Number of obs after merging with hrc: {datout.shape[0]}')

        datout = datout.drop(["SNP", "chr", "pos"], axis = 1)
        datout = datout.rename(columns = {"rsmid" : "SNP"})
        datout["cptid"] = datout["CHR"].astype(str) + ":" + datout["BP"].astype(str)

    return datout

def init_ecf(f, args, dat, tmpcsvout):

    '''
    Writes the starting of the ecf file

    f - opened ecf file
    args - script arguments
    dat - dataframe with sumarry statistics
    tmpcsvout - tmpfile directory
    '''

    colnames = ';'.join(dat.columns)
    coltype_pandas = dat.dtypes.map(str).tolist()
    coltype_map = {'int64' : 'numeric', 'int32' : 'numeric', 'float64' : 'numeric', 'float32' : 'numeric', 'object' : 'character'}
    coltype_easyqc = [coltype_map[c] for c in coltype_pandas]
    coltype_easyqc = ";".join(coltype_easyqc)

    f.write("#### EasyQC-script to perform study-level and meta-level QC\n")
    f.write("#### 0. Setup:\n")
    f.write(f'''DEFINE   --pathOut {args.outprefix}
--strMissing NA
--strSeparator COMMA
--acolIn {colnames}
--acolInClasses {coltype_easyqc}
''')

    f.write(f'''EASYIN --fileIn {tmpcsvout}\n''')

def write_ecf_sanitychecks(f, args):
    '''
    Write main portion of ecf file which filters stuff
    '''

    if args.toest is not None:
        effects = args.toest
    else:
        effects = dat['estimated_effects'][0]
    effects = effects.split("_")

    f.write('''START EASYQC
## Make alleles capitalized
EDITCOL --rcdEditCol toupper(A1) --colEdit A1
EDITCOL --rcdEditCol toupper(A2)  --colEdit A2

#### 1. Sanity checks:
## Filter out SNPs with missing values
CLEAN --rcdClean !(A1%in%c('A','C','G','T')) --strCleanName numDrop_invalid_a1 --blnWriteCleaned 0
CLEAN --rcdClean !(A2%in%c('A','C','G','T')) --strCleanName numDrop_invalid_a2 --blnWriteCleaned 0
CLEAN --rcdClean is.na(A1)&is.na(A2) --strCleanName numDrop_Missing_Alleles --blnWriteCleaned 0
CLEAN --rcdClean is.na(SNP) --strCleanName numDrop_Missing_SNP --blnWriteCleaned 0
CLEAN --rcdClean is.na(f) --strCleanName numDrop_Missing_EAF --blnWriteCleaned 0
CLEAN --rcdClean f<0|f>1 --strCleanName numDrop_invalid_EAF --blnWriteCleaned 0
#CLEAN  --rcdClean !CHR%in%c(1:22,NA) --strCleanName numDropSNP_ChrXY --blnWriteCleaned 1\n'''
    )


    for effect in effects:
        f.write(f'''
CLEAN --rcdClean is.na(theta_{effect}) --strCleanName numDrop_Missing_theta_{effect} --blnWriteCleaned 0
CLEAN --rcdClean is.na(se_{effect}) --strCleanName numDrop_Missing_se_{effect} --blnWriteCleaned 0
CLEAN --rcdClean se_{effect}<=0|se_{effect}==Inf|se_{effect}>=10 --strCleanName numDrop_invalid_se_{effect} --blnWriteCleaned 0
CLEAN --rcdClean abs(theta_{effect})==Inf --strCleanName numDrop_invalid_theta_{effect} --blnWriteCleaned 0\n
ADDCOL --rcdAddCol 2*pnorm(q=abs(z_{effect}), lower.tail=FALSE) --colOut PVAL_{effect}
''')

def write_ecf_filtering(f, args, dat):

    if args.af_ref is not None:
        print("Using reference AFs from {args.af_ref}")
        af_ref = args.af_ref
    else:
        af_ref = "/var/genetics/ukb/linner/EA3/EasyQC_HRC/EASYQC.ALLELE_FREQUENCY.MAPFILE.HRC.chr1_22_X.LET.FLIPPED_ALLELE_1000G+UK10K.txt"

    f.write('''#### 2. Prepare files for filtering and apply minimum thresholds:
    ''')

    if args.toest is not None:
        effects = args.toest
    else:
        effects = dat['estimated_effects'][0]
    effects = effects.split("_")

    for effect in effects:
        f.write(f'''
ADDCOL --rcdAddCol round((2*f*(1-f)*se_{effect}^2)^(-1)) --colOut n_{effect}\n
''')
    f.write(f'''
## Exclude monomorphic SNPs:
CLEAN --rcdClean (f==0)|(f==1) --strCleanName numDrop_Monomorph --blnWriteCleaned 0
## Exclude SNPs with low MAF
CLEAN --rcdClean f<{args.maf} | f>1-{args.maf} --strCleanName numDrop_MAF_{args.maf} --blnWriteCleaned 0
'''
    )
    if args.hwe is not None:
        f.write(f'''
## Filter based on HWE:
CLEAN --rcdClean hwe_p<1e-6 --strCleanName numDrop_hwe --blnWriteCleaned 0
'''
        )

    if args.info is not None:
        f.write(f'''
## Filter based on imputation quality:
CLEAN --rcdClean info_r2<0.99 --strCleanName numDrop_infor2 --blnWriteCleaned 0
CLEAN --rcdClean callrate<0.99 --strCleanName numDrop_callrate --blnWriteCleaned 0
'''
        )
    # loop through rgs
    rgpairs = get_rg_pairs(effects)
    if len(rgpairs) > 0:
        for pair in rgpairs:
            f.write(f'''
CLEAN --rcdClean rg_{pair[0]}_{pair[1]}>mean(rg_{pair[0]}_{pair[1]},na.rm=T) + 6 * sd(rg_{pair[0]}_{pair[1]},na.rm=T) --strCleanName numDrop_rg_greater_6sd_{pair[0]}_{pair[1]} --blnWriteCleaned 0
CLEAN --rcdClean rg_{pair[0]}_{pair[1]}<mean(rg_{pair[0]}_{pair[1]},na.rm=T) - 6 * sd(rg_{pair[0]}_{pair[1]},na.rm=T) --strCleanName numDrop_rg_less_6sd_{pair[0]}_{pair[1]} --blnWriteCleaned 0\n
''')

    f.write('''
HARMONIZEALLELES  --colInA1 A1 --colInA2 A2
''')

    if not args.cptid:
        f.write(f'''
#### 4. Harmonization of marker names (compile 'cptid')
CREATECPTID --fileMap /var/genetics/ukb/linner/EA3/EasyQC_HRC/EASYQC.RSMID.MAPFILE.HRC.chr1_22_X.txt
    --colMapMarker rsmid
    --colMapChr chr
    --colMapPos pos
    --colInMarker SNP
    --colInA1 A1
    --colInA2 A2
    --colInChr CHR
    --colInPos BP
    --blnUseInMarker 1
''')

    f.write(f'''
#### 5.Filter duplicate SNPs
## Aim: For duplicate SNPs keep only the duplicate with highest N
## Dropped duplicates to be written to *duplicates.txt
CLEANDUPLICATES --colInMarker cptid --strMode samplesize --colN n_{effects[0]}


#### 6. AF Checks
## Merge with file containing AFs for 1kG
MERGE    --colInMarker cptid
    --fileRef {af_ref}
    --acolIn ChrPosID;a1;a2;freq1
    --acolInClasses character;character;character;numeric
    --strRefSuffix .ref
    --colRefMarker ChrPosID
    --blnWriteNotInRef 1
    --blnInAll 0
    --blnRefAll 0

ADDCOL --rcdAddCol freq1.ref --colOut EAF.ref\n
    ''')


    beta_cols = ['theta_' + effect for effect in effects]
    z_cols = ['z_' + effect for effect in effects]
    beta_cols_str = ';'.join(beta_cols)
    z_cols_str = ';'.join(z_cols)
    f.write(f'''
## Adjust alleles to all be on the forward strand and to match the reference sample (happens before AFcheck plot!)
## All mismatches will be removed (e.g. A/T in input, A/C in reference)
ADJUSTALLELES  --colInA1 A1 --colInA2 A2
    --colInFreq f 
    --acolInBeta {beta_cols_str};{z_cols_str}
    --colRefA1 a1.ref --colRefA2 a2.ref
    --blnRemoveMismatch 1 --blnWriteMismatch 1
    --blnRemoveInvalid 1 --blnWriteInvalid 1
    --blnMetalUseStrand 1
''')

    
def make_plots(f, args, dat):

    '''
    Make the easyqc plots
    '''

    f.write('''
#### 9. Plotting
ADDCOL --rcdAddCol sqrt(f*(1-f)) --colOut normalized_f
ADDCOL --rcdAddCol abs(f-EAF.ref) --colOut DAF

## Compare allele frequencies to those in the reference sample
## blnPlotAll 0 --> only outlying SNPs with |Freq-Freq.ref|>0.2 will be plotted (way less computational time)
AFCHECK --colInFreq f --colRefFreq EAF.ref
    --numLimOutlier 0.2 --blnRemoveOutlier 1 --blnPlotAll 0
    --strXlab Reference allele frequency --strYlab Observed Allele Frequency
''')

    if args.toest is not None:
        effects = args.toest
    else:
        effects = dat['estimated_effects'][0]
    effects = effects.split("_")


    for effect in effects:
        f.write(f'''
QQPLOT   --acolQQPlot PVAL_{effect} --numPvalOffset 0.05 --strMode subplot --strTitle {effect.title()}
SPLOT  --rcdSPlotX normalized_f --rcdSPlotY se_{effect}  --strPlotName sef_{effect}
SPLOT --rcdSPlotX f --rcdSPlotY n_{effect}
''')


def finish_ecf(f, args, dat):

    colnames = ';'.join(dat.columns)

    if args.toest is not None:
        effects = args.toest
    else:
        effects = dat['estimated_effects'][0]
    effects = effects.split("_")

    pval_effects = ['PVAL_' + effect for effect in effects]
    n_col_names = ['n_' +  effect for effect in effects]
    pval_cols = ';'.join(pval_effects)
    n_cols = ';'.join(n_col_names)
    f.write(f'''
# write output
GETCOLS --acolOut cptid;{colnames};{pval_cols};{n_cols};EAF.ref
WRITE --strPrefix CLEANED. --strMissing . --strMode gz\n

STOP EASYQC''')



def run_rscript(ecfpath, tmpdir):

    '''
    Writes the temporary R script to
    run the ecf file
    '''

    rcode = '''
#!/usr/bin/env Rscript
# Import EasyQC package (from online source if necessary)
tryCatch(library("EasyQC"),
  error = function(e) {
    dir.create("easyqc_libraries", showWarnings=FALSE)
    .libPaths("easyqc_libraries")
    install.packages(pkgs="http://homepages.uni-regensburg.de/~wit59712/easyqc/EasyQC_9.2.tar.gz",
                     lib="easyqc_libraries/", repo=NULL, type="source")
    library("EasyQC")
  })
library(EasyQC)\n''' + f"EasyQC('{ecfpath}')"

    with open(f"{tmpdir}/runecf.R", "w") as f:
        f.write(rcode)

    
    os.system(f'Rscript --vanilla {tmpdir}/runecf.R')

def filter_SNPs(args):
    '''
    Filters out the abnormal looking SNPs in the f vs. Neff plots from QC
    '''
    if args.toest is not None:
        effects = args.toest
    else:
        effects = dat['estimated_effects'][0]
    effects = effects.split("_")

    ## filter SNPs
    ss = pd.read_csv(f"{args.outprefix}/CLEANED.out.gz", delim_whitespace=True)
    ss.to_csv(f"{args.outprefix}/CLEANED.unfilt.out.gz", sep = " ") # save copy
    
    def drop_SNPs(effect, ss):
        ss["f_rounded"] = ss["f"].round(2) # round f to 2 d.p.
        dat_rounded = ss.loc[:, [f'n_{effect}', "f_rounded"]].groupby("f_rounded").mean().rename(columns={f'n_{effect}': "n_mean"}) # calculate mean n_{effect} for each bin
        dat_rounded["sd"] = ss.loc[:, [f'n_{effect}', "f_rounded"]].groupby("f_rounded").std() # calculate sd for each bin
        ss_final = ss.merge(dat_rounded, on = "f_rounded", how = "left") # merge
        ss_final["lower"] = ss_final["n_mean"] - 5 * ss_final["sd"] # calculate lower bound
        ss_final["upper"] = ss_final["n_mean"] + 5 * ss_final["sd"] # calculate upper bound
        ss_final = ss_final[(ss_final[f'n_{effect}'] > ss_final["lower"]) & (ss_final[f'n_{effect}'] < ss_final["upper"])] # filter SNPs not within bounds
        snps_dropped = len(ss.index) - len(ss_final.index)
        print(f'{snps_dropped} SNPs did not fall within mean n_{effect} +- 5 sd.')
        ss_final.drop(["n_mean", "lower", "upper", "sd", "f_rounded"], axis = 1, inplace = True)
        return(ss_final)
        
    # drop SNPs based on direct N
    ss_final = drop_SNPs("direct", ss)
    # repeat for averageparental N if applicable
    if "averageparental" in effects:
        ss_final = drop_SNPs("averageparental", ss_final)
    # save
    ss_final.to_csv(f"{args.outprefix}/CLEANED.out.gz", sep = " ")

    ## plotting
    for effect in effects:
        plt.plot(ss_final["f"], ss_final[f"n_{effect}"], 'o')
        plt.xlabel("f")
        plt.ylabel(f"n_{effect}")
        plt.savefig(f"{args.outprefix}/out.sp.{effect}.clean.png")
        plt.clf()

def run_ldsc_rg(args):

    eur_w_ld_chr = "/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
    merge_alleles = "/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"
    ldsc_path = "/var/genetics/tools/ldsc/ldsc"

    act = "/disk/genetics/pub/python_env/anaconda2/bin/activate"
    pyenv = "/disk/genetics/pub/python_env/anaconda2/envs/ldsc"
    
    files = glob.glob(args.outprefix + '/CLEANED.out*.gz')
    files.sort()
    filein = files[0]
    dat = pd.read_csv(filein, delim_whitespace=True)

    subprocess.run(f'''
# Activating ldsc environment
source {act} {pyenv}

# munging data
python {ldsc_path}/munge_sumstats.py \
    --sumstats {filein} \
    --merge-alleles {merge_alleles} \
    --out {args.outprefix}/munged_ecf \
    --signed-sumstats z_population,0 --p PVAL_population --N-col n_population

# This for loop syntax is Bash only
python {ldsc_path}/ldsc.py \
    --rg {args.outprefix}/munged_ecf.sumstats.gz,{args.ldsc_ref} \
    --ref-ld-chr {eur_w_ld_chr} \
    --w-ld-chr {eur_w_ld_chr} \
    --out {args.outprefix}/refldsc
    ''',
    shell=True, check=True,
    executable='/usr/bin/bash')




if __name__ == '__main__':
    
    # Parse arguments
    parser = argparse.ArgumentParser()
    parser.add_argument('datapath', type=str, 
                        help='''Path to raw data. * symbol is wildcard
                        if extension is hdf5 then it reads as such, otherwise
                        it assumes it is a txt file delimited by spaces or tabs''')
    parser.add_argument('--effects', type = str, default = None,
    help = '''
    What are the effect names in the dataset inputted. Seperated by underscores. 
    Default is to infer what the hdf5 file or txt file has.
    ''')
    parser.add_argument('--toest', type = str, default = None,
    help = '''
    If anything is passed to this, the estimates will be transformed into this effect.
    ''')
    parser.add_argument('--outprefix', default = "./", type = str, help = "Output folder. If doesn't exist, script will create it.")
    parser.add_argument('--cptid', default = False, action = 'store_true', 
    help = "If passed, the SNP identifier for the data is assumed to be chromosome + bp.")
    parser.add_argument('--hwe', type = str,
    help = "If passed, the hwe files will be read and also QC-ed for. Filtered at 1e-6")
    parser.add_argument('--info', type = str,
    help = "If passed, the info files will be read and also QC-ed for. Filtered at 0.99 for for R2 and call rate")
    
    parser.add_argument('-maf', '--maf-thresh', dest = "maf", type = float, default = 0.01,
    help = """The threshold of minor allele frequency. All SNPs below this threshold
    are dropped.""")
    parser.add_argument('-mac', '--mac-thresh', dest = "mac", type = float, default = 25,
    help = """The threshold of minor allele count. All SNPs below this threshold
    are dropped.""")

    # variable names
    parser.add_argument('--bim', default = "bim", type = str, help = "Name of bim column")
    parser.add_argument('--bim_chromosome', default = 0, type = int, help = '''Column index of Chromosome in BIM variable. If set to 99 
the reader will try and infer the chromosome number from the file name.''')
    parser.add_argument('--bim_rsid', default = 1, type = int, help = "Column index of SNPID (RSID) in BIM variable")

    parser.add_argument('--rsid_readfrombim', type = str, 
                        help = '''Needs to be a comma seperated string of filename, BP-position, SNP-position, seperator.
                        If provided the variable bim_snp wont be used instead rsid's will be read
                        from the provided file set.''')
    parser.add_argument('--bim_bp', default = 2, type = int, help = "Column index of BP in BIM variable")
    parser.add_argument('--bim_a1', default = 3, type = int, help = "Column index of Chromosome in A1 variable")
    parser.add_argument('--bim_a2', default = 4, type = int, help = "Column index of Chromosome in A2 variable")

    parser.add_argument('--estimate', default = "estimate", type = str, help = "Name of estimate column")
    parser.add_argument('--estimate_ses', default = "estimate_ses", type = str, help = "Name of estimate_ses column")
    parser.add_argument('--N', default = "N_L", type = str, help = "Name of N column")
    parser.add_argument('--estimate_covariance', default = "estimate_covariance", type = str, help = "Name of estimate_covariance column")
    parser.add_argument('--freqs', default = "freqs", type = str, help = "Name of freqs column")

    parser.add_argument('--sigma2', default = "sigma2", type = str, help = "Name of sigma2 column")
    parser.add_argument('--tau', default = "tau", type = str, help = "Name of tau column")

    parser.add_argument('--ldsc-ref', default = None, type = str, help = "Name of reference GWAS sample to run ldsc on. Must be munged")
    parser.add_argument('--af-ref', default = None, type = str, help = "File path to reference AFs")
    parser.add_argument('--altphenotypicvar', default = False, 
    action='store_true', help = "IF passed phenotypic variance is calculated by adding sigma_0, sigma_1 and sigma_2")


    parser.add_argument('--ldsc-outprefix', default = "./", type = str, 
    help = "Name of where to save ldsc log output")

    parser.add_argument('--phvar', type = float, 
    help = '''What is the phenotypic variance of the dataset. If not passed, the phvar will be inferred if it is 
    an file.''')

    parser.add_argument('--normfiles', default=True, action='store_false',
    help = '''Should all files from output directory specified be removed before running analysis.''')
    
    parser.add_argument('--binary', action='store_true', default=False,
    help = 'Is the phenotype a binary phenotype. If so the normalization is different.')
    
    args = parser.parse_args()

    if args.normfiles:
        files = glob.glob(args.outprefix + '/*')
        print("Deleting files...")
        print(files)
        for file in files:
            os.remove(file)
    # parsing
    dat = read_file(args)
    print(f'Initial number of observations: {dat.shape[0]}')
    dat = process_dat(dat, args)

    with tempfile.TemporaryDirectory() as csvout:

        tmpcsvout = csvout + '/out'
        dat.to_csv(tmpcsvout, index = False)

        with open(f"{args.outprefix}/clean.ecf", "w") as f:

            init_ecf(f, args, dat, tmpcsvout)
            write_ecf_sanitychecks(f, args)
            write_ecf_filtering(f, args, dat)
            make_plots(f, args, dat)
            finish_ecf(f, args, dat)

        run_rscript(f"{args.outprefix}/clean.ecf", csvout)

    # filter SNPs that have abnormal effective Ns for their given AFs
    filter_SNPs(args)

    if args.ldsc_ref is not None:
        run_ldsc_rg(args)
