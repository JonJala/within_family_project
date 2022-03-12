library(data.table)
library(dplyr)
library(purrr)

standardize = function(x){
    out = (x - mean(x, na.rm=TRUE))/sd(x, na.rm=TRUE)
    return(out)
}

covariates = fread("/var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/phen/covar.txt")
ht_bmi = fread("/var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/phen/bmi_height_sweep7.txt")
ea = fread("/var/genetics/data/mcs/private/v1/processed/phen/EA/MCS_EA_zscore_mean.phen")
cog = fread("/var/genetics/data/mcs/private/latest/raw/phen/MDAC-2020-0031-05A-BENJAMIN_addtional_vars/csv/GENDAC_BENJAMIN_mcs_cm_structure_2021_10_08.csv")


# formatting ea
ea[,IID := paste(Benjamin_ID, Benjamin_ID, sep="_")]
ea[,FID := IID]
ea[, Benjamin_ID := NULL]

# formatting cognition
cog = cog[, c(grep("(GCNAAS0|Benjamin*)", names(cog))), with=FALSE]
cog$cog = rowSums(cog[, grep("GCNAAS0", names(cog)), with=FALSE])
cog[, cog := standardize(cog)]

cog[,IID := paste(Benjamin_ID, Benjamin_ID, sep="_")]
cog[,FID := IID]
cog[, Benjamin_ID := NULL]
cog[, Benjamin_FID := NULL]
cog[, grep("GCNAAS0", names(cog)) := NULL]

# setting names properly
setnames(ea, old=c("Z_EA"), new=c("ea"))
setnames(ht_bmi, old=c("height7", "bmi7"), new=c("height", "bmi"))

phenotypes = reduce(list(ht_bmi, ea, cog), merge, by = c("FID", "IID"), all=TRUE)
phenotypes = merge(phenotypes, covariates, by = c("FID", "IID"), all=TRUE)

# formatting bmi and height
phenotypes[, bmi := standardize(bmi), by=sex]
phenotypes[, height := standardize(height), by=sex]

fwrite(phenotypes, file="/var/genetics/proj/within_family/within_family_project/processed/fpgs/phenotypes.txt", sep=" ", na=".")