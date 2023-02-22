#!/usr/bin/bash

import pandas as pd
import os

# add N column to BBJ sumstats
# from https://pheweb.jp/downloads

# path to raw sumstats and n for each pheno
bmi_ss = "/disk/genetics4/data_dirs/bbj/public/v1/raw/sumstats/downloaded/hum0197.v3.BBJ.BMI.v1/GWASsummary_BMI_Japanese_SakaueKanai2020.auto.txt.gz"
bmi_n = 163835
height_ss = "/disk/genetics4/data_dirs/bbj/public/v1/raw/sumstats/downloaded/hum0197.v3.BBJ.Hei.v1/GWASsummary_Height_Japanese_SakaueKanai2020.auto.txt.gz"
height_n = 165056
bpd_ss = "/disk/genetics4/data_dirs/bbj/public/v1/raw/sumstats/downloaded/hum0197.v3.BBJ.DBP.v1/GWASsummary_DBP_Japanese_SakaueKanai2020.auto.txt.gz"
bpd_n = 145515
bps_ss = "/disk/genetics4/data_dirs/bbj/public/v1/raw/sumstats/downloaded/hum0197.v3.BBJ.SBP.v1/GWASsummary_SBP_Japanese_SakaueKanai2020.auto.txt.gz"
bps_n = 145505

outpath = "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/bbj_ref"

def add_n_col(ss_path, n, pheno):
    
    print(f"Starting {pheno}")

    # read file and add n column
    ss = pd.read_csv(ss_path, sep = "\t")
    ss["N"] = str(n)

    # create folder if it doesn't exist
    if not os.path.exists(f"{outpath}/{pheno}_ref/"):
        os.makedirs(f"{outpath}/{pheno}_ref/")

    # save
    ss.to_csv(f"{outpath}/{pheno}_ref/{pheno}_ref_with_n.txt.gz", sep = "\t", index = False)

    print(f"Done with {pheno}")

add_n_col(bmi_ss, bmi_n, "bmi")
add_n_col(height_ss, height_n, "height")
add_n_col(bpd_ss, bpd_n, "bpd")
add_n_col(bps_ss, bps_n, "bps")

