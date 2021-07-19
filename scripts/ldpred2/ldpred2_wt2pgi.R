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
        cat("BK file: ", bkfile, "\n")
        if (bkfile == ""){
            file.remove(paste0(file, ".bk"))
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
    make_option(c("--wtfile"),  type="character", default=NULL, help="Path of weight file." , metavar="character"),
    make_option(c("--wtcolname"),  type="character", default="ldpred_beta", help="Name of weight column." , metavar="character"),                            
    make_option(c("--outfile"),   type="character", default="",  help="File of outputted PGI file.", metavar="character"),
       make_option(c("--bed_backup"),  type="character", default="", help="To read the bed file a backup file needs
    to be created. This specifies where that will be. If empty, its the same location as the bed file itself.", metavar="character")
)



opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)

cat("Reading the bed file...\n")
obj.bigSNP <- import_validation_bed(opt$bfile, opt$bed_backup)
n_individuals = nrow(obj.bigSNP$fam)
n_snps = nrow(obj.bigSNP$map)
cat("Number of individuals in bed file:", n_individuals, "\n")
cat("Number of SNPs in bed file:", n_snps, "\n")

# extract the SNP information from the genotype
# Open a temporary file
map <- obj.bigSNP$map[-3]
names(map) <- c("chr", "rsid", "pos", "a1", "a0")

# perform SNP matching
# Assign the genotype to a variable for easier downstream analysis
genotypes <- obj.bigSNP$genotypes <- snp_fastImputeSimple(
    obj.bigSNP$genotypes,
    method = "random", ncores = nb_cores()
)
ind.test <- 1:nrow(genotypes)


df.wt = fread(opt$wtfile)

final_beta_auto <- df.wt[, opt$wtcolname]

final_pred_auto <- big_prodVec(
    genotypes, final_beta_auto,
    ind.row = ind.test
)

df.out <- as.data.table(obj.bigSNP$fam)
df.out[, PGI := final_pred_auto]
cat("Outputting PGI file...\n")
fwrite(df.out, paste0(opt$outfile, ".pgi.txt"), sep = " ", na = ".")


t1 <- proc.time()
time <- t1 - t0
timeminutes = time[3]/60
cat("Time Taken for Script:", timeminutes, "minutes\n")

