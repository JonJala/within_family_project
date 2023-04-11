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

# define functions to help with processing
standardize <- function(x) {
    out = (x - mean(x, na.rm=TRUE))/sd(x, na.rm=TRUE)
    return(out)
}

read_and_rename <- function(pheno_code, pheno_name, file_path = "/var/genetics/data/mcs/private/latest/raw/phen/MDAC-2020-0031-05A-BENJAMIN_addtional_vars/csv/GENDAC_BENJAMIN_mcs_cm_structure_2021_10_08.csv") {
    # read in the file
    pheno = fread(file_path)
    
    # select columns
    pheno = pheno[, c(grep(paste0("(", pheno_code, "|Benjamin*)"), names(pheno))), with=FALSE]

    # rename the ID columns
    pheno[,IID := paste(Benjamin_ID, Benjamin_ID, sep="_")]
    pheno[,FID := IID]

    # get rid of the Benjamin ID columns
    pheno[, grep("Benjamin_", names(pheno)) := NULL]

    # rename pheno
    setnames(pheno, pheno_code, pheno_name)

    # drop NAs
    pheno = na.omit(pheno)

    return(pheno)
}

# read in covariates
covariates = fread("/var/genetics/data/mcs/private/v1/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/covar_sas.txt")

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
phenotypes = merge(phenotypes, covariates, by = c("FID", "IID"), all=TRUE)

filter_and_std <- function(data, sample_path) {

    ## filter to just get relevant sample
    sample = fread(sample_path, col.names = c("FID", "IID"))
    data %<>% filter(IID %in% sample$IID)

    ## standardize

    # standardize bmi and height by sex
    data[, bmi := standardize(bmi), by=sex]
    data[, height := standardize(height), by=sex]

    # standardize ea
    data[, ea := standardize(ea)]

    ## remove duplicated rows
    data = distinct(data, .keep_all = TRUE)

    return(data)

}

## get eur sample
sas_pheno <- filter_and_std(phenotypes, "/disk/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/filter_extract/sas_samples_mz_removed.txt")
fwrite(sas_pheno, file="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/phenotypes_sas.txt", sep=" ", na="NA", quote = FALSE)

## get eur sample
eur_pheno <- filter_and_std(phenotypes, "/disk/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/filter_extract/eur_samples_mz_removed.txt")
fwrite(eur_pheno, file="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/phenotypes_eur.txt", sep=" ", na="NA", quote = FALSE)
