import pandas as pd
import numpy as np
import subprocess
import json

def make_rg_matrix(directmat, populationmat):
    '''
    Make upper triangle the popualtion rgs
    lower triange is direct rgs
    '''

    outmat = populationmat.copy()

    n = directmat.shape[0]
    assert n == populationmat.shape[0]

    for i in range(n):
        for j in range(n):
            if i < j:
                outmat.iloc[i,j] = directmat.iloc[i,j]

    return outmat

basepath = '/var/genetics/proj/within_family/within_family_project/'
fpgspath = basepath + 'processed/fpgs/'
phenotypes = ['bmi', 'height', 'cognition', 'depression', 'eversmoker', 'hdl']

dat = pd.DataFrame(columns = ['phenotype', 'effect', 'n_eff_median', 'h2', 
                'h2_se', 'rg_ref', 'rg_ref_se', 
                'dir_pop_rg', 'dir_pop_rg_se', 'dir_ntc_rg', 'dir_ntc_rg_se', 
                'n_cohorts'])

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

        # get median effective n
        meta = pd.read_csv(
            packageoutput + phenotype + '/meta.hm3.sumstats.gz',
            delim_whitespace=True
        )

        neff= meta[f'{effect}_N'].median()

        # get n cohorts
        with open(f'/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/{phenotype}/inputfiles.json') as f:
            inputfiles = json.load(f)
        ncohorts = len(inputfiles.keys())

        with open(packageoutput + phenotype + f'/{effect}_h2.log') as f:
            h2lines = [l for l in f if l.startswith('Total Observed scale h2')]
            h2 = h2lines[0] if len(h2lines) > 0 else None
            if h2 is not None:
                h2 = h2.split(':')[1]
                h2est = float(h2.split('(')[0])
                h2se = float(h2.split('(')[1].replace(')', ''))
            else:
                h2est = None
                h2se = None

        with open(packageoutput + phenotype + f'/{effect}_reference_sample.log') as f:
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
            packageoutput + phenotype + f'/marginal_corrs.txt',
            delim_whitespace=True
        )

        dir_pop_mrg = mrg.loc[mrg['correlation'] == 'r_direct_population', 'est'].values[0]
        dir_pop_mrg_se = mrg.loc[mrg['correlation'] == 'r_direct_population', 'SE'].values[0]

        dir_ntc_mrg = mrg.loc[mrg['correlation'] == 'r_direct_avg_NTC', 'est'].values[0]
        dir_ntc_mrg_se = mrg.loc[mrg['correlation'] == 'r_direct_avg_NTC', 'SE'].values[0]

        # fpgs results
        proband = pd.read_csv(
            basepath + 'processed/fpgs/' + phenotype + f'/{effect}_proband.pgs_effects.txt',
            delim_whitespace=True,
            names = ['coeff', 'se', 'r2']
        )

        full = pd.read_csv(
            basepath + 'processed/fpgs/' + phenotype + f'/{effect}_full.pgs_effects.txt',
            delim_whitespace=True,
            names = ['coeff', 'se', 'r2']
        )

        covariates_only = pd.read_csv(
            basepath + 'processed/fpgs/' + phenotype + '/covariates.pgs_effects.txt',
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
            basepath + 'processed/fpgs/' + phenotype + f'/dirpop_ceoffratiodiff.bootests',
            delim_whitespace=True
        )

        coeffratio = coeffratio.loc[f'{effect}_full/{effect}_proband', :]
        coeffratio_est = coeffratio['est']
        coeffratio_se = coeffratio['se']

        # parental PGI correlation
        parcorr = np.loadtxt(
            basepath + 'processed/sbayesr/' + phenotype + '/' + effect + '/.parentalcorr'
        )

        parcorr_est = parcorr[0]
        parcorr_se = parcorr[1]

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
                'n_cohorts' : [ncohorts],
            }
        )

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

        dat = dat.append(dattmp, ignore_index=True)
        datfpgs = datfpgs.append(datfpgs_tmp, ignore_index=True)

# reshape data
dat = dat.pivot(index='phenotype', columns='effect', values=None)
dat.columns = ['_'.join(column) for column in dat.columns.to_flat_index()]
dat = dat.drop(
    ['n_cohorts_population', 'dir_pop_rg_population', 'dir_pop_rg_se_population', 'dir_ntc_rg_population', 'dir_ntc_rg_se_population'], 
    axis = 1
)
dat = dat.rename(
    columns = {
        'n_cohorts_direct' : 'n_cohorts',
        'dir_pop_rg_direct' : 'dir_pop_rg',
        'dir_pop_rg_se_direct' : 'dir_pop_rg_se',
        'dir_ntc_rg_direct' : 'dir_ntc_rg',
        'dir_ntc_rg_se_direct' : 'dir_ntc_rg_se'
        }
)

# reordering columns
dat = dat[
    ['n_cohorts', 'n_eff_median_direct', 'n_eff_median_population',
    'h2_direct','h2_se_direct', 'h2_population','h2_se_population',
    'rg_ref_direct','rg_ref_se_direct',  'rg_ref_population', 'rg_ref_se_population',
    'dir_pop_rg', 'dir_pop_rg_se', 'dir_ntc_rg', 'dir_ntc_rg_se'
]
]

dat.to_csv(
    '/var/genetics/proj/within_family/within_family_project/processed/package_output/meta.results',
    sep = '\t'
)

floatcols = [c for c in datfpgs.columns if (c not in ['phenotype', 'effect'])]
datfpgs[floatcols] = datfpgs[floatcols].apply(pd.to_numeric)
datfpgs = datfpgs.pivot(index='phenotype', columns='effect', values=None)
datfpgs = datfpgs.reorder_levels(['effect', None], axis=1)
datfpgs = datfpgs.sort_index(axis=1, level=0, sort_remaining=False)
datfpgs.columns = ['_'.join(column) for column in datfpgs.columns.to_flat_index()]
datfpgs.to_csv(
    '/var/genetics/proj/within_family/within_family_project/processed/package_output/fpgs.results',
    sep = '\t'
)
# Make ldsc matrix
ssgacrepopath = "/var/genetics/proj/within_family/within_family_project/ssgac"
phenotypes.sort()
populationresults = [basepath + 'processed/package_output/' + p + '/populationmunged.sumstats.gz' for p in phenotypes]
directresults = [basepath + 'processed/package_output/' + p + '/directmunged.sumstats.gz' for p in phenotypes]
populationresults = ','.join(populationresults)
directresults = ','.join(directresults)
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
act = "/disk/genetics/pub/python_env/anaconda2/bin/activate"
pyenv = "/disk/genetics/pub/python_env/anaconda2/envs/mama"
phenolabels = ','.join(phenotypes)
print(phenolabels)

bashcommand = f'''
echo "Running LDSC-MOD"
source {act} {pyenv}

{ssgacrepopath}/ldsc_mod/ldsc.py \
    --rg {populationresults} \
    --ref-ld-chr {eur_w_ld_chr} \
    --w-ld-chr {eur_w_ld_chr} \
    --out {basepath}/processed/package_output/populationrg \
    --print-estimates \
    --write-excel \
    --filelabels {phenolabels}


{ssgacrepopath}/ldsc_mod/ldsc.py \
    --rg {directresults} \
    --ref-ld-chr {eur_w_ld_chr} \
    --w-ld-chr {eur_w_ld_chr} \
    --out {basepath}/processed/package_output/directrg \
    --print-estimates \
    --write-excel \
    --filelabels {phenolabels}
'''


subprocess.run(bashcommand,
    shell=True, check=True,
    executable='/usr/bin/bash')

directmat = pd.read_excel(
    basepath + '/processed/package_output/directrg_tables.xlsx',
    sheet_name='rg',
    index_col=0
)

populationmat = pd.read_excel(
    basepath + '/processed/package_output/populationrg_tables.xlsx',
    sheet_name='rg',
    index_col=0
)

outmat = make_rg_matrix(directmat, populationmat)
outmat.to_excel(
    basepath + '/processed/package_output/direct_population_rg_matrix.xlsx'
)