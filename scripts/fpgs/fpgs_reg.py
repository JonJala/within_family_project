import pandas as pd
import numpy as np
import argparse
import os
import statsmodels.formula.api as smf
from tables import Description
import tempfile

def fpgs_reg_dat(snipar_pgs, phenofile, outpath, sniparpath, gen_models, covariates):
    '''
    Core fpgs function with dataframes as arguments
    '''
    
    with tempfile.TemporaryDirectory() as dirout:
        phenofile.to_csv(dirout + '/pheno.txt', sep = ' ', index=False)
        snipar_pgs.to_csv(dirout + '/pgs.txt', sep = ' ', index=False)

        runstr = f'''PYTHONPATH={sniparpath} {sniparpath}/snipar/scripts/pgs.py {outpath} \
    --pgs {dirout + '/pgs.txt'} \
    --gen_models {gen_models} \
    --covar {covariates} \
    --phenofile {dirout}/pheno.txt'''

    print(runstr)

    os.system(runstr)

def run_fpgs_reg(args):

    '''
    Run the usual fpgs regression
    '''

    print('Running pgs.py...')

    with tempfile.TemporaryDirectory() as dirout:
        pgs = pd.read_csv(args.pgs, delim_whitespace=True)
        pheno = pd.read_csv(args.phenofile, delim_whitespace=True, names = ["FID", "IID", "pheno"]).drop("FID", axis = 1)
        merged = pd.merge(pgs, pheno, on = "IID", how = 'inner')

        # create file with just pgis
        pgs_only = merged[["FID", "IID", "FATHER_ID", "MOTHER_ID", "proband", "paternal", "maternal"]] 
        pgs_only.to_csv(dirout + '/pgs.txt', sep = ' ', index=False, na_rep='NA')
        
        # create file with just covariates
        covar = merged.filter(regex="FID|IID|age|sex|V")
        if args.dataset == "mcs":
            covar = covar[covar.columns.drop(list(covar.filter(regex="age")))] # drop age covariates if MCS
        if args.phenoname == "aafb" or args.phenoname == "agemenarche":
            covar = covar[covar.columns.drop(list(covar.filter(regex="sex")))] # drop sex covariates if phenotype only has one sex represented
        covar.to_csv(dirout + '/covar.txt', sep = '\t', index=False, na_rep = 'NA')

        # create file with just pheno
        phenotype = merged[["FID", "IID", "pheno"]]
        phenotype["FID"] = phenotype["IID"]
        phenotype.to_csv(dirout + '/pheno.txt', sep = ' ', index=False, na_rep = 'NA', header = None)

        if args.binary == 1:
            runstr = f'''PYTHONPATH={args.sniparpath} {args.sniparpath}/snipar/scripts/pgs.py {args.outpath} \
        --pgs {dirout}/pgs.txt \
        --covar {dirout}/covar.txt \
        --phenofile {dirout}/pheno.txt'''
        else:
            runstr = f'''PYTHONPATH={args.sniparpath} {args.sniparpath}/snipar/scripts/pgs.py {args.outpath} \
        --pgs {dirout}/pgs.txt \
        --covar {dirout}/covar.txt \
        --phenofile {dirout}/pheno.txt \
        --scale_phen '''

        print(runstr)

        os.system(runstr)

def ols_reg_dat(pgs, phenofile):
    '''
    Core OLS function
    '''
    regvars = [c for c in pgs.columns if c not in ['FID', 'IID', 'FATHER_ID', 'MOTHER_ID']]
    dat = pd.merge(pgs, phenofile, on = 'IID', how='inner')

    olsreg = smf.ols('pheno~' + '+'.join(regvars), data=dat).fit()

    ests = olsreg.params[1:]

    ses = olsreg.bse[1:]
    r2 = olsreg.rsquared

    outdat = pd.DataFrame(
        {
            'ests' : ests,
            'ses' : ses,
            'r2' : r2
        }
    )


    return outdat

def run_ols_reg(args):

    '''
    Run OLS. Wrapper around core ols function.
    '''

    print("Running OLS regression...")

    pgs = pd.read_csv(args.pgs, delim_whitespace=True)
    phenofile = pd.read_csv(args.phenofile, delim_whitespace=True, names = ['FID', 'IID', 'pheno'])

    outdat = ols_reg_dat(pgs, phenofile)

    print(f'Saving to {args.outpath}.pgs_effects.txt')
    outdat.to_csv(args.outpath + '.pgs_effects.txt', sep = ' ', header = False)

def logistic_reg_dat(pgs, phenofile):
    '''
    Core logistic regression function. Dataframes as arguments.
    '''
    regvars = [c for c in pgs.columns if c not in ['FID', 'IID', 'FATHER_ID', 'MOTHER_ID']]
    regvars = [c for c in regvars if c not in ['age2', 'age3', 'agesex', 'age2sex', 'age3sex']]

    dat = pd.merge(pgs, phenofile, on = 'IID', how='inner')

    logreg = smf.logit('pheno~' + '+'.join(regvars), data=dat).fit()

    ests = logreg.params[1:]

    ses = logreg.bse[1:]
    r2 = logreg.prsquared

    outdat = pd.DataFrame(
        {
            'ests' : ests,
            'ses' : ses,
            'r2' : r2
        }
    )

    return outdat


def run_logistic_reg(args):

    print("Running logistic regression...")

    pgs = pd.read_csv(args.pgs, delim_whitespace=True)
    phenofile = pd.read_csv(args.phenofile, delim_whitespace=True, names = ['FID', 'IID', 'pheno'])

    outdat = logistic_reg_dat(pgs, phenofile)

    print(f'Saving to {args.outpath}.pgs_effects.txt')
    outdat.to_csv(args.outpath + '.pgs_effects.txt', sep = ' ', header = False)


def run_subset_regs(args):
    '''
    Run fpgs for one subset of data (usually the entire intended sample
    with related individuals in it) to get the coefficients. Then run data on
    different subsample (usually sample of unrelated individuals) to estimate
    R2
    '''


    kin = pd.read_csv('/var/genetics/data/ukb/private/latest/processed/relatives/ukb_relatives_king.kin0', delim_whitespace=True)
    relatedids = kin[['FID2', 'ID2']].rename(columns = {'FID2' : 'FID', 'ID2' : 'IID'})
    relatedids['fid_iid'] = relatedids['FID'].astype(str) + '_' + relatedids['IID'].astype(str)
    pgs = pd.read_csv(args.pgs, delim_whitespace=True)
    snipar_pgs = pd.read_csv(args.snipar_pgs, delim_whitespace=True)
    phenofile = pd.read_csv(args.phenofile, delim_whitespace=True, names = ['FID', 'IID', 'pheno'])
    phenofile['fid_iid'] = phenofile['FID'].astype(str) + '_' + phenofile['IID'].astype(str)

    # getting coeff
    phenofile_r2 = phenofile.loc[~(phenofile.fid_iid.isin(relatedids.fid_iid))] # unrelated individuals

    with tempfile.TemporaryDirectory() as dirout:
        if args.logistic == '1':
            fpgsresult = logistic_reg_dat(pgs, phenofile) # logistic regression on all individuals using pgs file with covariates
        else:
            fpgs_reg_dat(snipar_pgs, phenofile, dirout + '/fpgsout', args.sniparpath, args.gen_models, args.covariates) # use snipar to run fpgs regression on related individuals
            fpgsresult = pd.read_csv(dirout + f'/fpgsout.{args.gen_models}.effects.txt', delim_whitespace=True, names = ['var', 'ests', 'ses'])
        
    # getting R2
    if args.logistic == '1':
        datout = logistic_reg_dat(pgs, phenofile_r2) # logistic regression on unrelated individuals using pgs file with covariates
    else:
        datout = ols_reg_dat(pgs, phenofile_r2) # ols regression on unrelated individuals using pgs file with covariates


    r2 = datout.r2[0]

    # joining coeffs and r2
    datout = pd.DataFrame({

        'ests' : fpgsresult['ests'],
        'ses' : fpgsresult['ses'],
        'r2' : r2
    })

    datout.index = fpgsresult['var']

    print(f'Saving to {args.outpath}.pgs_effects.txt')
    datout.to_csv(args.outpath + '.pgs_effects.txt', sep = ' ', header = False)


if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('outpath', type=str, 
                        help='''Output path/prefix''')
    parser.add_argument('--snipar_pgs', type=str, help="Raw PGS file path output from fpgs.py in SNIPAR")
    parser.add_argument('--pgs', type=str, help="PGS file path from fpgs.py in SNIPAR with covariates attached")
    parser.add_argument('--phenofile', type=str, help="Path to phenotype file.")
    parser.add_argument('--logistic', type=str,  help="Should regression be a logistic regression")
    parser.add_argument('--binary', type=str,  help="Is the outcome phenotype binary?")
    parser.add_argument('--ols', type=str,  help="Should regression be an OLS regression")
    parser.add_argument('--kin', type=str, default=None,  help='''Pass in path to kinship file. 
    If passed then coeff comes from full sample, and R2 comes from unrelated sample.''')
    parser.add_argument('--sniparpath', type=str,  help="Path to snipar installation")
    parser.add_argument('--gen_models', type=str,  help="Which multi-generational models should be fit in SNIPar pgs.py. 1 generation or 2 generation.")
    parser.add_argument('--covariates', type=str,  help="Path to covariates file")
    parser.add_argument('--dataset', type=str,  help="Which validation dataset is being used, ukb or mcs")
    parser.add_argument('--phenoname', type=str,  help="Phenotype name")
    
    args = parser.parse_args()

    if args.logistic == '1':
        run_logistic_reg(args)
    elif args.ols == '1':
        run_ols_reg(args)
    elif args.kin == '1':
        run_subset_regs(args)
    else:
        run_fpgs_reg(args)
        


