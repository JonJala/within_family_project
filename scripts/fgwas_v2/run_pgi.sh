#!/usr/bin/bash

source /var/genetics/proj/within_family/within_family_project/scripts/fgwas_v2/prscsfunc_fgwas.sh

# ============= Execution ============= #

# for ancestry in "eur" "sas"
for ancestry in "sas"
do

    ## unified

    # direct
    run_pgi "/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/v2/paper_results/unified/height/merged.sumstats.gz" "direct" "height" "unified" ${ancestry}
    run_pgi "/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/v2/paper_results/unified/EA/merged.sumstats.gz" "direct" "ea" "unified" ${ancestry}
    run_pgi "/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/v2/paper_results/unified/BMI/merged.sumstats.gz" "direct" "bmi" "unified" ${ancestry}

    # population
    run_pgi "/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/v2/paper_results/unified/height/merged.sumstats.gz" "population" "height" "unified" ${ancestry}
    run_pgi "/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/v2/paper_results/unified/EA/merged.sumstats.gz" "population" "ea" "unified" ${ancestry}
    run_pgi "/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/v2/paper_results/unified/BMI/merged.sumstats.gz" "population" "bmi" "unified" ${ancestry}

    ## robust
    run_pgi "/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/robust/with_grm/height/merged.sumstats.gz" "direct" "height" "robust" ${ancestry}
    run_pgi "/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/robust/with_grm/BMI/merged.sumstats.gz" "direct" "bmi" "robust" ${ancestry}
    run_pgi "/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/robust/with_grm/EA/merged.sumstats.gz" "direct" "ea" "robust" ${ancestry}

    ## sibdiff
    run_pgi "/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/sibdiff/with_grm/height/merged.sumstats.gz" "direct" "height" "sibdiff" ${ancestry}
    run_pgi "/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/sibdiff/with_grm/EA/merged.sumstats.gz" "direct" "ea" "sibdiff" ${ancestry}
    run_pgi "/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/sibdiff/with_grm/BMI/merged.sumstats.gz" "direct" "bmi" "sibdiff" ${ancestry}

    # young
    run_pgi "/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/v2/paper_results/young/height/merged.sumstats.gz" "direct" "height" "young" ${ancestry}
    run_pgi "/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/v2/paper_results/young/EA/merged.sumstats.gz" "direct" "ea" "young" ${ancestry}
    run_pgi "/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/v2/paper_results/young/BMI/merged.sumstats.gz" "direct" "bmi" "young" ${ancestry}

done