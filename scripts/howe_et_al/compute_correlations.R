#!/usr/bin/env Rscript

## ---------------------------------------------------------------------
## description: compute gcs between sibs for howe et al info score analysis
## ---------------------------------------------------------------------

list.of.packages <- c("data.table", "dplyr", "magrittr", "tidyverse", "ggplot2", "plinkFile",
                        "genio", "ggplot2")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos = "http://cran.rstudio.com/")
lapply(list.of.packages, library, character.only = TRUE)

## ---------------------------------------------------------------------
## define function to compute correlations
## ---------------------------------------------------------------------

compute_corrs <- function(sibs, raw_path = NULL, hard_calls = FALSE, bed_path = NULL, fam_path = NULL) {
    
    ## using dosages
    if (!hard_calls) {
        ## read in .raw file
        raw <- fread(raw_path)
        raw <- raw[, .SD, .SDcols = unique(names(raw))] %>%
                    select(-FID, -PAT, -MAT, -SEX, -PHENOTYPE)

        ## merge with sibling data
        sib1_dat <- sibs %>%
                        select(ID1) %>%
                        rename(IID = ID1) %>%
                        left_join(raw)
        sib2_dat <- sibs %>%
                        select(ID2) %>%
                        rename(IID = ID2) %>%
                        left_join(raw)
    } else if (hard_calls) {
        ## read in bed and fam files
        bed <- readBED(bed_path)
        fam <- read_fam(fam_path)
        ## process sibling data
        bed_dat <- data.table(ID = as.numeric(fam$id), bed)
        sib1_dat <- sibs %>%
                        select(ID1) %>%
                        rename(ID = ID1) %>%
                        left_join(bed_dat)
        sib2_dat <- sibs %>%
                        select(ID2) %>%
                        rename(ID = ID2) %>%
                        left_join(bed_dat)
    }
    
    ## compute corrs
    cors <- c()
    for (i in 1:ncol(sib1_dat)-1) {
        j <- i + 1
        cor <- cor(sib1_dat[, ..j], sib2_dat[, ..j], use = "pairwise.complete.obs")
        cors <- append(cors, cor[1])
    }

    return(unlist(cors))

}

## ---------------------------------------------------------------------
## compute correlations using dosages from .raw plink files
## ---------------------------------------------------------------------

## read in sibs file
sibs <- fread("/disk/genetics/ukb/alextisyoung/haplotypes/relatives/bedfiles/hap.kin0") # list of sibs in UKB
sibs %<>% filter(InfType == "FS") # full sibs only

## compute correlations using dosages
raw_path <- "/disk/genetics/data/ukb/private/latest/processed/proj/within_family/howe_info_analysis/plink_out"
raw_files <- list.files(path = raw_path, pattern = ".raw")
corr_df <- data.frame(info = NULL, mean = NULL, sd = NULL, n_na = NULL, n_snps = NULL, stringsAsFactors = FALSE)
for (file in raw_files) {
    
    print(paste0("Computing correlations for ", file, "."))
    raw <- paste0(raw_path, "/", file)
    corrs <- compute_corrs(sibs, raw_path = raw)
    f <- str_replace(file, ".raw", "")
    info <- f %>%
                str_replace("snps_", "") %>%
                str_replace("_", ".") %>%
                as.numeric()

    # get n snps
    keep <- fread(paste0("/var/genetics/data/ukb/private/v3/processed/proj/within_family/howe_info_analysis/keep/", f, ".txt"), header = FALSE)
    n_snps <- nrow(keep)

    # plot histogram
    ggplot(data.frame(corrs), aes(x = corrs)) +
        geom_histogram(binwidth = 0.01, fill = "#56B4E9", colour = "#56B4E9", alpha = 0.5) +
        labs(title = paste0("Sib Genotype Corrs for SNPS with INFO = ", info, "-", info+0.01, " (n = ", n_snps, ")"),
             x = "Sibling Genotype Correlation",
             y = "Count") +
        geom_vline(xintercept=0.5, linetype="dotted") +
        theme_classic() +
        theme(legend.position="none")
    ggsave(paste0("/disk/genetics/data/ukb/private/latest/processed/proj/within_family/howe_info_analysis/output/", f, "_hist.png"))

    # add summary stats to table
    mean <- mean(corrs, na.rm = T)
    sd <- sd(corrs, na.rm = T)
    n_na <- sum(is.na(corrs))
    corr_df <- rbind(corr_df, data.frame(info = f, mean = mean, sd = sd, n_na = n_na, n_snps = n_snps, stringsAsFactors = FALSE))

}
fwrite(corr_df, "/disk/genetics/data/ukb/private/latest/processed/proj/within_family/howe_info_analysis/output/corrs.csv", col.names = TRUE, row.names = FALSE, quote = FALSE)


## ---------------------------------------------------------------------
## compute correlations using hard calls from .bed files
## ---------------------------------------------------------------------

## compute correlations
path <- "/disk/genetics/data/ukb/private/latest/processed/proj/within_family/howe_info_analysis/plink_out/bed"
files <- list.files(path = path, pattern = "snps_0_[0-9]*.bed") %>%
                str_replace_all(".bed", "")
corr_df_hardcalls <- data.frame(info = NULL, mean = NULL, median = NULL, min = NULL, max = NULL, sd = NULL, n_na = NULL, n_snps = NULL, stringsAsFactors = FALSE)
for (file in files) {
    
    print(paste0("Computing correlations for ", file, "."))
    bed_path <- paste0(path, "/", file, ".bed")
    fam_path <- paste0(path, "/", file, ".fam")
    corrs <- compute_corrs(sibs, hard_calls = TRUE, bed_path = bed_path, fam_path = fam_path)
    info <- file %>%
                str_replace("snps_", "") %>%
                str_replace("_", ".") %>%
                as.numeric()

    # get n snps
    keep <- fread(paste0("/var/genetics/data/ukb/private/v3/processed/proj/within_family/howe_info_analysis/keep/", file, ".txt"), header = FALSE)
    n_snps <- nrow(keep)

    # plot histogram
    ggplot(data.frame(corrs), aes(x = corrs)) +
        geom_histogram(binwidth = 0.02, fill = "#56B4E9", colour = "#56B4E9", alpha = 0.5) +
        labs(title = paste0("Sib Genotype Corrs for SNPS with INFO = ", info, "-", info+0.01, " (n = ", n_snps, ")"),
             x = "Sibling Genotype Correlation",
             y = "Count") +
        geom_vline(xintercept=0.5, linetype="dotted") +
        theme_classic() +
        theme(legend.position="none")
    ggsave(paste0("/disk/genetics/data/ukb/private/latest/processed/proj/within_family/howe_info_analysis/output/hard_calls/", file, "_hist.png"))

    # add summary stats to table
    mean <- mean(corrs, na.rm = T)
    median <- median(corrs, na.rm = T)
    min <- min(corrs, na.rm = T)
    max <- max(corrs, na.rm = T)
    sd <- sd(corrs, na.rm = T)
    n_na <- sum(is.na(corrs))
    corr_df_hardcalls <- rbind(corr_df_hardcalls, data.frame(info = file, mean = mean, median = median, min = min, max = max, sd = sd, n_na = n_na, n_snps = n_snps, stringsAsFactors = FALSE))

}
fwrite(corr_df_hardcalls, "/disk/genetics/data/ukb/private/latest/processed/proj/within_family/howe_info_analysis/output/hard_calls/corrs.csv", col.names = TRUE, row.names = FALSE, quote = FALSE)


## ---------------------------------------------------------------------
## plot mean correlation for each info level
## ---------------------------------------------------------------------

plot_mean_correlations <- function(path, save_path, title) {

    # get data
    dat <- fread(path)
    dat %<>% mutate(info = str_replace(str_replace(info, "snps_", ""), "_", ".") %>% as.numeric(),
                    se = sd/sqrt(n_snps))
    
    # plot correlations
    ggplot(dat, aes(x = info, y = mean)) +
        geom_point() + 
        # geom_errorbar(aes(ymin=mean-1.96*se, ymax=mean+1.96*se), width=.01,
        #              position=position_dodge(.9)) +
        theme_classic() +
        labs(x = "INFO Score", y = "Mean Sibling Genotype Correlation") +
        geom_hline(yintercept=0.5, linetype="dotted") +
        ggtitle(title)
    ggsave(save_path)

}

## dosages
dosage_path <- "/disk/genetics/data/ukb/private/latest/processed/proj/within_family/howe_info_analysis/output/corrs.csv"
plot_mean_correlations(path = dosage_path, save_path = "/disk/genetics/data/ukb/private/latest/processed/proj/within_family/howe_info_analysis/output/mean_corrs.png", title = "Mean Sib. Genotype Corr. by INFO Score (dosage-based)")

## hard calls
hardcall_path <- "/disk/genetics/data/ukb/private/latest/processed/proj/within_family/howe_info_analysis/output/hard_calls/corrs.csv"
plot_mean_correlations(path = hardcall_path, save_path = "/disk/genetics/data/ukb/private/latest/processed/proj/within_family/howe_info_analysis/output/hard_calls/mean_corrs.png", title = "Mean Sib. Genotype Corr. by INFO Score (hard call-based)")
