'''
Cleaning the PGI depression GWAS
sum stat.
Used for seeing if fgwas results
provided make sense.
'''

import pandas as pd 
import numpy as np

mdd_ref = pd.read_csv('/disk/genetics/PGS/Aysu/PGS_Repo_pipeline/derived_data/1_UKB_GWAS/output/DEPRESS/UKB_DEPRESS_part3_BOLTLMM_plink',
        delim_whitespace = True)

# calculate effective N
f = np.array(mdd_ref['A1FREQ'].tolist())
sigma = np.array(mdd_ref['SE'].tolist())

mdd_ref['N'] = np.round((2*f*(1-f)*sigma**2)**(-1)).astype('int')


# Make MAF
mdd_ref['MAF'] = 1.0 - mdd_ref['A1FREQ']

# renaming cols
mdd_ref = mdd_ref.rename(columns = {'ALLELE1' : 'A2',
                        'ALLELE0' : 'A1'})

mdd_ref.to_csv(
    "/var/genetics/proj/within_family/within_family_project/processed/mdd_ref/UKB_DEPRESS_part3_BOLTLMM_plink_Neff",
    sep = " "
)