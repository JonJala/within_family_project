#!/usr/bin/env Rscript

## ---------------------------------------------------------------------
## description: run genomic SEM for pairs of traits
## ---------------------------------------------------------------------

list.of.packages <- c("GenomicSEM", "data.table")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos = "http://cran.rstudio.com/")
lapply(list.of.packages, library, character.only = TRUE)

## ---------------------------------------------------------------------
## define functions
## ---------------------------------------------------------------------

## function to run multivariable LDSC on set of 4 sumstats (2 traits, direct and pop). note: traits should be input in order trait1_direct, trait1_pop, trait2_direct, trait2_pop
## see https://github.com/GenomicSEM/GenomicSEM/wiki/3.-Models-without-Individual-SNP-effects for example
run_ldsc_genomicSEM <- function(traits, ld, wld, trait.names, outpath, filename, sample.prev=c(NA,NA,NA,NA), population.prev=c(NA,NA,NA,NA)) {

    if(!dir.exists(outpath)) {
        dir.create(outpath, recursive = TRUE)
    }
    setwd(outpath)

    # run LDSC
    LDSCoutput <- ldsc(traits=traits,sample.prev=sample.prev,population.prev=population.prev,ld=ld,wld=wld,trait.names=trait.names,ldsc.log=filename)

    # save output
    save(LDSCoutput,file=paste0(outpath, "/", "LDSCoutput_", filename, ".RData"))

}

covariance_to_correlation <- function(matrix) {
    M <- matrix(nrow = nrow(matrix), ncol = ncol(matrix))
    diag(M) <- 1
    for (i in 1:nrow(M)) {
        for (j in 1:ncol(M)) {
        M[i,j] <- matrix[i,j]/sqrt(matrix[i,i]*matrix[j,j])
        }
    }
    dimnames(M) <- dimnames(matrix)
    return(M)
}

analyze_genomicSEM_results <- function(LDSCoutput, logfile, outfile, basepath = NA) {

    if (!is.na(basepath)) {
        LDSCoutput <- paste0(basepath, LDSCoutput)
        logfile <- paste0(basepath, logfile)
        outfile <- paste0(basepath, outfile)
    }

    ## load and extract data
    load(LDSCoutput)
    gen_cov <- LDSCoutput$S # genetic covariances. note, not correlations
    sampling_vcov <- LDSCoutput$V # sampling vcov of covariances

    ## transform covariance matrix into correlation matrix and get difference between correlations
    gen_corr <- covariance_to_correlation(gen_cov)
    corr1 <- gen_corr[3,1]
    corr2 <- gen_corr[4,2]
    diff <- corr1 -  corr2

    ## get variances of correlations from log file
    log <- readLines(logfile)
    corrs <- grep("Genetic Correlation between", log, value = T)
    var_direct <- as.numeric(strsplit(strsplit(corrs[2], "\\(")[[1]][2], "\\)")[[1]][1])^2
    var_pop <- as.numeric(strsplit(strsplit(corrs[5], "\\(")[[1]][2], "\\)")[[1]][1])^2

    ## use delta method to approximate covariance of correlation

    # create sigma matrix. rows are direct, cols are pop
    sigma <- matrix(c(sampling_vcov[3,7], sampling_vcov[8,7],sampling_vcov[1,7],
                    sampling_vcov[3,10], sampling_vcov[8,10],sampling_vcov[1,10],
                    sampling_vcov[3,5], sampling_vcov[8,5],sampling_vcov[1,5]), nrow = 3, ncol = 3)

    df_1 <- 1 / (sqrt(gen_cov[3,3]*gen_cov[1,1]))
    df_2 <- -0.5*gen_cov[3,3]^(-1.5) * gen_cov[1,3]/sqrt(gen_cov[1,1])
    df_3 <- -0.5*gen_cov[1,1]^(-1.5) * gen_cov[1,3]/sqrt(gen_cov[3,3])
    dg_1 <- 1 / (sqrt(gen_cov[2,2]*gen_cov[4,4]))
    dg_2 <- -0.5*gen_cov[4,4]^(-1.5) * gen_cov[2,4]/sqrt(gen_cov[2,2])
    dg_3 <- -0.5*gen_cov[2,2]^(-1.5) * gen_cov[2,4]/sqrt(gen_cov[4,4])

    cov <- df_1 * dg_1 * sigma[1,1] +
            df_1 * dg_2 * sigma[1,2] +
            df_1 * dg_3 * sigma[1,3] +
            df_2 * dg_1 * sigma[2,1] +
            df_2 * dg_2 * sigma[2,2] +
            df_2 * dg_3 * sigma[2,3] +
            df_3 * dg_1 * sigma[3,1] +
            df_3 * dg_2 * sigma[3,2] +
            df_3 * dg_3 * sigma[3,3]

    ## variance and p-val of the difference between the correlations
    var_diff <- var_direct + var_pop - 2*cov
    se_diff <- sqrt(var_diff)

    z <- diff/se_diff
    p <- 2*pnorm(abs(z), lower.tail = FALSE)

    results <- data.table(variable=c("corr1", "corr2", "corr_diff", "cov", "se", "z", "p"), value=c(corr1, corr2, diff, cov, se_diff, z, p))
    print(results)
    fwrite(results, outfile, sep="\t", quote=F, row.names=F, col.names=T)

}

## ---------------------------------------------------------------------
## run genomic SEM
## ---------------------------------------------------------------------

eur_ldsc <- "/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
junming_ldsc <- "/disk/genetics/ukb/jguan/ukb_analysis/output/ldsc/v2/"
ss_basepath <- "/var/genetics/proj/within_family/within_family_project/processed/package_output/"

pheno1 <-"bmi"
pheno2 <- "ea"

## run genomic SEM

# # for bmi and ea, using ldsc ld scores
# run_ldsc_genomicSEM(traits=c(paste0(ss_basepath, pheno1, "/directmunged.sumstats.gz"), paste0(ss_basepath, pheno1, "/populationmunged.sumstats.gz"), paste0(ss_basepath, pheno2, "/directmunged.sumstats.gz"), paste0(ss_basepath, pheno2, "/populationmunged.sumstats.gz")), 
#                     ld=eur_ldsc,
#                     wld=eur_ldsc,
#                     trait.names=c(paste0(pheno1, "_direct"), paste0(pheno1, "_pop"), paste0(pheno2, "_direct"), paste0(pheno2, "_pop")),
#                     outpath=paste0("/var/genetics/proj/within_family/within_family_project/processed/genomic_sem/eur_ldsc/", pheno1, "_", pheno2),
#                     filename=paste0(pheno1, "_", pheno2))

# # just bmi direct and bmi pop, ldsc ld scores
# run_ldsc_genomicSEM(traits=c(paste0(ss_basepath, "bmi/directmunged.sumstats.gz"), paste0(ss_basepath, "bmi/populationmunged.sumstats.gz")), 
#                     ld=eur_ldsc,
#                     wld=eur_ldsc,
#                     trait.names=c("bmi_direct", "bmi_pop"),
#                     outpath=paste0("/var/genetics/proj/within_family/within_family_project/processed/genomic_sem/eur_ldsc/", "bmi"),
#                     filename=paste0("bmi"))

# # just ea direct and ea pop, ldsc ld scores
# run_ldsc_genomicSEM(traits=c(paste0(ss_basepath, "ea/directmunged.sumstats.gz"), paste0(ss_basepath, "ea/populationmunged.sumstats.gz")), 
#                     ld=eur_ldsc,
#                     wld=eur_ldsc,
#                     trait.names=c("ea_direct", "ea_pop"),
#                     outpath=paste0("/var/genetics/proj/within_family/within_family_project/processed/genomic_sem/eur_ldsc/", "ea"),
#                     filename=paste0("ea"))

# # just bmi direct and ea direct, ldsc ld scores
# run_ldsc_genomicSEM(traits=c(paste0(ss_basepath, "bmi/directmunged.sumstats.gz"), paste0(ss_basepath, "ea/directmunged.sumstats.gz")), 
#                     ld=eur_ldsc,
#                     wld=eur_ldsc,
#                     trait.names=c("bmi_direct", "ea_direct"),
#                     outpath=paste0("/var/genetics/proj/within_family/within_family_project/processed/genomic_sem/eur_ldsc/", "bmi_ea_direct"),
#                     filename=paste0("bmi_ea_direct"))



# # for bmi and ea, using junming's ld scores
# run_ldsc_genomicSEM(traits=c(paste0(ss_basepath, pheno1, "/directmunged.sumstats.gz"), paste0(ss_basepath, pheno1, "/populationmunged.sumstats.gz"), paste0(ss_basepath, pheno2, "/directmunged.sumstats.gz"), paste0(ss_basepath, pheno2, "/populationmunged.sumstats.gz")), 
#                     ld=junming_ldsc,
#                     wld=junming_ldsc,
#                     trait.names=c(paste0(pheno1, "_direct"), paste0(pheno1, "_pop"), paste0(pheno2, "_direct"), paste0(pheno2, "_pop")),
#                     outpath=paste0("/var/genetics/proj/within_family/within_family_project/processed/genomic_sem/junming_ldsc/", pheno1, "_", pheno2),
#                     filename=paste0(pheno1, "_", pheno2))

# just bmi direct and bmi pop, junming's ld scores
run_ldsc_genomicSEM(traits=c(paste0(ss_basepath, "bmi/directmunged.sumstats.gz"), paste0(ss_basepath, "bmi/populationmunged.sumstats.gz")), 
                    ld=junming_ldsc,
                    wld=junming_ldsc,
                    trait.names=c("bmi_direct", "bmi_pop"),
                    outpath=paste0("/var/genetics/proj/within_family/within_family_project/processed/genomic_sem/junming_ldsc/", "bmi"),
                    filename=paste0("bmi"))

# just ea direct and ea pop, junming's ld scores
run_ldsc_genomicSEM(traits=c(paste0(ss_basepath, "ea/directmunged.sumstats.gz"), paste0(ss_basepath, "ea/populationmunged.sumstats.gz")), 
                    ld=junming_ldsc,
                    wld=junming_ldsc,
                    trait.names=c("ea_direct", "ea_pop"),
                    outpath=paste0("/var/genetics/proj/within_family/within_family_project/processed/genomic_sem/junming_ldsc/", "ea"),
                    filename=paste0("ea"))

# just bmi direct and ea direct, junming's ld scores
run_ldsc_genomicSEM(traits=c(paste0(ss_basepath, "bmi/directmunged.sumstats.gz"), paste0(ss_basepath, "ea/directmunged.sumstats.gz")), 
                    ld=junming_ldsc,
                    wld=junming_ldsc,
                    trait.names=c("bmi_direct", "ea_direct"),
                    outpath=paste0("/var/genetics/proj/within_family/within_family_project/processed/genomic_sem/junming_ldsc/", "bmi_ea_direct"),
                    filename=paste0("bmi_ea_direct"))


## ---------------------------------------------------------------------
## analyze results
## ---------------------------------------------------------------------

# # for bmi and ea, using ldsc ld scores
# analyze_genomicSEM_results(LDSCoutput=paste0("LDSCoutput_", pheno1, "_", pheno2, ".RData"),
#                             logfile=paste0(pheno1, "_", pheno2, "_ldsc.log"),
#                             outfile=paste0(pheno1, "_", pheno2, "_results.txt"),
#                             basepath=paste0("/var/genetics/proj/within_family/within_family_project/processed/genomic_sem/eur_ldsc/", pheno1, "_", pheno2, "/"))

# # for bmi and ea, using junming's ld scores
# analyze_genomicSEM_results(LDSCoutput=paste0("LDSCoutput_", pheno1, "_", pheno2, ".RData"),
#                             logfile=paste0(pheno1, "_", pheno2, "_ldsc.log"),
#                             outfile=paste0(pheno1, "_", pheno2, "_results.txt"),
#                             basepath=paste0("/var/genetics/proj/within_family/within_family_project/processed/genomic_sem/junming_ldsc/", pheno1, "_", pheno2, "/"))