#!/usr/bin/bash
### Run the easyqc pipeline

reffile="/var/genetics/proj/within_family/within_family_project/processed/reference_samples/swb_ref/swb_ref.sumstats.gz"

#################
# Minnesota twins
#################

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/minn_twins/public/latest/raw/sumstats/fgwas/sumstats/SWB_chr*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/minn_twins/swb" \
    --ldsc-ref "$reffile" \
    --cptid \
    --effects "direct_averageparental" \
    --toest "direct_population" \
    --hwe '/var/genetics/data/minn_twins/public/v1/raw/sumstats/fgwas/sumstats/snpstats/hardy.hwe'

# ###############
# # HUNT
# ###############

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/wellbeing/wellbeing_chr*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/hunt/swb" \
#     --ldsc-ref "$reffile" \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --rsid_readfrombim "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/bimfiles/Eduhunt_results_chr*.bim,0,2,1, " \
#     --info '/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/snpstats/info.formatted.gz' \
#     --hwe '/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/snpstats/hwe.formatted.gz'

##########
# STR
##########

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/SWB/SWB_chr*.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/str/SWB" \
    --ldsc-ref "$reffile" \
    --effects "direct_averageparental" \
    --toest "direct_population" \
    --bim_bp 3 --bim_a1 4 --bim_a2 5 \
    --info "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/SNPstats/info.txt.gz" \
    --hwe "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/SNPstats/hardy.txt.gz" \
    --rsid_readfrombim "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/SNPs/chr_*.bim,0,3,1, "

#####
# Finnish twins
#####

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/wellbeing.chr*.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ft/swb" \
    --ldsc-ref "$reffile" \
    --effects "direct_averageparental" \
    --toest "direct_population" \
    --hwe /var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/snpstats/hardy.hwe \
    --info /var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/snpstats/info.txt

# #############
# # Dutch Twins
# #############

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/SatisfactionWithLife/NTR_SatisfactionWithLife_CHR*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/dutch_twin/swb" \
#     --ldsc-ref "$reffile" \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --cptid \
#     --info "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Info/info.txt.gz" \
#     --hwe "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Info/hwe.txt.gz"

# #####################
# # ====== UKB ====== #
# #####################

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/ukb/private/v3/processed/proj/within_family/sumstats/subjective.well.being/subjective.well.being.sumstats.gz" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ukb/swb" \
#     --effects "direct_averageparental" \
#     --toest "direct_population" \
#     --bim_chromosome 99 \
#     --ldsc-ref $reffile \
#     --hwe '/disk/genetics/ukb/alextisyoung/hapmap3/hwe/hwe.formatted' \
#     --info '/disk/genetics2/ukb/orig/UKBv3/imputed_data/info.formatted'

# ############
# # QIMR
# ###########

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/qimr/private/v1/raw/pgs/QIMR_FamilyGWAS/Wellbeing/Wellbeing_Chr*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/qimr/swb" \
#     --ldsc-ref "$reffile" \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --cptid

#####################
# ====== CKB ====== #
#####################

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/ckb/private/v1/processed/sumstats/Dec_2022/satisfaction_level_all_chr.sumstats.txt" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ckb/swb" \
    --effects "direct_averageparental" \
    --toest "direct_population" \
    --af-ref "/var/genetics/proj/within_family/within_family_project/processed/qc/otherqc/eas_afs/eas_1kg.frq" \
    --cptid
