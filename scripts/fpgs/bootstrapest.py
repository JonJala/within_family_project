import pandas as pd
import numpy as np
import argparse
import subprocess
import tempfile
import statsmodels.api as sm
import tqdm

def resample(df, iidcol, iids):

    idx = iids.apply(lambda x: np.where(df[iidcol] == x)[0])
    return idx

def parse_name(name):

    nameout = name.split('/')[-1]
    nameout = nameout.split('.')[0]

    return nameout

def runpgi_reg(dfpgs, pheno):


    datols = pd.merge(dfpgs, pheno, on = ['IID'], how='inner')
    datols['const'] = 1.0
    reg = sm.OLS(
        endog=datols['pheno'], 
        exog=datols[[c for c in datols if c not in ['IID', 'FID_x', 'FID_y', 'pheno']]],
        missing='drop'
    ).fit()

    ests = reg.params
    ses = reg.HC0_se 
    r2 = reg.rsquared

    df = pd.DataFrame(
        {
            'vars' : [c for c in datols if c not in ['IID', 'FID_x', 'FID_y', 'pheno']], 
            'ests' : ests,
            'se' : ses
        }
    )

    df['rsq'] = r2

    return df


def bootstrap_inner(args):

    if args.bootstrapfunc == 's':
        bfunc = lambda x,y: x - y
    elif args.bootstrapfunc == 'd':
        bfunc = lambda x,y: x/y
    
    with tempfile.TemporaryDirectory() as tmpdir:

        pheno1 = pd.read_csv(args.phenofile, delim_whitespace=True, names=['FID', 'IID', 'pheno'])
        pgigroup1 = args.pgsgroup1.split(',')
        pgigroup2 = args.pgsgroup2.split(',')
        pnameg1f1 = parse_name(pgigroup1[0])
        pnameg1f2 = parse_name(pgigroup1[1])
        pnameg2f1 = parse_name(pgigroup2[0])
        pnameg2f2 = parse_name(pgigroup2[1])
        names = [
            f'{pnameg1f1}/{pnameg1f2}-{pnameg2f1}/{pnameg2f2}',
            f'{pnameg1f1}/{pnameg1f2}',
            f'{pnameg2f1}/{pnameg2f2}'
        ]

        pgigroup1f1 = pd.read_csv(pgigroup1[0], delim_whitespace=True)
        pgigroup1f2 = pd.read_csv(pgigroup1[1], delim_whitespace=True)
        pgigroup2f1 = pd.read_csv(pgigroup2[0], delim_whitespace=True)
        pgigroup2f2 = pd.read_csv(pgigroup2[1], delim_whitespace=True)

        iids = pgigroup1f1.loc[pgigroup1f1['IID'].isin(pheno1['IID']), 'IID']
        n = iids.shape[0]
        xout = np.zeros((3, args.bootstrap_niter))

        for i in tqdm(range(args.bootstrap_niter)):

            iids_sample = iids.sample(n, replace=True)
            newiids = np.arange(1, iids_sample.shape[0] + 1)

            pgig1f1_res = pgigroup1f1.iloc[resample(pgigroup1f1, 'IID', iids_sample)].sort_values(by='IID')
            pgig1f2_res = pgigroup1f2.iloc[resample(pgigroup1f2, 'IID', iids_sample)].sort_values(by='IID')
            pgig2f1_res = pgigroup2f1.iloc[resample(pgigroup2f1, 'IID', iids_sample)].sort_values(by='IID')
            pgig2f2_res = pgigroup2f2.iloc[resample(pgigroup2f2, 'IID', iids_sample)].sort_values(by='IID')
            pheno1_res = pheno1.iloc[resample(pheno1, 'IID', iids_sample)].sort_values(by='IID')

            # rename IIDS so that pgs script doesnt drop duplicates
            pgig1f1_res['IID'] = newiids
            pgig1f2_res['IID'] = newiids
            pgig2f1_res['IID'] = newiids
            pgig2f2_res['IID'] = newiids
            pheno1_res['IID'] = newiids

            pgig1f1_res['FID'] = pgig1f1_res['IID']
            pgig1f2_res['FID'] = pgig1f2_res['IID']
            pgig2f1_res['FID'] = pgig2f1_res['IID']
            pgig2f2_res['FID'] = pgig2f2_res['IID']
            pheno1_res['FID'] = pheno1_res['IID']

            
            resultg1f1 = runpgi_reg(pgig1f1_res, pheno1_res).iloc[:, 1]
            resultg1f2 = runpgi_reg(pgig1f2_res, pheno1_res).iloc[:, 1]
            resultg2f1 = runpgi_reg(pgig2f1_res, pheno1_res).iloc[:, 1]
            resultg2f2 = runpgi_reg(pgig2f2_res, pheno1_res).iloc[:, 1]
            
            resultg1f1 = pd.to_numeric(resultg1f1, errors='coerce')
            resultg1f2 = pd.to_numeric(resultg1f2, errors='coerce')
            resultg2f1 = pd.to_numeric(resultg2f1, errors='coerce')
            resultg2f2 = pd.to_numeric(resultg2f2, errors='coerce')

            xout[0, i] = ((resultg1f1/resultg1f2) - (resultg2f1/resultg2f2)).loc['proband']
            xout[1, i] = ((resultg1f1/resultg1f2)).loc['proband']
            xout[2, i] = ((resultg2f1/resultg2f2)).loc['proband']
    

    xout = pd.DataFrame(xout, index=names)
    return xout

def bootstrap_est(args):
    
    with tempfile.TemporaryDirectory() as tmpdir:
        pgigroup1 = args.pgsgroup1.split(',')
        pgigroup2 = args.pgsgroup2.split(',')
        pnameg1f1 = parse_name(pgigroup1[0])
        pnameg1f2 = parse_name(pgigroup1[1])
        pnameg2f1 = parse_name(pgigroup2[0])
        pnameg2f2 = parse_name(pgigroup2[1])
        names = [
            f'{pnameg1f1}/{pnameg1f2}-{pnameg2f1}/{pnameg2f2}',
            f'{pnameg1f1}/{pnameg1f2}',
            f'{pnameg2f1}/{pnameg2f2}'
        ]

        datg1f1 = pd.read_csv(pgigroup1[0], delim_whitespace=True)
        datg1f2 = pd.read_csv(pgigroup1[1], delim_whitespace=True)
        datg2f1 = pd.read_csv(pgigroup2[0], delim_whitespace=True)
        datg2f2 = pd.read_csv(pgigroup2[1], delim_whitespace=True)
        pheno = pd.read_csv(args.phenofile, delim_whitespace=True, names=['FID', 'IID', 'pheno'])

        datg1f1 = runpgi_reg(datg1f1, pheno).iloc[:, 1]
        datg1f2 = runpgi_reg(datg1f2, pheno).iloc[:, 1]
        datg2f1 = runpgi_reg(datg2f1, pheno).iloc[:, 1]
        datg2f2 = runpgi_reg(datg2f2, pheno).iloc[:, 1]

        datg1f1 = pd.to_numeric(datg1f1, errors='coerce')
        datg1f2 = pd.to_numeric(datg1f2, errors='coerce')
        datg2f1 = pd.to_numeric(datg2f1, errors='coerce')
        datg2f2 = pd.to_numeric(datg2f2, errors='coerce')

        ests_dif = ((datg1f1/datg1f2) - (datg2f1/datg2f2)).loc['proband']
        ests_g1ratio = ((datg1f1/datg1f2)).loc['proband']
        ests_g2ratio = ((datg2f1/datg2f2)).loc['proband']
        ests = [ests_dif, ests_g1ratio, ests_g2ratio]

    xout = bootstrap_inner(args) 
    ses = np.std(xout, axis=1)
    datout = pd.DataFrame({'est' : ests, 'se' : ses}, index=names)

    return datout


if __name__ == '__main__':
    
    parser = argparse.ArgumentParser()
    parser.add_argument('outpath', type=str, 
                        help='''Output path/prefix''')
    parser.add_argument('--pgs', type = str , help = '''
    Which pgs scores to use''')
    parser.add_argument('--pgs2', type=str, help = '''Second PGS file to use''')
    parser.add_argument('--phenofile', type=str, help = '''Phenotype file to use''')
    parser.add_argument('--phenofile2', type=str, help='''Second phenotype file''')
    parser.add_argument('--pgsgroup1', type=str, help='''PGS group 1. The direct/pop ratio will be
    constructed between these. Files seperated by comma''')
    parser.add_argument('--pgsgroup2', type=str, help='''PGS group 2. The direct/pop ratio will be
    constructed between these. Then that will be subtracted from the ratio constructed in group 1''')
    parser.add_argument('--pgsreg-r2', action='store_true', default=False, help='''Should R squares be reported''')
    parser.add_argument('--bootstrap-niter', default=1000, help='''Number of bootstrap iterations''')
    parser.add_argument('--bootstrapfunc', default='d', help='''Should estimates be divided (d) or subtracted (s). 
    Takes in s or d as possible arguments''')
    
    args = parser.parse_args()


    datout = bootstrap_est(args)
    datout['ci_lo'] = datout['est'] - 1.96 * datout['se']
    datout['ci_hi'] = datout['est'] + 1.96 * datout['se']
    datout.to_csv(args.outpath + '.bootests',  sep=' ')