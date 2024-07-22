
## ---------------------------------------------------------------------
## description: get Neff for direct effects from howe et al. paper
## ---------------------------------------------------------------------

library(vcfR)
library(data.table)
library(dplyr)
library(magrittr)
library(ggplot2)

## ---------------------------------------------------------------------
## add AF and calculate Neff for each sumstats file
## ---------------------------------------------------------------------

af <- fread("/var/genetics/ukb/linner/EA3/EasyQC_HRC/EASYQC.ALLELE_FREQUENCY.MAPFILE.HRC.chr1_22_X.LET.FLIPPED_ALLELE_1000G+UK10K.txt")

get_neff <- function(file, pheno, phvar = 1) {

    # read in .vcf sumstats file
    vcf <- read.vcfR(file, verbose = FALSE)
    
    # get standard errors
    se <- extract.gt(vcf, element = 'SE') %>%
        as.data.frame()
    se %<>% mutate(ID = sub("\\_.*", "", rownames(se)))
    colnames(se)[1] <- "se"
    rownames(se) <- NULL
    se[,"se"] <- as.numeric(se[,"se"])

    # get genotype data and merge with af
    fix <- getFIX(vcf)
    data <- fix %>%
            as.data.frame() %>%
            mutate(ChrPosID = paste0(CHROM, ":", POS)) %>%
            merge(af)
    
    # merge with se
    final <- merge(data, se) %>%
                mutate(neff = round(phvar*(2*freq1*(1-freq1)*se^2)^(-1), 0))
                
    # # save effective N and add to table
    # neff <- data.frame(med_neff = median(final$neff))
    # write.table(neff, file = paste0("/var/genetics/proj/within_family/within_family_project/processed/howe_et_al/howe_",pheno,"_neff.txt"), sep = " \t", row.names =  FALSE, quote = FALSE)
    
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

    ss <- fread(paste0("/var/genetics/proj/within_family/within_family_project/processed/howe_et_al/howe_", pheno, ".txt"))

    med_neff <- median(ss$neff, na.rm = TRUE)
    max_neff <- max(ss$neff, na.rm = TRUE)
    
    ss_hm3 <- ss %>%
                filter(ID %in% hm3$SNP)
    med_neff_hm3 <- median(ss_hm3$neff, na.rm = TRUE)

    neff <- data.frame(pheno = pheno, med_neff = med_neff, max_neff = max_neff, med_neff_hm3 = med_neff_hm3)
    neff_df <- rbind(neff_df, neff)
    
}
fwrite(neff_df, "/var/genetics/proj/within_family/within_family_project/processed/howe_et_al/howe_med_neff.txt", sep = "\t", row.names =  FALSE, quote = FALSE)

## ---------------------------------------------------------------------
## QC diagnostic plots for just height
## ---------------------------------------------------------------------

## plot SE v.s. AF

height_ss <- fread("/var/genetics/proj/within_family/within_family_project/processed/howe_et_al/howe_height.txt")

se_af <- ggplot(height_ss, aes(x = freq1, y = se)) +
            geom_point() +
            labs(x = "Allele Frequency", y = "Standard Error") +
            theme_classic()
ggsave("/var/genetics/proj/within_family/within_family_project/processed/howe_et_al/howe_height_se_af.png", se_af)

## plot Neff v.s. AF
neff_af <- ggplot(height_ss, aes(x = freq1, y = neff)) +
            geom_point() +
            labs(x = "Allele Frequency", y = "Direct Effective N") +
            theme_classic()
ggsave("/var/genetics/proj/within_family/within_family_project/processed/howe_et_al/howe_height_neff_af.png", neff_af)

## plot Neff histogram
neff_hist <- ggplot(height_ss, aes(x = neff)) +
                geom_histogram() +
                labs(x="Effective N", y="Count") +
                theme_classic()
ggsave("/var/genetics/proj/within_family/within_family_project/processed/howe_et_al/howe_height_neff_hist.png", neff_hist)

## Neff histogram for just hm3 SNPs

hm3 <- fread("/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist")

height_ss_hm3 <- height_ss %>%
                    filter(ID %in% hm3$SNP)

neff_hm3_hist <- ggplot(height_ss_hm3, aes(x = neff)) +
                geom_histogram() +
                labs(x="Effective N", y="Count") +
                theme_classic()
ggsave("/var/genetics/proj/within_family/within_family_project/processed/howe_et_al/howe_height_neff_hm3_hist.png", neff_hm3_hist)




max(height_ss$neff)


neff_hist <- ggplot(ss, aes(x = neff)) +
                geom_histogram() +
                labs(x="Effective N", y="Count") +
                theme_classic()
ggsave("/var/genetics/proj/within_family/within_family_project/processed/howe_et_al/howe_education_neff_hist.png", neff_hist)



# # bmi <- fread("/var/genetics/proj/within_family/within_family_project/scratch/sibship_data_temp/bmi.txt")
# # height <- fread("/var/genetics/proj/within_family/within_family_project/scratch/sibship_data_temp/height.txt")
# # education <- fread("/var/genetics/proj/within_family/within_family_project/scratch/sibship_data_temp/education.txt")

# # median(bmi$neff)
# # median(height$neff)
# # median(education$neff)

# ## compare with effective N from our analysis

hm3 <- fread("/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist")

plot_Neff <- function(wf_path, sib_path, pheno) {
    
    # read in data
    wf <- fread(wf_path)
    sib <- fread(sib_path)

    # filter sib to hm3 SNPs only
    sib %<>% filter(ID %in% hm3$SNP) %>% rename("freq" = freq1)

    # create dataframe
    hist_dat <- rbind(wf %>%
                        select(freq, direct_N) %>%
                        rename("neff" = direct_N) %>%
                        mutate(data_source = "wf"),
                    sib %>%
                        select(freq, neff) %>%
                        mutate(data_source = "sib"))

    # plot
    p <- ggplot(hist_dat, aes(x = neff, fill = data_source)) +
                    geom_histogram(position="dodge", alpha = 0.5, bins = 50) +
                    scale_color_brewer(palette="Dark2", guide="none") +
                    scale_fill_brewer(palette="Dark2", labels=c("Sib Consortium", "Within-Family")) +
                    labs(x="Effective N", y="Count") +
                    # xlim(0, 80000) +
                    ggtitle("Effective N for Direct Effects") +
                    guides(fill = guide_legend(title = "")) +
                    theme_classic()
    p
    ggsave(paste0("/var/genetics/proj/within_family/within_family_project/processed/howe_et_al/howe_",pheno,"_neff_hm3_hist.png"), p)

}

plot_Neff("/var/genetics/proj/within_family/within_family_project/processed/package_output/height/meta.sumstats.gz", 
            "/var/genetics/proj/within_family/within_family_project/processed/howe_et_al/howe_height.txt",
            "height")
