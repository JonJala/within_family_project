import pandas as pd
import numpy as np
import argparse
import subprocess
import tempfile

def resample(df, iidcol, iids):

    idx = iids.apply(lambda x: np.where(df[iidcol] == x)[0])
    return idx


def runpgi_reg(pgs, phenofile, outpath, pgsreg_r2):


    pgireg_run = f'''
python /homes/nber/harij/gitrepos/SNIPar/fPGS.py {outpath} \
--pgs {pgs} \
--phenofile {phenofile}'''

    if pgsreg_r2:
        pgireg_run += ' --pgsreg-r2'

    subprocess.run(pgireg_run,
        shell=True, check=True,
        executable='/usr/bin/bash')

    if pgsreg_r2:
        colnames = ['variable', 'estimate', 'se', 'r2']
    else:
        colnames = ['variable', 'estimate', 'se']
    
    # subprocess.run(f'cat {outpath}.pgs_effects.txt',
    # shell = True, check=True, executable='/usr/bin/bash')

    df = pd.read_csv(outpath + '.pgs_effects.txt', delim_whitespace=True, 
            names = colnames)

    return df


def bootstrap_inner(args):

    if args.bootstrapfunc == 's':
        bfunc = lambda x,y: x - y
    elif args.bootstrapfunc == 'd':
        bfunc = lambda x,y: x/y
    
    with tempfile.TemporaryDirectory() as tmpdir:


        if args.phenofile2 is not None:
            
            pgi = pd.read_csv(args.pgs, delim_whitespace=True)
            pheno1 = pd.read_csv(args.phenofile, delim_whitespace=True, names=['FID', 'IID', 'SCORE'])
            pheno2 = pd.read_csv(args.phenofile2, delim_whitespace=True, names=['FID', 'IID', 'SCORE'])
            iids = pgi.loc[pgi['IID'].isin(pheno1['IID']), 'IID']
            n = iids.shape[0]

            xout = np.zeros((1, args.bootstrap_niter))

            for i in range(args.bootstrap_niter):

                iids_sample = iids.sample(n, replace=True)
                newiids = np.arange(1, iids_sample.shape[0] + 1)

                pgi_res = pgi.iloc[resample(pgi, 'IID', iids_sample)].sort_values(by='IID')
                pheno1_res = pheno1.iloc[resample(pheno1, 'IID', iids_sample)].sort_values(by='IID')
                pheno2_res = pheno2.iloc[resample(pheno2, 'IID', iids_sample)].sort_values(by='IID')

                # rename IIDS so that pgs script doesnt drop duplicates
                pgi_res['IID'] = newiids
                pheno1_res['IID'] = newiids
                pheno2_res['IID'] = newiids

                pgi_res['FID'] = pgi_res['IID']
                pheno1_res['FID'] = pheno1_res['IID']
                pheno2_res['FID'] = pheno2_res['IID']

                
                pgi_res.to_csv(tmpdir + '.pgs', index=False, sep =' ' )
                pheno1_res.to_csv(tmpdir + '.pheno1', index=False, header=False, sep =' ')
                pheno2_res.to_csv(tmpdir + '.pheno2', index=False, header=False, sep =' ')
                
                result1 = runpgi_reg(tmpdir + '.pgs', tmpdir + '.pheno1', tmpdir, args.pgsreg_r2).iloc[:, 1].map(float)
                result2 = runpgi_reg(tmpdir + '.pgs', tmpdir + '.pheno2', tmpdir, args.pgsreg_r2).iloc[:, 1].map(float)
                result1 = pd.to_numeric(result1, errors='coerce')
                result2 = pd.to_numeric(result2, errors='coerce')
                xout[:, i] = bfunc(result1, result2)[0]


        elif args.pgs2 is not None:

            pgi = pd.read_csv(args.pgs, delim_whitespace=True)
            pheno1 = pd.read_csv(args.phenofile, delim_whitespace=True, names=['FID', 'IID', 'SCORE'])
            pgi2 = pd.read_csv(args.pgs2, delim_whitespace=True)
            iids = pgi.loc[pgi['IID'].isin(pheno1['IID']), 'IID']
            n = iids.shape[0]
            xout = np.zeros((1, args.bootstrap_niter))

            for i in range(args.bootstrap_niter):

                iids_sample = iids.sample(n, replace=True)
                newiids = np.arange(1, iids_sample.shape[0] + 1)

                print(i)
                pgi_res = pgi.iloc[resample(pgi, 'IID', iids_sample)].sort_values(by='IID')
                pgi2_res = pgi2.iloc[resample(pgi2, 'IID', iids_sample)].sort_values(by='IID')
                pheno1_res = pheno1.iloc[resample(pheno1, 'IID', iids_sample)].sort_values(by='IID')

                # rename IIDS so that pgs script doesnt drop duplicates
                pgi_res['IID'] = newiids
                pgi2_res['IID'] = newiids
                pheno1_res['IID'] = newiids

                pgi_res['FID'] = pgi_res['IID']
                pgi2_res['FID'] = pgi2_res['IID']
                pheno1_res['FID'] = pheno1_res['IID']

                pgi_res.to_csv(tmpdir + '.pgs', index=False, sep = ' ')
                pgi2_res.to_csv(tmpdir + '.pgs2', index=False, sep = ' ')
                pheno1_res.to_csv(tmpdir + '.pheno', index=False, header=False, sep = ' ')
                
                result1 = runpgi_reg(tmpdir + '.pgs', tmpdir + '.pheno', tmpdir, args.pgsreg_r2).iloc[:, 1]
                result2 = runpgi_reg(tmpdir + '.pgs2', tmpdir + '.pheno', tmpdir, args.pgsreg_r2).iloc[:, 1]
                result1 = pd.to_numeric(result1, errors='coerce')
                result2 = pd.to_numeric(result2, errors='coerce')
                xout[:, i] = bfunc(result1, result2)[0]

        elif (args.pgsgroup1 is not None) and (args.pgsgroup2 is not None):

            pheno1 = pd.read_csv(args.phenofile, delim_whitespace=True, names=['FID', 'IID', 'SCORE'])
            pgigroup1 = args.pgsgroup1.split(',')
            pgigroup2 = args.pgsgroup2.split(',')

            pgigroup1f1 = pd.read_csv(pgigroup1[0], delim_whitespace=True)
            pgigroup1f2 = pd.read_csv(pgigroup1[1], delim_whitespace=True)
            pgigroup2f1 = pd.read_csv(pgigroup2[0], delim_whitespace=True)
            pgigroup2f2 = pd.read_csv(pgigroup2[1], delim_whitespace=True)

            iids = pgigroup1f1.loc[pgigroup1f1['IID'].isin(pheno1['IID']), 'IID']
            n = iids.shape[0]
            xout = np.zeros((1, args.bootstrap_niter))

            for i in range(args.bootstrap_niter):

                iids_sample = iids.sample(n, replace=True)
                newiids = np.arange(1, iids_sample.shape[0] + 1)

                print(i)
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

                pgig1f1_res.to_csv(tmpdir + '.pgsg1f1', index=False, sep = ' ')
                pgig1f2_res.to_csv(tmpdir + '.pgsg1f2', index=False, sep = ' ')
                pgig2f1_res.to_csv(tmpdir + '.pgsg2f1', index=False, sep = ' ')
                pgig2f2_res.to_csv(tmpdir + '.pgsg2f2', index=False, sep = ' ')
                pheno1_res.to_csv(tmpdir + '.pheno', index=False, header=False, sep = ' ')
                
                resultg1f1 = runpgi_reg(tmpdir + '.pgsg1f1', tmpdir + '.pheno', tmpdir, args.pgsreg_r2).iloc[:, 1]
                resultg1f2 = runpgi_reg(tmpdir + '.pgsg1f2', tmpdir + '.pheno', tmpdir, args.pgsreg_r2).iloc[:, 1]
                resultg2f1 = runpgi_reg(tmpdir + '.pgsg2f1', tmpdir + '.pheno', tmpdir, args.pgsreg_r2).iloc[:, 1]
                resultg2f2 = runpgi_reg(tmpdir + '.pgsg2f2', tmpdir + '.pheno', tmpdir, args.pgsreg_r2).iloc[:, 1]
                
                resultg1f1 = pd.to_numeric(resultg1f1, errors='coerce')
                resultg1f2 = pd.to_numeric(resultg1f2, errors='coerce')
                resultg2f1 = pd.to_numeric(resultg2f1, errors='coerce')
                resultg2f2 = pd.to_numeric(resultg2f2, errors='coerce')
                
                xout[:, i] = ((resultg1f1/resultg1f2) - (resultg2f1/resultg2f2))[0]

    return xout

def bootstrap_est(args):

    if args.bootstrapfunc == 's':
        bfunc = lambda x,y: x - y
    elif args.bootstrapfunc == 'd':
        bfunc = lambda x,y: x / y
    
    with tempfile.TemporaryDirectory() as tmpdir:
        if args.phenofile2 is not None:
            dat1 = runpgi_reg(args.pgs, args.phenofile, tmpdir, args.pgsreg_r2).iloc[:, 1]
            dat2 = runpgi_reg(args.pgs, args.phenofile2, tmpdir, args.pgsreg_r2).iloc[:, 1]
            dat1 = pd.to_numeric(dat1, errors='coerce')
            dat2 = pd.to_numeric(dat2, errors='coerce')
            ests = np.array(bfunc(dat1, dat2))[0]
        elif args.pgs2 is not None:
            dat1 = runpgi_reg(args.pgs, args.phenofile, tmpdir, args.pgsreg_r2).iloc[:, 1]
            dat2 = runpgi_reg(args.pgs2, args.phenofile, tmpdir, args.pgsreg_r2).iloc[:, 1]
            dat1 = pd.to_numeric(dat1, errors='coerce')
            dat2 = pd.to_numeric(dat2, errors='coerce')
            ests = np.array(bfunc(dat1, dat2))[0]
        elif (args.pgsgroup1 is not None) and (args.pgsgroup2 is not None):
            pgigroup1 = args.pgsgroup1.split(',')
            pgigroup2 = args.pgsgroup2.split(',')

            import pdb; pdb.set_trace()
            datg1f1 = runpgi_reg(pgigroup1[0], args.phenofile, tmpdir, args.pgsreg_r2).iloc[:, 1]
            datg1f2 = runpgi_reg(pgigroup1[1], args.phenofile, tmpdir, args.pgsreg_r2).iloc[:, 1]
            datg2f1 = runpgi_reg(pgigroup2[0], args.phenofile, tmpdir, args.pgsreg_r2).iloc[:, 1]
            datg2f2 = runpgi_reg(pgigroup2[1], args.phenofile, tmpdir, args.pgsreg_r2).iloc[:, 1]

            datg1f1 = pd.to_numeric(datg1f1, errors='coerce')
            datg1f2 = pd.to_numeric(datg1f2, errors='coerce')
            datg2f1 = pd.to_numeric(datg2f1, errors='coerce')
            datg2f2 = pd.to_numeric(datg2f2, errors='coerce')

            ests = ((datg1f1/datg1f2) - (datg2f1/datg2f2))[0]

    xout = bootstrap_inner(args) 
    ses = np.std(xout, axis=1)
    datout = pd.DataFrame({'est' : ests, 'se' : ses})

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
    parser.add_argument('--bootstrap-niter', default=100, help='''Number of bootstrap iterations''')
    parser.add_argument('--bootstrapfunc', default='d', help='''Should estimates be divided (d) or subtracted (s). 
    Takes in s or d as possible arguments''')
    
    args = parser.parse_args()


    datout = bootstrap_est(args)
    datout['ci_lo'] = datout['est'] - 1.96 * datout['se']
    datout['ci_hi'] = datout['est'] + 1.96 * datout['se']
    datout.to_csv(args.outpath + '.bootests', index=False, sep=' ')