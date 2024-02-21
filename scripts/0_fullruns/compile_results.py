import pandas as pd
import numpy as np
import subprocess
import json

## chooose which results to compile
metaanalysis = False
fpgs = False
ldsc = True

### define functions for compiling results

def make_rg_matrix(directmat, populationmat):
    '''
    Make upper triangle the population rgs
    lower triangle is direct rgs
    '''

    outmat = populationmat.copy()

    n = directmat.shape[0]
    assert n == populationmat.shape[0]

    for i in range(n):
        for j in range(n):
            if i < j:
                outmat.iloc[i,j] = directmat.iloc[i,j]

    return outmat

def get_meta_results(phenotype, effect): 
    
    basepath = '/var/genetics/proj/within_family/within_family_project/'
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

    # get h2
    with open(basepath + f'processed/genomic_sem/{phenotype}/{phenotype}_ldsc.log') as f:
        
        h2lines = [l for l in f if l.startswith('Total Observed Scale h2')]
        
        if (effect == "direct") & (len(h2lines) > 0):
            h2 = h2lines[0]
        elif (effect == "population") & (len(h2lines) > 0):
            h2 = h2lines[1]
        else:
            h2 = None
        
        if h2 is not None:
            h2 = h2.split(':')[1]
            h2est = float(h2.split('(')[0])
            h2se = float(h2.split('(')[1].replace(')', ''))
        else:
            h2est = None
            h2se = None

    # get h2 intercept
    with open(basepath + f'processed/genomic_sem/{phenotype}/{phenotype}_ldsc.log') as f:
        
        # get intercept
        h2_intercept_lines = [l for l in f if l.startswith('Intercept')]

        if (effect == "direct") & (len(h2_intercept_lines) > 0):
            h2_intercept = h2_intercept_lines[0]
        elif (effect == "population") & (len(h2_intercept_lines) > 0):
            h2_intercept = h2_intercept_lines[1]
        else:
            h2_intercept = None
        
        if h2_intercept is not None:
            h2_intercept = h2_intercept.split(':')[1]
            h2_intercept_est = float(h2_intercept.split('(')[0])
            h2_intercept_se = float(h2_intercept.split('(')[1].replace(')', ''))
        else:
            h2_intercept_est = None
            h2_intercept_se = None

    # get ldsc ratio
    with open(basepath + f'processed/genomic_sem/{phenotype}/{phenotype}_ldsc.log') as f:
        
        # get intercept
        ratio_lines = [l for l in f if l.startswith('Ratio')]

        if (effect == "direct") & (len(ratio_lines) > 0):
            ratio = ratio_lines[0]
        elif (effect == "population") & (len(ratio_lines) > 0):
            ratio = ratio_lines[1]
        else:
            ratio = None

        if ratio.startswith("Ratio < 0"):
            ratio_est = 0 # "Ratio < 0 (usually indicates GC correction)." but to keep it as numeric, set to 0
            ratio_se = None
        elif ratio is not None:
            ratio = ratio.split(':')[1]
            if ratio.startswith(" NA"):
                ratio_est = None
                ratio_se = None
            else:
                ratio_est = float(ratio.split('(')[0])
                ratio_se = float(ratio.split('(')[1].replace(')', ''))
        else:
            ratio_est = None
            ratio_se = None

    # get rg with ref
    with open(basepath + f'processed/genomic_sem/{phenotype}/{phenotype}_ldsc.log') as f:
        
        rglines = [l for l in f if (l.startswith('Genetic Correlation between') & ('and reference' in l))]
        
        if (effect == "direct") & (len(rglines) > 0):
            rg = rglines[0]
        elif (effect == "population") & (len(rglines) > 0):
            rg = rglines[1]
        else:
            rg = None

        if rg is not None:
            rg = rg.split(':')[1]
            rgest = float(rg.split('(')[0])
            rgse = float(rg.split('(')[1].replace(')', ''))
        else:
            rgest = None
            rgse = None

    # get dir-pop rg
    with open(basepath + f'processed/genomic_sem/{phenotype}/{phenotype}_ldsc.log') as f:
        ldsc_rglines = [l for l in f if l.startswith(f'Genetic Correlation between {phenotype}_direct and {phenotype}_pop')]
        ldsc_rg = ldsc_rglines[0] if len(ldsc_rglines) > 0 else None
        if ldsc_rg is not None:
            ldsc_rg = ldsc_rg.split(':')[1]
            ldsc_rgest = float(ldsc_rg.split('(')[0])
            ldsc_rgse = float(ldsc_rg.split('(')[1].replace(')', ''))
        else:
            ldsc_rgest = None
            ldsc_rgse = None
    
    # dir-pop dir-ntc marginal correlations
    mrg = pd.read_csv(
        packageoutput + phenotype + f'/marginal_corrs.txt',
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
            'h2_intercept' : [h2_intercept_est], 
            'h2_intercept_se': [h2_intercept_se],
            'ratio' : [ratio_est], 
            'ratio_se': [ratio_se],
            'rg_ref' : [rgest],
            'rg_ref_se' : [rgse],
            'dir_pop_rg' : [dir_pop_mrg],
            'dir_pop_rg_se' : [dir_pop_mrg_se],
            'dir_ntc_rg' : [dir_ntc_mrg],
            'dir_ntc_rg_se' : [dir_ntc_mrg_se],
            'dir_pop_rg_ldsc' : [ldsc_rgest],
            'dir_pop_rg_se_ldsc' : [ldsc_rgse],
            'n_cohorts' : [ncohorts],
            'reg_population_direct': [reg_population_direct_mrg],
            'reg_population_direct_se': [reg_population_direct_mrg_se],
            'v_population_uncorr_direct': [v_population_uncorr_direct_mrg],
            'v_population_uncorr_direct_se': [v_population_uncorr_direct_mrg_se]
        }
    )

    return(dattmp)

def get_fpgs_results(phenotype, effect):

    basepath = '/var/genetics/proj/within_family/within_family_project/'

    if phenotype == "height":
        proband_path = f"{basepath}processed/fpgs/{phenotype}/prscs/{height_validation}/{effect}.1.effects.txt"
        full_path = f"{basepath}processed/fpgs/{phenotype}/prscs/{height_validation}/{effect}.2.effects.txt"
        ntc_path = f"{basepath}/processed/fpgs/{phenotype}/prscs/{height_validation}/ntc_ratios.txt"
    elif phenotype == "ea":
        proband_path = f"{basepath}processed/fpgs/{phenotype}/prscs/{ea_validation}/{ea_pheno}/{effect}.1.effects.txt"
        full_path = f"{basepath}processed/fpgs/{phenotype}/prscs/{ea_validation}/{ea_pheno}/{effect}.2.effects.txt"
        ntc_path = f"{basepath}/processed/fpgs/{phenotype}/prscs/{ea_validation}/{ea_pheno}/ntc_ratios.txt"
    elif phenotype == "cognition":
        proband_path = f"{basepath}processed/fpgs/{phenotype}/prscs/{cog_validation}/{cog_pheno}/{effect}.1.effects.txt"
        full_path = f"{basepath}processed/fpgs/{phenotype}/prscs/{cog_validation}/{cog_pheno}/{effect}.2.effects.txt"
        ntc_path = f"{basepath}/processed/fpgs/{phenotype}/prscs/{cog_validation}/{cog_pheno}/ntc_ratios.txt"
    else:
        proband_path = f"{basepath}processed/fpgs/{phenotype}/prscs/{effect}.1.effects.txt"
        full_path = f"{basepath}processed/fpgs/{phenotype}/prscs/{effect}.2.effects.txt"
        ntc_path = f"{basepath}/processed/fpgs/{phenotype}/prscs/ntc_ratios.txt"
    
    # 1-generation model (proband only)
    proband = pd.read_csv(
        proband_path,
        delim_whitespace=True,
        names = ['coeff', 'se']
    )

    # 2-generation model (proband and parents)
    full = pd.read_csv(
        full_path,
        delim_whitespace=True,
        names = ['coeff', 'se']
    )

    # ntc coefficients and ratios
    ntc_ratio = pd.read_csv(
        ntc_path,
        delim_whitespace=True,
    )

    direst = full.loc['proband', 'coeff']
    dirse = full.loc['proband', 'se']
    patest = full.loc['paternal', 'coeff']
    patse = full.loc['paternal', 'se']
    matest = full.loc['maternal', 'coeff']
    matse = full.loc['maternal', 'se']
    avg_ntc_est = ntc_ratio.loc[ntc_ratio['rn'] == 'average_NTC', 'estimates'].values[0]
    avg_ntc_se = ntc_ratio.loc[ntc_ratio['rn'] == 'average_NTC', 'SE'].values[0]
    popest = proband.loc['proband', 'coeff']
    popse = proband.loc['proband', 'se']
    popest_ci_low = popest - 1.96 * popse
    popest_ci_high = popest + 1.96 * popse
    maternal_minus_paternal_est = ntc_ratio.loc[ntc_ratio['rn'] == 'maternal_minus_paternal', 'estimates'].values[0]
    maternal_minus_paternal_se = ntc_ratio.loc[ntc_ratio['rn'] == 'maternal_minus_paternal', 'SE'].values[0]
    parental_direct_ratio_est = ntc_ratio.loc[ntc_ratio['rn'] == 'parental_direct_ratio', 'estimates'].values[0]
    parental_direct_ratio_se = ntc_ratio.loc[ntc_ratio['rn'] == 'parental_direct_ratio', 'SE'].values[0]
    r2 = popest**2 - popse**2 # beta squared minus sampling variance of beta
    r2_ci_low = popest_ci_low**2 - popse**2 # lower CI of beta squared minus sampling variance of beta
    r2_ci_high = popest_ci_high**2 - popse**2 # higher CI of beta squared minus sampling variance of beta

    # parental PGI correlation from snipar log
    if phenotype in mcs_phenos:
        parcorr_path = '/var/genetics/data/mcs/private/latest/processed/pgs/fpgs/' + phenotype + '/prscs/' + effect + '.log'
    elif phenotype == "ea":
        if ea_validation == "mcs":
            parcorr_path = '/var/genetics/data/mcs/private/latest/processed/pgs/fpgs/ea/prscs/' + effect + '.log'
        elif ea_validation == "ukb":
            parcorr_path = '/var/genetics/data/ukb/private/latest/processed/proj/within_family/pgs/fpgs/ea/prscs/' + effect + '.log'    
    elif phenotype == "cognition":
        if ea_validation == "mcs":
            parcorr_path = '/var/genetics/data/mcs/private/latest/processed/pgs/fpgs/cognition/prscs/' + effect + '.log'
        elif ea_validation == "ukb":
            parcorr_path = '/var/genetics/data/ukb/private/latest/processed/proj/within_family/pgs/fpgs/cognition/prscs/' + effect + '.log'    
    else:
        parcorr_path = '/var/genetics/data/ukb/private/latest/processed/proj/within_family/pgs/fpgs/' + phenotype + '/prscs/' + effect + '.log'

    with open(parcorr_path) as f:
        rglines = [l for l in f if l.startswith('Estimated correlation between maternal and paternal PGSs:')]
        rg = rglines[0] if len(rglines) > 0 else None
        if rg is not None:
            rg = rg.split(':')[1]
            parcorr_est = float(rg.split('S.E.=')[0])
            parcorr_se = float(rg.split('S.E.=')[1])

    datfpgs_tmp = pd.DataFrame({
        'phenotype' : [phenotype],
        'effect' : [effect],
        'direct' : [direst],
        'direct_se' : [dirse],
        'pop' : [popest],
        'pop_se' : [popse],
        'avg_ntc' : [avg_ntc_est],
        'avg_ntc_se' : [avg_ntc_se],
        'paternal' : [patest],
        'paternal_se' : [patse],
        'maternal' : [matest],
        'maternal_se' : [matse],
        'maternal_minus_paternal_est' : [maternal_minus_paternal_est],
        'maternal_minus_paternal_se' : [maternal_minus_paternal_se],
        'parental_direct_ratio_est' : [parental_direct_ratio_est],
        'parental_direct_ratio_se' : [parental_direct_ratio_se],
        'r2' : [r2],
        'r2_ci_low' : [r2_ci_low],
        'r2_ci_high' : [r2_ci_high],
        'parental_pgi_corr' : [parcorr_est],
        'parental_pgi_corr_se' : [parcorr_se]
    })

    return(datfpgs_tmp)

def get_ldsc_results(phenotypes):

    # Make ldsc matrix
    ssgacrepopath = "/var/genetics/proj/within_family/ssgac"
    basepath = '/var/genetics/proj/within_family/within_family_project/'
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
        --print-delete-vals \
        --out {basepath}/processed/package_output/populationrg \
        --print-estimates \
        --write-excel \
        --filelabels {phenolabels}

    {ssgacrepopath}/ldsc_mod/ldsc.py \
        --rg {directresults} \
        --ref-ld-chr {eur_w_ld_chr} \
        --w-ld-chr {eur_w_ld_chr} \
        --out {basepath}/processed/package_output/directrg \
        --print-delete-vals \
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

def get_heritabilities(phenotypes):

    ssgacrepopath = "/var/genetics/proj/within_family/ssgac"
    basepath = '/var/genetics/proj/within_family/within_family_project/'
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
        --h2 {populationresults} \
        --ref-ld-chr {eur_w_ld_chr} \
        --w-ld-chr {eur_w_ld_chr} \
        --print-delete-vals \
        --out {basepath}/processed/package_output/populationh2 \
        --print-estimates \
        --write-excel \
        --filelabels {phenolabels}

    {ssgacrepopath}/ldsc_mod/ldsc.py \
        --h2 {directresults} \
        --ref-ld-chr {eur_w_ld_chr} \
        --w-ld-chr {eur_w_ld_chr} \
        --out {basepath}/processed/package_output/directh2 \
        --print-delete-vals \
        --print-estimates \
        --write-excel \
        --filelabels {phenolabels}
    '''
    subprocess.run(bashcommand,
        shell=True, check=True,
        executable='/usr/bin/bash')


### compile results

## all phenos
phenotypes = ['aafb', 'adhd', 'agemenarche', 'asthma', 'aud', 'bmi', 'bpd', 'bps', 'cannabis', 'cognition', 'copd', 'cpd', 'depression',
                 'depsymp', 'dpw', 'ea', 'eczema', 'eversmoker', 'extraversion', 'fev', 'hayfever', 'hdl', 'health', 'height', 'hhincome', 'hypertension', 'income', 
                 'migraine', 'morningperson', 'nchildren', 'nearsight', 'neuroticism', 'nonhdl', 'swb']

## mcs phenos, not including ea and cognition
mcs_phenos = ['bmi', 'depression', 'adhd', 'agemenarche', 'eczema', 'cannabis' ,'dpw', 'depsymp', 'eversmoker', 'extraversion', 'neuroticism', 'health', 'height', 'hhincome', 'swb']

## choose validation cohort and outcome phenos for height, ea, and cognition
height_validation = "mcs"
ea_validation = "mcs"
ea_pheno = "ea" # ea validation pheno
cog_validation = "mcs"
cog_pheno = "cognition" # cognition validation pheno

## initialize dataframes for saving results
if metaanalysis == True:    
    dat = pd.DataFrame(columns = ['phenotype', 'effect', 'n_eff_median', 'h2', 
        'h2_se', 'h2_intercept', 'h2_intercept_se', 'ratio', 'ratio_se', 
        'rg_ref', 'rg_ref_se', 'dir_pop_rg', 'dir_pop_rg_se', 'dir_ntc_rg', 
        'dir_ntc_rg_se', 'dir_pop_rg_ldsc', 'dir_pop_rg_se_ldsc',
        'n_cohorts', 'reg_population_direct', 'reg_population_direct_se',
        'v_population_uncorr_direct', 'v_population_uncorr_direct_se'])
if fpgs == True:
    datfpgs = pd.DataFrame(columns=['phenotype', 'effect', 'direct', 'direct_se',
                    'pop', 'pop_se', 'avg_ntc', 'avg_ntc_se',
                    'paternal', 'paternal_se',
                    'maternal', 'maternal_se',
                    'maternal_minus_paternal_est', 'maternal_minus_paternal_se',
                    'parental_direct_ratio_est', 'parental_direct_ratio_se',
                    'r2',  'r2_ci_low', 'r2_ci_high',
                    'parental_pgi_corr', 'parental_pgi_corr_se'])

## make table of results for each phenotype
for phenotype in phenotypes:
    for effect in ['direct', 'population']:
        print(f'Compiling results for {phenotype} {effect}...')
        if metaanalysis == True:    
            dattmp = get_meta_results(phenotype, effect) 
            dat = dat.append(dattmp, ignore_index=True)
        if fpgs == True:
            if phenotype in ['aud', 'copd', 'hypertension']:
                continue
            datfpgs_tmp = get_fpgs_results(phenotype, effect)
            datfpgs = datfpgs.append(datfpgs_tmp, ignore_index=True)

## format and save meta-analysis results
if metaanalysis == True:
    # reshape data
    dat = dat.pivot(index='phenotype', columns='effect', values=None)
    dat.columns = ['_'.join(column) for column in dat.columns.to_flat_index()]
    dat = dat.drop(
        ['n_cohorts_population', 'dir_pop_rg_population', 'dir_pop_rg_se_population', 'dir_ntc_rg_population', 'dir_ntc_rg_se_population',
        'reg_population_direct_population', 'reg_population_direct_se_population', 'v_population_uncorr_direct_population', 'v_population_uncorr_direct_se_population',
        'dir_pop_rg_ldsc_population', 'dir_pop_rg_se_ldsc_population'], 
        axis = 1
    )
    dat = dat.rename(
        columns = {
            'n_cohorts_direct' : 'n_cohorts',
            'dir_pop_rg_direct' : 'dir_pop_rg',
            'dir_pop_rg_se_direct' : 'dir_pop_rg_se',
            'dir_ntc_rg_direct' : 'dir_ntc_rg',
            'dir_ntc_rg_se_direct' : 'dir_ntc_rg_se',
            'dir_pop_rg_ldsc_direct' : 'dir_pop_rg_ldsc',
            'dir_pop_rg_se_ldsc_direct' : 'dir_pop_rg_se_ldsc',
            'v_population_uncorr_direct_direct': 'v_population_uncorr_direct',
            'v_population_uncorr_direct_se_direct': 'v_population_uncorr_direct_se',
            'reg_population_direct_direct': 'reg_population_direct',
            'reg_population_direct_se_direct': 'reg_population_direct_se'
            }
    )

    # reordering columns
    dat = dat[
        ['n_cohorts', 'n_eff_median_direct', 'n_eff_median_population',
        'h2_direct','h2_se_direct', 'h2_population','h2_se_population',
        'h2_intercept_direct', 'h2_intercept_se_direct', 'h2_intercept_population', 'h2_intercept_se_population',
        'ratio_direct', 'ratio_se_direct', 'ratio_population', 'ratio_se_population',
        'rg_ref_direct','rg_ref_se_direct',  'rg_ref_population', 'rg_ref_se_population',
        'dir_pop_rg_ldsc', 'dir_pop_rg_se_ldsc', 'dir_pop_rg', 'dir_pop_rg_se', 'dir_ntc_rg', 'dir_ntc_rg_se', 
        'reg_population_direct', 'reg_population_direct_se', 'v_population_uncorr_direct', 'v_population_uncorr_direct_se'
    ]
    ]

    # flip signs of correlations when negative
    dat['rg_ref_direct'].mask(dat['rg_ref_direct'] < 0, -1*dat['rg_ref_direct'], inplace = True)
    dat['rg_ref_population'].mask(dat['rg_ref_population'] < 0, -1*dat['rg_ref_population'], inplace = True)

    # save to excel
    dat.to_excel(
        '/var/genetics/proj/within_family/within_family_project/processed/package_output/meta_results.xlsx'
    )

## format and save fpgs results
if fpgs == True:
    floatcols = [c for c in datfpgs.columns if (c not in ['phenotype', 'effect'])]
    datfpgs[floatcols] = datfpgs[floatcols].apply(pd.to_numeric)
    datfpgs = datfpgs.pivot(index='phenotype', columns='effect', values=None)
    datfpgs = datfpgs.reorder_levels(['effect', None], axis=1)
    datfpgs = datfpgs.sort_index(axis=1, level=0, sort_remaining=False)
    datfpgs.columns = ['_'.join(column) for column in datfpgs.columns.to_flat_index()]
    datfpgs.to_excel(
        '/var/genetics/proj/within_family/within_family_project/processed/package_output/fpgs_results.xlsx'
    )

## compile and save ldsc results
if ldsc == True:
    subprocess.call ("Rscript /var/genetics/proj/within_family/within_family_project/scripts/0_fullruns/compile_correlation_matrix.R", shell=True)
    # get_heritabilities(phenotypes) # for jackknife estimates -- do not run / leave for now