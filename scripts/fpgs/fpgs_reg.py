import pandas as pd
import numpy as np
import argparse
import subprocess
import statsmodels.formula.api as smf


def run_fpgs_reg(args):

    '''
    Run the usual fpgs regression
    '''

    runstr = f'''
python {args.outpath}\
--pgs {args.pgs} \
--phenofile {args.phenofile} \
--pgsreg-r2 
'''

    if args.pgsreg_r2:
        runstr += "--pgsreg-r2"

    subprocess.run(runstr)


def run_logistic_reg(args):

    pgs = pd.read_csv(args.pgs, delim_whitespace=True)
    phenofile = pd.read_csv(args.phenofile, delim_whitespace=True, names = ['FID', 'IID', 'pheno'])
    regvars = [c for c in pgs.columns if c not in ['FID', 'IID']]

    dat = pd.merge(pgs, phenofile, on = 'IID', how='inner')

    logreg = smf.logit('pheno~' + '+'.join(regvars), data=dat).fit()




if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('outpath', type=str, 
                        help='''Output path/prefix''')
    parser.add_argument('--pgs', type=str, help="PGS file path from fpgs.py in SNIPAR")
    parser.add_argument('--phenofile', type=str, help="Path to phenotype file.")
    parser.add_argument('--pgsreg-r2', type=bool, action='store_true', help="Should R2 be reported")
    parser.add_argument('--logistic', type=bool, action='store_true', help="Should regression be a logistic regression")
    args = parser.parse_args()



