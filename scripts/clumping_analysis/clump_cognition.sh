#!/usr/bin/bash
within_family_path="/var/genetics/proj/within_family/within_family_project"
clumping_analysis_path="/var/genetics/proj/within_family/within_family_project/scripts/clumping_analysis"

pheno="cognition"
dataset="ukb"
effect="direct_population"
sumstats="/var/genetics/proj/within_family/within_family_project/processed/package_output/cognition/meta_noukb.hm3.sumstats.gz"
reference_sumstats="/disk/genetics3/data_dirs/published/sniekers_2017_intelligence/raw/sumstats/sumstats.txt.gz"
clump_dir="/var/genetics/proj/within_family/within_family_project/processed/clumping_analysis/${pheno}/clumps"
clump_outfile="${clump_dir}/cognition_ref"

mkdir -p ${clump_dir}

bash "${clumping_analysis_path}/get_clumps.sh" \
${reference_sumstats} \
"rsid" "p_value" ${clump_outfile}

Rscript ${clumping_analysis_path}/process_clumps.r \
    --sumstats ${sumstats} \
    --clump_prefix ${clump_outfile} \
    --effect ${effect} \
    --dataset ${dataset} \
    --pheno ${pheno}

## MAKE SURE OTHER CODE IS COMMENTED OUT IN THESE SCRIPTS BEFORE RUNNING
bash /var/genetics/proj/within_family/within_family_project/scripts/sbayesr/cognition_pgi.sh
bash /var/genetics/proj/within_family/within_family_project/scripts/fpgs/fpgs_cognition.sh