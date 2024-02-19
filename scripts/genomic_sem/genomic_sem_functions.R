#!/usr/bin/env Rscript

## ---------------------------------------------------------------------
## description: run genomic SEM
## ---------------------------------------------------------------------

list.of.packages <- c("GenomicSEM", "data.table", "dplyr", "stringr")
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
    LDSCoutput <- ldsc(traits=traits,sample.prev=sample.prev,population.prev=population.prev,ld=ld,wld=wld,trait.names=trait.names,ldsc.log=filename, stand = TRUE)

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

## analyze results from cross-trait analysis and get SE and p-values for difference between correlations
analyze_genomicSEM_results <- function(LDSCoutput, pheno1, pheno2, logfile, outfile, basepath = NA) {

    if (!is.na(basepath)) {
        LDSCoutput <- paste0(basepath, LDSCoutput)
        logfile <- paste0(basepath, logfile)
        outfile <- paste0(basepath, outfile)
    }

    ## load and extract data
    load(LDSCoutput)

    print(paste0("Running for ", pheno1, " x ", pheno2))

    ## run user specified model

    # define model
    model <- '
    pheno1_direct_std =~ NA*pheno1_direct
    pheno1_pop_std =~ NA*pheno1_pop
    pheno2_direct_std =~ NA*pheno2_direct
    pheno2_pop_std =~ NA*pheno2_pop

    pheno1_direct_std ~~ 1*pheno1_direct_std
    pheno1_pop_std ~~ 1*pheno1_pop_std
    pheno2_direct_std ~~ 1*pheno2_direct_std
    pheno2_pop_std ~~ 1*pheno2_pop_std

    pheno1_direct ~~ 0*pheno1_direct
    pheno1_pop ~~ 0*pheno1_pop
    pheno2_direct ~~ 0*pheno2_direct
    pheno2_pop ~~ 0*pheno2_pop

    pheno1_direct_std ~~ rg1*pheno2_direct_std
    pheno1_pop_std ~~ rg2*pheno2_pop_std

    diff := rg1 - rg2
    '

    # replace placeholders with phenos
    model <- str_replace_all(model, "pheno1", pheno1)
    model <- str_replace_all(model, "pheno2", pheno2)

    # run model
    output <- usermodel(LDSCoutput, estimation = "DWLS", model = model, CFIcalc = TRUE, std.lv = TRUE, imp_cov = FALSE)

    # save output
    save(output, file = paste0("/var/genetics/proj/within_family/within_family_project/processed/genomic_sem/cross_trait/", pheno1, "_", pheno2, "/", pheno1, "_", pheno2, "_modeloutput.RData"))

    # get results
    results <- output$results
    direct_results <- results[results$lhs == paste0(pheno1, "_direct_std") & results$rhs == paste0(pheno2, "_direct_std"),]
    direct_rg <- as.numeric(direct_results$Unstand_Est)
    direct_rg_se <- as.numeric(direct_results$Unstand_SE)
    pop_results <- results[results$lhs == paste0(pheno1, "_pop_std") & results$rhs == paste0(pheno2, "_pop_std"),]
    pop_rg <- as.numeric(pop_results$Unstand_Est)
    pop_rg_se <- as.numeric(pop_results$Unstand_SE)
    
    # flip sign on genetic correlations if necessary
    pheno1_direct_unstand <- results$Unstand_Est[results$lhs == paste0(pheno1, "_direct_std") & results$rhs == paste0(pheno1, "_direct") & results$op == "=~"]
    pheno2_direct_unstand <- results$Unstand_Est[results$lhs == paste0(pheno2, "_direct_std") & results$rhs == paste0(pheno2, "_direct") & results$op == "=~"]
    pheno1_pop_unstand <- results$Unstand_Est[results$lhs == paste0(pheno1, "_pop_std") & results$rhs == paste0(pheno1, "_pop") & results$op == "=~"]
    pheno2_pop_unstand <- results$Unstand_Est[results$lhs == paste0(pheno2, "_pop_std") & results$rhs == paste0(pheno2, "_pop") & results$op == "=~"]
    direct_rg_new <- direct_rg * sign(pheno1_direct_unstand) * sign(pheno2_direct_unstand)
    pop_rg_new <- pop_rg * sign(pheno1_pop_unstand) * sign(pheno2_pop_unstand)

    ## if the rgs have changed after sign flipping, need to rerun model
    if ((direct_rg_new != direct_rg) | (pop_rg_new != pop_rg)) {
        
        # add contraints
        model <- '
        pheno1_direct_std =~ NA*pheno1_direct + start(0.4)*pheno1_direct + h_1*pheno1_direct
        pheno1_pop_std =~ NA*pheno1_pop + start(0.4)*pheno1_pop + h_2*pheno1_pop
        pheno2_direct_std =~ NA*pheno2_direct + start(0.4)*pheno2_direct + h_3*pheno2_direct
        pheno2_pop_std =~ NA*pheno2_pop + start(0.4)*pheno2_pop + h_4*pheno2_pop

        pheno1_direct_std ~~ 1*pheno1_direct_std
        pheno1_pop_std ~~ 1*pheno1_pop_std
        pheno2_direct_std ~~ 1*pheno2_direct_std
        pheno2_pop_std ~~ 1*pheno2_pop_std

        pheno1_direct ~~ 0*pheno1_direct
        pheno1_pop ~~ 0*pheno1_pop
        pheno2_direct ~~ 0*pheno2_direct
        pheno2_pop ~~ 0*pheno2_pop

        pheno1_direct_std ~~ rg1*pheno2_direct_std
        pheno1_pop_std ~~ rg2*pheno2_pop_std

        diff := rg1 - rg2

        h_1 > 0.0001
        h_2 > 0.0001
        h_3 > 0.0001
        h_4 > 0.0001
        '

        # replace placeholders with phenos
        model <- str_replace_all(model, "pheno1", pheno1)
        model <- str_replace_all(model, "pheno2", pheno2)

        print("Rerunning model with updated start values")

        # rerun model
        output <- usermodel(LDSCoutput, estimation = "DWLS", model = model, CFIcalc = TRUE, std.lv = TRUE, imp_cov = FALSE)

        # save output
        save(output, file = paste0("/var/genetics/proj/within_family/within_family_project/processed/genomic_sem/cross_trait/", pheno1, "_", pheno2, "/", pheno1, "_", pheno2, "_modeloutput.RData"))

        # get results
        results <- output$results
        direct_results <- results[results$lhs == paste0(pheno1, "_direct_std") & results$rhs == paste0(pheno2, "_direct_std"),]
        direct_rg <- as.numeric(direct_results$Unstand_Est)
        direct_rg_se <- as.numeric(direct_results$Unstand_SE)
        pop_results <- results[results$lhs == paste0(pheno1, "_pop_std") & results$rhs == paste0(pheno2, "_pop_std"),]
        pop_rg <- as.numeric(pop_results$Unstand_Est)
        pop_rg_se <- as.numeric(pop_results$Unstand_SE)
        
        if (sum(results$Unstand_Est[1:4] < 0) > 0) {
            count <- sum(results$Unstand_Est[1:4] < 0)
            print(paste0("WARNING: ", count, " of the sumstats have had their signs flipped."))
        }

    }

    # calculate difference and p-value
    diff_results <- results[results$lhs == "diff",]
    diff_est <- as.numeric(diff_results$Unstand_Est)
    diff_se <- as.numeric(diff_results$Unstand_SE)
    z <- diff_est/diff_se
    p <- 2*pnorm(abs(z), lower.tail = FALSE)

    results <- data.table(variable=c("direct_rg", "direct_rg_se", "pop_rg", "pop_rg_se", "diff_est", "diff_se", "z", "p"), value=c(direct_rg, direct_rg_se, pop_rg, pop_rg_se, diff_est, diff_se, z, p))
    fwrite(results, outfile, sep="\t", quote=F, row.names=F, col.names=T)

}

get_h2_results <- function(phenotype, ref = TRUE) {

    load(paste0("/var/genetics/proj/within_family/within_family_project/processed/genomic_sem/", phenotype, "/LDSCoutput_", phenotype, ".RData"))
    log <- readLines(paste0("/var/genetics/proj/within_family/within_family_project/processed/genomic_sem/", phenotype, "/", phenotype, "_ldsc.log"))

    # direct h2
    h2_lines <- grep("Total Observed Scale h2", log, value = T)
    direct_h2_line <- h2_lines[1]
    direct_h2 <- as.numeric(strsplit(strsplit(direct_h2_line, ": ")[[1]][2], " \\(")[[1]][1])
    direct_h2_se <- as.numeric(strsplit(strsplit(direct_h2_line, "\\(")[[1]][2], "\\)")[[1]][1])
    
    # pop h2
    pop_h2_line <- h2_lines[2]
    pop_h2 <- as.numeric(strsplit(strsplit(pop_h2_line, ": ")[[1]][2], " \\(")[[1]][1])
    pop_h2_se <- as.numeric(strsplit(strsplit(pop_h2_line, "\\(")[[1]][2], "\\)")[[1]][1])

    # cov between direct and pop h2
    if (ref == TRUE) { # if genomicSEM has been run with the reference sumstats included
        cov <- LDSCoutput$V[4,1]
    } else { # if no reference ss
        cov <- LDSCoutput$V[3,1]
    }
    
    
    # get h2 diff se
    h2_diff <- direct_h2 - pop_h2
    h2_diff_var <- direct_h2_se^2 + pop_h2_se^2 - 2*cov
    h2_diff_se <- sqrt(h2_diff_var)

    z <- h2_diff/h2_diff_se
    p <- 2*pnorm(abs(z), lower.tail = FALSE)

    results <- data.table(variable=c("direct_h2", "direct_h2_se", "pop_h2", "pop_h2_se", "h2_diff", "h2_diff_se", "z", "p"), value=c(direct_h2, direct_h2_se, pop_h2, pop_h2_se, h2_diff, h2_diff_se, z, p))
    fwrite(results, paste0("/var/genetics/proj/within_family/within_family_project/processed/genomic_sem/", phenotype, "/h2_results_", phenotype, ".txt"), sep="\t", quote=F, row.names=F, col.names=T)

}

## single trait analysis, including corr with ref ss, for ST3
run_single_trait <- function(pheno, direct_ss, pop_ss, ldsc, h2_results = TRUE, ref_ss = NA, sample.prev=c(NA,NA,NA,NA), population.prev=c(NA,NA,NA,NA)) {
    
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
        if (h2_results) {
            get_h2_results(pheno)
        }
    } else {
        run_ldsc_genomicSEM(traits=c(direct_ss, pop_ss),
                        ld=ldsc,
                        wld=ldsc,
                        trait.names=c(paste0(pheno, "_direct"), paste0(pheno, "_pop")),
                        sample.prev=sample.prev,
                        population.prev=population.prev,
                        filename=pheno,
                        outpath=outpath)
        if (h2_results) {
            get_h2_results(pheno, ref = FALSE)
        }
    }

}

## run cross-trait analysis. note: traits should be input in order trait1_direct, trait1_pop, trait2_direct, trait2_pop
run_cross_trait <- function(pheno1, pheno2, pheno1_direct, pheno1_pop, pheno2_direct, pheno2_pop, ldsc, sample.prev=c(NA,NA,NA,NA), population.prev=c(NA,NA,NA,NA), analyze_results = TRUE) {

    outpath <- paste0("/var/genetics/proj/within_family/within_family_project/processed/genomic_sem/cross_trait/", pheno1, "_", pheno2, "/")
    if(!dir.exists(outpath)) {
        dir.create(outpath, recursive = TRUE)
    }

    # run_ldsc_genomicSEM(traits=c(pheno1_direct, pheno1_pop, pheno2_direct, pheno2_pop), 
    #                 ld=ldsc,
    #                 wld=ldsc,
    #                 trait.names=c(paste0(pheno1, "_direct"), paste0(pheno1, "_pop"), paste0(pheno2, "_direct"), paste0(pheno2, "_pop")),
    #                 filename=paste0(pheno1, "_", pheno2),
    #                 outpath=outpath)

    if (analyze_results) {
        analyze_genomicSEM_results(LDSCoutput=paste0("LDSCoutput_", pheno1, "_", pheno2, ".RData"),
                            pheno1 = pheno1,
                            pheno2 = pheno2,
                            logfile=paste0(pheno1, "_", pheno2, "_ldsc.log"),
                            outfile=paste0(pheno1, "_", pheno2, "_results.txt"),
                            basepath=outpath)
    }

}
