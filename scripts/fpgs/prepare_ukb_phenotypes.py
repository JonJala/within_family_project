#---------------------------------------------------------------------------------------------------------------------
# prepare UKB phenotypes
#---------------------------------------------------------------------------------------------------------------------

import pandas as pd
import numpy as np

#---------------------------------------------------------------------------------------------------------------------
# load data
#---------------------------------------------------------------------------------------------------------------------

# original ukb pheno file from alex
ukb_phenos = pd.read_csv("/disk/genetics/ukb/alextisyoung/phenotypes/processed_traits_noadj.txt", sep = " ") # note: FID == FID.1 == FID.2 == IID

# ea4 ea / cognition phenotype
ea_pheno = pd.read_csv("/disk/genetics4/ws_dirs/mbennett/UKB_EAfixed_resid.pheno", sep = "\t")
# (same as /disk/genetics4/projects/EA4/derived_data/GWAS/UKB/input/UKB_EAfixed_resid.pheno ?)

# health phenotypes from ukb gp and hospital admissions data, from aysu
health_phenos = pd.read_csv("/var/genetics/data/ukb/private/v3/processed/proj/within_family/phen/UKB_health.pheno", sep = " ")

# log income pheno derived from occupation
income_data = pd.read_csv("/var/genetics/proj/ea4/derived_data/WFvBF/UKB_SES.csv")

#---------------------------------------------------------------------------------------------------------------------
# define functions
#---------------------------------------------------------------------------------------------------------------------

def standardize_by_sex(data, phenos):
    for pheno in phenos:
        data[pheno] = data.filter([pheno, "Sex"]).groupby("Sex").transform(lambda x: (x - x.mean()) / x.std())
    return(data)

def remove_outliers(data, pheno, remove_upper = False, remove_lower = False, remove_neg = False):
    if remove_neg:
        data.loc[data[pheno] < 0, pheno] = np.nan
    if remove_upper:
        data.loc[data[pheno] > data[pheno].quantile(0.9995), pheno] = np.nan
    if remove_lower:
        data.loc[data[pheno] < data[pheno].quantile(0.0005), pheno] = np.nan
    return(data)

#---------------------------------------------------------------------------------------------------------------------
# process health phenotypes
#---------------------------------------------------------------------------------------------------------------------

# drop unneeded columns
pheno_clean = health_phenos[health_phenos.columns.drop(list(health_phenos.filter(regex="res_|raw_|PC|Batch|BYEAR")))]
pheno_clean.drop(["BL_TRYG", "BPpulse", "BRCA", "COPD", "HARDCAD", "IBD", "PRCA", "SOFTCAD", "T2D", "BL_CHOL", "ASTECZRHI"], axis = 1, inplace = True)

# harmonize ids
id_file = pd.read_csv("/disk/genetics2/ukb/orig/UKBv3/crosswalk/ukb_imp_chr1_22_v3.ukb11425_imp_chr1_22_v3_s487395.crosswalk", sep = " ", names = ["ID1", "ID2"]) # first col has the pheno "sample_" ID, second col has the ID we need
pheno_clean = pheno_clean.merge(id_file, left_on = "FID", right_on = "ID1")
pheno_clean["FID"] = pheno_clean["ID2"]
pheno_clean["IID"] = pheno_clean["ID2"]
pheno_clean.drop(["ID1", "ID2"], axis = 1, inplace = True)

#---------------------------------------------------------------------------------------------------------------------
# add ea and income
#---------------------------------------------------------------------------------------------------------------------

pheno_clean = pheno_clean.merge(income_data[["n_eid", "logyh_hourly"]], left_on = "IID", right_on = "n_eid")
pheno_clean = pheno_clean.merge(ea_pheno[["IID", "resid_EAfixed"]], on = "IID")

#---------------------------------------------------------------------------------------------------------------------
# filter to relevant sample, remove outliers and standardize by sex
#---------------------------------------------------------------------------------------------------------------------

# Get sample QC
sqc = pd.read_csv('/disk/genetics2/ukb/orig/UKBv2/linking/ukb_sqc_v2_combined_header.txt', sep = " ")

# Get withdrawn participants
withdrawn = pd.read_csv('/var/genetics/data/ukb/private/v3/misc/linking/ukb_withdrawn_ind.csv', names = ["IID"])

# Filter sample 
sample = sqc[(sqc["het.missing.outliers"]==0) & (sqc["putative.sex.chromosome.aneuploidy"]==0) & (sqc["excess.relatives"]==0) & (sqc["in.white.British.ancestry.subset"]==1) & (~sqc["IID"].isin(withdrawn["IID"]))]

# filter to get relevant sample only
pheno_clean = pheno_clean[pheno_clean["IID"].isin(sample["IID"])]

# remove outliers
pheno_clean = remove_outliers(pheno_clean, "BL_HDL", remove_upper = True, remove_lower = True, remove_neg = False)
pheno_clean = remove_outliers(pheno_clean, "BPdia", remove_upper = True, remove_lower = True, remove_neg = False)
pheno_clean = remove_outliers(pheno_clean, "BPsys", remove_upper = True, remove_lower = True, remove_neg = False)
pheno_clean = remove_outliers(pheno_clean, "BL_LDL", remove_upper = True, remove_lower = True, remove_neg = False)
pheno_clean = remove_outliers(pheno_clean, "logyh_hourly", remove_upper = True, remove_lower = True, remove_neg = True)

# standardize non-binary phenotypes by sex
nonbinary_phenos = ["BL_HDL", "BPdia", "BPsys", "BL_LDL", "logyh_hourly", "resid_EAfixed"]
pheno_clean = standardize_by_sex(pheno_clean, nonbinary_phenos)

# drop unneeded columns
pheno_clean = pheno_clean[pheno_clean.columns.drop(list(pheno_clean.filter(regex="Sex|n_eid")))]
ukb_phenos = ukb_phenos[["FID", "IID", "cigarettes.per.day", "self.rated.health", "BMI", "Cognitive.ability", "Neuroticism", 
                        "AAFB", "household.income", "subjective.well.being", "drinks.per.week", "height", "menarche", "FEV1", 
                        "depressive.symptoms", "ever.smoked", "ever.cannabis", "morning.person", "NC"]]

# merge
pheno_clean = pheno_clean.merge(ukb_phenos, on = ["FID", "IID"], how = "outer")

# rename cols
pheno_clean.rename(columns={"ASTHMA": "asthma", "BL_HDL": "hdl", "BPdia": "bpd", "BPsys": "bps", "ECZEMA": "eczema", "HAYFEVER": "hayfever", 
                            "MIGRAINE": "migraine", "NEARSIGHTED": "nearsight", "BL_LDL": "nonhdl", "resid_EAfixed": "ea", "cigarettes.per.day": "cpd",
                            "self.rated.health": "health", "BMI": "bmi", "Cognitive.ability": "cognition", "Neuroticism": "neuroticism", "AAFB": "aafb",
                            "household.income": "hhincome", "subjective.well.being": "swb", "drinks.per.week": "dpw", "menarche": "agemenarche",
                            "FEV1": "fev", "depressive.symptoms": "depsymp", "ever.smoked": "eversmoker", "ever.cannabis": "cannabis", "morning.person": "morningperson",
                            "NC": "nchildren", "logyh_hourly": "income"}, inplace = True)

# save
pheno_clean.to_csv("/var/genetics/data/ukb/private/v3/processed/proj/within_family/phen/ukb_phenos.txt", sep = " ", index = False, na_rep = "NA")