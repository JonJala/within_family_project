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
# find cases and controls
# ---------------------------------------------------------------------

## cases and controls
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

## exclusions
# Bipolar (ICD codes F30, F31 or non-cancer illness code 1291)
# o Multiple personality disorder (ICD code F44.8)
# o Schizophrenia / psychosis (ICD codes F2*, or non-cancer illness code 1289)
# Treatment/medication codes for antipsychotics (Field 20003):
#  Treatment/medication codes for antidepressants (Field 20003):

# field ids needed
fids <- c("_2090_", "_2100_", "_41202_", "_41204_", "_20003_", "_20002_")

# read in ukb dct file
dct <- fread('/disk/genetics/data/ukb/private/v3/raw/phen/9690_update/ukb22597.dct', header = F)

# create list of relevant columns (n_eid and cols corresponding to fids above)
cols <- append("n_eid", dct[str_detect(V2, paste(fids, collapse = '|')), V2])

# read in ukb data
ukb_9690 <- read.dta13('/disk/genetics/data/ukb/private/v3/raw/phen/9690_update/ukb9690_update_jun14_2018.dta', select.cols = cols)

filter_ukb_data <- function(data = ukb_9690, fids, search_vals, type) {

    # subset data to fids of interest
    fid_data <- data %>%
                    select(n_eid, contains(fids)) %>%
                    pivot_longer(!n_eid, names_to = "fid", values_to = "val") # wide to long

    if (type == "exclusions") {
        exclusions <- fid_data %>%
                        filter(grepl(search_vals, val)) %>%
                        distinct(n_eid)
        return(exclusions)
    } else if (type == "cases") {
        cases <- fid_data %>%
                    filter(val == search_vals) %>%
                    mutate(mdd = 1) %>%
                    distinct(n_eid, .keep_all = TRUE)
        return(cases)
    } else if (type == "controls") {
        controls <- fid_data %>%
                        filter(val == search_vals) %>%
                        mutate(mdd = 0) %>%
                        distinct(n_eid, .keep_all = TRUE)
        return(controls)
    }

}

cases_41202_41204 <- filter_ukb_data(ukb_9690, fids = c("_41202_", "_41204_"), search_vals = "F32|F33|F34|F38|F39", type = "cases")
cases_2090_2100 <- filter_ukb_data(ukb_9690, fids = c("_2090_", "_2100_"), search_vals = "Yes", type = "cases")

controls_2090 <- filter_ukb_data(ukb_9690, fids = c("_2090_"), search_vals = "No", type = "controls")
controls_2100 <- filter_ukb_data(ukb_9690, fids = c("_2100_"), search_vals = "No", type = "controls")
controls_2090_2100 <- rbind(controls_2090, controls_2100) %>%
                        filter(n_eid %in% controls_2090$n_eid & n_eid %in% controls_2100$n_eid) %>%
                        distinct(n_eid, .keep_all = TRUE)
controls_2090_2100 <- controls_2090_2100 %>%
                        filter(!(n_eid %in% cases_2090_2100$n_eid))

cases_and_controls <- rbind(cases_41202_41204, cases_2090_2100, controls_2090_2100) %>%
                        select(n_eid, mdd) %>%
                        distinct(n_eid, .keep_all = TRUE)

# ---------------------------------------------------------------------
# find exclusions
# ---------------------------------------------------------------------

## cases and controls

# fields 41202 and 41204 (ICD10 codes)
exclusions_41202_41204 <- filter_ukb_data(ukb_9690, fids = c("_41202_", "_41204_"), search_vals = "F30|F31|F448|F2", type = "exclusions")

# field 20002 (non-cancer illness code)
exclusions_20002 <- filter_ukb_data(ukb_9690, fids = c("_20002_"), search_vals = "1291|1289", type = "exclusions")

# field 20003 (treatment / medication codes)
treatment1 <- "1141202024|1141153490|1141195974|1140867078|1140867494|1141171566|2038459704|1140872064|1140879658|1140867342|1140867420|1140882320|"
treatment2 <- "1140872216|1140910358|1141200458|1141172838|1140867306|1140867180|1140872200|1140867210|1140867398|1140882098|1140867184|1140867168|1140863416|1140909802|"
treatment3 <- "1140867498|1140867490|1140910976|1140867118|1140867456|1140928916|1140872268|1140867134|1140867208|1140867218|1140867572|1140879674|1140909804|1140867504|1140868170|1140879746|1141152848|1141177762|1140867444|1140867092|1141152860|"
treatment4 <- "1140872198|1140867244|1140868172|1140867304|1140872072|1140879750|1140868120|1140872214|1141201792|1140882100|1141167976"
treatment_codes_1 <- paste0(treatment1, treatment2, treatment3, treatment4)
exclusions_20003 <- filter_ukb_data(ukb_9690, fids = c("_20003_"), search_vals = treatment_codes_1, type = "exclusions")

# combine
case_control_exclusions <- rbind(exclusions_41202_41204, exclusions_20002, exclusions_20003) %>% distinct(n_eid)
nrow(case_control_exclusions) # 8282

## controls only

# field 20003 (treatment / medication codes)
treatment5 <- "1140867820|1140867948|1140879616|1140867938|1140867690|1141190158|1141151946|1140921600|1140879620|1141201834|1140867152|1140909806|1140879628|1140867640|1141200564|1141151982|1140916288|1141180212|1140867860|1140867952|"
treatment6 <- "1140879540|1140867150|1140909800|1140867940|1140879544|1140879630|1140867856|1140867726|1140867884|1140867922|1140910820|1140879556|1141152732|1140867920|1140882244|1140867852|1140867818|1141174756|1140867916|1140867888|1140867850|"
treatment7 <- "1140867624|1140867876|1141151978|1140882236|1140867878|1201|1140882312|1140867758|1140867712|1140867914|1140867944|1140879634|1140867756|1140867756|1140867960|1140916282|1141200570|1141152736"
treatment_codes_2 <- paste0(treatment5, treatment6, treatment7)
exclusions_20003_controls <- filter_ukb_data(ukb_9690, fids = c("_20003_"), search_vals = treatment_codes_2, type = "exclusions")

# fields 41202 and 41204 (ICD10 codes)
exclusions_41202_41204_controls <- filter_ukb_data(ukb_9690, fids = c("_41202_", "_41204_"), search_vals = "F32|F33|F34|F38|F39", type = "exclusions")

# field 20002 (non-cancer illness code)
exclusions_20002_controls <- filter_ukb_data(ukb_9690, fids = c("_20002_"), search_vals = "1286", type = "exclusions")

# combine
control_exclusions <- rbind(exclusions_41202_41204_controls, exclusions_20002_controls, exclusions_20003_controls) %>% distinct(n_eid)
nrow(control_exclusions) # 55303

# ---------------------------------------------------------------------
# set exclusions to NA
# ---------------------------------------------------------------------

final <- cases_and_controls %>%
            mutate(mdd_final = ifelse((n_eid %in% case_control_exclusions$n_eid) | (mdd == 0 & n_eid %in% control_exclusions$n_eid), NA, mdd))
final %<>% select(n_eid, mdd_final) %>% rename("mdd" = "mdd_final")

# ---------------------------------------------------------------------
# QC filters
# ---------------------------------------------------------------------

# Get sample QC
sqc = fread('/disk/genetics2/ukb/orig/UKBv2/linking/ukb_sqc_v2_combined_header.txt', header = T, stringsAsFactors = F)

# Get withdrawn participants
withdrawn = fread('/var/genetics/data/ukb/private/v3/misc/linking/ukb_withdrawn_ind.csv',header=F,sep=",")[,1]

# Filter sample
sqc = sqc[sqc$het.missing.outliers==0 & sqc$putative.sex.chromosome.aneuploidy==0 &
            sqc$excess.relatives==0 & sqc$in.white.British.ancestry.subset==1 & !sqc$IID%in%withdrawn,]
final %<>% filter(n_eid %in% sqc$FID)

# ---------------------------------------------------------------------
# save
# ---------------------------------------------------------------------

fwrite(final, "/var/genetics/data/ukb/private/v3/processed/proj/within_family/phen/ukb_mdd_pheno.txt", sep = " ", na = "NA", quote = FALSE)

sum(final$mdd == 1, na.rm = T) # 140048 cases
sum(final$mdd == 0, na.rm = T) #  254005 controls
sum(is.na(final$mdd)) # 11639 exclusions
