#!/usr/bin/env Rscript

# ---------------------------------------------------------------------
# description: create UKB MDD phenotype as per definition of broad
# depression in howard et al. (2018)
# ---------------------------------------------------------------------

list.of.packages <- c("data.table", "stringr", "readstata13", "tidyr", "dplyr", "magrittr", "tidyverse")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos = "http://cran.rstudio.com/")
lapply(list.of.packages, library, character.only = TRUE)

# ---------------------------------------------------------------------
# select cases
# ---------------------------------------------------------------------

# "Have you ever seen a GP/psychiatrist for nerves, anxiety, tension or 
# depression?" (Fields 2090 and 2100) - Yes
# From Hospital Episodes Data from UK bodies (English HES Data, Scottish Morbidity 
# Register, Patient Episode Data) (Fields 41202 and 41204) 
#  Any primary or secondary diagnosis of ICD-10 Codes for mood disorders
#  F32 - Single Episode Depression
#  F33 - Recurrent Depression
#  F34 - Persistent mood disorders (Cyclothymia, Dysthymia)
#  F38 - Other mood disorders
#  F39 - Unspecified mood disorders

# field ids needed
fids <- c("_2090_", "_2100_", "_41202_", "_41204_")

# read in ukb dct file
dct <- fread('/disk/genetics/data/ukb/private/v3/raw/phen/9690_update/ukb22597.dct', header = F)

# create list of relevant columns (n_eid and cols corresponding to fids above)
cols <- append("n_eid", dct[str_detect(V2, paste(fids, collapse = '|')), V2])

# read in ukb data
ukb_9690 <- read.dta13('/disk/genetics/data/ukb/private/v3/raw/phen/9690_update/ukb9690_update_jun14_2018.dta', select.cols = cols)

# fields 2090 and 2100
fid_2090_2100 <- ukb_9690 %>%
                select(n_eid, contains(c("_2090_", "_2100_"))) %>%
                pivot_longer(!n_eid, names_to = "fid", values_to = "val") # wide to long
phen_2090_2100 <- fid_2090_2100 %>%
                        filter(val == "Yes" | val == "No") %>%
                        mutate(mdd = ifelse(val == "Yes", 1, 0)) %>% # cases = 1, controls = 0
                        distinct(n_eid, .keep_all = TRUE)
# saveRDS(phen_2090_2100, "/disk/genetics3/data_dirs/ukb/private/v3/processed/proj/within_family/phen/phen_2090_2100") # just temporary

# fields 41202 and 41204
fid_41202_41204 <- ukb_9690 %>%
                        select(n_eid, contains(c("_41202_", "_41204_"))) %>%
                        pivot_longer(!n_eid, names_to = "fid", values_to = "val") # wide to long
phen_41202_41204 <- fid_41202_41204 %>%
                        filter(grepl("F32|F33|F34|F38|F39", val)) %>%
                        mutate(mdd = 1)
# saveRDS(phen_41202_41204, "/disk/genetics3/data_dirs/ukb/private/v3/processed/proj/within_family/phen/phen_41202_41204") # just temporary

# combine
cases_and_controls <- rbind(phen_2090_2100, phen_41202_41204) %>%
                        select(n_eid, mdd)
# fwrite(cases_and_controls, "/disk/genetics3/data_dirs/ukb/private/v3/processed/proj/within_family/phen/ukb_mdd_cases_controls.txt") # just temporary

# ---------------------------------------------------------------------
# select exclusions
# ---------------------------------------------------------------------





# ---------------------------------------------------------------------
# residualize phenotype and subset to EUR ancestry only
# ---------------------------------------------------------------------

# ## residualize pheno on sex, birth year (with square and cubic), sex x birth year (with square and cubic) interactions, pcs 1-40, and a bunch of batch dummy variables

# # subset birth year variable
# ukb_byear <- ukb_9690 %>%
#                 select(n_eid, contains(fid_byear)) %>%
#                 mutate(BYEAR = ifelse(is.na(n_34_0_0), n_22200_0_0, n_34_0_0))

# # create df of covariates
# covar_data <- read.dta13("/disk/genetics2/ukb/orig/UKBv2/linking/ukb_sqc_v2_combined_header.dta")
# covars <- covar_data %>% 
#             select(IID, Sex, Batch, starts_with("PC")) %>%
#             rename(n_eid = "IID") %>%
#             left_join(ukb_byear[c("n_eid", "BYEAR")]) %>% # merge with byear
#             mutate(BYEAR = (BYEAR-1900)/10, BYEAR2 = BYEAR^2, BYEAR3 = BYEAR^3, SEXxBYEAR = Sex*BYEAR, SEXxBYEAR2 = Sex*BYEAR2, SEXxBYEAR3 = Sex*BYEAR3) # add interaction terms

# # merge with phenotype
# df <- pheno %>%
#         select(IID, ALZ) %>%
#         rename(n_eid = "IID") %>%
#         left_join(covars) %>%
#         na.omit()

# # remove individuals of non-EUR ancestry
# df_final <- df %>%
#                 filter(PC1 < 0) %>%
#                 column_to_rownames(., var = "n_eid")

# # run regression
# lm <- lm(ALZ ~., data=df_final)
# # summary(lm)

# # save residuals
# residuals <- data.frame(FID = names(lm$residuals), IID = names(lm$residuals), residuals = lm$residuals)
# fwrite(residuals, file = "/var/genetics/proj/alz_pgi/alz_pgi_project/processed/proxy/1_gwas/ukb_alz_gwas_pheno_resid.txt", sep = "\t", row.names = F, quote = F)

# # save gwas keep file
# keep_gwas <- data.frame(ID_1 = names(lm$residuals), ID_2 = names(lm$residuals))
# fwrite(keep_gwas, file = "/var/genetics/proj/alz_pgi/alz_pgi_project/processed/proxy/1_gwas/ukb_alz_gwas_keep.txt", sep = "\t", row.names = F, quote = F, col.names = F)

