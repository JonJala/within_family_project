
#!/usr/bin/bash
### Run the easyqc pipeline

reffile="/var/genetics/proj/within_family/within_family_project/processed/reference_samples/age_menarche_ref/age_menarche_ref.sumstats.gz"


# #########
# # Hunt
# ######

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/AgeMenarch/AgeMenarch_chr*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/hunt/agemenarche" \
#     --ldsc-ref $reffile \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --rsid_readfrombim "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/bimfiles/Eduhunt_results_chr*.bim,0,2,1, " \
#     --info '/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/snpstats/info.formatted.gz' \
#     --hwe '/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/snpstats/hwe.formatted.gz'

# #############
# # Dutch Twins
# #############

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Menarche/NTR_Menarche_CHR*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/dutch_twin/menarche" \
#     --ldsc-ref "$reffile" \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --cptid \
#     --info "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Info/info.txt.gz" \
#     --hwe "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Info/hwe.txt.gz"

# #####################
# # ====== UKB ====== #
# #####################

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/disk/genetics3/data_dirs/ukb/private/v3/processed/proj/within_family/sumstats/menarche/menarche.sumstats.gz" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ukb/agemenarche" \
#     --effects "direct_averageparental" \
#     --toest "direct_population" \
#     --bim_chromosome 99 \
#     --ldsc-ref $reffile \
#     --hwe '/disk/genetics/ukb/alextisyoung/hapmap3/hwe/hwe.formatted' \
#     --info '/disk/genetics2/ukb/orig/UKBv3/imputed_data/info.formatted'

# #############
# # QIMR
# ############

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/disk/genetics3/data_dirs/qimr/private/v1/raw/pgs/QIMR_FamilyGWAS/Menarche/Menarche_Chr*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/qimr/agemenarche" \
#     --ldsc-ref "$reffile" \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --cptid

#####################
# ====== CKB ====== #
#####################

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/proj/within_family/within_family_project/processed/qc/ckb/raw/mena_age.sumstats.txt" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ckb/agemenarche" \
    --effects "direct_averageparental" \
    --toest "direct_population" \
    --ldsc-ref "$reffile" \
    --cptid

