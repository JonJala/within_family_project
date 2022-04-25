import pandas as pd
import numpy as np
import argparse
import os
import statsmodels.formula.api as smf
from tables import Description


def run_fpgs_reg(args):

    '''
    Run the usual fpgs regression
    '''

    print('Running fpgs.py script...')

    runstr = f'''python /homes/nber/harij/gitrepos/SNIPar/fPGS.py {args.outpath} \
--pgs {args.pgs} \
--phenofile {args.phenofile}'''

    if args.pgsreg_r2:
        runstr += " --pgsreg-r2"

    print(runstr)

    os.system(runstr)


def run_logistic_reg(args):

    print("Running logistic regression...")

    pgs = pd.read_csv(args.pgs, delim_whitespace=True)
    phenofile = pd.read_csv(args.phenofile, delim_whitespace=True, names = ['FID', 'IID', 'pheno'])
    regvars = [c for c in pgs.columns if c not in ['FID', 'IID']]
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

    outdat.to_csv(args.outpath + '.pgs_effects.txt', sep = ' ', header = False)




if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('outpath', type=str, 
                        help='''Output path/prefix''')
    parser.add_argument('--pgs', type=str, help="PGS file path from fpgs.py in SNIPAR")
    parser.add_argument('--phenofile', type=str, help="Path to phenotype file.")
    parser.add_argument('--pgsreg-r2', action='store_true',  help="Should R2 be reported")
    parser.add_argument('--logistic', type=str,  help="Should regression be a logistic regression")
    args = parser.parse_args()


    if args.logistic == '1':
        run_logistic_reg(args)
    else:
        run_fpgs_reg(args)


