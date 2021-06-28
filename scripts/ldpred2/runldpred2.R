t0 <- proc.time()

cat("Start time:\n", t0)

library(data.table)
library(magrittr)
library(rlang)
library(bigsnpr)
options(bigstatsr.check.parallel.blas = FALSE)
options(default.nproc.blas = NULL)
library(ggplot2)
library(dplyr)
library(optparse)
library(stringr)

########################
# Functions
#######################
remove_ambig_alleles = function(dat, allele1name, allele2name){

    dfout = dat[!((get(allele1name) == "A" & get(allele2name) == "T") |
          (get(allele1name) == "T" & get(allele2name) == "A") |
          (get(allele1name) == "C" & get(allele2name) == "G") |
          (get(allele1name) == "G" & get(allele2name) == "C"))]

    return(dfout)

}

import_validation_bed <- function(file, bkfile) {

    rds_file <- paste0(file, ".rds")
    rds_file_backup <- paste0(file, ".bk")
    rds_file_bk <- paste0(bkfile, ".rds")
    rds_file_bk_backup <- paste0(rds_file_bk, ".bk")

    if (file.exists(rds_file) & file.exists(rds_file_backup)) {
        cat("Reading RDS File from", rds_file, "\n")
        obj.bigSNP <- snp_attach(rds_file)
    } else if (file.exists(rds_file_bk) & file.exists(rds_file_bk_backup)) {
        cat("Reading RDS File from", rds_file_bk, "\n")
        obj.bigSNP <- snp_attach(rds_file_bk)
    } else {
        cat("Reading bed file from", file, "\n")
        
        if (bkfile == ""){
            file.remove(paste0(bfile, ".bk"))
            rds <- snp_readBed(paste0(file, ".bed"))
        } else {
            file.remove(paste0(bkfile, ".bk"))
            rds <- snp_readBed(paste0(file, ".bed"), backingfile = bkfile)
        }
        obj.bigSNP <- snp_attach(rds)
    }
    return(obj.bigSNP)
}


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
    Overrides the N_col option", metavar="character"),
    make_option(c("--read_ldmat"),  type="character", default="", help="Read the LD matrix from an RDS file.
    If empty will calculate the LD matrix from the genotype data. If non-empty provide two files which are comma
    seperated - the actual data with the LD matrices with ~ instead of the chromosome, and the map data.", metavar="character"),
    make_option(c("--bed_backup"),  type="character", default="", help="To read the bed file a backup file needs
    to be created. This specifies where that will be. If empty, its the same location as the bed file itself.", metavar="character"),
    make_option(c("--predout"),  action="store_true", default=FALSE, help="Should PGIs also be calculated and
    outputted. If no the script will only output the weights.", metavar="character"),
    make_option(c("--scale_pgi"),  action="store_true", default=FALSE, help="If true PGI's are standardized
    to have mean 0 and variance 1. Only works if the predout option is chosen.", metavar="character")
)


opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)

bfile = opt$bfile

sumstats <- fread(opt$sumstats)
sumstats <- unique(sumstats, by = opt$rsid)

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
    sumstats[, beta := log(get(opt$or))]
} else {
    setnames(sumstats, opt$beta, "beta")
}

if (opt$gwas_samplesize != 0.0) {
    sumstats[, N := opt$gwas_samplesize]
} else {
    setnames(sumstats, opt$N_col, "N")
}

#########################
# removing ambigous Alleles
sumstats <- remove_ambig_alleles(sumstats, opt$a1, opt$a2)

#HM3 snps
info <- fread(opt$hm3)

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
cat("Sumstats file:\n")
cat("Nrows: ", nrow(sumstats), "\n")
head(sumstats)


# calcualte LD matrix
# Get maximum amount of cores
NCORES <- nb_cores()

# preprocess the bed file (only need to do once for each data set)
cat("Reading the bed file...\n")
obj.bigSNP <- import_validation_bed(bfile, opt$bed_backup)
n_individuals = nrow(obj.bigSNP$fam)
n_snps = nrow(obj.bigSNP$map)
cat("Number of individuals in bed file:", n_individuals, "\n")
cat("Number of SNPs in bed file:", n_snps, "\n")

# extract the SNP information from the genotype
# Open a temporary file
if (opt$read_ldmat != ""){
    ld_path = str_split(opt$read_ldmat, ",")[[1]][[1]]
    map_path = str_split(opt$read_ldmat, ",")[[1]][[2]]
    ld_path = str_split(ld_path, "~")[[1]]
    map <- readRDS(map_path)

} else {
    map <- obj.bigSNP$map[-3]
    names(map) <- c("chr", "rsid", "pos", "a1", "a0")
}

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
cat("Calculating the LD Matrix...\n")
POS2 <- snp_asGeneticPos(CHR, POS, ncores = NCORES)
cat("LD Mat reading option:", opt$read_ldmat, "\n")
for (chr in 1:22) {

    cat("Reading chromosome number", chr, "...\n")

    # Extract SNPs that are included in the chromosome
    ind.chr <- which(info_snp$chr == chr)
    ind.chr2 <- info_snp$`_NUM_ID_`[ind.chr]

    if (opt$read_ldmat != "") {
        cat("Reading LDmatrix\n")
        # if we are using external LD mat data
        ind.chr3 <- match(ind.chr2, which(CHR == chr))
        corr0 <- readRDS(paste0(ld_path[[1]], chr, ld_path[[2]]))[ind.chr3, ind.chr3]
    } else {
        cat("Calculating LD Matrix\n")
        corr0 <- snp_cor(
                genotypes,
                ind.col = ind.chr2,
                ncores = NCORES,
                infos.pos = POS2[ind.chr2],
                size = 3 / 1000
            )
    }
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
        old = c("family.ID", "sample.ID"),
        new = c("FID", "IID"))

# LD score reg
cat("Conducting the LD-Score Regression\n")
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
cat("Calculating the PGI\n")
multi_auto <- snp_ldpred2_auto(
    corr,
    df_beta,
    h2_init = h2_est,
    vec_p_init = seq_log(1e-4, 0.9, length.out = NCORES),
    ncores = NCORES
)
beta_auto <- sapply(multi_auto, function(auto) {auto$beta_est})
ind.test <- 1:nrow(genotypes)
final_beta_auto <- rowMeans(beta_auto)


df.out.wt <- as.data.table(info_snp[, c("chr", "pos",  "rsid.ss", "a1", "a0")])
df.out.wt[, ldpred_beta := final_beta_auto]
setnames(df.out.wt,
    old = c("chr", "pos", "rsid.ss", "a1", "a0"),
    new = c("chrom", "pos", "sid", "nt1", "nt2")
)

cat("Outputting weight file...\n")
fwrite(df.out.wt, paste0(opt$outfile, ".wt.txt.gz"),  sep = " ", na = ".")

if (opt$predout) {
    
    final_pred_auto <- big_prodVec(
        genotypes, final_beta_auto,
        ind.row = ind.test, ind.col = info_snp$`_NUM_ID_`
    )

    df.out[, PGI := final_pred_auto]

    if opt$scale_pgi{

        df.out[, PGI := (PGI - mean(PGI, na.rm = TRUE)/sd(PGI, na.rm = TRUE))]
        cat("PGI has been standarized!\n")
    }
    cat("Outputting PGI file...\n")
    fwrite(df.out, paste0(opt$outfile, ".pgi.txt.gz"), sep = " ", na = ".")

}

# remove bk files
if (opt$bed_backup == ""){
    file.remove(paste0(bfile, ".bk"))
} else {
    file.remove(paste0(opt$bed_backup, ".bk"))
}

t1 <- proc.time()
time <- t1 - t0
timeminutes = time[3]/60
cat("Time Taken for Script:", timeminutes, "minutes\n")