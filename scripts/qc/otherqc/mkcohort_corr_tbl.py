import pandas as pd
import numpy as np
from os.path import exists


for pheno in ['ea', 'bmi', 'height']:
    print(f"Parsing {pheno}...")
    dirlist = {
        'EB' : f'/var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/{pheno}/controls/',
        'FT' : f'/var/genetics/proj/within_family/within_family_project/processed/qc/ft/{pheno}/',
        'Geisinger' : f'/var/genetics/proj/within_family/within_family_project/processed/qc/geisinger/{pheno}/',
        'GS' : f'/var/genetics/proj/within_family/within_family_project/processed/qc/gs/{pheno}/',
        'Hunt' : f'/var/genetics/proj/within_family/within_family_project/processed/qc/hunt/{pheno}/',
        'Lifeline' : f'/var/genetics/proj/within_family/within_family_project/processed/qc/lifelines/{pheno}/',
        'MT' : f'/var/genetics/proj/within_family/within_family_project/processed/qc/minn_twins/{pheno}/',
        'MOBA' : f'/var/genetics/proj/within_family/within_family_project/processed/qc/moba/{pheno}/',
        'STR' : f'/var/genetics/proj/within_family/within_family_project/processed/qc/str/{pheno}/',
        'UKB' : f'/var/genetics/proj/within_family/within_family_project/processed/qc/ukb/{pheno}/'
    }

    filename = 'marginal_correlations.txt'

    dat = pd.DataFrame(columns = ['cohort', 'correlation', 'S.E'])
    for dir in dirlist:
        file = dirlist[dir] + filename
        print(file)
        if exists(file):
            dattmp = pd.read_csv(file, delim_whitespace=True)
            dattmp = dattmp.loc['direct_population']
            dattmp = pd.DataFrame(dattmp).T.reset_index(drop=True)
            dattmp['cohort'] = dir
            dattmp = dattmp[['cohort', 'correlation', 'S.E']]
            dat = dat.append(dattmp, ignore_index=True)


    dat.to_csv(f'/var/genetics/proj/within_family/within_family_project/processed/qc/otherqc/dirpop_rg/{pheno}_dir_pop.txt',
    sep = ' ', na_rep = 'nan', index=False)
