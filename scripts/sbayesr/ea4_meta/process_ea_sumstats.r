#!/usr/bin/bash

library(data.table)
library(dplyr)
library(magrittr)
library(ggplot2)
library(stringr)

# ---------------------------------------------------------------------------------------------
# define function
# ---------------------------------------------------------------------------------------------

process_sumstats <- function(ss, no_ukb, lead_snps_only = FALSE, save = TRUE) {

    if (lead_snps_only == TRUE) {

        # ea4 sumstats with lead SNPs from each clump only
        ea4_snps <- fread("/var/genetics/proj/within_family/within_family_project/processed/ea4_meta/EA4_additive_p1e-5_clumped.txt")

        # filter p-val < 5*10^-8
        ea4_snps %<>% filter(P < 5*10^-8) %>% rename(SNP = "rsID")

            # get direct effects for these SNPs
        ea_final <- ss %>% filter(SNP %in% ea4_snps$SNP)
        
    } else {

        # get list of all gws snps from each ea4 clump
        ea4_snps <- data.table()
        for (chr in 1:22) {
            clumps <- fread(paste0("/disk/genetics/ukb/aokbay/EA4_clumped/EA4_2020_08_20.meta.chr", chr, ".clumped"))
            for (row in 1:nrow(clumps)) {
                snplist <- c()
                lead_snp <- clumps$SNP[row]
                other_snps <- unlist(strsplit(clumps$SP2[row], "\\(1\\),"))
                snplist <- append(snplist, lead_snp)
                snplist <- append(snplist, other_snps)
                snplist <- str_remove_all(snplist, "\\(1\\)") # remove any remaining instances of (1)
                snplist <- snplist[! snplist %in% "NONE"] # remove all instances of "NONE"
                ea4_snps <- rbind(ea4_snps, data.table(SNP = snplist, Chr = chr, clump_number = row))
            }
        }

        ea_final <- ss %>%
                    filter(SNP %in% ea4_snps$SNP) %>%
                    left_join(ea4_snps) %>%
                    group_by(chromosome, clump_number) %>%
                    filter(direct_N == max(direct_N)) %>%
                    ungroup()

    }

    # format in plink format
    ea_final %<>% 
        mutate(ID = seq(1,nrow(ea_final)), varid = cptid, Pos = pos) %>%
        select("ID", "SNP", "direct_N", "direct_SE", "A1", "A2", "freq", "direct_Beta", "direct_pval", "Chr", "Pos", "varid")

    if (save == TRUE) {
        # save
        if (no_ukb == FALSE) {
            fwrite(ea_final, "/var/genetics/proj/within_family/within_family_project/processed/sbayesr/ea4_meta/direct/weights/meta_weights.snpRes.formatted", quote = F, sep = "\t")    
        } else {
            fwrite(ea_final, "/var/genetics/proj/within_family/within_family_project/processed/sbayesr/ea4_meta/direct/weights/meta_noukb_weights.snpRes.formatted", quote = F, sep = "\t")
        }
    }
    
    # plot distribution of no. cohorts
    title <- ifelse(no_ukb == FALSE, "Number of Cohorts Contributing to Meta-Analysis", "Number of Cohorts Contributing to Meta-Analysis (Without UKB)")
    p <- ggplot(ss[ss$SNP %in% ea4_snps$SNP],
                aes(x = n_cohorts)) +
                geom_histogram(stat = "count", fill = "lightskyblue3") +
                labs(x="Number of Cohorts", y="Count") +
                scale_x_continuous(breaks = seq(1,11)) + 
                ggtitle(title) +
                theme_classic()
    print(p)

    if (save == TRUE) {
        # save plot
        path <- ifelse(no_ukb == FALSE, "/var/genetics/proj/within_family/within_family_project/processed/sbayesr/ea4_meta/direct/n_cohorts.png", "/var/genetics/proj/within_family/within_family_project/processed/sbayesr/ea4_meta/direct/n_cohorts_noukb.png")
        ggsave(filename = path)
    }

}

# ---------------------------------------------------------------------------------------------
# run analysis
# ---------------------------------------------------------------------------------------------

## read in WF metaanalysed sumstats for EA

# ea metaanalysis sumstats (all cohorts)
ea_meta <- fread("/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/meta.sumstats.gz")

# ea metaanalysis sumstats without ukb
ea_meta_noukb <- fread("/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/meta_noukb.sumstats.gz")

# ## process meta-analysed EA sumstats to create PGIs using EA4 genome-wide significant lead SNPs only
# process_sumstats(ea_meta, no_ukb = FALSE, lead_snps_only = TRUE) # mcs
# process_sumstats(ea_meta_noukb, no_ukb = TRUE, lead_snps_only = TRUE) # ukb

# process meta-analysed EA sumstats to create PGIs using all EA4 genome-wide significant SNPs
process_sumstats(ea_meta, no_ukb = FALSE) # mcs
process_sumstats(ea_meta_noukb, no_ukb = TRUE) # ukb
