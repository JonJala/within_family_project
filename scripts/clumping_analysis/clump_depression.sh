#!/usr/bin/bash
within_family_path="/var/genetics/proj/within_family/within_family_project"
clumping_analysis_path="/var/genetics/proj/within_family/within_family_project/scripts/clumping_analysis"

pheno="depression"
dataset="mcs"
effect="direct_population"
sumstats="/var/genetics/proj/within_family/within_family_project/processed/package_output/${pheno}/meta.hm3.sumstats.gz"
reference_sumstats="/var/genetics/data/published/howard_2019_mdd/raw/sumstats/PGC_UKB_depression_genome-wide.txt"
clump_dir="/var/genetics/proj/within_family/within_family_project/processed/clumping_analysis/${pheno}/clumps"
clump_outfile="${clump_dir}/PGC_UKB_depression_genome-wide"

mkdir -p ${clump_dir}

## make sure to change the names of the rsID and p-value cols if necessary
# bash "${clumping_analysis_path}/get_clumps.sh" \
# ${reference_sumstats} \
# "MarkerName" "P" ${clump_outfile}

# Rscript ${clumping_analysis_path}/process_clumps.r \
#     --sumstats ${sumstats} \
#     --clump_prefix ${clump_outfile} \
#     --effect ${effect} \
#     --dataset ${dataset} \
#     --pheno ${pheno}

## MAKE SURE OTHER CODE IS COMMENTED OUT IN THESE SCRIPTS BEFORE RUNNING
# bash "/var/genetics/proj/within_family/within_family_project/scripts/sbayesr/${pheno}_pgi.sh"
source /var/genetics/proj/within_family/within_family_project/snipar/bin/activate
bash "/var/genetics/proj/within_family/within_family_project/scripts/fpgs/fpgs_${pheno}.sh"

