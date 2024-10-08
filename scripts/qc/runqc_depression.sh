#!/usr/bin/bash
### Run the easyqc pipeline

within_family_path="/var/genetics/proj/within_family/within_family_project"

reffile="/var/genetics/proj/within_family/within_family_project/processed/reference_samples/depression_ref/depression_ref.sumstats.gz"

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

####
## Finnish twins
####

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/depression.chr*.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ft/depression" \
    --ldsc-ref "$reffile" \
    --effects "direct_averageparental" \
    --toest "direct_population" \
    --hwe /var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/snpstats/hardy.hwe \
    --info /var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/snpstats/info.txt \
    --binary

####################
# ====== UKB ====== #
####################

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/ukb/private/v3/processed/proj/within_family/sumstats/mdd/mdd.sumstats.gz" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ukb/depression" \
    --effects "direct_averageparental" \
    --toest "direct_population" \
    --bim_chromosome 99 \
    --ldsc-ref "$reffile" \
    --hwe '/disk/genetics/ukb/alextisyoung/hapmap3/hwe/hwe.formatted' \
    --info '/disk/genetics2/ukb/orig/UKBv3/imputed_data/info.formatted' \
    --binary

###############
## iPSYCH
###########

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/disk/genetics/data/ipsych/public/v2/processed/sumstats/sumstats_depression_export_plinkfiltered.txt" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ipsych/depression" \
    --effects "direct_averageparental" \
    --toest "direct_population" \
    --cptid \
    --ldsc-ref "$reffile" \
    --binary

############
# Finn Gen
############

## 6/19/2023 : This data will hopefully be moved from private to public, and it's likely OK to use it this way, but this is an issue that does need to be resolved in a more permanent way. This code / paradigm shouldn't be copy-pasted or used elsewhere as-is

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/finngen/private/v1/processed/sumstats/depression.sumstats.txt" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/finngen/depression" \
    --ldsc-ref "$reffile" \
    --info "/disk/genetics/data/finngen/private/v1/processed/sumstats/qc.txt" \
    --effects "direct_averageparental" \
    --toest "direct_population" \
    --binary
