t0 <- proc.time()

library(data.table)
library(magrittr)
library(rlang)
library(bigsnpr)
options(bigstatsr.check.parallel.blas = FALSE)
options(default.nproc.blas = NULL)
library(ggplot2)
library(dplyr)

setwd("/var/genetics/proj/within_family/within_family_project/")


bfile = "/var/genetics/data/ukb/private/latest/processed/user/harij/projects/within_family/data/ukb_chr1_22_geno01_maf001_hwe10e6_500k_removedwithdrawn"

dat <- fread("/var/genetics/proj/within_family/within_family_project/processed/ea_ref/GWAS_EA_excl23andMe.txt")
dat <- unique(dat, by = "MarkerName")

####################
# options
####################
zscore <- FALSE
gwas_samplesize <- 1100000

if (!is.null(gwas_samplesize)){
    dat[, N := gwas_samplesize]
}
#########################
# removing ambigous Alleles
dat <- dat[!((A1 == "A" & A2 == "T") |
          (A1 == "T" & A2 == "A") |
          (A1 == "C" & A2 == "G") |
          (A1 == "G" & A2 == "C"))]

#HM3 snps
info <- fread("/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist")

# Read in the summary statistic file
sumstats <- dat

# LDpred 2 require the header to follow the exact naming
if (!zscore){
    setnames(sumstats,
            old = c("CHR", "POS", "MarkerName", "A1", "A2", "Beta", "SE", "N"),
            new = c("chr", "pos", "rsid", "a1", "a0", "beta", "beta_se", "n_eff"))
} else {
        setnames(sumstats,
            old = c("Chr", "BP", "SNP", "A1", "A2", "Z", "N"),
            new = c("chr", "pos", "rsid", "a1", "a0", "Z", "n_eff"))
}
# Filter out hapmap SNPs
sumstats <- sumstats[sumstats$rsid %in% info$SNP,]


file.remove(paste0(bfile, ".bk"))
# calcualte LD matrix
# Get maximum amount of cores
NCORES <- nb_cores()
# Initialize variables for storing the LD score and LD matrix
corr <- NULL
ld <- NULL
# We want to know the ordering of samples in the bed file 
df.out <- NULL
# preprocess the bed file (only need to do once for each data set)
rds <- snp_readBed(paste0(bfile, ".bed"), backingfile = bfile)
obj.bigSNP <- snp_attach(rds)


# extract the SNP information from the genotype
# Open a temporary file
map <- obj.bigSNP$map[-3]
names(map) <- c("chr", "rsid", "pos", "a1", "a0")
# perform SNP matching
info_snp <- snp_match(sumstats, map)
# Assign the genotype to a variable for easier downstream analysis
genotypes <- obj.bigSNP$genotypes <- snp_fastImputeSimple(
    obj.bigSNP$genotypes,
    method = "random", ncores = nb_cores()
)
# Rename the data structures
CHR <- map$chr
POS <- map$pos
# get the CM information from 1000 Genome
# will download the 1000G file to the current directory (".")
POS2 <- snp_asGeneticPos(CHR, POS, ncores = NCORES)
# calculate LD
for (chr in 1:22) {
    # Extract SNPs that are included in the chromosome
    ind.chr <- which(info_snp$chr == chr)
    ind.chr2 <- info_snp$`_NUM_ID_`[ind.chr]
    # Calculate the LD
    corr0 <- snp_cor(
            genotypes,
            ind.col = ind.chr2,
            ncores = NCORES,
            infos.pos = POS2[ind.chr2],
            size = 3 / 1000
        )
    if (chr == 1) {
        ld <- Matrix::colSums(corr0^2)
        corr <- as_SFBM(corr0)
    } else {
        ld <- c(ld, Matrix::colSums(corr0^2))
        corr$add_columns(corr0, nrow(corr))
    }
}
# We assume the fam order is the same across different chromosomes
df.out <- as.data.table(obj.bigSNP$fam)
# Rename fam order
setnames(df.out,
        c("family.ID", "sample.ID"),
        c("FID", "IID"))



# LD score reg
if (!zscore){
    df_beta <- info_snp[,c("beta", "beta_se", "n_eff", "_NUM_ID_")]
    ldsc <- snp_ldsc(   ld, 
                    length(ld), 
                    chi2 = (df_beta$beta / df_beta$beta_se)^2,
                    sample_size = df_beta$n_eff, 
                    blocks = NULL)
    h2_est <- ldsc[["h2"]]
} else {
    df_beta <- info_snp[,c("Z", "n_eff", "_NUM_ID_")]
    ldsc <- snp_ldsc(   ld, 
                    length(ld), 
                    chi2 = df_beta$Z^2,
                    sample_size = df_beta$n_eff, 
                    blocks = NULL)
    h2_est <- ldsc[["h2"]]
}



# calcualte NULL R2

# Reformat the phenotype file such that y is of the same order as the 
# sample ordering in the genotype file

# auto model
# Get adjusted beta from the auto model
multi_auto <- snp_ldpred2_auto(
    corr,
    df_beta,
    h2_init = h2_est,
    vec_p_init = seq_log(1e-4, 0.9, length.out = NCORES),
    ncores = NCORES
)
beta_auto <- sapply(multi_auto, function(auto) {auto$beta_est})

# obtain pgi
# calculate PRS for all samples
ind.test <- 1:nrow(genotypes)
final_beta_auto <- rowMeans(beta_auto)
pred_auto <- big_prodVec(genotypes,
                        final_beta_auto,
                        ind.row = ind.test,
                        ind.col = info_snp$`_NUM_ID_`)

df.out$PGI <- pred_auto

fwrite(df.out, "processed/ldpred2/ea_pgi_ea_ref.txt.gz")

t1 <- proc.time()
time <- t1 - t0
cat("Time Taken for Script:", time[3]/60, "minutes\n")