#!/usr/bin/env Rscript

# ---------------------------------------------------------------------
# description: meta-analyze h2 across cohorts using metafor package
# ---------------------------------------------------------------------

list.of.packages <- c("data.table", "stringr", "metafor", "tidyr", "dplyr", "magrittr", "tidyverse", "readxl")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos = "http://cran.rstudio.com/")
lapply(list.of.packages, library, character.only = TRUE)

# ---------------------------------------------------------------------
# meta-analyze h2 estimates
# ---------------------------------------------------------------------

## read in and format data
dat <- read_excel("/var/genetics/proj/within_family/within_family_project/processed/package_output/h2_est_height.xlsx")
dat %<>% 
    fill(phenotype) %>%
    mutate(direct_h2_var = direct_h2_se^2, population_h2_var = population_h2_se^2,
                cohort = case_when(cohort %in% c("ukb", "str", "fhs", "ft", "gs", "moba", "qimr") ~ toupper(cohort),
                                    cohort %in% c("botnia", "geisinger", "hunt", "lifelines") ~ str_to_title(cohort),
                                    cohort == "dutch_twin" ~ "Dutch Twin",
                                    cohort == "estonian_biobank" ~ "Estonian Biobank",
                                    cohort == "minn_twins" ~ "Minn Twins"))
direct <- escalc(measure="GEN", data=dat, yi=direct_h2, vi=direct_h2_var, slab=cohort)
pop <- escalc(measure="GEN", data=dat, yi=population_h2, vi=population_h2_var, slab=cohort)

## fit random-effects model
direct_res <- rma(yi = yi, vi = vi, data = direct)
pop_res <- rma(yi = yi, vi = vi, data = pop)

## plot and save

# direct
png(file="/var/genetics/proj/within_family/within_family_project/processed/package_output/height_direct_h2_forest.png")
forest(direct_res, header = "Cohort")
dev.off()

# population
png(file="/var/genetics/proj/within_family/within_family_project/processed/package_output/height_population_h2_forest.png")
forest(pop_res, header = "Cohort")
dev.off()