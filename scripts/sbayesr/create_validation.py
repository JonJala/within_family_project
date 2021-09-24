'''
Creates validation cohort for generation
scotland. Intended to be used in sbayesr.
'''


import pandas as pd
import numpy as np

sampling_prop = 0.1

dat = pd.read_csv(
    "/disk/genetics/sibling_consortium/GS20k/aokbay/imputed/HRC/plink/HM3/GS_HRC_HM3.fam",
    delim_whitespace = True,
    usecols = [0, 1],
    names = ['FID', 'IID']
)

N = dat.shape[0]
sampling_n = int(np.ceil(sampling_prop * N))

print(f"Number of observations is: {N}")
print(f"Sampling {sampling_prop * 100} percent of obs, i.e. {sampling_n} observations...")

dat = dat[['FID', 'IID']]
datout = dat.sample(n=sampling_n, random_state=1)



datout.to_csv(
    "/var/genetics/proj/within_family/within_family_project/processed/sbayesr/gs_validation.fam",
    sep = "\t", na_rep = ".", index = False, header = False
)

