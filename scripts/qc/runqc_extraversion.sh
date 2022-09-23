#!/usr/bin/bash

reffile="/var/genetics/proj/within_family/within_family_project/processed/reference_samples/extraversion_ref/extraversion_ref.sumstats.gz"

# ##########
# # STR
# ##########

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/extraversion/extraversion_chr*.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/str/extraversion" \
#     --ldsc-ref "$reffile" \
#     --toest "direct_population" \
#     --bim_bp 3 --bim_a1 4 --bim_a2 5 \
#     --info "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/SNPstats/info.txt.gz" \
#     --hwe "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/SNPstats/hardy.txt.gz" \
#     --rsid_readfrombim "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/SNPs/chr_*.bim,0,3,1, "

#############
# Dutch Twins
#############

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Extraversion/NTR_Extraversion_CHR*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/dutch_twin/extraversion" \
    --ldsc-ref "$reffile" \
    --toest "direct_paternal_maternal_averageparental_population" \
    --cptid \
    --info "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Info/info.txt.gz" \
    --hwe "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Info/hwe.txt.gz"


