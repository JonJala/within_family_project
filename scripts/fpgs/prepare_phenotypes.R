library(data.table)
library(dplyr)
library(purrr)

#---------------------------------------------------------------------------------------------------------------------
# prepare MCS validation phenotypes
#---------------------------------------------------------------------------------------------------------------------

# PROCESSING STEPS:
# 1. find / read in the MCS data file containing the pheno
# 2. select the pheno and two ID columns
# 3. rename the two ID columns to IID and FID, where FID = IID = Benjamin ID x 2
# 4. get rid of the Benjamin ID columns
# 5. perform whatever processing you need on the pheno, e.g. standardization, renaming, drop NAs, etc.
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
covariates = fread("/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/covar.txt")

#---------------------------------------------------------------------------------------------------------------------
# ea
#---------------------------------------------------------------------------------------------------------------------

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
# cognition
#---------------------------------------------------------------------------------------------------------------------

cog = fread("/var/genetics/data/mcs/private/latest/raw/phen/MDAC-2020-0031-05A-BENJAMIN_addtional_vars/csv/GENDAC_BENJAMIN_mcs_cm_structure_2021_10_08.csv")

# formatting cognition
cog = cog[, c(grep("(GCNAAS0|Benjamin*)", names(cog))), with=FALSE]
cog$cog = rowSums(cog[, grep("GCNAAS0", names(cog)), with=FALSE])
cog[, cog := standardize(cog)]

cog[,IID := paste(Benjamin_ID, Benjamin_ID, sep="_")]
cog[,FID := IID]
cog[, Benjamin_ID := NULL]
cog[, Benjamin_FID := NULL]
cog[, grep("GCNAAS0", names(cog)) := NULL]

#---------------------------------------------------------------------------------------------------------------------
# depression
#---------------------------------------------------------------------------------------------------------------------

# depression is reverse coded compared to our cohorts
dep <- read_and_rename("GCDEAN00", "depression")
dep[depression == 2, depression := 0]
dep = dep[depression %in% c(0, 1)]

#---------------------------------------------------------------------------------------------------------------------
# adhd
#---------------------------------------------------------------------------------------------------------------------

adhd <- read_and_rename("GHYPER_C", "adhd")

# standardize
adhd[, adhd := standardize(adhd)] 

#---------------------------------------------------------------------------------------------------------------------
# age at first menarche
#---------------------------------------------------------------------------------------------------------------------

menarche <- read_and_rename("GCAGMN00", "menarche")

# remove outliers
menarche[menarche<quantile(menarche,0.001,na.rm=T)] = NA
menarche[menarche>quantile(menarche,0.999,na.rm=T)] = NA

# standardize
menarche[, menarche := standardize(menarche)]

#---------------------------------------------------------------------------------------------------------------------
# eczema
#---------------------------------------------------------------------------------------------------------------------

eczema <- read_and_rename("GCCLSM0P", "eczema")
summary(eczema) # coded as 0 1 binary variable

#---------------------------------------------------------------------------------------------------------------------
# ever cannabis
#---------------------------------------------------------------------------------------------------------------------

cann <- read_and_rename("GCDRUA00", "cannabis")
# table(cann$cannabis) # coded as 2, 1, -1; 2 = no, 1 = yes, -1 = missing? (https://cls.ucl.ac.uk/wp-content/uploads/2020/01/MCS7-Young-Person-Self-Completion-Questionnaire.pdf)

# reverse coding and remove missing values
cann[cannabis == 2, cannabis := 0]
cann = cann[cannabis %in% c(0, 1)]

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

# remove missings
drinks_12 = drinks_12[drinks_12_months %in% seq(1, 7)]

# take midpoint of each bin
# 1 = 0; 2 = 1.5; 3 = 4; 4 = 7.5; 5 = 14.5; 6 = 29.5; 7 = 40
drinks_12[drinks_12_months == 1, drinks_12_months := 0]
drinks_12[drinks_12_months == 2, drinks_12_months := 1.5]
drinks_12[drinks_12_months == 3, drinks_12_months := 4]
drinks_12[drinks_12_months == 4, drinks_12_months := 7.5]
drinks_12[drinks_12_months == 5, drinks_12_months := 14.5]
drinks_12[drinks_12_months == 6, drinks_12_months := 29.5]
drinks_12[drinks_12_months == 7, drinks_12_months := 40]

# standardize
drinks_12[, drinks_12_months := standardize(drinks_12_months)]

#---------------------------------------------------------------------------------------------------------------------
# drinks in last 4 weeks
#---------------------------------------------------------------------------------------------------------------------

drinks_4 <- read_and_rename("GCALNF00", "drinks_4_weeks")

# 1 Never
# 2 1-2 times
# 3 3-5 times
# 4 6-9 times
# 5 10-19 times
# 6 20-39 times
# 7 40 or more times

# remove missings
drinks_4 = drinks_4[drinks_4_weeks %in% seq(1, 7)]

# take midpoint of each bin
# 1 = 0; 2 = 1.5; 3 = 4; 4 = 7.5; 5 = 14.5; 6 = 29.5; 7 = 40
drinks_4[drinks_4_weeks == 1, drinks_4_weeks := 0]
drinks_4[drinks_4_weeks == 2, drinks_4_weeks := 1.5]
drinks_4[drinks_4_weeks == 3, drinks_4_weeks := 4]
drinks_4[drinks_4_weeks == 4, drinks_4_weeks := 7.5]
drinks_4[drinks_4_weeks == 5, drinks_4_weeks := 14.5]
drinks_4[drinks_4_weeks == 6, drinks_4_weeks := 29.5]
drinks_4[drinks_4_weeks == 7, drinks_4_weeks := 40]

# standardize
drinks_4[, drinks_4_weeks := standardize(drinks_4_weeks)]

#---------------------------------------------------------------------------------------------------------------------
# depressive symptoms
#---------------------------------------------------------------------------------------------------------------------

dep_symp <- read_and_rename("GDCKESSL", "depressive_symptoms")
# table(dep_symp$depressive_symptoms) # 0 to 24

# standardize
dep_symp[, depressive_symptoms := standardize(depressive_symptoms)]

#---------------------------------------------------------------------------------------------------------------------
# ever smoker
#---------------------------------------------------------------------------------------------------------------------

es <- read_and_rename("GCSMOK00", "ever_smoker")
# table(es$ever_smoker) # coded 1-6, -1 = missing?

# 1 I have never smoked cigarettes
# 2 I have only ever tried smoking cigarettes once
# 3 I used to smoke sometimes but I never smoke a cigarette now
# 4 I sometimes smoke cigarettes now but I don’t smoke as many as one a week
# 5 I usually smoke between one and six cigarettes a week
# 6 I usually smoke more than six cigarettes a week 

# code as binary variable and remove missing values
es[ever_smoker == 1, ever_smoker := 0]
es[ever_smoker != 0 & ever_smoker != -1, ever_smoker := 1]
es = es[ever_smoker %in% c(0, 1)]

#---------------------------------------------------------------------------------------------------------------------
# extraversion
#---------------------------------------------------------------------------------------------------------------------

extra <- read_and_rename("GDCEXTRAV", "extraversion")
# table(extra$extraversion)

# remove 0 and negative values
extra = extra[extraversion > 0]

# standardize
extra[, extraversion := standardize(extraversion)]

#---------------------------------------------------------------------------------------------------------------------
# hayfever
#---------------------------------------------------------------------------------------------------------------------

hayfever = copy(eczema) # same variable code

# rename pheno
hayfever[, hayfever := eczema]
hayfever[, eczema := NULL]

#---------------------------------------------------------------------------------------------------------------------
# neuroticism
#---------------------------------------------------------------------------------------------------------------------

neuro <- read_and_rename("GDCNEUROT", "neuroticism")
table(neuro$neuroticism)

# remove 0 and negative values
neuro = neuro[neuroticism > 0]

# standardize
neuro[, neuroticism := standardize(neuroticism)]

#---------------------------------------------------------------------------------------------------------------------
# self-rated health
#---------------------------------------------------------------------------------------------------------------------

health <- read_and_rename("GCCGHE00", "health")
# table(health$health) # 1 to 5, -1 = missing? need to reverse order of scale so that higher values = higher level of wellbeing

# reorder scale
health[health == 1, self_rated_health := 5]
health[health == 2, self_rated_health := 4]
health[health == 3, self_rated_health := 3]
health[health == 4, self_rated_health := 2]
health[health == 5, self_rated_health := 1]
health[, health := NULL]

# remove missing values
health = health[self_rated_health > 0]

# standardize
health[, self_rated_health := standardize(self_rated_health)]

#---------------------------------------------------------------------------------------------------------------------
# subjective well-being
#---------------------------------------------------------------------------------------------------------------------

swb <- read_and_rename("GDWEMWBS", "swb")
# table(swb$swb)

# standardize
swb[, swb := standardize(swb)]

#---------------------------------------------------------------------------------------------------------------------
# merge phenos
#---------------------------------------------------------------------------------------------------------------------

phenotypes = reduce(list(ht_bmi, ea, cog, dep, adhd, menarche, eczema, cann, drinks_12, drinks_4, dep_symp, es, extra, hayfever, neuro, health, swb), merge, by = c("FID", "IID"), all=TRUE)
phenotypes = merge(phenotypes, covariates, by = c("FID", "IID"), all=TRUE)

# standardize bmi and height by sex
phenotypes[, bmi := standardize(bmi), by=sex]
phenotypes[, height := standardize(height), by=sex]

# make cognition same as ea
phenotypes[, cog := ea]

# save
fwrite(phenotypes, file="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/phenotypes.txt", sep=" ", na="NA")
