library(tidyverse)
library(data.table)
library(stargazer)
library(ggpubr)
theme_set(theme_pubr())

hm3 = fread("/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist")

dat = fread("/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/meta.sumstats.gz") 
datncohorts = dat[, .( N = .N, `Fraction of SNPs` = .N/nrow(dat)), by=n_cohorts]
datncohorts_hm3 = merge(dat, hm3, by=SNP, all.x)
datncohorts_hm3 = dat[SNP %in% hm3$SNP, .( N = .N, `Fraction of SNPs` = .N/nrow(dat)), by=n_cohorts]
datncohorts = merge(datncohorts, datncohorts_hm3, by = "n_cohorts", all=TRUE, suffixes = c("", " (HM3)"))
setnames(datncohorts, "n_cohorts", "N Cohorts")
datncohorts %>% 
    fwrite("/var/genetics/proj/within_family/within_family_project/processed/package_output/n_cohorts_coverage.csv")

