#!/usr/bin/bash
### Run the easyqc pipeline

within_family_path="/var/genetics/proj/within_family/within_family_project"
# 
# ${within_family_path}/processed/mdd_ref/PGC_UKB_depression_genome-wide.sumstats.gz alternate ref

##########
# EB - Estonian Biobank
##########

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/depression/Depression/Depression_chr*_results.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/depression" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/dep_ref/DS_Full.sumstats.gz" \
    --toest "direct_paternal_maternal_averageparental_population"

# 1.1245 (0.1913)

#########
# Geisinger
#########

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/depression/OUTPUT/fGWAS.OUT.GHS145k.hg38.GSA.OMNI.EUR.sampleQC.PCA.WF_GWAS.DEPRESSION.chr*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/geisinger/depression" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/dep_ref/DS_Full.sumstats.gz" \
    --toest "direct_paternal_maternal_averageparental_population"

# 0.7575 (0.1053)