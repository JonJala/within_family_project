#!/usr/bin/bash

within_family_path="/var/genetics/proj/within_family/within_family_project"
clumping_analysis_path="/var/genetics/proj/within_family/within_family_project/scripts/clumping_analysis"

bash "${clumping_analysis_path}/get_clumps.sh" \
"/disk/genetics3/data_dirs/published/yengo_2018_height_and_bmi/raw/sumstats/Meta-analysis_Wood_et_al+UKBiobank_2018.txt" \
"SNP" "P" "/var/genetics/proj/within_family/within_family_project/processed/clumping_analysis/height/clumps/Meta-analysis_Wood_et_al+UKBiobank_2018"

Rscript ${clumping_analysis_path}/process_clumps.r \
    --sumstats "/var/genetics/proj/within_family/within_family_project/processed/package_output/height/meta.sumstats.gz" \
    --clump_prefix "/var/genetics/proj/within_family/within_family_project/processed/clumping_analysis/height/clumps/Meta-analysis_Wood_et_al+UKBiobank_2018" \
    --effect "direct" \
    --dataset "mcs" \
    --pheno "height"

Rscript ${clumping_analysis_path}/process_clumps.r \
    --sumstats "/var/genetics/proj/within_family/within_family_project/processed/package_output/height/meta.sumstats.gz" \
    --clump_prefix "/var/genetics/proj/within_family/within_family_project/processed/clumping_analysis/height/clumps/Meta-analysis_Wood_et_al+UKBiobank_2018" \
    --effect "population" \
    --dataset "mcs" \
    --pheno "height"

## note: this is just mcs for now. need to repeat for ukb but use metaanalysis WITHOUT UKB