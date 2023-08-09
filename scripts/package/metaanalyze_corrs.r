#!/usr/bin/env Rscript

# ---------------------------------------------------------------------
# description: meta-analyze r_direct_pop across cohorts using metafor package
# ---------------------------------------------------------------------

list.of.packages <- c("data.table", "stringr", "metafor", "tidyr", "dplyr", "magrittr", "tidyverse", "readxl", "optparse")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos = "http://cran.rstudio.com/")
lapply(list.of.packages, library, character.only = TRUE)

# ---------------------------------------------------------------------
# read in options
# ---------------------------------------------------------------------

option_list = list(
  make_option(c("--pheno"),  type="character", default=NULL, help="Phenotype", metavar="character")
)
opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)
pheno <- opt$pheno

# ---------------------------------------------------------------------
# meta-analyze corr estimates
# ---------------------------------------------------------------------

## read in and format data
dat <- read_excel(paste0("/var/genetics/proj/within_family/within_family_project/processed/package_output/correlation_meta/marginal_corrs_", pheno, ".xlsx"))
dat$corr <- as.numeric(dat$corr)
dat$se <- as.numeric(dat$se)
dat %<>% 
    fill(phenotype) %>%
    mutate(var = se^2,
     cohort = case_when(cohort %in% c("ukb", "str", "fhs", "ft", "gs", "moba", "qimr") ~ toupper(cohort),
                                    cohort %in% c("botnia", "geisinger", "hunt", "lifelines", "finngen") ~ str_to_title(cohort),
                                    cohort == "dutch_twin" ~ "Dutch Twin",
                                    cohort == "estonian_biobank" ~ "Estonian Biobank",
                                    cohort == "ipsych" ~ "iPSYCH",
                                    cohort == "minn_twins" ~ "Minn Twins"))  %>% 
    filter(se < 0.25)
dat_final <- escalc(measure="GEN", data=dat, yi=corr, vi=var, slab=cohort)

## fit random-effects model
res <- rma(yi = yi, vi = vi, data = dat_final)

## plot and save

# direct
png(file=paste0("/var/genetics/proj/within_family/within_family_project/processed/package_output/correlation_meta/", pheno, "_corr_forest.png"))
forest(res, header = "Cohort", cex = 1, xlim = c(-4, 4))
text(-4, -1.05, pos=4, cex=1, bquote(paste("RE Model (p = ", .(formatC(res$QEp, digits=2, format="f")), "; ", tau, " = ",
     .(formatC(sqrt(res$tau2), digits=3, format="f")), ")")))
dev.off()