#!/usr/bin/bash

library(data.table)
library(dplyr)
library(magrittr)
library(stringr)
library(optparse)

option_list = list(
  make_option(c("--sumstats"),  type="character", default=NULL, help="Path to sumstats", metavar="character"),
  make_option(c("--clump_prefix"),  type="character", default=NULL, help="File / folder prefix for clumped reference sumstats", metavar="character"),
  make_option(c("--effect"),  type="character", default=NULL, help="Direct or population effects, or both", metavar="character"),
  make_option(c("--dataset"),  type="character", default=NULL, help="MCS or UKB", metavar="character"),
  make_option(c("--pheno"),  type="character", default=NULL, help="Phenotype", metavar="character")
)
opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)

## define function
process_clumps <- function(opt, effect = opt$effect) {

    # read in sumstats
    ss <- fread(opt$sumstats)

    # get list of all gws snps from each reference clump
    snps <- data.table()
    chr_no_clumps <- c()
    for (chr in 1:22) {
        clump_file <- paste0(opt$clump_prefix, ".chr", chr, ".clumped")
        if (file.exists(clump_file)) {
            clumps <- fread(clump_file)
            for (row in 1:nrow(clumps)) {
                snplist <- c()
                lead_snp <- clumps$SNP[row] # lead SNP in clump
                other_snps <- unlist(strsplit(clumps$SP2[row], "\\(1\\),")) # other SNPs in clump
                snplist <- append(snplist, lead_snp) # add lead SNP to list of SNPs
                snplist <- append(snplist, other_snps) # add all other SNPs to list of SNPs
                snplist <- str_remove_all(snplist, "\\(1\\)") # remove any remaining instances of (1)
                snplist <- snplist[! snplist %in% "NONE"] # remove all instances of "NONE"
                snps <- rbind(snps, data.table(SNP = snplist, Chr = chr, clump_number = row)) # add SNP list to new row of table
            }
        } else {
            print(paste0("File ", clump_file, " does not exist"))
            chr_no_clumps <- append(chr_no_clumps, chr)
        }

    }
    write.table(chr_no_clumps, paste0("/var/genetics/proj/within_family/within_family_project/processed/clumping_analysis/", opt$pheno, "/clumps/chr_no_clumps.txt"))

    # SNP from each clump with the highest effective N in our sumstats
    final <- ss %>%
                filter(SNP %in% snps$SNP) %>%
                left_join(snps) %>%
                group_by(chromosome, clump_number)

    if (effect == "direct") {
        final %<>% 
            filter(direct_N == max(direct_N)) %>%
            ungroup()
    } else if (effect == "population") {
        final %<>% 
            filter(population_N == max(population_N)) %>%
            ungroup()
    }

    # format in plink format
    final %<>% 
        mutate(ID = seq(1,nrow(final))) %>%
        select("ID", "SNP", paste0(effect, "_N"), paste0(effect, "_SE"), "A1", "A2", "freq", paste0(effect, "_Beta"), paste0(effect, "_pval"), "Chr", "pos", "cptid") %>%
        setNames(c("ID", "Name", paste0(effect, "_N"), paste0(effect, "_SE"), "A1", "A2", "freq", "A1Effect", paste0(effect, "_pval"), "Chrom", "Position", "varid"))


    # save
    output_dir <- paste0("/var/genetics/proj/within_family/within_family_project/processed/clumping_analysis/", opt$pheno, "/", effect, "/weights/", opt$dataset)
    if (!dir.exists(output_dir)) {
        dir.create(output_dir, recursive = TRUE)
    }
    fwrite(final, paste0(output_dir, "/meta_weights.snpRes.formatted"), quote = F, sep = "\t")

}

## run function
if (opt$effect == "direct" | opt$effect == "population") {
    process_clumps(opt)
} else if (opt$effect == "direct_population") {
    process_clumps(opt, effect = "direct")
    process_clumps(opt, effect = "population")
}