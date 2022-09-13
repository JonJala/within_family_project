#!/usr/bin/bash

library(data.table)
library(dplyr)
library(magrittr)
library(ggplot2)
library(stringr)

# ---------------------------------------------------------------------------------------------
# define function
# ---------------------------------------------------------------------------------------------

plot_n_cohorts <- function(ea_final, effect, no_ukb = no_ukb, save = TRUE) {

    # plot distribution of no. cohorts
    title <- ifelse(no_ukb == FALSE, "Number of Cohorts Contributing to Meta-Analysis", "Number of Cohorts Contributing to Meta-Analysis (Without UKB)")
    p <- ggplot(ea_final,
                aes(x = n_cohorts)) +
                geom_histogram(stat = "count", fill = "lightskyblue3") +
                labs(x="Number of Cohorts", y="Count") +
                scale_x_continuous(breaks = seq(1,11)) + 
                ggtitle(title) +
                theme_classic()
    print(p)

    if (save == TRUE) {
        # save plot
        path <- ifelse(no_ukb == FALSE, paste0("/var/genetics/proj/within_family/within_family_project/processed/sbayesr/ea4_meta/", effect, "/n_cohorts.png"), paste0("/var/genetics/proj/within_family/within_family_project/processed/sbayesr/ea4_meta/", effect, "/n_cohorts_noukb.png"))
        ggsave(filename = path)
    }

}

get_snps <- function(effect, ss, ea4_snps, no_ukb, save = TRUE, plot = TRUE) {
    
    # SNP from each clump with the highest effective N in our sumstats
    ea_final <- ss %>%
                filter(SNP %in% ea4_snps$SNP) %>%
                left_join(ea4_snps) %>%
                group_by(chromosome, clump_number)
    
    if (effect == "direct") {
        ea_final %<>% 
            filter(direct_N == max(direct_N)) %>%
            ungroup()
    } else if (effect == "population") {
        ea_final %<>% 
            filter(population_N == max(population_N)) %>%
            ungroup()
    }

    # plot SNP coverage by cohorts
    if (plot == T) {
        plot_n_cohorts(ea_final, effect, no_ukb, save)
    }

    # format in plink format
    ea_final %<>% 
        mutate(ID = seq(1,nrow(ea_final))) %>%
        select("ID", "SNP", paste0(effect, "_N"), paste0(effect, "_SE"), "A1", "A2", "freq", paste0(effect, "_Beta"), paste0(effect, "_pval"), "Chr", "pos", "cptid") %>%
        setNames(c("ID", "Name", paste0(effect, "_N"), paste0(effect, "_SE"), "A1", "A2", "freq", "A1Effect", paste0(effect, "_pval"), "Chrom", "Position", "varid"))

    if (save == TRUE) {
        # save
        if (no_ukb == FALSE) {
            fwrite(ea_final, paste0("/var/genetics/proj/within_family/within_family_project/processed/sbayesr/ea4_meta/", effect, "/weights/meta_weights.snpRes.formatted"), quote = F, sep = "\t")    
        } else {
            fwrite(ea_final, paste0("/var/genetics/proj/within_family/within_family_project/processed/sbayesr/ea4_meta/", effect, "/weights/meta_noukb_weights.snpRes.formatted"), quote = F, sep = "\t")
        }
    }

}

process_sumstats <- function(ss, no_ukb, save = TRUE, plot = TRUE) {

    # get list of all gws snps from each ea4 clump
    ea4_snps <- data.table()
    for (chr in 1:22) {
        clumps <- fread(paste0("/disk/genetics/ukb/aokbay/EA4_clumped/EA4_2020_08_20.meta.chr", chr, ".clumped"))
        for (row in 1:nrow(clumps)) {
            snplist <- c()
            lead_snp <- clumps$SNP[row] # lead SNP in clump
            other_snps <- unlist(strsplit(clumps$SP2[row], "\\(1\\),")) # other SNPs in clump
            snplist <- append(snplist, lead_snp) # add lead SNP to list of SNPs
            snplist <- append(snplist, other_snps) # add all other SNPs to list of SNPs
            snplist <- str_remove_all(snplist, "\\(1\\)") # remove any remaining instances of (1)
            snplist <- snplist[! snplist %in% "NONE"] # remove all instances of "NONE"
            ea4_snps <- rbind(ea4_snps, data.table(SNP = snplist, Chr = chr, clump_number = row)) # add SNP list to new row of table
        }
    }

    # get SNP from each clump with the highest direct Neff in our sumstats
    get_snps("direct", ss, ea4_snps, no_ukb, save, plot)

    # get SNP from each clump with the highest population Neff in our sumstats
    get_snps("population", ss, ea4_snps, no_ukb, save, plot)

}

# ---------------------------------------------------------------------------------------------
# run analysis
# ---------------------------------------------------------------------------------------------

## read in WF metaanalysed sumstats for EA

# ea metaanalysis sumstats (all cohorts)
ea_meta <- fread("/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/meta.sumstats.gz")

# ea metaanalysis sumstats without ukb
ea_meta_noukb <- fread("/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/meta_noukb.sumstats.gz")

# process meta-analysed EA sumstats to create PGIs using all EA4 genome-wide significant SNPs
process_sumstats(ea_meta, no_ukb = FALSE) # mcs
process_sumstats(ea_meta_noukb, no_ukb = TRUE) # ukb
