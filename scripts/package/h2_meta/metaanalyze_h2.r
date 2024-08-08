#!/usr/bin/env Rscript

# ---------------------------------------------------------------------
# description: meta-analyze h2 across cohorts using metafor package
# ---------------------------------------------------------------------

list.of.packages <- c("data.table", "stringr", "metafor", "tidyr", "dplyr", "magrittr", "tidyverse", "readxl", "optparse")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos = "http://cran.rstudio.com/")
lapply(list.of.packages, library, character.only = TRUE)

# ---------------------------------------------------------------------
# read in options
# ---------------------------------------------------------------------

option_list = list(
  make_option(c("--cohorts"),  type="character", default=NULL, help="Cohorts to meta-analyze", metavar="character"),
  make_option(c("--pheno"),  type="character", default=NULL, help="Phenotype", metavar="character")
)
opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)

cohorts <- strsplit(opt$cohorts, " ")
pheno <- opt$pheno

# ---------------------------------------------------------------------
# meta-analyze h2 estimates
# ---------------------------------------------------------------------

## read in and format data
dat <- read_excel(paste0("/var/genetics/proj/within_family/within_family_project/processed/package_output/h2_est_", pheno, ".xlsx"))
dat %<>% 
    fill(phenotype) %>%
    mutate(direct_h2_var = direct_h2_se^2, population_h2_var = population_h2_se^2,
                cohort = case_when(cohort %in% c("ukb", "str", "fhs", "gs", "moba", "qimr") ~ toupper(cohort),
                                    cohort %in% c("botnia", "geisinger", "hunt", "lifelines") ~ str_to_title(cohort),
                                    cohort == "dutch_twin" ~ "Dutch Twin",
                                    cohort == "estonian_biobank" ~ "Estonian Biobank",
                                    cohort == "ft" ~ "FTC",
                                    cohort == "finngen" ~ "FinnGen",
                                    cohort == "ipsych" ~ "iPSYCH",
                                    cohort == "minn_twins" ~ "Minn Twins"))  %>% 
    filter(direct_h2_se < 0.25)
direct <- escalc(measure="GEN", data=dat, yi=direct_h2, vi=direct_h2_var, slab=cohort)
pop <- escalc(measure="GEN", data=dat, yi=population_h2, vi=population_h2_var, slab=cohort)

## fit random-effects model
direct_res <- rma(yi = yi, vi = vi, data = direct)
pop_res <- rma(yi = yi, vi = vi, data = pop)

## plot and save

# direct
png(file=paste0("/var/genetics/proj/within_family/within_family_project/processed/figures/h2_meta/", pheno, "_direct_h2_forest.png"))
forest(direct_res, header = "Cohort", cex = 1, xlim = c(-2, 2))
text(-2, -1.1, pos=4, cex=1, bquote(paste("RE Model (p = ", .(formatC(direct_res$QEp, digits=2, format="f")), "; ", tau, " = ",
     .(formatC(sqrt(direct_res$tau2), digits=3, format="f")), ")")))
dev.off()

# population
png(file=paste0("/var/genetics/proj/within_family/within_family_project/processed/figures/h2_meta/", pheno, "_population_h2_forest.png"))
forest(pop_res, header = "Cohort", cex = 1, xlim = c(-2, 2))
text(-2, -1.1, pos=4, cex=1, bquote(paste("RE Model (p = ", .(formatC(pop_res$QEp, digits=2, format="f")), "; ", tau, " = ",
     .(formatC(sqrt(pop_res$tau2), digits=3, format="f")), ")")))
dev.off()
