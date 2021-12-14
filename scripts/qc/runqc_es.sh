#!/usr/bin/bash
### Run the easyqc pipeline
# Ever smoker


reffile="/var/genetics/proj/within_family/within_family_project/processed/reference_samples/smoking_ref/Smokinginit.sumstats.gz"

#################
# Minnesotta twins
#################


# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/minn_twins/public/latest/raw/sumstats/fgwas/sumstats/ES_chr*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/minn_twins/es" \
#     --ldsc-ref "$reffile" \
#     --cptid \
#     --toest "direct_population"

##############
# Estonian Biobank
##############

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/smoke/SMOKE_chr*_results.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/smoking" \
#     --ldsc-ref "$reffile" \
#     --toest "direct_paternal_maternal_averageparental_population"

#############
# Geisinger
#############

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/smoke_ever/OUTPUT/fGWAS.OUT.GHS145k.hg38.GSA.OMNI.EUR.sampleQC.PCA.WF_GWAS.SMOKE_EVER.chr*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/geisinger/smoking" \
    --ldsc-ref "$reffile" \
    --toest "direct_paternal_maternal_averageparental_population"