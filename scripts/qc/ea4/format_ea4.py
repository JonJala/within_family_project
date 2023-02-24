import pandas as pd
import numpy as np

dat = pd.read_csv(
    '/var/genetics/proj/ea4/derived_data/Meta_analysis/1_Main/2020_08_20/output/EA4_2020_08_20.meta',
    delim_whitespace=True   
)

# renaming files
# modeled after snipar fgwas output
dat = dat[['Chr', 'BP', 'rsID', 'EA', 'OA', 'EAF', 'N', 'BETA', 'SE']]
dat = dat.rename(
    columns = {
        'Chr' : 'chromosome',
        'BP' : 'pos',
        'rsID' : 'SNP',
        'EA' : 'A1',
        'OA' : 'A2',
        'EAF' : 'freq',
        'N' : 'population_N',
        'BETA' : 'population_Beta',
        'SE' : 'population_SE'
    }
)

dat.to_csv(
    '/var/genetics/proj/within_family/within_family_project/processed/ea4/ea4_formetanalysis.sumstats',
    index=False,
    na_rep='nan',
    sep='\t'
)