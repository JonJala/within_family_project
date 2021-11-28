'''
Reads fgwas output files
and combines them into
one table
'''


import numpy as np
import pandas as pd
import argparse

logfiles = {"bmi_dir": '/var/genetics/proj/within_family/within_family_project/processed/fpgs/direct_bmi.pgs_effects.txt',
            'bmi_pop': '/var/genetics/proj/within_family/within_family_project/processed/fpgs/population_bmi.pgs_effects.txt',
            'ea_dir' :'/var/genetics/proj/within_family/within_family_project/processed/fpgs/direct_ea.pgs_effects.txt',
            'ea_pop' : '/var/genetics/proj/within_family/within_family_project/processed/fpgs/population_ea.pgs_effects.txt'}

dat = pd.DataFrame(columns = ['regvariable', 'estimate', 'se', 'r2', 'phenotype', 'meta_effect'])
for log in logfiles:
    dat_tmp = pd.read_csv(logfiles[log], 
                    names = ['regvariable', 'estimate', 'se', 'r2'],
                    delim_whitespace=True)
    logsplit = log.split('_')
    pheno = logsplit[0]
    meta_effect =  logsplit[1]
    dat_tmp['phenotype'] = pheno
    dat_tmp['meta_effect'] = meta_effect
    dat = dat.append(dat_tmp)

print(dat.head())

dat.to_csv(
    '/var/genetics/proj/within_family/within_family_project/processed/fpgs/effects.table',
    sep = " ",
    na_rep = "nan",
    index=False
)


