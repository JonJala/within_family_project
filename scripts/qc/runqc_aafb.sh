#!/usr/bin/bash
### Run the easyqc pipeline

reffile="/var/genetics/proj/within_family/within_family_project/processed/reference_samples/aafb_ref/aafb_ref.sumstats.gz"

##############
# Estonian Biobank
##############

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/newresults/AGE-First-BIRTH-ext/AGE_chr*_results.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/aafb" \
    --ldsc-ref "$reffile" \
    --toest "direct_paternal_maternal_averageparental_population" \
    --hwe "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/HWE/chr*.hwe" \
    --info "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/ImputationQuality_formatted.TXT"


##############
# Hunt
##############

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/AgeFirstBirth/AgeFirstBirth_chr*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/hunt/aafb" \
#     --ldsc-ref "$reffile" \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --rsid_readfrombim "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/bimfiles/Eduhunt_results_chr*.bim,0,2,1, "

# #####
# # Finnish twins
# #####

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/afb.chr*.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ft/aafb" \
#     --ldsc-ref $reffile \
#     --toest "direct_population" \
#     --hwe /var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/snpstats/hardy.hwe \
#     --info /var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/snpstats/info.txt


#####################
# ====== UKB ====== #
#####################

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/ukb/public/latest/raw/sumstats/fgwas/16/chr_*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ukb/aafb" \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --bim_chromosome 99 \
#     --ldsc-ref "$reffile"
