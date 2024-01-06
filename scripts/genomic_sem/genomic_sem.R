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

gen_cov <- LDSCoutput$S # genetic covariances. note, not correlations
sampling_vcov <- LDSCoutput$V # sampling vcov of covariances
dimnames(sampling_vcov) <- list(c(), c("bmi_direct_bmi_direct", "bmi_direct_bmi_pop", "bmi_direct_ea_direct", "bmi_direct_ea_pop", "bmi_pop_bmi_pop", "bmi_pop_ea_direct", "bmi_pop_ea_pop", "ea_direct_ea_direct", "ea_direct_ea_pop", "ea_pop_ea_pop"))

## transform covariance matrix into correlation matrix and get difference between correlations

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
diff <- gen_corr[3,1] - gen_corr[4,2]

## get variances of correlations from log file (manually inputting for now)
var_bmi_ea_direct <- 0.0477^2
var_bmi_ea_direct <- 0.0223^2

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
var_diff <- var_bmi_ea_direct + var_bmi_ea_direct + 2*cov
se_diff <- sqrt(var_diff)

z <- diff/se_diff
p <- 2*pnorm(abs(z), lower.tail = FALSE)
