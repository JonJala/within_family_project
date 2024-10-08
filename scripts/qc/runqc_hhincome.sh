#!/usr/bin/bash
### Run the easyqc pipeline

reffile="/var/genetics/proj/within_family/within_family_project/processed/reference_samples/hhincome_ref/hhincome_ref.sumstats.gz"

##########
# STR
##########

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/hhInc/hhInc_chr*.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/str/hhincome" \
    --ldsc-ref "$reffile" \
    --effects "direct_averageparental" \
    --toest "direct_population" \
    --bim_bp 3 --bim_a1 4 --bim_a2 5 \
    --info "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/SNPstats/info.txt.gz" \
    --hwe "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/SNPstats/hardy.txt.gz" \
    --rsid_readfrombim "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/SNPs/chr_*.bim,0,3,1, "

# #####################
# # ====== UKB ====== #
# #####################

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/ukb/private/v3/processed/proj/within_family/sumstats/household.income/household.income.sumstats.gz" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ukb/hhincome" \
#     --effects "direct_averageparental" \
#     --toest "direct_population" \
#     --bim_chromosome 99 \
#     --ldsc-ref "$reffile" \
#     --hwe '/disk/genetics/ukb/alextisyoung/hapmap3/hwe/hwe.formatted' \
#     --info '/disk/genetics2/ukb/orig/UKBv3/imputed_data/info.formatted'

###############
## iPSYCH
###########

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/ipsych/public/latest/processed/sumstats/sumstats_inc_export_plinkfiltered.txt" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ipsych/hhincome" \
    --effects "direct_averageparental" \
    --toest "direct_population" \
    --cptid \
    --ldsc-ref "$reffile"
