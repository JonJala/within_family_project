#!/usr/bin/bash python3

import pandas as pd
import numpy as np

## adjust multiply standard errors by sqrt of direct effect h2 ratio

phenos = ['aafb', 'adhd', 'agemenarche', 'asthma', 'aud', 'bmi', 'bpd', 'bps', 'cannabis', 'cognition', 'copd', 'cpd', 'depression',
                 'depsymp', 'dpw', 'ea', 'eczema', 'eversmoker', 'extraversion', 'fev', 'hayfever', 'hdl', 'health', 'height', 'hhincome', 'hypertension', 'income', 
                 'migraine', 'morningperson', 'nchildren', 'nearsight', 'neuroticism', 'nonhdl', 'swb']

for pheno in phenos:

    # get meta ss
    path = f"/var/genetics/proj/within_family/within_family_project/processed/package_output/{pheno}/meta.sumstats.gz"
    ss = pd.read_csv(path, sep=" ")

    # get intercept
    meta = pd.read_excel("/disk/genetics3/proj_dirs/within_family/within_family_project/processed/package_output/meta_results.xlsx")
    intercept = meta.loc[meta["phenotype"] == pheno, "h2_intercept_direct"].values[0]
    sqrt_intercept = np.sqrt(intercept)

    # adjust se
    ss["direct_SE"] = ss["direct_SE"] * sqrt_intercept
    ss["population_SE"] = ss["population_SE"] * sqrt_intercept

    # save
    savepath = f"/var/genetics/proj/within_family/within_family_project/processed/package_output/{pheno}/meta_adj_se.sumstats.gz"
    ss.to_csv(savepath, sep = ' ', index = False, na_rep = "nan")
