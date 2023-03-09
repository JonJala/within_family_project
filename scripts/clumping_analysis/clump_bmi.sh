#!/usr/bin/bash
within_family_path="/var/genetics/proj/within_family/within_family_project"
clumping_analysis_path="/var/genetics/proj/within_family/within_family_project/scripts/clumping_analysis"

pheno="bmi"
dataset="mcs"
effect="direct_population"
sumstats="/var/genetics/proj/within_family/within_family_project/processed/package_output/${pheno}/meta.hm3.sumstats.gz"
reference_sumstats="/var/genetics/data/published/yengo_2018_height_and_bmi/raw/sumstats/Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED.txt.gz"
clump_dir="/var/genetics/proj/within_family/within_family_project/processed/clumping_analysis/${pheno}/clumps"
clump_outfile="${clump_dir}/Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED"

mkdir -p ${clump_dir}

bash "${clumping_analysis_path}/get_clumps.sh" \
${reference_sumstats} \
"SNP" "P" ${clump_outfile}

Rscript ${clumping_analysis_path}/process_clumps.r \
    --sumstats ${sumstats} \
    --clump_prefix ${clump_outfile} \
    --effect ${effect} \
    --dataset ${dataset} \
    --pheno ${pheno}

## MAKE SURE OTHER CODE IS COMMENTED OUT IN THESE SCRIPTS BEFORE RUNNING
bash "/var/genetics/proj/within_family/within_family_project/scripts/sbayesr/${pheno}_pgi.sh"
source /var/genetics/proj/within_family/snipar_venv/bin/activate
bash "/var/genetics/proj/within_family/within_family_project/scripts/fpgs/fpgs_${pheno}.sh"

