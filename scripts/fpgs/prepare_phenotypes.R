library(data.table)
library(dplyr)

standardize = function(x){
    out = (x - mean(x, na.rm=TRUE))/sd(x, na.rm=TRUE)
    return(out)
}

covariates = fread("/var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/phen/covar.txt")
ht_bmi = fread("/var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/phen/bmi_height_sweep7.txt")
ea = fread("/var/genetics/data/mcs/private/v1/processed/phen/EA/MCS_EA_zscore_mean.phen")

ea[,IID := paste(Benjamin_ID, Benjamin_ID, sep="_")]
ea[,FID := IID]
ea[, Benjamin_ID := NULL]

setnames(ea, old=c("Z_EA"), new=c("EA"))
setnames(ht_bmi, old=c("height7", "bmi7"), new=c("height", "bmi"))

phenotypes = merge(ht_bmi, ea, by=c("FID", "IID"), all=TRUE)
phenotypes = merge(phenotypes, covariates, by=c("FID", "IID"), all=TRUE)

phenotypes[, bmi_std := standardize(bmi), by=sex]
phenotypes[, height_std := standardize(height), by=sex]

fwrite(phenotypes, file="/var/genetics/proj/within_family/within_family_project/processed/fpgs/phenotypes.txt", sep=" ")