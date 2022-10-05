import pandas as pd
import numpy as np

# read in ukb data 
pheno_file = pd.read_csv("/disk/genetics3/data_dirs/ukb/private/v3/processed/proj/within_family/phen/UKB_health.pheno", sep = " ") # hospital and gp data adjusted UKB health phenos
income_data = pd.read_csv("/disk/genetics4/projects/EA4/derived_data/WFvBF/UKB_SES.csv")

# drop unneeded columns, add col for nonhdl
pheno_clean = pheno_file[pheno_file.columns.drop(list(pheno_file.filter(regex="res_|raw_|PC|Batch|BYEAR")))]
pheno_clean["BL_NONHDL"] = pheno_clean["BL_CHOL"] - pheno_clean["BL_HDL"]
pheno_clean = pheno_clean.loc[pheno_clean["BL_NONHDL"] >= 0,:]
pheno_clean.drop(["BL_LDL", "BL_TRYG", "BPpulse", "BRCA", "COPD", "HARDCAD", "IBD", "PRCA", "SOFTCAD", "T2D", "BL_CHOL"], axis = 1, inplace = True)

# harmonize ids
id_file = pd.read_csv("/disk/genetics2/ukb/orig/UKBv3/crosswalk/ukb_imp_chr1_22_v3.ukb11425_imp_chr1_22_v3_s487395.crosswalk", sep = " ", names = ["ID1", "ID2"])
pheno_clean = pheno_clean.merge(id_file, left_on = "FID", right_on = "ID1")
pheno_clean["FID"] = pheno_clean["ID2"]
pheno_clean["IID"] = pheno_clean["ID2"]
pheno_clean.drop(["ID1", "ID2"], axis = 1, inplace = True)

# add income data and standardize by sex
pheno_clean = pheno_clean.merge(income_data[["n_eid", "logyh_hourly"]], left_on = "FID", right_on = "n_eid")
income_std = pheno_clean[["logyh_hourly", "Sex", "FID"]]
income_std["income"] = income_std.filter(["logyh_hourly", "Sex"]).groupby("Sex").transform(lambda x: (x - x.mean()) / x.std())
pheno_clean = pheno_clean.merge(income_std[["FID", "income"]], on = "FID")
pheno_clean = pheno_clean[pheno_clean.columns.drop(list(pheno_clean.filter(regex="Sex|logyh_hourly|n_eid")))] # drop sex columns and untransformed income

# rename cols
pheno_clean.rename(columns={"ASTHMA": "asthma", "BL_HDL": "HDL", "BPdia": "bpd", "BPsys": "bps", "ECZEMA": "eczema", "HAYFEVER": "hayfever", "MIGRAINE": "migraine", "NEARSIGHTED": "nearsight", "BL_NONHDL": "nonhdl"}, inplace = True) # maybe remove this

# standardize non-binary phenotypes
nonbinary_phenos = ["HDL", "bpd", "bps", "nonhdl"]
for pheno in nonbinary_phenos:
    pheno_clean[pheno] = (pheno_clean[pheno] - np.nanmean(pheno_clean[pheno])) / np.nanstd(pheno_clean[pheno])

# save
pheno_clean.to_csv("/disk/genetics3/data_dirs/ukb/private/v3/processed/proj/within_family/phen/UKB_health_income_std_WF.pheno", sep = " ", index = False, na_rep = "NA")