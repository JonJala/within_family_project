'''
Rename iPSYCH sumstats columns so that they align with QC pipeline
'''

import pandas as pd
import glob

files = glob.glob("/var/genetics/data/ipsych/public/v1/raw/sumstats/sumstats_*")

for file in files:

    print(file)

    ss = pd.read_csv(file, sep = "\t")
    ss.columns = ss.columns.str.replace("_beta", "_Beta")
    ss.columns = ss.columns.str.replace("_ntc", "_NTC")
    ss.columns = ss.columns.str.replace("_n", "_N")
    ss.columns = ss.columns.str.replace("_se", "_SE")
    ss.columns = ss.columns.str.replace("_z", "_Z")
    ss.columns = ss.columns.str.replace("a1", "A1")
    ss.columns = ss.columns.str.replace("a2", "A2")
    ss.columns = ss.columns.str.replace("snp", "SNP")

    savepath = file.replace("raw", "processed")
    ss.to_csv(savepath, sep = " ", index = False, na_rep = "NA")

    print(f"Done with {file}")