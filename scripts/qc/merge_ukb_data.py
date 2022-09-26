#!/usr/bin/bash

import pandas as pd
import os

#-------------------------------------------------------------------------------
# merge phased and unphased ukb data into a single set of sumstats
#-------------------------------------------------------------------------------

# phased in /disk/genetics/ukb/jguan/ukb_analysis/output/gwas/v2/{pheno_name}/parsep/release/
# unphased in  /disk/genetics/ukb/jguan/ukb_analysis/output/gwas/v4/{PHENO_NAME}/parsep/release/

# we want to choose SNPs from the phased data where available. if no phased data available, use unphased 

phenos =  ["Non_HDL", "cigarettes.per.day", "Glucose", "HDL", "SBP", "DBP", "self.rated.health", "BMI", 
"Cognitive.ability", "Neuroticism", "AAFB", "NC_M", "NC_F", "household.income", "subjective.well.being", "drinks.per.week", 
"menarche", "ever.smoked", "ever.cannabis", "myopia", "EA", "FEV1", "height", "depressive.symptoms"]

for pheno in phenos:

    print(f"Starting {pheno}")

    final = pd.DataFrame()

    for chr in range(1,23):

        phased_path = f'/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/v2/{pheno}/parsep/release/chr_{chr}.sumstats.gz'
        unphased_path = f'/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/v4/{pheno}/parsep/release/chr_{chr}.sumstats.gz'

        phased_ss = pd.read_csv(phased_path, sep = " ", compression = "gzip")
        unphased_ss = pd.read_csv(unphased_path, sep = " ", compression = "gzip")

        combined_ss = phased_ss.append(unphased_ss[~unphased_ss['SNP'].isin(phased_ss['SNP'])], ignore_index=True)
        
        final = pd.concat([final, combined_ss])

    save_path = f"/disk/genetics3/data_dirs/ukb/private/v3/processed/proj/within_family/sumstats/{pheno}"
    os.makedirs(save_path, exist_ok = True)
    final.to_csv(f"{save_path}/{pheno}.sumstats.gz", index = False, sep = " ", compression = "gzip")

    print(f"Completed for {pheno}")