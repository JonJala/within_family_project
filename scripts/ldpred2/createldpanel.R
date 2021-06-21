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


####### Options ###########

option_list = list(

    make_option(c("--bfile"),  type="character", default=NULL, help="Path of bed file. Do not include the extension .bed. 
                                        Assumes the .bim and .fam files are located in the same place", metavar="character"),
    make_option(c("--outprefix"),   type="character", default="",  help="File of outputted ldmatrix file. 
    The chromosome number will be added to this name and then the extension of .rds will be added.", metavar="character"),


opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)

bfile = opt$bfile


file.remove(paste0(bfile, ".bk"))
# calcualte LD matrix
# Get maximum amount of cores
NCORES <- nb_cores()
# preprocess the bed file (only need to do once for each data set)
cat("Reading the bed file...")
rds <- snp_readBed(paste0(bfile, ".bed"), backingfile = bfile)
obj.bigSNP <- snp_attach(rds)


# extract the SNP information from the genotype
map <- obj.bigSNP$map[-3]
names(map) <- c("chr", "rsid", "pos", "a1", "a0")


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
for (chr in 1:22) {

    cat("Chromosome Number: ", chr, "\n")
    # Extract SNPs that are included in the chromosome
    ind.chr <- which(CHR == chr)
    # ind.chr2 <- map$`_NUM_ID_`[ind.chr]

    corr0 <- snp_cor(
            genotypes,
            ind.col = ind.chr,
            ncores = NCORES,
            infos.pos = POS2[ind.chr],
            size = 3 / 1000
        )
    
    saveRDS(corr0, file = paste0(opt$outprefix, chr, ".rds"), version = 2)
}