#!/usr/bin/env Rscript

## ---------------------------------------------------------------------
## description: compute gcs between sibs for howe et al info score analysis
## ---------------------------------------------------------------------

list.of.packages <- c("data.table", "dplyr", "magrittr", "tidyverse", "ggplot2")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos = "http://cran.rstudio.com/")
lapply(list.of.packages, library, character.only = TRUE)

## ---------------------------------------------------------------------
## compute correlations using plink filtered files
## ---------------------------------------------------------------------

compute_corrs <- function(raw_path, sibs) {
    
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

    ## compute corrs
    cors <- c()
    for (i in 1:100) {
        j <- i + 1
        cor <- cor(sib1_dat[, ..j], sib2_dat[, ..j], use = "pairwise.complete.obs")
        cors <- append(cors, cor[1])
    }

    return(unlist(cors))

}

## read in sibs file
sibs <- fread("/disk/genetics/ukb/alextisyoung/haplotypes/relatives/bedfiles/hap.kin0") # list of sibs in UKB
sibs %<>% filter(InfType == "FS") # full sibs only

## compute correlations
raw_path <- "/disk/genetics/data/ukb/private/latest/processed/proj/within_family/howe_info_analysis/plink_out"
raw_files <- list.files(path = raw_path, pattern = ".raw")
corr_df <- data.frame(info = NULL, mean = NULL, sd = NULL, n_na = NULL, n_snps = NULL, stringsAsFactors = FALSE)
for (file in raw_files) {
    
    print(paste0("Computing correlations for ", file, "."))
    raw <- paste0(raw_path, "/", file)
    corrs <- compute_corrs(raw, sibs)
    f <- str_replace(file, ".raw", "")
    info <- f %>%
                str_replace("snps_", "") %>%
                str_replace("_", ".")

    # get n snps
    keep <- fread(paste0("/disk/genetics3/data_dirs/ukb/private/v3/processed/proj/within_family/howe_info_analysis/keep/", f, ".txt"), header = FALSE)
    n_snps <- nrow(keep)

    # plot histogram
    ggplot(data.frame(corrs), aes(x = corrs)) +
        geom_histogram(binwidth = 0.01, fill = "#56B4E9", colour = "#56B4E9", alpha = 0.5) +
        labs(title = paste0("Genetic Correlations for SNPS with INFO = ", info, " (n = ", n_snps, ")"),
             x = "Genetic Correlation",
             y = "Count") +
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