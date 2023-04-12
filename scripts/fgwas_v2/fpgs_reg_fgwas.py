import pandas as pd
import numpy as np
import argparse
import os
import statsmodels.formula.api as smf
from tables import Description
import tempfile

def run_fpgs_reg(args):

    '''
    Run the usual fpgs regression
    '''

    print('Running fpgs.py script...')

    runstr = f'''PYTHONPATH={args.sniparpath} {args.sniparpath}/snipar/scripts/pgs.py {args.outpath} \
--pgs {args.snipar_pgs} \
--gen_models {args.gen_models} \
--covariates {args.covariates} \
--phenofile {args.phenofile}'''


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


if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('outpath', type=str, 
                        help='''Output path/prefix''')
    parser.add_argument('--snipar_pgs', type=str, help="Raw PGS file path output from fpgs.py in SNIPAR")
    parser.add_argument('--pgs', type=str, help="PGS file path from fpgs.py in SNIPAR with covariates attached")
    parser.add_argument('--phenofile', type=str, help="Path to phenotype file.")
    parser.add_argument('--logistic', type=str,  help="Should regression be a logistic regression")
    parser.add_argument('--ols', type=str,  help="Should regression be an OLS regression")
    parser.add_argument('--kin', type=str, default=None,  help='''Pass in path to kinship file. 
    If passed then coeff comes from full sample, and R2 comes from unrelated sample.''')
    parser.add_argument('--sniparpath', type=str,  help="Path to snipar installation")
    parser.add_argument('--gen_models', type=str,  help="Which multi-generational models should be fit in SNIPar pgs.py. 1 generation or 2 generation.")
    parser.add_argument('--covariates', type=str,  help="Path to covariates file")
    parser.add_argument('--covariates_only', action='store_true', default = False, help = '''Covariates-only regression''')
    
    args = parser.parse_args()

    if args.logistic == '1':
        run_logistic_reg(args)
    elif args.ols == '1':
        run_ols_reg(args)
    else:
        run_fpgs_reg(args)


