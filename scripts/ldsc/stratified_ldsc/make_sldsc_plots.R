#!/usr/bin/env Rscript

## ---------------------------------------------------------------------
## description: create plots of sldsc results
## ---------------------------------------------------------------------

list.of.packages <- c("data.table", "tidyr", "dplyr", "magrittr", "tidyverse", "ggplot2",
                        "readxl", "stringr", "ggplot2")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos = "http://cran.rstudio.com/")
lapply(list.of.packages, library, character.only = TRUE)

## ---------------------------------------------------------------------
## format data
## ---------------------------------------------------------------------

pheno <- "ea"
effect <- "direct"

## read in stratified ldsc results
data <- fread(paste0("/var/genetics/proj/within_family/within_family_project/processed/ldsc/stratified_ldsc/", pheno, "/", effect, ".baselineLD.results"))

## remove unneeded categories
data <- subset(data, !grepl("extend", Category, ignore.case = TRUE))
data <- subset(data, !grepl("MAF", Category, ignore.case = FALSE))
data <- subset(data, !grepl("Recomb_Rate", Category, ignore.case = FALSE))
data <- subset(data, !grepl("Nucleotide_Diversity", Category, ignore.case = FALSE))
data <- subset(data, !grepl("Backgrd_Selection", Category, ignore.case = FALSE))
data <- subset(data, !grepl("CpG_Content_", Category, ignore.case = FALSE))
data <- subset(data, !grepl("base", Category, ignore.case = FALSE))
data <- subset(data, !grepl("GERP.RSsup", Category, ignore.case = FALSE))

## ---------------------------------------------------------------------
## plot
## ---------------------------------------------------------------------

## enrichment estimates
p1 <- ggplot(data) +
        geom_bar(aes(x=factor(Category, levels = rev(data$Category)), y=Enrichment), stat="identity", fill="#0a4295", alpha=0.5) +
        geom_errorbar(aes(x=Category, ymin=Enrichment-1.96*Enrichment_std_error, ymax=Enrichment+1.96*Enrichment_std_error), width=0.2, colour="black", alpha=0.9, linewidth=0.5) +
        coord_flip() +
        theme_classic() +
        theme(axis.title.y = element_blank())
ggsave(paste0("/var/genetics/proj/within_family/within_family_project/processed/ldsc/stratified_ldsc/", pheno, "/", pheno, "_", effect, "_enrichment.png"), p1)

## prop h2 estimates
p2 <- ggplot(data) +
        geom_bar(aes(x=factor(Category, levels = rev(data$Category)), y=Prop._h2), stat="identity", fill="#0a4295", alpha=0.5) +
        geom_errorbar(aes(x=Category, ymin=Prop._h2-1.96*Prop._h2_std_error, ymax=Prop._h2+1.96*Prop._h2_std_error), width=0.2, colour="black", alpha=0.9, linewidth=0.5) +
        coord_flip() +
        theme_classic() +
        theme(axis.title.y = element_blank())
ggsave(paste0("/var/genetics/proj/within_family/within_family_project/processed/ldsc/stratified_ldsc/", pheno, "/", pheno, "_", effect, "_prop_h2.png"), p2)