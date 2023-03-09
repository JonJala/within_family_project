#!/usr/bin/bash
within_family_path="/var/genetics/proj/within_family/within_family_project"
clumping_analysis_path="/var/genetics/proj/within_family/within_family_project/scripts/clumping_analysis"

pheno="ea"
effect="direct_population"
reference_sumstats="/var/genetics/proj/ea4/derived_data/Meta_analysis/1_Main/2020_08_20/output/EA4_2020_08_20.meta"
clump_dir="/var/genetics/proj/within_family/within_family_project/processed/clumping_analysis/${pheno}/clumps"
clump_outfile="${clump_dir}/EA4_2020_08_20.meta"

mkdir -p ${clump_dir}

bash "${clumping_analysis_path}/get_clumps.sh" \
${reference_sumstats} \
"rsID" "P" ${clump_outfile}

### MCS
dataset="mcs"
sumstats="/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/meta.hm3.sumstats.gz"
Rscript ${clumping_analysis_path}/process_clumps.r \
    --sumstats ${sumstats} \
    --clump_prefix ${clump_outfile} \
    --effect ${effect} \
    --dataset ${dataset} \
    --pheno ${pheno}

### UKB
dataset="ukb"
sumstats="/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/meta_noukb.hm3.sumstats.gz"
Rscript ${clumping_analysis_path}/process_clumps.r \
    --sumstats ${sumstats} \
    --clump_prefix ${clump_outfile} \
    --effect ${effect} \
    --dataset ${dataset} \
    --pheno ${pheno}

## MAKE SURE OTHER CODE IS COMMENTED OUT IN THESE SCRIPTS BEFORE RUNNING
bash /var/genetics/proj/within_family/within_family_project/scripts/sbayesr/ea_pgi.sh
source /var/genetics/proj/within_family/snipar_venv/bin/activate
bash /var/genetics/proj/within_family/within_family_project/scripts/fpgs/fpgs_ea.sh



