#!/usr/bin/env Rscript

# ---------------------------------------------------------------------
# description: info score analysis for howe et al. paper
# ---------------------------------------------------------------------

list.of.packages <- c("data.table", "dplyr", "magrittr", "tidyverse", "bigsnpr", "plinkFile", "genio")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos = "http://cran.rstudio.com/")
lapply(list.of.packages, library, character.only = TRUE)

# ---------------------------------------------------------------------
# read in data
# ---------------------------------------------------------------------

# read in chr 1 data
dat <- fread("/disk/genetics2/ukb/orig/UKBv3/imputed_data/ukb_mfi_chr1_v3.txt")
dat %<>% 
    filter(0.3 < V8 & V8 < 0.31) %>% # filter info score between 0.3 and 0.31
    mutate(snp_id = paste0("1_", V3, "_", V4, "_", V5)) # create snp_id column
set.seed(42)
snps <- sample(dat$snp_id, 100, replace = FALSE) # randomly select 100 snps

# read in sibs
sibs <- fread("/disk/genetics/ukb/alextisyoung/haplotypes/relatives/bedfiles/hap.kin0") # list of sibs in UKB
sibs %<>% filter(InfType == "FS") # full sibs only

# read in bgen sample file
sample <- fread("/disk/genetics2/ukb/orig/UKBv3/sample/ukb11425_imp_chr1_22_v3_s487395.sample")

# get index of siblings in sample file
sib1_ind <- match(sibs$ID1, sample$ID_1)
sib2_ind <- match(sibs$ID2, sample$ID_1)

# read in bgen data for each set of sibs
# sib1_path <- snp_readBGEN("/disk/genetics2/ukb/orig/UKBv3/imputed_data/ukb_imp_chr1_v3.bgen", backingfile = "/disk/genetics4/ukb/tammytan/wf/sib1", list_snp_id = list(snps))
sib1_bgen <- readRDS("/disk/genetics4/ukb/tammytan/wf/sib1.rds")

# sib2_path <- snp_readBGEN("/disk/genetics2/ukb/orig/UKBv3/imputed_data/ukb_imp_chr1_v3.bgen", backingfile = "/disk/genetics4/ukb/tammytan/wf/sib2", ind_row = sib2_ind, list_snp_id = list(snps))
sib2_bgen <- readRDS("/disk/genetics4/ukb/tammytan/wf/sib2.rds")

# extract genotypes
sib1_gen <- sib1_bgen$genotypes[]
sib2_gen <- sib2_bgen$genotypes[]

cors <- c()
for (i in 1:dim(sib1_gen)[2]) {
    cor <- cor(sib1_gen[i,], sib2_gen[i,])
    cors <- append(cors, cor)
}
hist(cors) # this doesn't look right....

# ---------------------------------------------------------------------
# create sample and snp files to filter bgen in plink
# ---------------------------------------------------------------------

## list of snps to keep

# read in chr 1 data
dat <- fread("/disk/genetics2/ukb/orig/UKBv3/imputed_data/ukb_mfi_chr1_v3.txt")
dat %<>% 
    filter(0.3 < V8 & V8 < 0.31) # filter info score between 0.3 and 0.31
set.seed(42)
snps <- sample(dat$V2, 100, replace = FALSE) # randomly select 100 snps
fwrite(data.frame(snps), "/disk/genetics4/ukb/tammytan/wf/howe_analysis/snps.txt", col.names = FALSE, row.names = FALSE, quote = FALSE)

# test snp list for high info score snps
dat_test <- fread("/disk/genetics2/ukb/orig/UKBv3/imputed_data/ukb_mfi_chr1_v3.txt")
dat_test %<>% 
    filter(V8 > 0.99)
set.seed(42)
high_info_snps <- sample(dat_test$V2, 100, replace = FALSE) # randomly select 100 snps
fwrite(data.frame(high_info_snps), "/disk/genetics4/ukb/tammytan/wf/howe_analysis/high_info_snps.txt", col.names = FALSE, row.names = FALSE, quote = FALSE)


## sib sample files

# read in sibs
sibs <- fread("/disk/genetics/ukb/alextisyoung/haplotypes/relatives/bedfiles/hap.kin0") # list of sibs in UKB
sibs %<>% filter(InfType == "FS") # full sibs only

sib1 <- data.frame(sibs$FID1, sibs$ID1, fix.empty.names =  FALSE)
fwrite(sib1, "/disk/genetics4/ukb/tammytan/wf/howe_analysis/sib1.txt", col.names = FALSE, row.names = FALSE, quote = FALSE, sep = "\t")
sib2 <- data.frame(sibs$FID2, sibs$ID2, fix.empty.names =  FALSE)
fwrite(sib2, "/disk/genetics4/ukb/tammytan/wf/howe_analysis/sib2.txt", col.names = FALSE, row.names = FALSE, quote = FALSE, sep = "\t")

all_sibs <- rbind(sib1, sib2)
fwrite(all_sibs, "/disk/genetics4/ukb/tammytan/wf/howe_analysis/all_sibs.txt", col.names = FALSE, row.names = FALSE, quote = FALSE, sep = "\t")


## read in processed plink files
sib1_bed  <- readBED("/disk/genetics4/ukb/tammytan/wf/howe_analysis/sib1.bed")
sib1_fam  <- read_fam("/disk/genetics4/ukb/tammytan/wf/howe_analysis/sib1.fam")
sib1_bed <- data.table(ID1 = as.numeric(sib1_fam$id), sib1_bed)
sib1_dat <- sibs %>%
                select(ID1) %>%
                left_join(sib1_bed)

sib2_bed  <- readBED("/disk/genetics4/ukb/tammytan/wf/howe_analysis/sib2.bed")
sib2_fam  <- read_fam("/disk/genetics4/ukb/tammytan/wf/howe_analysis/sib2.fam")
sib2_bed <- data.table(ID2 = as.numeric(sib2_fam$id), sib2_bed)
sib2_dat <- sibs %>%
                select(ID2) %>%
                left_join(sib2_bed)

cors <- c()
for (i in 1:100) {
    j <- i + 1
    cor <- cor(sib1_dat[,..j], sib2_dat[,..j], use = "pairwise.complete.obs")
    print(cor)
    cors <- append(cors, cor[1])
}
hist(cors)
mean(cors, na.rm = TRUE)
median(cors, na.rm = TRUE)




## test with high info snps
bed <- readBED("/disk/genetics4/ukb/tammytan/wf/howe_analysis/all_sibs_high_info.bed")
fam <- read_fam("/disk/genetics4/ukb/tammytan/wf/howe_analysis/all_sibs_high_info.fam")

head(bed)
head(fam)

bed_dat <- data.table(ID = as.numeric(fam$id), bed)
sib1_dat <- sibs %>%
                select(ID1) %>%
                rename(ID = ID1) %>%
                left_join(bed_dat)
sib2_dat <- sibs %>%
                select(ID2) %>%
                rename(ID = ID2) %>%
                left_join(bed_dat)
cors <- c()
for (i in 1:100) {
    j <- i + 1
    cor <- cor(sib1_dat[,..j], sib2_dat[,..j], use = "pairwise.complete.obs")
    print(cor)
    cors <- append(cors, cor[1])
}
hist(cors)
mean(cors, na.rm = TRUE)
median(cors, na.rm = TRUE)