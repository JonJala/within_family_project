#---------------------------------------------------------------------------------------------------------------------
# prepare UKB phenotypes
#---------------------------------------------------------------------------------------------------------------------

import pandas as pd
import numpy as np

#---------------------------------------------------------------------------------------------------------------------
# load data
#---------------------------------------------------------------------------------------------------------------------

# original ukb pheno file from alex
ukb_phenos = pd.read_csv("/disk/genetics/ukb/alextisyoung/phenotypes/processed_traits_noadj.txt", sep = " ")

# ea4 ea / cognition phenotype
ea_pheno = pd.read_csv("/disk/genetics4/ws_dirs/mbennett/UKB_EAfixed_resid.pheno", sep = "\t")

# health phenotypes from ukb gp and hospital admissions data, from aysu
health_phenos = pd.read_csv("/disk/genetics3/data_dirs/ukb/private/v3/processed/proj/within_family/phen/UKB_health.pheno", sep = " ")

# log income pheno derived from occupation
income_data = pd.read_csv("/disk/genetics4/projects/EA4/derived_data/WFvBF/UKB_SES.csv")

#---------------------------------------------------------------------------------------------------------------------
# process health phenotypes
#---------------------------------------------------------------------------------------------------------------------

# drop unneeded columns, add col for nonhdl
pheno_clean = health_phenos[health_phenos.columns.drop(list(health_phenos.filter(regex="res_|raw_|PC|Batch|BYEAR")))]
pheno_clean["BL_NONHDL"] = pheno_clean["BL_CHOL"] - pheno_clean["BL_HDL"]
pheno_clean = pheno_clean.loc[pheno_clean["BL_NONHDL"] >= 0,:]
pheno_clean.drop(["BL_LDL", "BL_TRYG", "BPpulse", "BRCA", "COPD", "HARDCAD", "IBD", "PRCA", "SOFTCAD", "T2D", "BL_CHOL", "ASTECZRHI"], axis = 1, inplace = True)

# harmonize ids
id_file = pd.read_csv("/disk/genetics2/ukb/orig/UKBv3/crosswalk/ukb_imp_chr1_22_v3.ukb11425_imp_chr1_22_v3_s487395.crosswalk", sep = " ", names = ["ID1", "ID2"])
pheno_clean = pheno_clean.merge(id_file, left_on = "FID", right_on = "ID1")
pheno_clean["FID"] = pheno_clean["ID2"]
pheno_clean["IID"] = pheno_clean["ID2"]
pheno_clean.drop(["ID1", "ID2"], axis = 1, inplace = True)

# standardize non-binary phenotypes
nonbinary_phenos = ["BL_HDL", "BPdia", "BPsys", "BL_NONHDL"]
for pheno in nonbinary_phenos:
    pheno_clean[pheno] = (pheno_clean[pheno] - np.nanmean(pheno_clean[pheno])) / np.nanstd(pheno_clean[pheno])

#---------------------------------------------------------------------------------------------------------------------
# add income data and standardize by sex
#---------------------------------------------------------------------------------------------------------------------

pheno_clean = pheno_clean.merge(income_data[["n_eid", "logyh_hourly"]], left_on = "FID", right_on = "n_eid")
income_std = pheno_clean[["logyh_hourly", "Sex", "FID"]]
income_std["income"] = income_std.filter(["logyh_hourly", "Sex"]).groupby("Sex").transform(lambda x: (x - x.mean()) / x.std())
pheno_clean = pheno_clean.merge(income_std[["FID", "income"]], on = "FID")
pheno_clean = pheno_clean[pheno_clean.columns.drop(list(pheno_clean.filter(regex="Sex|logyh_hourly|n_eid")))] # drop sex columns and untransformed income

#---------------------------------------------------------------------------------------------------------------------
# add ea phenotype
#---------------------------------------------------------------------------------------------------------------------

pheno_clean = pheno_clean.merge(ea_pheno[["FID", "resid_EAfixed"]], on = "FID")

#---------------------------------------------------------------------------------------------------------------------
# merge with original pheno file and save
#---------------------------------------------------------------------------------------------------------------------

# drop unneeded phenos
ukb_phenos = ukb_phenos[["FID", "cigarettes.per.day", "self.rated.health", "BMI", "Cognitive.ability", "Neuroticism", 
                        "AAFB", "household.income", "subjective.well.being", "drinks.per.week", "height", "menarche", "FEV1", 
                        "depressive.symptoms", "ever.smoked", "ever.cannabis", "morning.person", "NC"]]

# merge
pheno_clean = pheno_clean.merge(ukb_phenos, on = "FID")

# rename cols
pheno_clean.rename(columns={"ASTHMA": "asthma", "BL_HDL": "hdl", "BPdia": "bpd", "BPsys": "bps", "ECZEMA": "eczema", "HAYFEVER": "hayfever", 
                            "MIGRAINE": "migraine", "NEARSIGHTED": "nearsight", "BL_NONHDL": "nonhdl", "resid_EAfixed": "ea", "cigarettes.per.day": "cpd",
                            "self.rated.health": "health", "BMI": "bmi", "Cognitive.ability": "cognition", "Neuroticism": "neuroticism", "AAFB": "aafb",
                            "household.income": "hhincome", "subjective.well.being": "swb", "drinks.per.week": "dpw", "menarche": "agemenarche",
                            "FEV1": "fev", "depressive.symptoms": "depsymp", "ever.smoked": "eversmoker", "ever.cannabis": "cannabis", "morning.person": "morningperson",
                            "NC": "nchildren"}, inplace = True)

# save
pheno_clean.to_csv("/disk/genetics3/data_dirs/ukb/private/v3/processed/proj/within_family/phen/ukb_phenos.txt", sep = " ", index = False, na_rep = "NA")

