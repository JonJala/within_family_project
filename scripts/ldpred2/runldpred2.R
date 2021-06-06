t0 <- proc.time()

library(data.table)
library(magrittr)
library(rlang)
library(bigsnpr)
options(bigstatsr.check.parallel.blas = FALSE)
options(default.nproc.blas = NULL)
library(ggplot2)
library(dplyr)
library(optparse)


####### Options ###########

option_list = list(

    make_option(c("--bfile"),  type="character", default=NULL, help="Path of bed file. Do not include the extension .bed. 
                                        Assumes the .bim and .fam files are located in the same place", metavar="character"),
    make_option(c("--sumstats"),   type="character", default="",  help="Sumstats file", metavar="character"),
    make_option(c("--hm3"),   type="character", default="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist",  help="Sumstats file", metavar="character"),
    make_option(c("--outfile"),   type="character", default="",  help="File of outputted PGI file.", metavar="character"),

    # Column names for sumstats
    make_option(c("--chr"),  type="character", default="chr", help="chr column name for sumstats", metavar="character"),
    make_option(c("--pos"),  type="character", default="pos", help="BP column name for sumstats", metavar="character"),
    make_option(c("--rsid"),  type="character", default="rsid", help="rsid column name for sumstats", metavar="character"),
    make_option(c("--a1"),  type="character", default="a1", help="A1 column name for sumstats", metavar="character"),
    make_option(c("--a2"),  type="character", default="a0", help="A2 column name for sumstats", metavar="character"),
    make_option(c("--beta"),  type="character", default="beta", help="beta column name for sumstats", metavar="character"),
    make_option(c("--beta_se"),  type="character", default="beta_se", help="beta SE column name for sumstats", metavar="character"),
    make_option(c("--N_col"),  type="character", default="N", help="N column name for sumstats", metavar="character"),

    # Other options on how to read sumstats
    make_option(c("--or"),  type="character", default="", help="OR column name for sumstats. Will be logged to be used
                                                as beta.
                                                If non-empty this will be used instead of
                                                beta and beta_se", metavar="character"),
    make_option(c("--zscore"),  type="character", default="", help="Z-score column name for sumstats
                                                If non-empty this will be used instead of
                                                beta and beta_se", metavar="character"),
    make_option(c("--gwas_samplesize"),  type="double", default=0.0, help="GWAS sample size to be used for all SNPs
    Overrides the N_col option", metavar="character")
)

opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)

bfile = opt$bfile

dat <- fread(opt$sumstats)
dat <- unique(dat, by = opt$rsid)

####################
# options
####################
if (opt$zscore != "") {
    zscore = opt$zscore
    use_zscore = TRUE
} else {
    use_zscore = FALSE
}

if (opt$or != "") {
    cat(paste("Using column name", opt$or, "as Odd's Ratio\n"))
    dat[, beta := log(get(opt$or))]
} else {
    setnames(dat, opt$beta, "beta")
}

if (opt$gwas_samplesize != 0.0) {
    dat[, N := get(opt$gwas_samplesize)]
} else {
    setnames(dat, opt$N_col, "N")
}

#########################
# removing ambigous Alleles
dat <- dat[!((get(opt$a1) == "A" & get(opt$a2) == "T") |
          (get(opt$a1) == "T" & get(opt$a2) == "A") |
          (get(opt$a1) == "C" & get(opt$a2) == "G") |
          (get(opt$a1) == "G" & get(opt$a2) == "C"))]

#HM3 snps
info <- fread(opt$hm3)

# Read in the summary statistic file
sumstats <- dat

# LDpred 2 require the header to follow the exact naming
if (!use_zscore){
    setnames(sumstats,
            old = c(opt$chr, opt$pos, opt$rsid, opt$a1, opt$a2, opt$beta_se, "N"),
            new = c("chr", "pos", "rsid", "a1", "a0", "beta_se", "n_eff"))
} else {
        setnames(sumstats,
            old = c(opt$chr, opt$pos, opt$rsid, opt$a1, opt$a2, zscore, "N"),
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
if (!use_zscore){
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

fwrite(df.out, opt$outfile)

t1 <- proc.time()
time <- t1 - t0
cat("Time Taken for Script:", time[3]/60, "minutes\n")