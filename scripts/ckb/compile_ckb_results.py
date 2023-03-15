import pandas as pd
import numpy as np
import os

basepath = "/var/genetics/proj/within_family/within_family_project/"

## meta phenos
phenotypes = ['agemenarche', 'asthma', 'bmi', 'bpd', 'bps', 'cpd', 
                 'depsymp', 'dpw', 'ea', 'eversmoker', 'fev', 'health', 'height', 
                 'nchildren', 'swb']

dat = pd.DataFrame(columns = ['phenotype', 'effect', 'n_eff_median', 'h2', 
                'h2_se', 'rg_ref', 'rg_ref_se', 
                'dir_pop_rg', 'dir_pop_rg_se', 'dir_ntc_rg', 'dir_ntc_rg_se', 
                'reg_population_direct', 'reg_population_direct_se',
                'v_population_uncorr_direct', 'v_population_uncorr_direct_se'])

# make table of results
for phenotype in phenotypes:
    for effect in ['direct', 'population']:

        print(f'Compiling results for {phenotype} {effect}...')
        qc_output = basepath + 'processed/qc/ckb/'


        # get median effective n
        qc = pd.read_csv(
            qc_output + phenotype + '/CLEANED.out.gz',
            delim_whitespace=True
        )
        neff= qc[f'n_{effect}'].median()

        # get h2
        with open(qc_output + phenotype + f'/h2_{effect}.log') as f:
            h2lines = [l for l in f if l.startswith('Total Observed scale h2')]
            h2 = h2lines[0] if len(h2lines) > 0 else None
            if h2 is not None:
                h2 = h2.split(':')[1]
                h2est = float(h2.split('(')[0])
                h2se = float(h2.split('(')[1].replace(')', ''))
            else:
                h2est = None
                h2se = None

        # get rg with ref
        if os.path.isfile(qc_output + phenotype + f'/refldsc.log'):
            with open(qc_output + phenotype + f'/refldsc.log') as f:
                rglines = [l for l in f if l.startswith('Genetic Correlation:')]
                rg = rglines[0] if len(rglines) > 0 else None
                if rg is not None:
                    rg = rg.split(':')[1]
                    rgest = float(rg.split('(')[0])
                    rgse = float(rg.split('(')[1].replace(')', ''))
        else:
            rgest = None
            rgse = None
    
        # dir-pop dir-ntc marginal correlations
        mrg = pd.read_csv(
            "/var/genetics/proj/within_family/within_family_project/processed/ckb/marginal_corrs/" + phenotype + f'_marginal_corrs.txt',
            delim_whitespace=True
        )

        dir_pop_mrg = mrg.loc[mrg['correlation'] == 'r_direct_population', 'est'].values[0]
        dir_pop_mrg_se = mrg.loc[mrg['correlation'] == 'r_direct_population', 'SE'].values[0]

        dir_ntc_mrg = mrg.loc[mrg['correlation'] == 'r_direct_avg_NTC', 'est'].values[0]
        dir_ntc_mrg_se = mrg.loc[mrg['correlation'] == 'r_direct_avg_NTC', 'SE'].values[0]

        reg_population_direct_mrg = mrg.loc[mrg['correlation'] == 'reg_population_direct', 'est'].values[0]
        reg_population_direct_mrg_se = mrg.loc[mrg['correlation'] == 'reg_population_direct', 'SE'].values[0]

        v_population_uncorr_direct_mrg = mrg.loc[mrg['correlation'] == 'v_population_uncorr_direct', 'est'].values[0]
        v_population_uncorr_direct_mrg_se = mrg.loc[mrg['correlation'] == 'v_population_uncorr_direct', 'SE'].values[0]

        dattmp = pd.DataFrame(
            {
                'phenotype' : [phenotype], 
                'effect' : [effect],
                'n_eff_median' : [neff], 
                'h2' : [h2est], 
                'h2_se': [h2se],
                'rg_ref' : [rgest],
                'rg_ref_se' : [rgse],
                'dir_pop_rg' : [dir_pop_mrg],
                'dir_pop_rg_se' : [dir_pop_mrg_se],
                'dir_ntc_rg' : [dir_ntc_mrg],
                'dir_ntc_rg_se' : [dir_ntc_mrg_se],
                'reg_population_direct': [reg_population_direct_mrg],
                'reg_population_direct_se': [reg_population_direct_mrg_se],
                'v_population_uncorr_direct': [v_population_uncorr_direct_mrg],
                'v_population_uncorr_direct_se': [v_population_uncorr_direct_mrg_se]
            }
        )

        dat = dat.append(dattmp, ignore_index=True)

# reshape data
dat = dat.pivot(index='phenotype', columns='effect', values=None)
dat.columns = ['_'.join(column) for column in dat.columns.to_flat_index()]
dat = dat.drop(
    ['dir_pop_rg_population', 'dir_pop_rg_se_population', 'dir_ntc_rg_population', 'dir_ntc_rg_se_population',
    'reg_population_direct_population', 'reg_population_direct_se_population', 'v_population_uncorr_direct_population', 'v_population_uncorr_direct_se_population'], 
    axis = 1
)
dat = dat.rename(
    columns = {
        'dir_pop_rg_direct' : 'dir_pop_rg',
        'dir_pop_rg_se_direct' : 'dir_pop_rg_se',
        'dir_ntc_rg_direct' : 'dir_ntc_rg',
        'dir_ntc_rg_se_direct' : 'dir_ntc_rg_se',
        'v_population_uncorr_direct_direct': 'v_population_uncorr_direct',
        'v_population_uncorr_direct_se_direct': 'v_population_uncorr_direct_se',
        'reg_population_direct_direct': 'reg_population_direct',
        'reg_population_direct_se_direct': 'reg_population_direct_se'
        }
)

# reordering columns
dat = dat[
    ['n_eff_median_direct', 'n_eff_median_population',
    'h2_direct','h2_se_direct', 'h2_population','h2_se_population',
    'rg_ref_direct','rg_ref_se_direct',  'rg_ref_population', 'rg_ref_se_population',
    'dir_pop_rg', 'dir_pop_rg_se', 'dir_ntc_rg', 'dir_ntc_rg_se', 'reg_population_direct',
    'reg_population_direct_se', 'v_population_uncorr_direct', 'v_population_uncorr_direct_se'
]
]

dat.to_excel(
    '/var/genetics/proj/within_family/within_family_project/processed/ckb/ckb_results.xlsx'
)