#!/usr/bin/bash

import pandas as pd
import numpy as np
from scipy.stats import norm

## read in jackknife estimates from ldsc
directrg = pd.read_excel("/disk/genetics/proj/within_family/within_family_project/processed/package_output/directrg_tables.xlsx", sheet_name = "est_del")
poprg = pd.read_excel("/disk/genetics/proj/within_family/within_family_project/processed/package_output/populationrg_tables.xlsx", sheet_name = "est_del")

## take difference between direct and population rg estimates for each pair of traits
diff = directrg - poprg
diff = diff.drop("Unnamed: 0", axis = 1)
means = diff.mean()

## calculate jackknife variance
n = 200
df = pd.DataFrame(columns = ["trait", "diff", "var", "se", "z", "p"])
for i in range(diff.shape[1]):
    diff_jack = (diff.iloc[:,i] - means[i])**2
    var_jack = (n-1)/n * diff_jack.sum()
    se_jack = np.sqrt(var_jack)
    row = pd.DataFrame({"trait": [diff.columns[i]], "diff": [means.iloc[i]],  "var": [var_jack], "se": [se_jack], "z": [means.iloc[i]/se_jack], "p": [2*(1-norm.cdf(abs(means.iloc[i]/se_jack)))]})
    df = df.append(row)
df.to_csv("/disk/genetics/proj/within_family/within_family_project/processed/ldsc/jackknife_pvals.csv", index = False)
