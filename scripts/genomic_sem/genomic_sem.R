#!/usr/bin/env Rscript

## ---------------------------------------------------------------------
## description: genomic SEM for EA and BMI
## ---------------------------------------------------------------------

list.of.packages <- c("GenomicSEM")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos = "http://cran.rstudio.com/")
lapply(list.of.packages, library, character.only = TRUE)

## ---------------------------------------------------------------------
## run multivariable LDSC
## ---------------------------------------------------------------------

basepath <- "/var/genetics/proj/within_family/within_family_project/processed/package_output"

#vector of munged summary statisitcs
traits<-c(paste0(basepath, "/bmi/directmunged.sumstats.gz"), paste0(basepath, "/bmi/populationmunged.sumstats.gz"), paste0(basepath, "/ea/directmunged.sumstats.gz"), paste0(basepath, "/ea/populationmunged.sumstats.gz"))

#enter sample prevalence of .5 to reflect that all traits were munged using the sum of effective sample size
sample.prev<-c(NA,NA,NA,NA)

#vector of population prevalences
population.prev<-c(NA,NA,NA,NA)

#the folder of LD scores
ld<-"/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"

#the folder of LD weights [typically the same as folder of LD scores]
wld<-"/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"

#name the traits
trait.names<-c("bmi_direct","bmi_population","ea_direct","ea_population")

#run LDSC
LDSCoutput<-ldsc(traits=traits,sample.prev=sample.prev,population.prev=population.prev,ld=ld,wld=wld,trait.names=trait.names)

#optional command to save the output as a .RData file for later use
save(LDSCoutput,file="/var/genetics/proj/within_family/within_family_project/scratch/LDSCoutput.RData")

## ---------------------------------------------------------------------
## analyse results
## ---------------------------------------------------------------------

load("/var/genetics/proj/within_family/within_family_project/scratch/LDSCoutput.RData")

gen_cov <- LDSCoutput$S # genetic covariances. note, not correlations. diagonal is heritabilities
sampling_vcov <- LDSCoutput$V # sampling variances and covariances

## transform covariance matrix into correlation matrix
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

gen_corr <- covariance_to_correlation(gen_cov)

bmi_ea_rg_direct <- gen_cov[1,3]/(sqrt(gen_cov[1,1])*sqrt(gen_cov[3,3]))
bmi_ea_rg_pop <- gen_cov[2,4]/(sqrt(gen_cov[2,2])*sqrt(gen_cov[4,4]))
bmi_ea_dir_pop_rg_diff <- bmi_ea_rg_direct - bmi_ea_rg_pop

## convert sampling vcov of variances to vcov of correlations




## get standard error of difference
bmi_direct_ea_direct_var <- sampling_vcov[3,3]
bmi_pop_ea_pop_var <- sampling_vcov[7,7]
bmi_ea_direct_pop_cov <- sampling_vcov[3,7]

var_diff <- bmi_direct_ea_direct_var + bmi_pop_ea_pop_var + 2*bmi_ea_direct_pop_cov
se_diff <- sqrt(var_diff)

## get p-value
z <- bmi_ea_dir_pop_rg_diff/se_diff
p <- 2*pnorm(abs(z), lower.tail = FALSE)
2*pt(z, df = 1000, lower.tail = FALSE)
