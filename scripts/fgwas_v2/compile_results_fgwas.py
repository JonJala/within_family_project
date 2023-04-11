#!/usr/bin/env python3

import pandas as pd

basepath = '/var/genetics/proj/within_family/within_family_project/'
fpgspath = basepath + 'processed/fpgs/'
phenotypes = ['bmi', 'ea', 'height']

def compile_results_fgwas(phenotypes, ancestry, effect, methods):
    
    datfpgs = pd.DataFrame(columns=['phenotype', 'effect', 'direct', 'direct_se',
                'pop', 'pop_se', 'paternal', 'paternal_se',
                'maternal', 'maternal_se',
                'incr_r2_proband'])
    
    for method in methods:
        for phenotype in phenotypes:
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
        f'/var/genetics/proj/within_family/within_family_project/processed/fgwas_v2/fgwas_fpgs_results_{ancestry}_{effect}.xlsx'
    )

compile_results_fgwas(phenotypes, "sas", "direct", ['unified', 'robust', 'sibdiff', 'young'])
compile_results_fgwas(phenotypes, "eur", "direct", ['unified', 'robust', 'sibdiff', 'young'])
[]
compile_results_fgwas(phenotypes, "sas", "population", ["unified"])
compile_results_fgwas(phenotypes, "eur", "population", ["unified"])