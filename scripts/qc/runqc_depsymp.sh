#!/usr/bin/bash
### Run the easyqc pipeline

reffile="/var/genetics/proj/within_family/within_family_project/processed/reference_samples/dep_ref/DS_Full.sumstats.gz"

##########
# MOBA
#########

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/moba/private/v1/raw/sumstats/hdf5/depanx_chr*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/moba/depsymp" \
    --ldsc-ref "$reffile" \
    --toest "direct_paternal_maternal_averageparental_population" \
    --info "/var/genetics/data/moba/public/latest/raw/sumstats/fgwas/snpqcstats/sampleQC/info.formatted.txt.gz" \
    --hwe "/var/genetics/data/moba/public/latest/raw/sumstats/fgwas/snpqcstats/sampleQC/hwe.formatted.txt.gz"

# ####################
# # ====== UKB ====== #
# ####################

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/ukb/private/v3/processed/proj/within_family/sumstats/depressive.symptoms/depressive.symptoms.sumstats.gz" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ukb/depsymp" \
#     --effects "direct_averageparental" \
#     --toest "direct_population" \
#     --bim_chromosome 99 \
#     --ldsc-ref "$reffile" \
#     --hwe '/disk/genetics/ukb/alextisyoung/hapmap3/hwe/hwe.formatted' \
#     --info '/disk/genetics2/ukb/orig/UKBv3/imputed_data/info.formatted'

# #########
# # Hunt
# #########
# # deprcat - depression coded as 8 categories
# # deprcont - depression on continuous scale
# # we use deprcont for now

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/deprCat/deprCat_chr*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/hunt/deprcat" \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --rsid_readfrombim "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/bimfiles/Eduhunt_results_chr*.bim,0,2,1, " \
#     --ldsc-ref "$reffile" 

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/deprCont/deprCont_chr*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/hunt/deprcont" \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --rsid_readfrombim "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/bimfiles/Eduhunt_results_chr*.bim,0,2,1, " \
#     --ldsc-ref "$reffile" 

# #############
# # QIMR
# ############

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/qimr/private/v1/raw/pgs/QIMR_FamilyGWAS/Depression_Symptoms/DepSym_Chr*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/qimr/depsymp" \
#     --ldsc-ref "$reffile" \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --cptid

# #####################
# # ====== FHS ====== #
# #####################

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/fhs/public/v1/processed/sumstats/gwas/dep/chr*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/fhs/depsymp" \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --ldsc-ref $reffile \
#     --cptid

# #####################
# # ====== CKB ====== #
# #####################

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/ckb/private/v1/processed/sumstats/Dec_2022/bin_depressive_symptoms_all_chr.sumstats.txt" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ckb/depsymp" \
#     --effects "direct_averageparental_population" \
#     --toest "direct_averageparental_population" \
#     --af-ref "/var/genetics/proj/within_family/within_family_project/processed/qc/otherqc/eas_afs/eas_1kg.frq" \
#     --cptid