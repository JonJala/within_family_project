#!/usr/bin/bash

library(data.table)
library(dplyr)
library(magrittr)
library(ggplot2)

# -----------------------------------------------------------------------------------------
# process meta-analysed EA sumstats to create PGIs using EA4 genome-wide significant SNPs
# -----------------------------------------------------------------------------------------

# define function
process_sumstats <- function(ss, no_ukb) {

    # ea4 sumstats
    ea4_ss <- fread("/var/genetics/proj/within_family/within_family_project/processed/ea4_meta/EA4_additive_p1e-5_clumped.txt")

    # filter p-val < 5*10^-8
    ea4_ss %<>% filter(P < 5*10^-8)

    print(paste0("There are ", length(unique(ea4_ss$rsID)), " genome-wide significant SNPs in the EA4 sumstats."))
    print(paste0("There are ", sum(unique(ea4_ss$rsID) %in% unique(ss$SNP)), " SNPs in the overlap between the sumstats files."))

    # get direct effects for these SNPs
    ea_final <- ss %>% 
                    filter(SNP %in% ea4_ss$rsID) %>%
                    merge(ea4_ss[,c("rsID", "Chr", "BP")], by.x = "SNP", by.y = "rsID")

    # format in plink format
    ea_final %<>% 
        mutate(ID = seq(1,nrow(ea_final)), varid = paste0(Chr, ":", BP)) %>%
        relocate(c("ID", "SNP", "direct_N", "direct_SE", "A1", "A2", "freq", "direct_Beta", "direct_pval", "Chr", "BP", "varid"))

    # save
    if (no_ukb == FALSE) {
        fwrite(ea_final, "/var/genetics/proj/within_family/within_family_project/processed/sbayesr/ea4_meta/direct/weights/meta_weights.snpRes.formatted", quote = F, sep = "\t")    
    } else {
        fwrite(ea_final, "/var/genetics/proj/within_family/within_family_project/processed/sbayesr/ea4_meta/direct/weights/meta_noukb_weights.snpRes.formatted", quote = F, sep = "\t")
    }

    # plot distribution of no. cohorts
    title <- ifelse(no_ukb == FALSE, "Number of Cohorts Contributing to Meta-Analysis", "Number of Cohorts Contributing to Meta-Analysis (Without UKB)")
    p <- ggplot(ss[ss$SNP %in% ea4_ss$rsID],
                aes(x = n_cohorts)) +
                geom_histogram(stat = "count", fill = "lightskyblue3") +
                labs(x="Number of Cohorts", y="Count") +
                scale_x_continuous(breaks = seq(1,11)) + 
                ggtitle(title) +
                theme_classic()
    print(p)

    # save plot
    path <- ifelse(no_ukb == FALSE, "/var/genetics/proj/within_family/within_family_project/processed/sbayesr/ea4_meta/direct/n_cohorts.png", "/var/genetics/proj/within_family/within_family_project/processed/sbayesr/ea4_meta/direct/n_cohorts_noukb.png")
    ggsave(filename = path)

}

# ea metaanalysis sumstats (all cohorts)
ea_meta <- fread("/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/meta.sumstats.gz")

# ea metaanalysis sumstats without ukb
ea_meta_noukb <- fread("/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/meta_noukb.sumstats.gz")


process_sumstats(ea_meta, no_ukb = FALSE) # mcs
process_sumstats(ea_meta_noukb, no_ukb = TRUE) # ukb
