#!/usr/bin/env Rscript

## ---------------------------------------------------------------------
## description: run genomic SEM
## ---------------------------------------------------------------------

list.of.packages <- c("GenomicSEM", "data.table", "dplyr")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos = "http://cran.rstudio.com/")
lapply(list.of.packages, library, character.only = TRUE)

## ---------------------------------------------------------------------
## define functions
## ---------------------------------------------------------------------

## function to run multivariable LDSC on set of sumstats
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

## function to munge sumstats for genomic SEM
## see https://github.com/GenomicSEM/GenomicSEM/wiki/3.-Models-without-Individual-SNP-effects
munge_sumstats <- function(meta_ss, trait.names, outpath) {
    
    setwd(outpath)

    meta_ss <- fread(meta_ss)

    direct_out <- paste0(outpath, "/directmunged_temp.sumstats.gz")
    direct <- meta_ss %>% 
                select(SNP, A1, A2, direct_N, direct_Z, direct_pval) %>%
                rename(N = direct_N, effect = direct_Z, P = direct_pval)
    fwrite(direct, direct_out, sep="\t", quote=F, row.names=F, col.names=T, na="NA")

    population_out <- paste0(outpath, "/populationmunged_temp.sumstats.gz")
    population <- meta_ss %>% 
                select(SNP, A1, A2, population_N, population_Z, population_pval) %>%
                rename(N = population_N, effect = population_Z, P = population_pval)
    fwrite(population, population_out, sep="\t", quote=F, row.names=F, col.names=T, na="NA")

    #define the reference file being used to allign alleles across summary stats
    #here we are using hapmap3
    hm3<-"/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"

    #run munge
    munge(files=c(direct_out, population_out),hm3=hm3,trait.names=trait.names)

    # delete temp files
    file.remove(direct_out)
    file.remove(population_out)

}

## convert covariance matrix to correlation matrix
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

## analyze results from cross-trait analysis and get SE and p-values for difference between correlations
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

## single trait analysis, including corr with ref ss, for ST3
run_single_trait <- function(pheno, direct_ss, pop_ss, ldsc, ref_ss = NA, sample.prev=c(NA,NA,NA,NA), population.prev=c(NA,NA,NA,NA)) {
    
    outpath=paste0("/var/genetics/proj/within_family/within_family_project/processed/genomic_sem/", pheno, "/")
    if(!dir.exists(outpath)) {
        dir.create(outpath, recursive = TRUE)
    }

    if (!is.na(ref_ss)) {
        run_ldsc_genomicSEM(traits=c(direct_ss, pop_ss, ref_ss), 
                    ld=ldsc,
                    wld=ldsc,
                    trait.names=c(paste0(pheno, "_direct"), paste0(pheno, "_pop"), "reference"),
                    sample.prev=sample.prev,
                    population.prev=population.prev,
                    filename=pheno,
                    outpath=outpath)

    } else {
        run_ldsc_genomicSEM(traits=c(direct_ss, pop_ss),
                        ld=ldsc,
                        wld=ldsc,
                        trait.names=c(paste0(pheno, "_direct"), paste0(pheno, "_pop")),
                        sample.prev=sample.prev,
                        population.prev=population.prev,
                        filename=pheno,
                        outpath=outpath)
    }

}

## run cross-trait analysis. note: traits should be input in order trait1_direct, trait1_pop, trait2_direct, trait2_pop
run_cross_trait <- function(pheno1, pheno2, pheno1_direct, pheno1_pop, pheno2_direct, pheno2_pop, ldsc, sample.prev=c(NA,NA,NA,NA), population.prev=c(NA,NA,NA,NA), analyze_results = TRUE) {

    outpath <- paste0("/var/genetics/proj/within_family/within_family_project/processed/genomic_sem/cross_trait/", pheno1, "_", pheno2, "/")
    if(!dir.exists(outpath)) {
        dir.create(outpath, recursive = TRUE)
    }

    run_ldsc_genomicSEM(traits=c(pheno1_direct, pheno1_pop, pheno2_direct, pheno2_pop), 
                    ld=ldsc,
                    wld=ldsc,
                    trait.names=c(paste0(pheno1, "_direct"), paste0(pheno1, "_pop"), paste0(pheno2, "_direct"), paste0(pheno2, "_pop")),
                    filename=paste0(pheno1, "_", pheno2),
                    outpath=outpath)

    if (analyze_results) {
        analyze_genomicSEM_results(LDSCoutput=paste0("LDSCoutput_", pheno1, "_", pheno2, ".RData"),
                            logfile=paste0(pheno1, "_", pheno2, "_ldsc.log"),
                            outfile=paste0(pheno1, "_", pheno2, "_results.txt"),
                            basepath=outpath)
    }

}
