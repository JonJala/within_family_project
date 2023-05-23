library(data.table)
library(dplyr)
library(purrr)
library(haven)
library(tibble)
library(magrittr)
library(foreign)
library(metamisc)

#---------------------------------------------------------------------------------------------------------------------
# prepare MCS phenotypes
#---------------------------------------------------------------------------------------------------------------------

# PROCESSING STEPS:
# 1. find / read in the MCS data file containing the pheno
# 2. select the pheno and two ID columns
# 3. rename the two ID columns to IID and FID, where FID = IID = Benjamin ID x 2
# 4. get rid of the Benjamin ID columns
# 5. perform whatever processing you need on the pheno, e.g. standardization, remove outliers, renaming, drop NAs, etc.
# 6. merge all the phenos by FID and IID
# 7. save

## define functions to help with processing

## read in file and rename columns
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

## filter to get relevant sample only
filter_sample <- function(data, sample) {
    data <- data %>% 
            filter(IID %in% sample$IID)
    return(data)
}

## set mean to 0 and variance 1
standardize <- function(x) {
    out = (x - mean(x, na.rm=TRUE))/sd(x, na.rm=TRUE)
    return(out)
}

## function to remove outliers and negative values
remove_outliers <- function(y, remove_upper = F, remove_lower = F, remove_neg = F) {
  
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

## average of english and math grade z-scores
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

ht_bmi = fread("/var/genetics/data/mcs/private/latest/raw/downloaded/NCDS_SFTP_1TB_1/imputed/phen/bmi_height_sweep7.txt")

# rename
setnames(ht_bmi, old=c("height7", "bmi7"), new=c("height", "bmi"))

#---------------------------------------------------------------------------------------------------------------------
# cognition
#---------------------------------------------------------------------------------------------------------------------

## MCS verbal similarity score. ranges from 0 to 19.

cogverb = fread("/var/genetics/data/mcs/private/v1/raw/phen/GENDAC-2022-05-26_sweep6wordscore/csv/GENDAC_BENJAMIN_mcs_cm_structure_26-05-2022.csv")

# formatting cognition
cogverb = cogverb[, c(grep("(FCWRDSC|Benjamin*)", names(cogverb))), with=FALSE]
cogverb$cogverb = rowSums(cogverb[, grep("FCWRDSC", names(cogverb)), with=FALSE])

cogverb[,IID := paste(Benjamin_ID, Benjamin_ID, sep="_")]
cogverb[,FID := IID]
cogverb[, Benjamin_ID := NULL]
cogverb[, Benjamin_FID := NULL]
cogverb[, grep("FCWRDSC", names(cogverb)) := NULL]

## MCS cognitive assessment score

cog_out = read_sav("/var/genetics/data/mcs/private/v1/raw/phen/MDAC-2020-0031-05A-BENJAMIN_mcs_HHGRID7_CORRECTION_COGASS/MDAC-2020-0031-05A-BENJAMIN_mcs_hhgrid7_correction_20221004.sav")
cog_phen = fread("/var/genetics/data/mcs/private/v1/raw/phen/MDAC-2020-0031-05A-BENJAMIN_addtional_vars/csv/GENDAC_BENJAMIN_mcs_cm_structure_2021_10_08.csv")
cog_phen = cog_phen[, c(grep("GCNAAS0|Benjamin", names(cog_phen))), with=FALSE]

# map to correct answers from mcs data dictionary archive (https://beta.ukdataservice.ac.uk/datacatalogue/studies/study?id=8682#!/documentation)
cog_phen_final <- cog_phen %>%
        mutate(GCNAAS0A = ifelse(GCNAAS0A == 5, 1, 0),
                GCNAAS0B = ifelse(GCNAAS0B == 1, 1, 0),
                GCNAAS0C = ifelse(GCNAAS0C == 3, 1, 0),
                GCNAAS0D = ifelse(GCNAAS0D == 4, 1, 0),
                GCNAAS0E = ifelse(GCNAAS0E == 1, 1, 0),
                GCNAAS0F = ifelse(GCNAAS0F == 5, 1, 0),
                GCNAAS0G = ifelse(GCNAAS0G == 4, 1, 0),
                GCNAAS0H = ifelse(GCNAAS0H == 4, 1, 0),
                GCNAAS0I = ifelse(GCNAAS0I == 2, 1, 0),
                GCNAAS0J = ifelse(GCNAAS0J == 5, 1, 0))

# filter out incomplete individuals and individuals with 6 or more missing answers
cog_ass_partial <- cog_out %>% 
            select(benjamin_id, benjamin_fid, G_OUT_COGASS) %>%
            merge(cog_phen_final, by.x = "benjamin_id", by.y = "Benjamin_ID") %>%
            filter(G_OUT_COGASS == 1) %>% # only keep partially and fully productive individuals 
            distinct(benjamin_id, .keep_all = TRUE)
cog_ass_partial %<>% 
    mutate(n_nas = rowSums(is.na(cog_ass_partial[c(grep("GCNAAS0", names(cog_ass_partial)))]))) %>%
    filter(n_nas < 6) %>%
    select(-n_nas, -G_OUT_COGASS, -Benjamin_FID)

# create dataframe with imputed values
mat <- as.matrix(cog_ass_partial[c(grep("GCNAAS0", names(cog_ass_partial)))])
rownames(mat) <- cog_ass_partial$benjamin_id
cov <- as.matrix(cov(mat, use = "complete.obs"))
mu <- as.vector(colMeans(mat, na.rm = TRUE))
filled <- t(apply(mat, 1, function(x) impute_conditional_mean(x, mu, cov)))
filled[filled > 1] <- 1 # threshold values so that they're between 0 and 1
filled[filled < 0] <- 0
cog_ass_filled <- cbind(cog_ass_partial[1:2], filled)
names(cog_ass_filled) <- c("benjamin_id", "benjamin_fid", "GCNAAS0A", "GCNAAS0B", "GCNAAS0C", "GCNAAS0D", "GCNAAS0E", "GCNAAS0F", "GCNAAS0G", "GCNAAS0H", "GCNAAS0I", "GCNAAS0J")

# sum over responses to create cognition variable, and drop duplicates. final variable ranges from 0 to 10.
cognition <- cog_ass_filled %>%
            mutate(cognition = rowSums(across(c(grep("GCNAAS0", names(cog_ass_filled)))), na.rm = TRUE),
            IID = paste(benjamin_id, benjamin_id, sep="_"),
            FID = IID) %>%
            select(IID, FID, cognition) %>%
            distinct(FID, .keep_all = TRUE)
rownames(cognition) <- NULL

#---------------------------------------------------------------------------------------------------------------------
# depression
#---------------------------------------------------------------------------------------------------------------------

# depression is reverse coded compared to our cohorts (1 = depression, 2 = no depression). convert to binary 0/1, 1 = has depression.
dep <- read_and_rename("GCDEAN00", "depression")
dep[depression == 2, depression := 0]
dep[depression == -1, depression := NA] # set -1 to NA

#---------------------------------------------------------------------------------------------------------------------
# adhd
#---------------------------------------------------------------------------------------------------------------------

adhd <- read_and_rename("GHYPER_C", "adhd") # score from 0-10 corresponding to hyperactivity/inattention score. note: NOT BINARY

#---------------------------------------------------------------------------------------------------------------------
# age at menarche
#---------------------------------------------------------------------------------------------------------------------

menarche <- read_and_rename("GCAGMN00", "agemenarche")

#---------------------------------------------------------------------------------------------------------------------
# eczema
#---------------------------------------------------------------------------------------------------------------------

eczema <- read_and_rename("GCCLSM0P", "eczema")
# summary(eczema) # coded as 0 1 binary variable

#---------------------------------------------------------------------------------------------------------------------
# ever cannabis
#---------------------------------------------------------------------------------------------------------------------

cann <- read_and_rename("GCDRUA00", "cannabis")
# table(cann$cannabis) # coded as 2, 1, -1; 2 = no, 1 = yes, -1 = missing? (https://cls.ucl.ac.uk/wp-content/uploads/2020/01/MCS7-Young-Person-Self-Completion-Questionnaire.pdf)

# reverse coding and set missing to NA
cann[cannabis == 2, cannabis := 0]
cann[cannabis == -1, cannabis := NA]

#---------------------------------------------------------------------------------------------------------------------
# drinks in last 12 months
#---------------------------------------------------------------------------------------------------------------------

drinks_12 <- read_and_rename("GCALCN00", "drinks_12_months")

# 1 Never
# 2 1-2 times
# 3 3-5 times
# 4 6-9 times
# 5 10-19 times
# 6 20-39 times
# 7 40 or more times

# take midpoint of each bin
# 1 = 0; 2 = 1.5; 3 = 4; 4 = 7.5; 5 = 14.5; 6 = 29.5; 7 = 40
drinks_12[drinks_12_months == 1, drinks_12_months := 0]
drinks_12[drinks_12_months == 2, drinks_12_months := 1.5]
drinks_12[drinks_12_months == 3, drinks_12_months := 4]
drinks_12[drinks_12_months == 4, drinks_12_months := 7.5]
drinks_12[drinks_12_months == 5, drinks_12_months := 14.5]
drinks_12[drinks_12_months == 6, drinks_12_months := 29.5]
drinks_12[drinks_12_months == 7, drinks_12_months := 40]

# set missing to NA
drinks_12[drinks_12_months == -1, drinks_12_months := NA]

#---------------------------------------------------------------------------------------------------------------------
# drinks in last 4 weeks
#---------------------------------------------------------------------------------------------------------------------

drinks_4 <- read_and_rename("GCALNF00", "dpw")

# 1 Never
# 2 1-2 times
# 3 3-5 times
# 4 6-9 times
# 5 10-19 times
# 6 20-39 times
# 7 40 or more times

# take midpoint of each bin
# 1 = 0; 2 = 1.5; 3 = 4; 4 = 7.5; 5 = 14.5; 6 = 29.5; 7 = 40
drinks_4[dpw == 1, dpw := 0]
drinks_4[dpw == 2, dpw := 1.5]
drinks_4[dpw == 3, dpw := 4]
drinks_4[dpw == 4, dpw := 7.5]
drinks_4[dpw == 5, dpw := 14.5]
drinks_4[dpw == 6, dpw := 29.5]
drinks_4[dpw == 7, dpw := 40]

# set missing to NA
drinks_4[dpw == -1, dpw := NA]

#---------------------------------------------------------------------------------------------------------------------
# depressive symptoms
#---------------------------------------------------------------------------------------------------------------------

dep_symp <- read_and_rename("GDCKESSL", "depsymp")
# table(dep_symp$depressive_symptoms) # 0 to 24

#---------------------------------------------------------------------------------------------------------------------
# ever smoker
#---------------------------------------------------------------------------------------------------------------------

es <- read_and_rename("GCSMOK00", "eversmoker")
# table(es$ever_smoker) # coded 1-6, -1 = missing?

# 1 I have never smoked cigarettes
# 2 I have only ever tried smoking cigarettes once
# 3 I used to smoke sometimes but I never smoke a cigarette now
# 4 I sometimes smoke cigarettes now but I don’t smoke as many as one a week
# 5 I usually smoke between one and six cigarettes a week
# 6 I usually smoke more than six cigarettes a week 

# code as binary variable and -1 to NA
es[eversmoker == -1, eversmoker := NA]
es[eversmoker == 1, eversmoker := 0]
es[eversmoker > 0, eversmoker := 1]

#---------------------------------------------------------------------------------------------------------------------
# extraversion
#---------------------------------------------------------------------------------------------------------------------

extra <- read_and_rename("GDCEXTRAV", "extraversion")
# table(extra$extraversion)

## scores should be between 3 and 21. remove values below 3.
extra[extraversion < 3, extraversion := NA]

#---------------------------------------------------------------------------------------------------------------------
# hayfever
#---------------------------------------------------------------------------------------------------------------------

hayfever = copy(eczema) # same variable code

# rename pheno
hayfever[, hayfever := eczema]
hayfever[, eczema := NULL]

#---------------------------------------------------------------------------------------------------------------------
# hhincome
#---------------------------------------------------------------------------------------------------------------------

## read in data
fid_map = fread("/var/genetics/data/mcs/private/latest/raw/phen/MDAC-2020-0031-05A-BENJAMIN_addtional_vars/csv/GENDAC_BENJAMIN_mcs_cm_structure_2021_10_08.csv", select = c("Benjamin_ID", "Benjamin_FID"))
hhincome = as.data.table(read_sav("/var/genetics/data/mcs/private/v1/raw/phen/MDAC-2020-0031-05A-BENJAMIN_v7_mcs_family_structure_20221208.sav"))

## rename columns and log transform
hhincome = merge(hhincome, fid_map, by.x = "benjamin_fid", by.y = "Benjamin_FID")
hhincome[,IID := paste(Benjamin_ID, Benjamin_ID, sep="_")]
hhincome %<>% 
    mutate(FID = IID, hhincome = log(FOEDE000)) %>%
    select(FID, IID, hhincome)

#---------------------------------------------------------------------------------------------------------------------
# neuroticism
#---------------------------------------------------------------------------------------------------------------------

neuro <- read_and_rename("GDCNEUROT", "neuroticism")
# table(neuro$neuroticism)

## scores should be between 3 and 21. exclude values below 3.
neuro[neuroticism < 3, neuroticism := NA]

#---------------------------------------------------------------------------------------------------------------------
# self-rated health
#---------------------------------------------------------------------------------------------------------------------

health <- read_and_rename("GCCGHE00", "self_rated_health")
# table(health$self_rated_health) # 1 to 5, -1 = missing? need to reverse order of scale so that higher values = higher level of wellbeing

# reorder scale
health[self_rated_health == 1, health := 5]
health[self_rated_health == 2, health := 4]
health[self_rated_health == 3, health := 3]
health[self_rated_health == 4, health := 2]
health[self_rated_health == 5, health := 1]
health[self_rated_health == -1, health := NA]
health[, self_rated_health := NULL]

#---------------------------------------------------------------------------------------------------------------------
# subjective well-being
#---------------------------------------------------------------------------------------------------------------------

swb <- read_and_rename("GDWEMWBS", "swb")
# summary(swb$swb) # looks fine -- score from 7 to 35

#---------------------------------------------------------------------------------------------------------------------
# merge phenos, standardize and remove outliers
#---------------------------------------------------------------------------------------------------------------------

## merge phenos
# note: ea = average of english and math scores; cogverb = verbal similarity score; cog = cognitive assessment score
phenotypes <- reduce(list(ht_bmi, ea, cognition, cogverb, dep, adhd, menarche, eczema, cann, drinks_4, dep_symp, es, extra, hayfever, neuro, health, hhincome, swb), merge, by = c("FID", "IID"), all=TRUE)

## filter to get relevant sample
sample <- fread("/var/genetics/data/mcs/private/latest/raw/downloaded/NCDS_SFTP_1TB_1/imputed/filter_extract/eur_samples.txt", col.names = c("FID", "IID"))  # MCS EUR individuals + parents, MZ removed
phenotypes <- filter_sample(phenotypes, sample)

## process each variable as appropriate (remove outliers / negative values, standardize by sex)

# remove outliers / negative values for quantitative phenos
phenotypes$height <- remove_outliers(phenotypes$height, remove_upper = T, remove_lower = T, remove_neg = T)
phenotypes$bmi <- remove_outliers(phenotypes$bmi, remove_upper = T, remove_lower = T, remove_neg = T)
phenotypes$ea <- remove_outliers(phenotypes$ea, remove_upper = T, remove_lower = T, remove_neg = F)
phenotypes$cognition <- remove_outliers(phenotypes$cognition, remove_upper = F, remove_lower = F, remove_neg = T)
phenotypes$cogverb <- remove_outliers(phenotypes$cogverb, remove_upper = F, remove_lower = F, remove_neg = T)
phenotypes$adhd <- remove_outliers(phenotypes$adhd, remove_upper = F, remove_lower = F, remove_neg = T)
phenotypes$agemenarche <- remove_outliers(phenotypes$agemenarche, remove_upper = T, remove_lower = T, remove_neg = T)
phenotypes$dpw <- remove_outliers(phenotypes$dpw, remove_upper = F, remove_lower = F, remove_neg = T)
phenotypes$depsymp <- remove_outliers(phenotypes$depsymp, remove_upper = F, remove_lower = F, remove_neg = T)
phenotypes$extraversion <- remove_outliers(phenotypes$extraversion, remove_upper = F, remove_lower = F, remove_neg = T)
phenotypes$neuroticism <- remove_outliers(phenotypes$neuroticism, remove_upper = F, remove_lower = F, remove_neg = T)
phenotypes$health <- remove_outliers(phenotypes$health, remove_upper = F, remove_lower = F, remove_neg = T)
phenotypes$hhincome <- remove_outliers(phenotypes$hhincome, remove_upper = T, remove_lower = T, remove_neg = T)
phenotypes$swb <- remove_outliers(phenotypes$swb, remove_upper = F, remove_lower = F, remove_neg = T)

## standardize by sex

# read in covariates and merge
covariates <- fread("/var/genetics/data/mcs/private/latest/raw/downloaded/NCDS_SFTP_1TB_1/imputed/phen/covar.txt")
phenotypes <- left_join(phenotypes, covariates, by = c("FID", "IID"))

# standardize by sex
phenotypes[, height := standardize(height), by=sex]
phenotypes[, bmi := standardize(bmi), by=sex]
phenotypes[, ea := standardize(ea), by=sex]
phenotypes[, cognition := standardize(cognition), by=sex]
phenotypes[, cogverb := standardize(cogverb), by=sex]
phenotypes[, adhd := standardize(adhd), by=sex]
phenotypes[, agemenarche := standardize(agemenarche), by=sex]
phenotypes[, dpw := standardize(dpw), by=sex]
phenotypes[, depsymp := standardize(depsymp), by=sex]
phenotypes[, extraversion := standardize(extraversion), by=sex]
phenotypes[, neuroticism := standardize(neuroticism), by=sex]
phenotypes[, health := standardize(health), by=sex]
phenotypes[, hhincome := standardize(hhincome), by=sex]
phenotypes[, swb := standardize(swb), by=sex]

# remove duplicated rows
phenotypes = distinct(phenotypes, .keep_all = TRUE)

# save
fwrite(phenotypes, file="/var/genetics/data/mcs/private/latest/raw/downloaded/NCDS_SFTP_1TB_1/imputed/phen/phenotypes.txt", sep=" ", na="NA", quote = FALSE)
