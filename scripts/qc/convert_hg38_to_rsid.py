#!/usr/bin/bash

##-------------------------------------------------------------------------------
## convert hg38 sumstats to use rsid SNP identifiers
##-------------------------------------------------------------------------------

import pandas as pd
import numpy as np
import glob

##-------------------------------------------------------------------------------
## define function
##-------------------------------------------------------------------------------

def convert_sumstats(pheno, sumstats_path, savepath, dbsnp38, separator = " "):
    
    print(f"Starting {pheno}")

    # concat all sumstats into one file
    files = glob.glob(sumstats_path)
    ss = pd.concat([pd.read_csv(f, sep = separator, compression = "gzip") for f in files])

    # create chrposid column
    dbsnp38["ChrPosID"] = dbsnp38[0].str[3:]
    ss["ChrPosID"] = ss["chromosome"].astype(str) + ":" + ss["pos"].astype(str)

    # merge
    merged = pd.merge(ss, dbsnp38, on = "ChrPosID", how = "left")
    merged = merged.drop(columns = ["SNP", "ChrPosID", 0, 2, 3])
    merged = merged.rename(columns = {1: "SNP"})
    merged.insert(1, "SNP", merged.pop("SNP"))
    merged = merged[merged["SNP"].notnull()]

    # save
    merged.to_csv(savepath, index = False, sep = " ", compression = "gzip", na_rep = np.nan)

    print(f"Done with {pheno}")

##-------------------------------------------------------------------------------
## convert sumstats
##-------------------------------------------------------------------------------

## concatenate all dbsnp files
dbsnp_files = glob.glob("/disk/genetics/data/1000G/public/20130502/processed/misc/dbSNP/all/dbSNP153_chr*.txt.gz")
dbsnp38 = pd.concat([pd.read_csv(f, sep = " ", header = None, compression = "gzip") for f in dbsnp_files])

## DT

dt_phenos = ["Education", "Cannabis", "NoHDL", "BMI", "Neuroticism", "Menarche", "EverSmoke", "SelfRatedHealth", "DepressionASR", "DBP", "Migraine", "Nkids", "MorningP", "Height", "Extraversion", "CPD", "DPW", "SBP", "SatisfactionWithLife", "Asthma", "HDL"]

for pheno in dt_phenos:

    sumstats_path = f"/disk/genetics/data/dutch_twin/public/v1/raw/sumstats/fgwas/{pheno}/*.sumstats.gz"
    savepath = f"/disk/genetics/data/dutch_twin/public/v1/processed/sumstats/fgwas/{pheno}.sumstats.gz"

    convert_sumstats(pheno, sumstats_path, savepath, dbsnp38)