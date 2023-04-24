'''
Rename iPSYCH sumstats columns so that they align with QC pipeline
and filter out SNPs with hwe p-values < 10^-6
'''

import pandas as pd
import glob

files = glob.glob("/var/genetics/data/ipsych/public/latest/raw/sumstats/sumstats_*")

for file in files:

    print(file)

    ss = pd.read_csv(file, sep = "\t")
    
    # rename columns
    ss.columns = ss.columns.str.replace("_beta", "_Beta")
    ss.columns = ss.columns.str.replace("_ntc", "_NTC")
    ss.columns = ss.columns.str.replace("_n", "_N")
    ss.columns = ss.columns.str.replace("_se", "_SE")
    ss.columns = ss.columns.str.replace("_z", "_Z")
    ss.columns = ss.columns.str.replace("a1", "A1")
    ss.columns = ss.columns.str.replace("a2", "A2")
    ss.columns = ss.columns.str.replace("snp", "SNP")

    nrow_before = ss.shape[0]
    print(f"Number of SNPs before filtering: {nrow_before}")

    # filter hwe p-values < 10^-6
    ss = ss[ss["p"] < 10**-6]
    nrow_after = ss.shape[0]
    print(f"Number of SNPs after filtering: {nrow_after}")

    savepath = file.replace("raw", "processed")
    ss.to_csv(savepath, sep = " ", index = False, na_rep = "NA")

    print(f"Done with {file}")