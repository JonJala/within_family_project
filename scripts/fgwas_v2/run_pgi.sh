#!/usr/bin/bash

source /var/genetics/proj/within_family/within_family_project/scripts/fgwas_v2/prscsfunc_fgwas.sh

# ============= Execution ============= #

# ## unified

# direct
# run_pgi "/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/v2/paper_results/unified/height/merged.sumstats.gz" "direct" "height" "unified"
# run_pgi "/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/v2/paper_results/unified/EA/merged.sumstats.gz" "direct" "ea" "unified"
# run_pgi "/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/v2/paper_results/unified/BMI/merged.sumstats.gz" "direct" "bmi" "unified"

# population
run_pgi "/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/v2/paper_results/unified/height/merged.sumstats.gz" "population" "height" "unified"
run_pgi "/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/v2/paper_results/unified/EA/merged.sumstats.gz" "population" "ea" "unified"
run_pgi "/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/v2/paper_results/unified/BMI/merged.sumstats.gz" "population" "bmi" "unified"

# ## robust
# run_pgi "/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/robust/with_grm/height/merged.sumstats.gz" "direct" "height" "robust"
# run_pgi "/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/robust/with_grm/BMI/merged.sumstats.gz" "direct" "bmi" "robust"
# run_pgi "/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/robust/with_grm/EA/merged.sumstats.gz" "direct" "ea" "robust"

# ## sibdiff
# run_pgi "/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/sibdiff/with_grm/height/merged.sumstats.gz" "direct" "height" "sibdiff"
# run_pgi "/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/sibdiff/with_grm/EA/merged.sumstats.gz" "direct" "ea" "sibdiff"
# run_pgi "/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/sibdiff/with_grm/BMI/merged.sumstats.gz" "direct" "bmi" "sibdiff"

## young
# run_pgi "/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/v2/paper_results/young/height/merged.sumstats.gz" "direct" "height" "young"
# run_pgi "/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/v2/paper_results/young/EA/merged.sumstats.gz" "direct" "ea" "young"
# run_pgi "/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/v2/paper_results/young/BMI/merged.sumstats.gz" "direct" "bmi" "young"
