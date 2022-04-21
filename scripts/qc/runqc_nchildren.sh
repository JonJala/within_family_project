#!/usr/bin/bash
### Run the easyqc pipeline

reffile="/var/genetics/proj/within_family/within_family_project/processed/reference_samples/neb_ref/nchildren_pooled.sumstats.gz"

#############
# Hunt
#############

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/ChildrenN/ChildrenN_chr*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/hunt/nchildren" \
#     --ldsc-ref "$reffile" \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --rsid_readfrombim "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/bimfiles/Eduhunt_results_chr*.bim,0,2,1, "

#############
# MOBA
###############

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/moba/public/latest/raw/sumstats/fgwas/sumstats/fert_chr*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/moba/nchildren" \
    --ldsc-ref "$reffile" \
    --toest "direct_paternal_maternal_averageparental_population" \
    --info "/var/genetics/data/moba/public/latest/raw/sumstats/fgwas/snpqcstats/sampleQC/info.formatted.txt.gz" \
    --hwe "/var/genetics/data/moba/public/latest/raw/sumstats/fgwas/snpqcstats/sampleQC/hwe.formatted.txt.gz"

# ##########
# # STR
# ##########

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/numberChildren/numberChildren_chr*.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/str/nchildren" \
#     --ldsc-ref "$reffile" \
#     --toest "direct_population" \
#     --bim_bp 3 --bim_a1 4 --bim_a2 5 \
#     --info "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/SNPstats/info.txt.gz" \
#     --hwe "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/SNPstats/hardy.txt.gz" \
#     --rsid_readfrombim "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/SNPs/chr_*.bim,0,3,1, "

# #####
# # Finnish twins
# #####

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/nchildren.chr*.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ft/nchildren" \
#     --ldsc-ref "$reffile" \
#     --toest "direct_population" \
#     --hwe /var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/snpstats/hardy.hwe \
#     --info /var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/snpstats/info.txt

#############
# Dutch Twins
#############

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Nkids/NTR_Nkids_CHR*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/dutch_twin/nchildren" \
#     --ldsc-ref "$reffile" \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --cptid \
#     --info "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Info/info.txt.gz" \
#     --hwe "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Info/hwe.txt.gz"

#####################
# ====== UKB ====== #
#####################

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/ukb/public/latest/raw/sumstats/fgwas/23/chr_*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ukb/nchildren" \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --bim_chromosome 99 \
#     --ldsc-ref "$reffile"
