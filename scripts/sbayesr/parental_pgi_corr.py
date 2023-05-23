import numpy as np
import pandas as pd
import argparse
from scipy import stats

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('pgi', type=str, 
                        help='''Path to pgi scores''')

    parser.add_argument('--pedigree', type=str, default='/var/genetics/data/mcs/private/latest/raw/downloaded/NCDS_SFTP_1TB_1/imputed/imputed_parents/pedigree.txt',
                        help='''Path to pedigree file''')
    
    parser.add_argument('--outprefix', type=str, default='.',
                        help='''Output prefix''')
    args = parser.parse_args()

    pgi = pd.read_csv(args.pgi, delim_whitespace=True)
    pgi['IID'] = pgi['IID'].astype('str')

    pedigree = pd.read_csv(
        args.pedigree,
        delim_whitespace=True
    )

    pedigree = pedigree[['IID', 'MOTHER_ID', 'FATHER_ID']]

    bothparents = pedigree.loc[(~pedigree['MOTHER_ID'].str.endswith('__M') & ~pedigree['FATHER_ID'].str.endswith('__P')),['MOTHER_ID', 'FATHER_ID']]
    bothparents['FATHER_ID'] = bothparents['FATHER_ID'].astype('str')
    bothparents['MOTHER_ID'] = bothparents['MOTHER_ID'].astype('str')
    
    dat = pd.merge(bothparents, pgi.rename(columns = {'SCORE' : 'FATHER_SCORE'}), left_on='FATHER_ID', right_on='IID', how='inner')
    dat = dat.drop(['IID', 'FID'], axis=1)
    dat = pd.merge(dat, pgi.rename(columns = {'SCORE' : 'MOTHER_SCORE'}), left_on='MOTHER_ID', right_on='IID', how='inner')
    dat = dat.drop(['IID', 'FID'], axis=1)
    ncomplete = (~(dat['MOTHER_SCORE'].isna()) & ~(dat['FATHER_ID'].isna()))
    print(f'Number of complete observations: {ncomplete.sum()}')

    corr = stats.pearsonr(dat['MOTHER_SCORE'], dat['FATHER_SCORE'])
    corr_se = np.sqrt((1 - corr[0])/(ncomplete.sum() - 2))
    print(f'Correlation Coefficient: {corr[0]}, SE: {corr_se},  P-value: {corr[1]}')

    corrarray = np.array((corr[0], corr_se))
    np.savetxt(args.outprefix + '.parentalcorr', corrarray)





 