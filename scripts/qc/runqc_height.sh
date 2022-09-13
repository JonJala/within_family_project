#!/usr/bin/bash
### Run the easyqc pipeline

refsample="/var/genetics/proj/within_family/within_family_project/processed/reference_samples/ht_ref/Meta-analysis_Wood_et_al+UKBiobank_2018.sumstats.gz"

#####################
# ====== UKB ====== #
#####################

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/disk/genetics3/data_dirs/ukb/private/v3/processed/sumstats/fgwas/Imp_height.sumstats.gz" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ukb/height" \
    --effects "direct_averageparental" \
    --toest "direct_population" \
    --bim_chromosome 99 \
    --ldsc-ref $refsample \
    --hwe '/disk/genetics/ukb/alextisyoung/hapmap3/hwe/hwe.formatted' \
    --info '/disk/genetics2/ukb/orig/UKBv3/imputed_data/info.formatted'

#######################
# generation scotland
#######################

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/5/chr_*chr_clean.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/gs/height" \
    --ldsc-ref $refsample \
    --rsid_readfrombim "/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/SNPs/chr_*_rsids.txt,0,3,1, " \
    --toest "direct_paternal_maternal_averageparental_population" \
    --hwe "/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/hwe/chr_*.hwe" \
    --info "/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/info/combined_clean.info.gz"


#############
# Lifelines
##########

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/disk/genetics3/data_dirs/lifelines/public/v1/raw/sumstats/fgwas/fgwas_ll_height18.sumstats.gz" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/lifelines/height18" \
    --ldsc-ref $refsample  \
    --effects "direct_averageparental" \
    --toest "direct_population"  \
    --info "/disk/genetics3/data_dirs/lifelines/public/v1/raw/sumstats/fgwas/fgwas_ll_info_hwe.formatted.txt" \
    --hwe "/disk/genetics3/data_dirs/lifelines/public/v1/raw/sumstats/fgwas/fgwas_ll_info_hwe.formatted.txt"

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/disk/genetics3/data_dirs/lifelines/public/v1/raw/sumstats/fgwas/fgwas_ll_height.sumstats.gz" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/lifelines/height" \
    --ldsc-ref $refsample  \
    --effects "direct_averageparental" \
    --toest "direct_population"  \
    --info "/disk/genetics3/data_dirs/lifelines/public/v1/raw/sumstats/fgwas/fgwas_ll_info_hwe.formatted.txt" \
    --hwe "/disk/genetics3/data_dirs/lifelines/public/v1/raw/sumstats/fgwas/fgwas_ll_info_hwe.formatted.txt"


###########
# MOBA
############

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/moba/public/latest/raw/sumstats/fgwas/sumstats/ht_chr*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/moba/height" \
    --ldsc-ref $refsample \
    --toest "direct_paternal_maternal_averageparental_population" \
    --info "/var/genetics/data/moba/public/latest/raw/sumstats/fgwas/snpqcstats/sampleQC/info.formatted.txt.gz" \
    --hwe "/var/genetics/data/moba/public/latest/raw/sumstats/fgwas/snpqcstats/sampleQC/hwe.formatted.txt.gz"

#########
# Estonian Biobank
#########


# estonian bio bnak with controls
python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/newresults/height/height_chr*_results.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/height/" \
    --ldsc-ref "$refsample" \
    --toest "direct_paternal_maternal_averageparental_population"  \
    --hwe "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/HWE/chr*.hwe" \
    --info "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/ImputationQuality_formatted.TXT"

##########
# STR
##########

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/height/height_chr*.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/str/height" \
    --ldsc-ref $refsample \
    --toest "direct_population" \
    --bim_bp 3 --bim_a1 4 --bim_a2 5 \
    --info "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/SNPstats/info.txt.gz" \
    --hwe "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/SNPstats/hardy.txt.gz"


#####
# Finnish twins
#####

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/height.chr*.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ft/height" \
    --ldsc-ref $refsample \
    --toest "direct_population" \
    --hwe /var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/snpstats/hardy.hwe \
    --info /var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/snpstats/info.txt

# 0.9227 (0.081)

#########
# Hunt
######


python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/height/height_chr*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/hunt/height" \
    --ldsc-ref $refsample \
    --toest "direct_paternal_maternal_averageparental_population" \
    --rsid_readfrombim "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/bimfiles/Eduhunt_results_chr*.bim,0,2,1, " \
    --info '/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/snpstats/info.formatted.gz' \
    --hwe '/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/snpstats/hwe.formatted.gz'


#################
# Minnesota twins
#################

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/minn_twins/public/latest/raw/sumstats/fgwas/sumstats/Height_chr*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/minn_twins/height" \
    --ldsc-ref $refsample \
    --cptid \
    --toest "direct_population" \
    --hwe '/disk/genetics3/data_dirs/minn_twins/public/v1/raw/sumstats/fgwas/sumstats/snpstats/hardy.hwe'



################
# Geisinger
############

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/OUTPUT/fGWAS.OUT.GHS145k.hg38.GSA.OMNI.EUR.sampleQC.PCA.WF_GWAS.HEIGHT.std.chr*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/geisinger/height" \
    --ldsc-ref $refsample \
    --toest "direct_paternal_maternal_averageparental_population" \
    --info '/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/OUTPUT.SNP_INFO/info.formatted.txt' \
    --hwe '/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/OUTPUT.SNP_INFO/hwe.formatted.txt'

#############
# Dutch Twins
#############

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Height/NTR_Height_CHR*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/dutch_twin/height" \
    --ldsc-ref "$refsample" \
    --toest "direct_paternal_maternal_averageparental_population" \
    --cptid \
    --info "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Info/info.txt.gz" \
    --hwe "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Info/hwe.txt.gz"

#############
# QIMR
############

## awaiting updated ss

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/qimr/public/latest/raw/sumstats/fgwas/new_data/QIMR_Updated_fGWAS/Height/Height_Chr*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/qimr/height" \
#     --ldsc-ref "$refsample" \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --cptid

#############
# botnia
###########

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/botnia_fam/private/latest/processed/sumstats/fgwas/5/chr_*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/botnia/height" \
    --ldsc-ref "$refsample" \
    --toest "direct_population" \
    --cptid