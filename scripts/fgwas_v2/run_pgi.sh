#!/usr/bin/bash

source /var/genetics/proj/within_family/within_family_project/scripts/fgwas_v2/prscsfunc_fgwas.sh

# ============= Execution ============= #
# run_pgi "/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/v2/BMI/parsep/with_grm/merged.sumstats.gz" "direct" "bmi" "with_grm"
run_pgi "/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/v2/EA/parsep/with_grm/merged.sumstats.gz" "direct" "ea" "with_grm"
# run_pgi "/disk/genetics/ukb/jguan/ukb_analysis/output/gwas/v2/height/parsep/with_grm/merged.sumstats.gz" "direct" "height" "with_grm"