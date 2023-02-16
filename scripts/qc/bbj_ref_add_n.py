#!/usr/bin/bash

import pandas as pd

# add N column to BBJ sumstats
# from https://pheweb.jp/downloads

# path to raw sumstats and n for each pheno
bmi_ss = "/disk/genetics4/data_dirs/bbj/public/v1/raw/sumstats/downloaded/hum0197.v3.BBJ.BMI.v1/GWASsummary_BMI_Japanese_SakaueKanai2020.auto.txt.gz"
bmi_n = 163835
height_ss = "/disk/genetics4/data_dirs/bbj/public/v1/raw/sumstats/downloaded/hum0197.v3.BBJ.BMI.v1/GWASsummary_Height_Japanese_SakaueKanai2020.auto"
height_n = 165056
hdl_ss = "/disk/genetics4/data_dirs/bbj/public/v1/raw/sumstats/downloaded/hum0197.v3.BBJ.BMI.v1/GWASsummary_HbA1c_Japanese_SakaueKanai2020.auto"
hdl_n = 74970

outpath = "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/bbj_ref"

def add_n_col(ss_path, n, pheno):
    
    ss = pd.read_csv(f"{ss_path}.txt.gz", sep = "\t")
    ss["N"] = str(n)

    ss.to_csv(f"{outpath}/{pheno}_ref/{pheno}_ref_with_n.txt.gz", sep = "\t", index = False)

add_n_col(bmi_ss, bmi_n)
add_n_col(height_ss, height_n)
add_n_col(hdl_ss, hdl_n)

