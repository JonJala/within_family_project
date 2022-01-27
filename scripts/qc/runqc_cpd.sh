#!/usr/bin/bash
### Run the easyqc pipeline
reffile="/var/genetics/proj/within_family/within_family_project/processed/reference_samples/smoking_ref/Smokinginit.sumstats.gz"

#################
# Minnesotta twins
#################

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/minn_twins/public/latest/raw/sumstats/fgwas/sumstats/CPD_chr*.sumstats.hdf5"  \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/minn_twins/cpd/" \
#     --ldsc-ref $reffile \
#     --cptid \
#     --toest "direct_population"

#############
# Dutch Twins
#############

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Cannabis/NTR_Cannabis_CHR*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/dutch_twin/cpd" \
#     --ldsc-ref "$reffile" \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --cptid \
#     --info "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Info/info.txt.gz" \
#     --hwe "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Info/hwe.txt.gz"

#########
# Hunt
######


python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/cigPerDay/cigPerDay_chr*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/hunt/cpd" \
    --ldsc-ref $reffile \
    --toest "direct_paternal_maternal_averageparental_population" \
    --rsid_readfrombim "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/bimfiles/Eduhunt_results_chr*.bim,0,2,1, "
