import pandas as pd
import numpy as np

ea4 = pd.read_csv(
    '/var/genetics/proj/ea4/output/meta-analyses/1_Main/EA4_2020_01_18.meta',
    delim_whitespace=True,
)
 

ea4 = ea4[['rsID', 'EA', 'OA', 'EAF', 'BETA', 'SE', 'P', 'N']]
print(ea4.head())

ea4 = ea4[ea4['N'] > 3000000]

# import pdb;pdb.set_trace()

# hm3 = pd.read_csv("/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist", delim_whitespace=True)
# ea4 = ea4[ea4['rsID'].isin(hm3.SNP)].reset_index(drop = True)

ea4.to_csv(
    '/var/genetics/proj/within_family/within_family_project/processed/ea4/ea4_full_forsabyesr.sumstats',
    index=False,
    sep=' ',
    na_rep='nan'
)