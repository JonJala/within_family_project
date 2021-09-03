'''
Intended to convert ea4 sumstats to meta analysis ready
txt file.
'''

import pandas as pd

ea4 = pd.read_csv(
    "/disk/genetics4/projects/EA4/derived_data/Meta_analysis/5_Excl_UKBrel_STR_GS/2020_08_21/output/EA4_excl_UKBrel_STR_GS_2020_08_21.meta",
    delim_whitespace = True
)

ea4 = ea4.rename(
    columns = {
        "Chr" : "chromosome",
        "rsID" :"SNP",
        "BP" : "pos",
        "EAF" : "freq",
        "EA" : "A1",
        "OA" : "A2" ,
        "BETA" : "pop_Beta",
        "SE" : "pop_SE"
    }
)



ea4 = ea4[["chromosome", "SNP", "pos", "freq", "A1", "A2", "pop_Beta", "pop_SE", "Z", "P", "N"]]

print(ea4.head())

ea4.to_csv(
    "/var/genetics/proj/within_family/within_family_project/processed/ea4/ea4_excl_ukb_str_gs_2020_08_21.txt",
    sep = ' ', index = False, na_rep = "."
)