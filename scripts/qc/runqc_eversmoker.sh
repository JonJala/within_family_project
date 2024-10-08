#!/usr/bin/bash
### Run the easyqc pipeline
# Ever smoker


reffile="/var/genetics/proj/within_family/within_family_project/processed/reference_samples/eversmoker_ref/eversmoker_ref.sumstats.gz"

################
## Minnesota twins
################


python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/minn_twins/public/latest/raw/sumstats/fgwas/sumstats/ES_chr*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/minn_twins/es" \
    --ldsc-ref "$reffile" \
    --cptid \
    --effects "direct_averageparental" \
    --toest "direct_population" \
    --hwe '/var/genetics/data/minn_twins/public/v1/raw/sumstats/fgwas/sumstats/snpstats/hardy.hwe' \
    --binary

##############
# Estonian Biobank
##############

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/newresults/SMOKING_ext/SMOKE_chr*_results.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/smoking" \
    --ldsc-ref "$reffile" \
    --toest "direct_paternal_maternal_averageparental_population" \
    --hwe "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/HWE/chr*.hwe" \
    --info "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/ImputationQuality_formatted.TXT" \
    --binary


#############
# Geisinger
#############

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/OUTPUT/fGWAS.OUT.GHS145k.hg38.GSA.OMNI.EUR.sampleQC.PCA.WF_GWAS.SMOKE_EVER.chr*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/geisinger/es" \
    --ldsc-ref "$reffile" \
    --toest "direct_paternal_maternal_averageparental_population" \
    --info '/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/OUTPUT.SNP_INFO/info.formatted.txt' \
    --hwe '/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/OUTPUT.SNP_INFO/hwe.formatted.txt' \
    --binary

##############
# Lifelines
##############

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/disk/genetics/data/lifelines/public/latest/raw/sumstats/fgwas/fgwas_ll_smk18.sumstats.gz" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/lifelines/es18" \
    --ldsc-ref "$reffile" \
    --effects "direct_averageparental" \
    --toest "direct_population" \
    --info "/var/genetics/data/lifelines/public/v1/raw/sumstats/fgwas/fgwas_ll_info_hwe.formatted.txt" \
    --hwe "/var/genetics/data/lifelines/public/v1/raw/sumstats/fgwas/fgwas_ll_info_hwe.formatted.txt" \
    --binary


python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/disk/genetics/data/lifelines/public/latest/raw/sumstats/fgwas/fgwas_ll_smk.sumstats.gz" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/lifelines/es" \
    --ldsc-ref "$reffile" \
    --effects "direct_averageparental" \
    --toest "direct_population" \
    --info "/var/genetics/data/lifelines/public/v1/raw/sumstats/fgwas/fgwas_ll_info_hwe.formatted.txt" \
    --hwe "/var/genetics/data/lifelines/public/v1/raw/sumstats/fgwas/fgwas_ll_info_hwe.formatted.txt" \
    --binary

#########
# Hunt
######

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/smoEv/smoEv_chr*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/hunt/es" \
    --ldsc-ref "$reffile" \
    --toest "direct_paternal_maternal_averageparental_population" \
    --rsid_readfrombim "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/bimfiles/Eduhunt_results_chr*.bim,0,2,1, " \
    --info '/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/snpstats/info.formatted.gz' \
    --hwe '/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/snpstats/hwe.formatted.gz' \
    --binary

#####
# Finnish twins
#####

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/eversmk.chr*.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ft/es" \
    --ldsc-ref "$reffile" \
    --effects "direct_averageparental" \
    --toest "direct_population" \
    --hwe /var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/snpstats/hardy.hwe \
    --info /var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/snpstats/info.txt \
    --binary

#############
# Dutch Twins
#############

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/EverSmoke/NTR_EverSmoke_CHR*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/dutch_twin/es" \
    --ldsc-ref "$reffile" \
    --toest "direct_paternal_maternal_averageparental_population" \
    --cptid \
    --info "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Info/info.txt.gz" \
    --hwe "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Info/hwe.txt.gz" \
    --binary


####################
## ====== UKB ====== #
####################

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/ukb/private/v3/processed/proj/within_family/sumstats/ever.smoked/ever.smoked.sumstats.gz" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ukb/es" \
    --effects "direct_averageparental" \
    --toest "direct_population" \
    --bim_chromosome 99 \
    --ldsc-ref "$reffile" \
    --hwe '/disk/genetics/ukb/alextisyoung/hapmap3/hwe/hwe.formatted' \
    --info '/disk/genetics2/ukb/orig/UKBv3/imputed_data/info.formatted' \
    --binary

#############
# QIMR
############

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/qimr/private/v1/raw/pgs/QIMR_FamilyGWAS/EverSmoker/EverSmoker_Chr*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/qimr/eversmoker" \
    --ldsc-ref "$reffile" \
    --toest "direct_paternal_maternal_averageparental_population" \
    --cptid \
    --binary

####################
## ====== CKB ====== #
####################

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/ckb/private/v1/processed/sumstats/Dec_2022/ever_smoker_all_chr.sumstats.txt" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ckb/eversmoker" \
    --effects "direct_averageparental" \
    --toest "direct_population" \
    --af-ref "/var/genetics/proj/within_family/within_family_project/processed/qc/otherqc/eas_afs/eas_1kg.frq" \
    --cptid \
    --binary

############
## Finn Gen
############

## 6/19/2023 : This data will hopefully be moved from private to public, and it's likely OK to use it this way, but this is an issue that does need to be resolved in a more permanent way. This code / paradigm shouldn't be copy-pasted or used elsewhere as-is

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/finngen/private/v1/processed/sumstats/ever_smoker.sumstats.txt" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/finngen/eversmoker" \
    --ldsc-ref "$reffile" \
    --info "/disk/genetics/data/finngen/private/v1/processed/sumstats/qc.txt" \
    --effects "direct_averageparental" \
    --toest "direct_population" \
    --binary
