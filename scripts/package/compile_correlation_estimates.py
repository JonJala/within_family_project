import pandas as pd
import argparse

## compile marginal correlation estimates from sinpar into excel spreadsheet

parser=argparse.ArgumentParser()
parser.add_argument('--pheno', type=str, 
                    help='''Phenotype name''')
parser.add_argument('--cohorts', type=str, 
                    help='''Phenotype cohorts''')
args=parser.parse_args()

basepath = '/var/genetics/proj/within_family/within_family_project/'
phenotype = args.pheno
cohorts = args.cohorts.split(' ')

dat = pd.DataFrame(columns=['phenotype', 'cohort', 'corr', 'corr_se'])

# make table of results
for cohort in cohorts:

    print(f'Compiling results for {cohort}...')
    packageoutput = basepath + 'processed/qc/'
    
    # h2 from ldsc log
    path = packageoutput + cohort + '/' + phenotype + '/marginal_correlations.txt'
    corrs = pd.read_csv(path, sep=" ")
    corr = corrs["correlation"][0]
    se = corrs["S.E"][0]

    dat_tmp = pd.DataFrame({
            'phenotype' : [phenotype],
            'cohort' : [cohort],
            'corr' : [corr],
            'se' : [se]
    })

    dat = dat.append(dat_tmp, ignore_index=True)

floatcols = [c for c in dat.columns if (c not in ['phenotype', 'cohort'])]
dat[floatcols] = dat[floatcols].apply(pd.to_numeric)
# dat = dat.pivot(index=['phenotype', 'cohort'], columns='effect', values=None)
# dat = dat.reorder_levels(['effect', None], axis=1)
dat = dat.sort_index(axis=1, level=0, sort_remaining=False)
dat.columns = ['_'.join(column) for column in dat.columns.to_flat_index()]
dat.to_excel(
    f'/var/genetics/proj/within_family/within_family_project/processed/package_output/marginal_corrs_{phenotype}.xlsx'
)

