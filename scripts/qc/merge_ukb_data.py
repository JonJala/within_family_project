#!/usr/bin/bash

import pandas as pd
import numpy as np
import os

#-------------------------------------------------------------------------------
# merge phased and unphased ukb data into a single set of sumstats
#-------------------------------------------------------------------------------

# phased in /disk/genetics/ukb/jguan/ukb_analysis/output/gwas/v2/{pheno_name}/parsep/release/
# unphased in  /disk/genetics/ukb/jguan/ukb_analysis/output/gwas/v4/{PHENO_NAME}/parsep/release/

# we want to choose SNPs from the phased data where available. if no phased data available, use unphased 

phenos =  ["cigarettes.per.day", "Glucose", "self.rated.health", "BMI", "Cognitive.ability", "Neuroticism", 
"AAFB", "household.income", "subjective.well.being", "drinks.per.week", "menarche", "ever.smoked", "ever.cannabis", 
"EA", "FEV1", "height", "depressive.symptoms", "asthma", "hayfever", "BPsys", "BPdia", "ECZEMA", "BL_HDL", "income", 
"MIGRAINE", "morning.person", "NC", "nonhdl", "NEARSIGHTED", "mdd"]

for pheno in phenos:

    print(f"Starting {pheno}")

    final = pd.DataFrame()

    for chr in range(1,23):

        phased_path = f'/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/v2/{pheno}/parsep/release/chr_{chr}.sumstats.gz'
        unphased_path = f'/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/v4/{pheno}/parsep/release/chr_{chr}.sumstats.gz'

        phased_ss = pd.read_csv(phased_path, sep = " ", compression = "gzip")
        unphased_ss = pd.read_csv(unphased_path, sep = " ", compression = "gzip")

        combined_ss = pd.concat([phased_ss, unphased_ss[~unphased_ss['SNP'].isin(phased_ss['SNP'])]], ignore_index=True)
        
        final = pd.concat([final, combined_ss])

    save_path = f"/var/genetics/data/ukb/private/v3/processed/proj/within_family/sumstats/{pheno}"
    os.makedirs(save_path, exist_ok = True)
    final.to_csv(f"{save_path}/{pheno}.sumstats.gz", index = False, sep = " ", compression = "gzip", na_rep = np.nan)

    print(f"Completed for {pheno}")