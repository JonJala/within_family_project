#!/usr/bin/bash
### Run the easyqc pipeline

within_family_path="/var/genetics/proj/within_family/within_family_project"
# 
# ${within_family_path}/processed/mdd_ref/PGC_UKB_depression_genome-wide.sumstats.gz alternate ref
reffile="/var/genetics/proj/within_family/within_family_project/processed/reference_samples/dep_ref/DS_Full.sumstats.gz"

##########
# EB - Estonian Biobank
##########

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/newresults/Depression_ext/Depression_chr*_results.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/depression" \
    --ldsc-ref "$reffile" \
    --toest "direct_paternal_maternal_averageparental_population" \
    --hwe "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/HWE/chr*.hwe" \
    --info "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/ImputationQuality_formatted.TXT" \
    --binary

# median with binary is 5114
# median without binary is 29379
# 1.1245 (0.1913)

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/newresults/MDD_ext/MDD_chr*_results.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/mdd" \
    --ldsc-ref "$reffile" \
    --toest "direct_paternal_maternal_averageparental_population" \
    --hwe "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/HWE/chr*.hwe" \
    --info "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/ImputationQuality_formatted.TXT" \
    --binary

#########
# Geisinger
#########

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/OUTPUT/fGWAS.OUT.GHS145k.hg38.GSA.OMNI.EUR.sampleQC.PCA.WF_GWAS.DEPRESSION.chr*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/geisinger/depression" \
    --ldsc-ref "$reffile" \
    --toest "direct_paternal_maternal_averageparental_population" \
    --binary
# # 0.7575 (0.1053)

#############
# Dutch Twins
#############

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/DepressionASR/NTR_DepressionASR_CHR*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/dutch_twin/depression" \
    --ldsc-ref "$reffile" \
    --toest "direct_paternal_maternal_averageparental_population" \
    --cptid \
    --info "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Info/info.txt.gz" \
    --hwe "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Info/hwe.txt.gz" \
    --binary

#####
# Finnish twins
#####

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/depression.chr*.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ft/depression" \
    --ldsc-ref "$reffile" \
    --toest "direct_population" \
    --hwe /var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/snpstats/hardy.hwe \
    --info /var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/snpstats/info.txt \
    --binary

# ####################
# ====== UKB ====== #
# ####################

# awaiting updated ss

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/ukb/public/latest/raw/sumstats/fgwas/20/chr_*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ukb/depression" \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --bim_chromosome 99 \
#     --ldsc-ref "$reffile" \
#     --binary


################
# iPSYCH
############

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/disk/genetics3/data_dirs/ipsych/private/v1/processed/sumstats/sumstats_depression_export.txt" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ipsych/depression" \
    --toest "direct_population" \
    --ldsc-ref "$reffile"