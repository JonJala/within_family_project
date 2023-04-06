#!/usr/bin/env python3

import pandas as pd
import numpy as np

basepath = '/var/genetics/proj/within_family/within_family_project/'
fpgspath = basepath + 'processed/fpgs/'

phenotypes = ['bmi', 'ea', 'height']

datfpgs = pd.DataFrame(columns=['phenotype', 'effect', 'direct', 'direct_se',
                'pop', 'pop_se', 'paternal', 'paternal_se',
                'maternal', 'maternal_se',
                'incr_r2_proband',  'incr_r2_full',
                'parental_pgi_corr', 'parental_pgi_corr_se'])
fpgsfiles = [fpgspath + ph for ph in phenotypes]

# ancestry = "eur"
ancestry = "sas"

# make table of results
if ancestry == "eur":
    for method in ['unified', 'robust', 'sibdiff', 'young']:
    # for method in ['unified']:
        for phenotype in phenotypes:
            for effect in ['direct']:
            # for effect in ['population']:
            
                print(f'Compiling results for {method} {phenotype} {effect}...')

                # fpgs results
                proband = pd.read_csv(
                    basepath + 'processed/fpgs/' + phenotype + f'/{method}/{ancestry}/{effect}_proband.pgs_effects.txt',
                    delim_whitespace=True,
                    names = ['coeff', 'se', 'r2']
                )

                full = pd.read_csv(
                    basepath + 'processed/fpgs/' + phenotype + f'/{method}/{ancestry}/{effect}_full.pgs_effects.txt',
                    delim_whitespace=True,
                    names = ['coeff', 'se', 'r2']
                )

                covariates_only = pd.read_csv(
                    basepath + 'processed/fpgs/' + phenotype + '/' + method + '/' + ancestry + '/covariates.pgs_effects.txt',
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
                        'method' : [method],
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
elif ancestry == "sas":
    for method in ['unified', 'robust', 'sibdiff', 'young']:
    # for method in ['unified']:
        for phenotype in phenotypes:
            for effect in ['direct']:
            # for effect in ['population']:
            
                print(f'Compiling results for {method} {phenotype} {effect}...')

                # fpgs results
                proband = pd.read_csv(
                    basepath + 'processed/fpgs/' + phenotype + f'/{method}/{ancestry}/{effect}_proband.pgs_effects.txt',
                    delim_whitespace=True,
                    names = ['coeff', 'se', 'r2']
                )

                covariates_only = pd.read_csv(
                    basepath + 'processed/fpgs/' + phenotype + '/' + method + '/' + ancestry + '/covariates.pgs_effects.txt',
                    delim_whitespace=True,
                    names = ['coeff', 'se', 'r2']
                )

                popest = proband.loc['proband', 'coeff']
                popse = proband.loc['proband', 'se']
                incrr2_proband = proband.loc['proband', 'r2'] - covariates_only.loc['age', 'r2']

                datfpgs_tmp = pd.DataFrame({
                        'method' : [method],
                        'phenotype' : [phenotype],
                        'effect' : [effect],
                        'pop' : [popest],
                        'pop_se' : [popse],
                        'incr_r2_proband' : [incrr2_proband],
                })

                datfpgs = datfpgs.append(datfpgs_tmp, ignore_index=True)

floatcols = [c for c in datfpgs.columns if (c not in ['method', 'phenotype', 'effect'])]
datfpgs[floatcols] = datfpgs[floatcols].apply(pd.to_numeric)
datfpgs = datfpgs.pivot(index=['method', 'phenotype'], columns='effect', values=None)
datfpgs = datfpgs.reorder_levels(['effect', None], axis=1)
datfpgs = datfpgs.sort_index(axis=1, level=0, sort_remaining=False)
datfpgs.columns = ['_'.join(column) for column in datfpgs.columns.to_flat_index()]
datfpgs.to_excel(
    f'/var/genetics/proj/within_family/within_family_project/processed/fgwas_v2/fgwas_fpgs_results_{ancestry}.xlsx'
)