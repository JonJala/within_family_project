import pandas as pd
import numpy as np
import subprocess
import json

'''
Compile Supplementary Table 4a
'''

basepath = '/var/genetics/proj/within_family/within_family_project/'
fpgspath = basepath + 'processed/fpgs/'
phenotypes = ['bmi', 'height', 'cognition', 'depression', 'eversmoker']
dataset = "mcs"

datfpgs = pd.DataFrame(columns=['phenotype', 'effect', 'direct', 'direct_se',
                'pop', 'pop_se', 'paternal', 'paternal_se',
                'maternal', 'maternal_se',
                 'dir_pop_ratio', 
                'dir_pop_ratio_se', 
                'incr_r2_proband',  'incr_r2_full',
                'parental_pgi_corr', 'parental_pgi_corr_se'])

fpgsfiles = [fpgspath + ph for ph in phenotypes]

# make table of results
for phenotype in phenotypes:
    for effect in ['direct', 'population']:

        print(f'Compiling results for {phenotype} {effect}...')
        packageoutput = basepath + 'processed/package_output/'

        # fpgs results
        if phenotype == 'ea4_meta':
            for dataset in ['mcs', 'ukb']:
                proband = pd.read_csv(
                    basepath + 'processed/fpgs/' + phenotype + f'/{dataset}/{effect}_proband.pgs_effects.txt',
                    delim_whitespace=True,
                    names = ['coeff', 'se', 'r2']
                )

                full = pd.read_csv(
                    basepath + 'processed/fpgs/' + phenotype +  f'/{dataset}/{effect}_full.pgs_effects.txt',
                    delim_whitespace=True,
                    names = ['coeff', 'se', 'r2']
                )

                covariates_only = pd.read_csv(
                    basepath + 'processed/fpgs/' + phenotype +  f'/{dataset}/covariates.pgs_effects.txt',
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

                coeffratio = pd.read_csv(
                    basepath + 'processed/fpgs/' + phenotype +  f'/{dataset}/dirpop_ceoffratiodiff.bootests',
                    delim_whitespace=True
                )

                coeffratio = coeffratio.loc[f'{effect}_full/{effect}_proband', :]
                coeffratio_est = coeffratio['est']
                coeffratio_se = coeffratio['se']

                # parental PGI correlation
                parcorr = np.loadtxt(
                    basepath + 'processed/sbayesr/' + phenotype + '/' + effect + f'/{dataset}/.parentalcorr'
                )

                parcorr_est = parcorr[0]
                parcorr_se = parcorr[1]

                datfpgs_tmp = pd.DataFrame({
                'phenotype' : [phenotype + f'_{dataset}'],
                'effect' : [effect],
                'direct' : [direst],
                'direct_se' : [dirse],
                'pop' : [popest],
                'pop_se' : [popse],
                'paternal' : [patest],
                'paternal_se' : [patse],
                'maternal' : [matest],
                'maternal_se' : [matse],
                'dir_pop_ratio' : [coeffratio_est],
                'dir_pop_ratio_se' : [coeffratio_se], 
                'incr_r2_proband' : [incrr2_proband],
                'incr_r2_full' : [incrr2_full],
                'parental_pgi_corr' : [parcorr_est],
                'parental_pgi_corr_se' : [parcorr_se]
                })

                datfpgs = datfpgs.append(datfpgs_tmp, ignore_index=True)

        else:

            proband = pd.read_csv(
                basepath + 'processed/fpgs/' + phenotype + f'/clumping_analysis/{dataset}/{effect}_proband.pgs_effects.txt',
                delim_whitespace=True,
                names = ['coeff', 'se', 'r2']
            )

            full = pd.read_csv(
                basepath + 'processed/fpgs/' + phenotype + f'/clumping_analysis/{dataset}/{effect}_full.pgs_effects.txt',
                delim_whitespace=True,
                names = ['coeff', 'se', 'r2']
            )

            covariates_only = pd.read_csv(
                basepath + 'processed/fpgs/' + phenotype + '/clumping_analysis/' + dataset + '/covariates.pgs_effects.txt',
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

            coeffratio = pd.read_csv(
                basepath + 'processed/fpgs/' + phenotype + f'/clumping_analysis/{dataset}/dirpop_ceoffratiodiff.bootests',
                delim_whitespace=True
            )

            coeffratio = coeffratio.loc[f'{effect}_full/{effect}_proband', :]
            coeffratio_est = coeffratio['est']
            coeffratio_se = coeffratio['se']

            # parental PGI correlation
            parcorr = np.loadtxt(
                basepath + 'processed/sbayesr/' + phenotype + '/clumping_analysis/' + effect + '/' + dataset + '/.parentalcorr'
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
            'dir_pop_ratio' : [coeffratio_est],
            'dir_pop_ratio_se' : [coeffratio_se], 
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
    '/var/genetics/proj/within_family/within_family_project/processed/package_output/supp.table.4a.xlsx'
)