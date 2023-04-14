library(data.table)
library(dplyr)
library(purrr)
library(haven)
library(tibble)
library(magrittr)
library(foreign)

#---------------------------------------------------------------------------------------------------------------------
# prepare MCS phenotypes
#---------------------------------------------------------------------------------------------------------------------

# PROCESSING STEPS:
# 1. find / read in the MCS data file containing the pheno
# 2. select the pheno and two ID columns
# 3. rename the two ID columns to IID and FID, where FID = IID = Benjamin ID x 2
# 4. get rid of the Benjamin ID columns
# 5. perform whatever processing you need on the pheno.
# 6. merge all the phenos by FID and IID
# 7. save

## set mean to 0 and variance 1
standardize <- function(x) {
    out = (x - mean(x, na.rm=TRUE))/sd(x, na.rm=TRUE)
    return(out)
}

## function to remove outliers and negative values
remove_outliers <- function(y, remove_upper, remove_lower, remove_neg) {
  
  y = as.numeric(y)
  
  # Remove negatives
  if (remove_neg) {
    y[y < 0] <- NA
  }
  
  # Remove outliers (top / bottom 0.5%)
  if (remove_lower) {
    y[y < quantile(y, 0.005, na.rm = T)] <- NA
  }
  if (remove_upper) {
    y[ y > quantile(y, 0.995, na.rm = T)] <- NA
  }

  # Return
  return(y)

}

#---------------------------------------------------------------------------------------------------------------------
# ea
#---------------------------------------------------------------------------------------------------------------------

## average of english and math grades
ea = fread("/var/genetics/data/mcs/private/v1/processed/phen/EA/MCS_EA_zscore_mean.phen")

# formatting ea
ea[,IID := paste(Benjamin_ID, Benjamin_ID, sep="_")]
ea[,FID := IID]
ea[, Benjamin_ID := NULL]

# setting names properly
setnames(ea, old=c("Z_EA"), new=c("ea"))

#---------------------------------------------------------------------------------------------------------------------
# height and bmi
#---------------------------------------------------------------------------------------------------------------------

ht_bmi = fread("/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/bmi_height_sweep7.txt")

# rename
setnames(ht_bmi, old=c("height7", "bmi7"), new=c("height", "bmi"))

#---------------------------------------------------------------------------------------------------------------------
# merge phenos
#---------------------------------------------------------------------------------------------------------------------

## merge phenos
phenotypes = reduce(list(ht_bmi, ea), merge, by = c("FID", "IID"), all=TRUE)

## function to filter to relevant sample and process using remove_outliers
filter_and_std <- function(data, sample_path, covariates_path) {

    ## filter to just get relevant sample
    sample = fread(sample_path, col.names = c("FID", "IID"))
    data %<>% filter(IID %in% sample$IID)

    ## merge with covariates
    covariates <- fread(covariates_path, sep = "\t")
    data <- left_join(data, covariates, by = c("FID", "IID"))

    ## standardize bmi and height by sex to have mean 0 and variance 1. remove upper and lower outliers, and any negative values.
    data$height <- remove_outliers(data$height, remove_upper = T, remove_lower = T, remove_neg = T)
    data[, height := standardize(height), by = sex]

    data$bmi <- remove_outliers(data$bmi, remove_upper = T, remove_lower = T, remove_neg = T)
    data[, bmi := standardize(bmi), by = sex]

    ## remove upper and lower outliers from ea, standardize within sex
    data$ea <- remove_outliers(data$ea, remove_upper = T, remove_lower = T, remove_neg = F)
    data[, ea := standardize(ea), by = sex]

    ## remove duplicated rows
    data <- distinct(data, .keep_all = TRUE)

    ## remove rows with all NAs
    data <- data[!apply(is.na(data[,3:ncol(data)]), 1, all),]

    return(data)

}

## get sas sample
sas_pheno <- filter_and_std(phenotypes, sample_path = "/disk/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/filter_extract/sas_samples_mz_removed.txt", covariates_path = "/var/genetics/data/mcs/private/v1/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/covar_sas.txt")
fwrite(sas_pheno, file="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/phenotypes_sas.txt", sep=" ", na="NA", quote = FALSE)

## get eur sample
eur_pheno <- filter_and_std(phenotypes, sample_path = "/disk/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/filter_extract/eur_samples_mz_removed.txt", covariates_path = "/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/covar.txt")
fwrite(eur_pheno, file="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/phenotypes_eur.txt", sep=" ", na="NA", quote = FALSE)
