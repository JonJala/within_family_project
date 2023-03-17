import pandas as pd
import numpy as np
import subprocess
import json

basepath = '/var/genetics/proj/within_family/within_family_project/'
fpgspath = basepath + 'processed/fpgs/'

phenotypes = ['bmi', 'ea', 'height']

datfpgs = pd.DataFrame(columns=['phenotype', 'effect', 'direct', 'direct_se',
                'pop', 'pop_se', 'paternal', 'paternal_se',
                'maternal', 'maternal_se',
                'incr_r2_proband',  'incr_r2_full',
                'parental_pgi_corr', 'parental_pgi_corr_se'])
fpgsfiles = [fpgspath + ph for ph in phenotypes]

# make table of results
for phenotype in phenotypes:
    for effect in ['direct']:
        for method in ['with_grm']:

            print(f'Compiling results for {method} {phenotype} {effect}...')
            packageoutput = basepath + 'processed/package_output/'

            # fpgs results
            proband = pd.read_csv(
                basepath + 'processed/fpgs/' + phenotype + f'/{method}/{effect}_proband.pgs_effects.txt',
                delim_whitespace=True,
                names = ['coeff', 'se', 'r2']
            )

            full = pd.read_csv(
                basepath + 'processed/fpgs/' + phenotype + f'/{method}/{effect}_full.pgs_effects.txt',
                delim_whitespace=True,
                names = ['coeff', 'se', 'r2']
            )

            covariates_only = pd.read_csv(
                basepath + 'processed/fpgs/' + phenotype + '/' + method + '/covariates.pgs_effects.txt',
                delim_whitespace=True,
                names = ['coeff', 'se', 'r2']
            )

            direst = full.loc['proband', 'coeff']
            dirse = full.loc['proband', 'se']
            patest = full.loc['paternal', 'coeff']
            patse = full.loc['paternal', 'se']
            matest = full.loc['maternal', 'coeff']
            matse = full.loc['maternal', 'se']
            popest = proband.loc['proband', 'coeff']
            popse = proband.loc['proband', 'se']

            incrr2_proband = proband.loc['proband', 'r2'] - covariates_only.loc['age', 'r2']
            incrr2_full = full.loc['proband', 'r2'] - covariates_only.loc['age', 'r2']

            # parental PGI correlation
            parcorr = np.loadtxt(
                basepath + 'processed/fgwas_v2/' + method + '/' + phenotype + '/' + effect + '/.parentalcorr'
            )

            parcorr_est = parcorr[0]
            parcorr_se = parcorr[1]

            datfpgs_tmp = pd.DataFrame({
                    'phenotype' : [phenotype],
                    'effect' : [effect],
                    'direct' : [direst],
                    'direct_se' : [dirse],
                    'pop' : [popest],
                    'pop_se' : [popse],
                    'paternal' : [patest],
                    'paternal_se' : [patse],
                    'maternal' : [matest],
                    'maternal_se' : [matse],
                    'incr_r2_proband' : [incrr2_proband],
                    'incr_r2_full' : [incrr2_full],
                    'parental_pgi_corr' : [parcorr_est],
                    'parental_pgi_corr_se' : [parcorr_se]
            })

            datfpgs = datfpgs.append(datfpgs_tmp, ignore_index=True)


floatcols = [c for c in datfpgs.columns if (c not in ['phenotype', 'effect'])]
datfpgs[floatcols] = datfpgs[floatcols].apply(pd.to_numeric)
datfpgs = datfpgs.pivot(index='phenotype', columns='effect', values=None)
datfpgs = datfpgs.reorder_levels(['effect', None], axis=1)
datfpgs = datfpgs.sort_index(axis=1, level=0, sort_remaining=False)
datfpgs.columns = ['_'.join(column) for column in datfpgs.columns.to_flat_index()]
datfpgs.to_excel(
    '/var/genetics/proj/within_family/within_family_project/processed/fgwas_v2/fgwas_fpgs_results.xlsx'
)