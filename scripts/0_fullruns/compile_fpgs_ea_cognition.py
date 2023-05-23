import pandas as pd
import numpy as np

basepath = '/var/genetics/proj/within_family/within_family_project/'
fpgspath = basepath + 'processed/fpgs/'

phenotypes = ['ea', 'cognition']
mcs_validation = ['gcse', 'cogass', 'cogverb']
ukb_validation = ['ea4', 'fluid_intelligence']
validation_phenos = mcs_validation + ukb_validation

datfpgs = pd.DataFrame(columns=['phenotype', 'validation_pheno', 'effect', 'direct', 'direct_se',
                'pop', 'pop_se', 'paternal', 'paternal_se',
                'maternal', 'maternal_se',
                'dir_pop_ratio', 
                'r2',  'r2_ci_low', 'r2_ci_high',
                'parental_pgi_corr', 'parental_pgi_corr_se'])
fpgsfiles = [fpgspath + ph for ph in phenotypes]

# make table of results
for phenotype in phenotypes:
    for validation_pheno in validation_phenos:
        for effect in ['direct', 'population']:

            print(f'Compiling results for {phenotype} {effect}...')
            packageoutput = basepath + 'processed/package_output/'

            ## fpgs results
            data_set = "mcs" if if validation_pheno in mcs_validation else "ukb"
            proband_path = f"{basepath}processed/fpgs/{phenotype}/prscs/{data_set}/{validation_pheno}/{effect}.1.effects.txt" 
            full_path = f"{basepath}processed/fpgs/{phenotype}/prscs/{data_set}/{validation_pheno}/{effect}.2.effects.txt"

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

            direst = full.loc['proband', 'coeff']
            dirse = full.loc['proband', 'se']
            patest = full.loc['paternal', 'coeff']
            patse = full.loc['paternal', 'se']
            matest = full.loc['maternal', 'coeff']
            matse = full.loc['maternal', 'se']
            popest = proband.loc['proband', 'coeff']
            popse = proband.loc['proband', 'se']
            popest_ci_low = popest - 1.96 * popse
            popest_ci_high = popest + 1.96 * popse
            r2 = popest**2 - popse**2 # beta squared minus sampling variance of beta
            r2_ci_low = popest_ci_low**2 - popse**2 # lower CI of beta squared minus sampling variance of beta
            r2_ci_high = popest_ci_high**2 - popse**2 # higher CI of beta squared minus sampling variance of beta
            coeffratio_est = direst/popest

            # parental PGI correlation from snipar log
            if validation_pheno in mcs_validation:
                parcorr_path = '/var/genetics/data/mcs/private/latest/processed/pgs/fpgs/' + phenotype + '/prscs/' + validation_pheno + '/' + effect + '.log'
            elif validation_pheno in ukb_validation:
                    parcorr_path = '/var/genetics/data/ukb/private/latest/processed/proj/within_family/pgs/fpgs/' + phenotype + '/prscs/' + validation_pheno + '/' + effect + '.log'    

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
                    'r2' : [r2],
                    'r2_ci_low' : [r2_ci_low],
                    'r2_ci_high' : [r2_ci_high],
                    'parental_pgi_corr' : [parcorr_est],
                    'parental_pgi_corr_se' : [parcorr_se]
            })

            datfpgs = datfpgs.append(datfpgs_tmp, ignore_index=True)

floatcols = [c for c in datfpgs.columns if (c not in ['phenotype', 'validation_pheno', 'effect'])]
datfpgs[floatcols] = datfpgs[floatcols].apply(pd.to_numeric)
datfpgs = datfpgs.pivot(index=['phenotype', 'validation_pheno'], columns='effect', values=None)
datfpgs = datfpgs.reorder_levels(['effect', None], axis=1)
datfpgs = datfpgs.sort_index(axis=1, level=0, sort_remaining=False)
datfpgs.columns = ['_'.join(column) for column in datfpgs.columns.to_flat_index()]
datfpgs.to_excel(
    '/var/genetics/proj/within_family/within_family_project/processed/package_output/fpgs_results_ea_cognition.xlsx'
)

