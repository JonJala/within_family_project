
## ---------------------------------------------------------------------
## description: look at Neff and QC diagnostics from howe paper
## ---------------------------------------------------------------------

list.of.packages <- c("data.table", "dplyr", "magrittr", "tidyverse", "vcfR", "ggplot2")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos = "http://cran.rstudio.com/")
lapply(list.of.packages, library, character.only = TRUE)

## ---------------------------------------------------------------------
## add AF and calculate Neff for each sumstats file
## ---------------------------------------------------------------------

af <- fread("/var/genetics/ukb/linner/EA3/EasyQC_HRC/EASYQC.ALLELE_FREQUENCY.MAPFILE.HRC.chr1_22_X.LET.FLIPPED_ALLELE_1000G+UK10K.txt")

get_neff <- function(file, pheno, phvar = 1) {

    print(pheno)

    # read in .vcf sumstats file
    vcf <- read.vcfR(file, verbose = FALSE)

    # extract data from gt
    gt <- vcf@gt
    df <- data.frame(gt[,2])
    colnames(df) <- "data"
    strings <- df$data
    split_strings <- strsplit(strings, ":")
    new_df <- do.call(rbind, split_strings)
    colnames(new_df) <- c("ES", "SE", "LP", "SS", "ID")
    new_df <- as.data.frame(new_df)
    new_df$ES <- as.numeric(new_df$ES)
    new_df$SE <- as.numeric(new_df$SE)
    new_df$LP <- as.numeric(new_df$LP)
    new_df$SS <- as.numeric(new_df$SS)

    # get genotype data and merge with af
    fix <- getFIX(vcf)
    data <- fix %>%
            as.data.frame() %>%
            mutate(ChrPosID = paste0(CHROM, ":", POS)) %>%
            merge(af) %>%
            select(-a1, -a2)
    
    # merge with se
    final <- merge(data, new_df, by = "ID")
    
    # save final sumstats
    write.table(final, file = paste0("/var/genetics/proj/within_family/within_family_project/processed/howe_et_al/howe_",pheno,".txt"), sep = " \t", row.names =  FALSE, quote = FALSE)

}

get_neff("/var/genetics/data/published/howe_2022_sibship/raw/ieu-b-4835.vcf.gz", "education")
get_neff("/var/genetics/data/published/howe_2022_sibship/raw/ieu-b-4815.vcf.gz", "bmi")
get_neff("/var/genetics/data/published/howe_2022_sibship/raw/ieu-b-4813.vcf.gz", "height")
get_neff("/var/genetics/data/published/howe_2022_sibship/raw/ieu-b-4857.vcf.gz", "eversmoker")
get_neff("/var/genetics/data/published/howe_2022_sibship/raw/ieu-b-4817.vcf.gz", "bps")
get_neff("/var/genetics/data/published/howe_2022_sibship/raw/ieu-b-4843.vcf.gz", "hdl")
get_neff("/var/genetics/data/published/howe_2022_sibship/raw/ieu-b-4833.vcf.gz", "alc_consumption")
get_neff("/var/genetics/data/published/howe_2022_sibship/raw/ieu-b-4845.vcf.gz", "ldl")
get_neff("/var/genetics/data/published/howe_2022_sibship/raw/ieu-b-4847.vcf.gz", "neuroticism")
get_neff("/var/genetics/data/published/howe_2022_sibship/raw/ieu-b-4851.vcf.gz", "wellbeing")
get_neff("/var/genetics/data/published/howe_2022_sibship/raw/ieu-b-4827.vcf.gz", "nchildren")
get_neff("/var/genetics/data/published/howe_2022_sibship/raw/ieu-b-4839.vcf.gz", "depsymp")
get_neff("/var/genetics/data/published/howe_2022_sibship/raw/ieu-b-4853.vcf.gz", "fev1")
get_neff("/var/genetics/data/published/howe_2022_sibship/raw/ieu-b-4819.vcf.gz", "aafb")
get_neff("/var/genetics/data/published/howe_2022_sibship/raw/ieu-b-4837.vcf.gz", "cognition")
get_neff("/var/genetics/data/published/howe_2022_sibship/raw/ieu-b-4825.vcf.gz", "cpd")
get_neff("/var/genetics/data/published/howe_2022_sibship/raw/ieu-b-4821.vcf.gz", "agemenarche")

## ---------------------------------------------------------------------
## compile median neff for all phenos
## ---------------------------------------------------------------------

hm3 <- fread("/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist")

phenos <- c("height", "education", "bmi", "eversmoker", "bps", "hdl", "alc_consumption", "ldl", "neuroticism", "wellbeing", "nchildren", "depsymp", "fev1", "aafb", "cognition", "cpd", "agemenarche")

neff_df <- data.frame(pheno = NULL, med_neff = NULL, max_neff = NULL, med_neff_hm3 = NULL)
for (pheno in phenos) {

    print(pheno)

    ss <- fread(paste0("/var/genetics/proj/within_family/within_family_project/processed/howe_et_al/howe_", pheno, ".txt"))

    med_neff <- median(ss$SS, na.rm = TRUE)
    max_neff <- max(ss$SS, na.rm = TRUE)
    
    ss_hm3 <- ss %>%
                filter(ID %in% hm3$SNP)
    med_neff_hm3 <- median(ss_hm3$SS, na.rm = TRUE)

    neff <- data.frame(pheno = pheno, med_neff = med_neff, max_neff = max_neff, med_neff_hm3 = med_neff_hm3)
    neff_df <- rbind(neff_df, neff)
    
}
fwrite(neff_df, "/var/genetics/proj/within_family/within_family_project/processed/howe_et_al/howe_med_neff.txt", sep = "\t", row.names =  FALSE, quote = FALSE)

## ---------------------------------------------------------------------
## QC diagnostic plots for just education
## ---------------------------------------------------------------------

## plot SE v.s. AF

education_ss <- fread("/var/genetics/proj/within_family/within_family_project/processed/howe_et_al/howe_education.txt")

se_af <- ggplot(education_ss, aes(x = freq1, y = SE)) +
            geom_point() +
            labs(x = "Allele Frequency", y = "Standard Error") +
            theme_classic()
ggsave("/var/genetics/proj/within_family/within_family_project/processed/howe_et_al/howe_education_se_af.png", se_af)

## plot Neff v.s. AF
neff_af <- ggplot(education_ss, aes(x = freq1, y = SS)) +
            geom_point() +
            labs(x = "Allele Frequency", y = "Direct Effective N") +
            theme_classic()
ggsave("/var/genetics/proj/within_family/within_family_project/processed/howe_et_al/howe_education_neff_af.png", neff_af)

## plot Neff histogram
neff_hist <- ggplot(education_ss, aes(x = SS)) +
                geom_histogram() +
                labs(x="Effective N", y="Count") +
                theme_classic()
ggsave("/var/genetics/proj/within_family/within_family_project/processed/howe_et_al/howe_education_neff_hist.png", neff_hist)

## Neff histogram for just hm3 SNPs

hm3 <- fread("/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist")

education_ss_hm3 <- education_ss %>%
                    filter(ID %in% hm3$SNP)

neff_hm3_hist <- ggplot(education_ss_hm3, aes(x = SS)) +
                geom_histogram() +
                labs(x="Effective N", y="Count") +
                theme_classic()
ggsave("/var/genetics/proj/within_family/within_family_project/processed/howe_et_al/howe_education_neff_hm3_hist.png", neff_hm3_hist)
