#!/usr/bin/bash
### Run the easyqc pipeline

#####################
# ====== UKB ====== #
#####################


python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/ukb/public/latest/raw/sumstats/fgwas/13/chr_*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ukb/bmi" \
    --toest "direct_paternal_maternal_averageparental_population" \
    --bim_chromosome 99 \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/bmi_ref/Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED.sumstats.gz" \
    --hwe '/disk/genetics/ukb/alextisyoung/hapmap3/hwe/hwe.formatted' \
    --info '/disk/genetics2/ukb/orig/UKBv3/imputed_data/info.formatted'

# 0.9506 (0.0218)
#####################
# ==== MT ========= #
#####################

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/minn_twins/public/latest/raw/sumstats/fgwas/sumstats/BMI_chr*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/minn_twins/bmi" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/bmi_ref/Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED.sumstats.gz" \
    --cptid \
    --toest "direct_population" \
    --hwe '/disk/genetics3/data_dirs/minn_twins/public/v1/raw/sumstats/fgwas/sumstats/snpstats/hardy.hwe'
# 1.1505 (0.9728)


# #######################
# # generation scotland
# #######################

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/6/chr_*.sumstatschr_clean.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/gs/bmi" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/bmi_ref/Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED.sumstats.gz" \
    --rsid_readfrombim "/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/SNPs/chr_*_rsids.txt,0,3,1, " \
    --toest "direct_paternal_maternal_averageparental_population" \
    --hwe "/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/hwe/chr_*.hwe" \
    --info "/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/info/combined_clean.info.gz"
# 0.9903 (0.0854)

# #############
# # LIfelines
# ##########

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/disk/genetics/data/lifelines/public/latest/raw/sumstats/fgwas/fgwas_ll_bmi.sumstats" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/lifelines/bmi" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/bmi_ref/Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED.sumstats.gz" \
    --effects "direct_averageparental" \
    --toest "direct_population"  \
    --info "/disk/genetics3/data_dirs/lifelines/public/v1/raw/sumstats/fgwas/fgwas_ll_info_hwe.formatted.txt" \
    --hwe "/disk/genetics3/data_dirs/lifelines/public/v1/raw/sumstats/fgwas/fgwas_ll_info_hwe.formatted.txt"
# 0.8591 (0.0775)

# ###########
# # MOBA
# ############

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/moba/public/latest/raw/sumstats/fgwas/sumstats/bmi_chr*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/moba/bmi" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/bmi_ref/Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED.sumstats.gz" \
    --toest "direct_paternal_maternal_averageparental_population" \
    --info "/var/genetics/data/moba/public/latest/raw/sumstats/fgwas/snpqcstats/sampleQC/info.formatted.txt.gz" \
    --hwe "/var/genetics/data/moba/public/latest/raw/sumstats/fgwas/snpqcstats/sampleQC/hwe.formatted.txt.gz"


    # 0.9627 (0.2823)

# #########
# # Estonian Biobank
# #########

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/newresults/BMI/BMI_chr*_results.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/bmi/" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/bmi_ref/Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED.sumstats.gz" \
    --toest "direct_paternal_maternal_averageparental_population" \
    --hwe "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/HWE/chr*.hwe" \
    --info "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/ImputationQuality_formatted.TXT"

# ##########
# # STR
# ##########

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/bmi/bmi_chr*.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/str/bmi" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/bmi_ref/Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED.sumstats.gz" \
    --toest "direct_population" \
    --bim_bp 3 --bim_a1 4 --bim_a2 5 \
    --info "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/SNPstats/info.txt.gz" \
    --hwe "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/SNPstats/hardy.txt.gz" \
    --rsid_readfrombim "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/SNPs/chr_*.bim,0,3,1, "

# NA

# #####
# # Finnish twins
# #####

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/BMI.chr*.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ft/bmi" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/bmi_ref/Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED.sumstats.gz" \
    --toest "direct_population" \
    --hwe /var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/snpstats/hardy.hwe \
    --info /var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/snpstats/info.txt

#  0.8264 (0.1247)

############
# Geisinger
############

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/OUTPUT/fGWAS.OUT.GHS145k.hg38.GSA.OMNI.EUR.sampleQC.PCA.WF_GWAS.BMI.chr*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/geisinger/bmi" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/bmi_ref/Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED.sumstats.gz" \
    --toest "direct_paternal_maternal_averageparental_population" \
# 0.941 (0.031)

#############
# Dutch Twins
#############

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/BMI/NTR_BMI_CHR*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/dutch_twin/bmi" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/bmi_ref/Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED.sumstats.gz" \
    --toest "direct_paternal_maternal_averageparental_population" \
    --cptid \
    --info "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Info/info.txt.gz" \
    --hwe "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Info/hwe.txt.gz"


############
# HUNT
############


python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/bmi/bmi_chr*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/hunt/bmi" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/bmi_ref/Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED.sumstats.gz" \
    --toest "direct_paternal_maternal_averageparental_population" \
    --rsid_readfrombim "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/bimfiles/Eduhunt_results_chr*.bim,0,2,1, "
# 1.0875 (0.1359)

#############
# QIMR
############

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/qimr/public/latest/raw/sumstats/fgwas/BMI/BMI_Chr*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/qimr/bmi" \
#     --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/bmi_ref/Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED.sumstats.gz" \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --cptid
