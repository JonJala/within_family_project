#!/usr/bin/bash

import pandas as pd
import shutil
import glob

def convert_to_chrposid(path, out, copy_l2M = True):

    if copy_l2M:
        files = glob.glob(f"{path}/*.l2.M*")
        for file in files:
            print(f"Copying {file}")
            shutil.copyfile(file, f"{out}/{file.split('/')[-1]}")

    for chr in range(1,23):
        ldsc = pd.read_csv(f"{path}/{chr}.l2.ldscore.gz", sep="\t")
        ldsc["SNP"] = ldsc["CHR"].astype(str) + ":" + ldsc["BP"].astype(str)
        ldsc.to_csv(f"{out}/{chr}.l2.ldscore.gz", sep="\t", index=False, compression="gzip")

convert_to_chrposid("/disk/genetics4/ukb/alextisyoung/haplotypes/relatives/bedfiles/ldscores", "/disk/genetics/data/ukb/private/latest/processed/proj/within_family/ldscores/alex")
convert_to_chrposid("/disk/genetics/ukb/jguan/ukb_analysis/output/ldsc/v2", "/disk/genetics/data/ukb/private/latest/processed/proj/within_family/ldscores/junming_phased")
convert_to_chrposid("/disk/genetics/ukb/jguan/ukb_analysis/output/ldsc/v4", "/disk/genetics/data/ukb/private/latest/processed/proj/within_family/ldscores/junming_unphased")
