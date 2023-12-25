import pandas as pd
import numpy as np

## define function to compile results

def compile_results(datfpgs, phenotype, effect, dataset, validation_pheno, basepath):

    print(f'Compiling results for {phenotype} {validation_pheno} {effect}...')

    ## fpgs results
    proband_path = f"{basepath}processed/fpgs/{phenotype}/prscs/{dataset}/{validation_pheno}/{effect}.1.effects.txt" 
    full_path = f"{basepath}processed/fpgs/{phenotype}/prscs/{dataset}/{validation_pheno}/{effect}.2.effects.txt"
    ratio_path = f"{basepath}processed/fpgs/{phenotype}/prscs/{dataset}/{validation_pheno}/dirpop_coeffratiodiff.bootests"
    ntc_path = f"{basepath}/processed/fpgs/{phenotype}/prscs/{dataset}/{validation_pheno}/ntc_ratios.txt"

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

    # dir-pop coeff ratio
    coeffratio = pd.read_csv(
            ratio_path,
            delim_whitespace=True
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
    
    # direct to pop ratio
    coeffratio = coeffratio.loc[f'{effect}_full/{effect}_proband', :]
    coeffratio_est = coeffratio['est']
    coeffratio_se = coeffratio['se']

    # parental PGI correlation from snipar log
    if dataset == "mcs":
        parcorr_path = '/var/genetics/data/mcs/private/latest/processed/pgs/fpgs/' + phenotype + '/prscs/' + effect + '.log'
    elif dataset == "ukb":
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
            'validation_pheno' : [validation_pheno],
            'dataset' : [dataset],
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
            'dir_pop_ratio' : [coeffratio_est],
            'dir_pop_ratio_se': [coeffratio_se],
            'parental_direct_ratio_est' : [parental_direct_ratio_est],
            'parental_direct_ratio_se' : [parental_direct_ratio_se],
            'r2' : [r2],
            'r2_ci_low' : [r2_ci_low],
            'r2_ci_high' : [r2_ci_high],
            'parental_pgi_corr' : [parcorr_est],
            'parental_pgi_corr_se' : [parcorr_se]
    })

    datfpgs = datfpgs.append(datfpgs_tmp, ignore_index=True)
    return datfpgs


## set paths and define variables
basepath = '/var/genetics/proj/within_family/within_family_project/'
fpgspath = basepath + 'processed/fpgs/'

phenotypes = ['ea', 'cognition']
mcs_validation = ['ea', 'cognition', 'cogverb']
ukb_validation = ['ea', 'cognition']
validation_phenos = mcs_validation + ukb_validation

datfpgs = pd.DataFrame(columns=['phenotype', 'validation_pheno', 'dataset', 'effect', 'direct', 'direct_se',
                    'pop', 'pop_se', 'avg_ntc', 'avg_ntc_se',
                    'paternal', 'paternal_se',
                    'maternal', 'maternal_se',
                    'maternal_minus_paternal_est', 'maternal_minus_paternal_se',
                    'dir_pop_ratio', 'dir_pop_ratio_se',
                    'parental_direct_ratio_est', 'parental_direct_ratio_se',
                    'r2',  'r2_ci_low', 'r2_ci_high',
                    'parental_pgi_corr', 'parental_pgi_corr_se'])
fpgsfiles = [fpgspath + ph for ph in phenotypes]

## make table of results
for phenotype in phenotypes:
    for effect in ['direct', 'population']:
        for validation_pheno in mcs_validation:
            datfpgs = compile_results(datfpgs, phenotype, effect, 'mcs', validation_pheno, basepath)
        for validation_pheno in ukb_validation:
            datfpgs =  compile_results(datfpgs, phenotype, effect, 'ukb', validation_pheno, basepath)

## format and save table
floatcols = [c for c in datfpgs.columns if (c not in ['phenotype', 'validation_pheno', 'dataset', 'effect'])]
datfpgs[floatcols] = datfpgs[floatcols].apply(pd.to_numeric)
datfpgs = datfpgs.pivot(index=['phenotype', 'validation_pheno', 'dataset'], columns='effect', values=None)
datfpgs = datfpgs.reorder_levels(['effect', None], axis=1)
datfpgs = datfpgs.sort_index(axis=1, level=0, sort_remaining=False)
datfpgs.columns = ['_'.join(column) for column in datfpgs.columns.to_flat_index()]
datfpgs.to_excel(
    '/var/genetics/proj/within_family/within_family_project/processed/package_output/fpgs_results_ea_cognition.xlsx'
)

