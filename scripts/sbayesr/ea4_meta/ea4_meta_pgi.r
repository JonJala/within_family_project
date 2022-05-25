library(data.table)
library(dplyr)
library(magrittr)
library(ggplot2)

# --------------------------------------------------------------------------------
# create PGIs using EA4 SNPs and WF meta sumstats direct effects
# --------------------------------------------------------------------------------

# ea4 sumstats
ea4_ss <- fread("/var/genetics/proj/within_family/within_family_project/processed/sbayesr/ea4_meta/EA4_additive_p1e-5_clumped.txt")

# filter p-val < 5*10^-8
ea4_ss %<>% filter(P < 5*10^-8)
# nrow(ea4_ss)

# ea metaanalysis sumstats (all cohorts)
ea_meta <- fread("/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/meta.sumstats.gz")
# nrow(ea_meta)

# ea metaanalysis sumstats without ukb
ea_meta_noukb <- fread("/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/meta_noukb.sumstats.gz")
# nrow(ea_meta_noukb)

process_sumstats <- function(ss, no_ukb = TRUE) {
    
    print(paste0("There are ", sum(ea4_ss$rsID %in% ss$SNP), " SNPs in the overlap between the sumstats files."))

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

}

process_sumstats(ea_meta, no_ukb = FALSE)
process_sumstats(ea_meta_noukb, no_ukb = TRUE)



hist(ea_meta$n_cohorts[ea4_ss$rsID %in% ea_meta$SNP])
max(ea_meta$n_cohorts[ea4_ss$rsID %in% ea_meta$SNP])

p <- ggplot(ea_meta[ea_meta$SNP %in% ea4_ss$rsID],
                aes(x = n_cohorts)) +
                geom_histogram(stat = "count", fill = "lightskyblue3") +
                labs(x="Number of Cohorts", y="Count") +
                scale_x_continuous(breaks = seq(1,11)) + 
                ggtitle("Number of Cohorts Contributing to Meta-Analysis") +
                theme_classic()
p


# sum(ea4_ss$rsID %in% ea_meta_noukb$SNP) # 2939

# # get direct effects for these SNPs
# ea_final <- ea_meta %>% 
#                 filter(SNP %in% ea4_ss$rsID) %>%
#                 merge(ea4_ss[,c("rsID", "Chr", "BP")], by.x = "SNP", by.y = "rsID")

# # format in plink format
# ea_final %<>% 
#     mutate(ID = seq(1,nrow(ea_final)), varid = paste0(Chr, ":", BP)) %>%
#     relocate(c("ID", "SNP", "direct_N", "direct_SE", "A1", "A2", "freq", "direct_Beta", "direct_pval", "Chr", "BP", "varid"))

# # save
# fwrite(ea_final, "/var/genetics/proj/within_family/within_family_project/processed/sbayesr/ea4_meta/direct/weights/meta_weights.snpRes.formatted", quote = F, sep = "\t")