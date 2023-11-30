import pandas as pd
import argparse

parser=argparse.ArgumentParser()
parser.add_argument('--pheno', type=str, 
                    help='''Phenotype name''')
parser.add_argument('--cohorts', type=str, 
                    help='''Phenotype cohorts''')
args=parser.parse_args()

basepath = '/var/genetics/proj/within_family/within_family_project/'
phenotype = args.pheno
cohorts = args.cohorts.split(' ')

dat = pd.DataFrame(columns=['phenotype', 'cohort', 'h2', 'h2_se'])

# make table of results
for cohort in cohorts:
    for effect in ['direct', 'population']:

        print(f'Compiling results for {cohort} {effect}...')
        packageoutput = basepath + 'processed/qc/'
        
        # h2 from ldsc log
        path = packageoutput + cohort + '/' + phenotype + '/' + effect + '_h2.log'
        
        with open(path) as f:
            h2lines = [l for l in f if l.startswith('Total Observed scale h2:')]
            h2 = h2lines[0] if len(h2lines) > 0 else None
            if h2 is not None:
                h2 = h2.split(':')[1]
                h2_est = float(h2.split('(')[0])
                h2_se = float(h2.split('(')[1].split(')')[0])

        dat_tmp = pd.DataFrame({
                'phenotype' : [phenotype],
                'cohort' : [cohort],
                'effect' : [effect],
                'h2' : [h2_est],
                'h2_se' : [h2_se]
        })

        dat = dat.append(dat_tmp, ignore_index=True)

floatcols = [c for c in dat.columns if (c not in ['phenotype', 'cohort', 'effect'])]
dat[floatcols] = dat[floatcols].apply(pd.to_numeric)
dat = dat.pivot(index=['phenotype', 'cohort'], columns='effect', values=None)
dat = dat.reorder_levels(['effect', None], axis=1)
dat = dat.sort_index(axis=1, level=0, sort_remaining=False)
dat.columns = ['_'.join(column) for column in dat.columns.to_flat_index()]
dat.to_excel(
    f'/var/genetics/proj/within_family/within_family_project/processed/package_output/h2_est_{phenotype}.xlsx'
)

