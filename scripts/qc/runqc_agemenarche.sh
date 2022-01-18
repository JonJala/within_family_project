
#!/usr/bin/bash
### Run the easyqc pipeline

refsample="/var/genetics/proj/within_family/within_family_project/processed/reference_samples/age_menarche_ref/age_menarche_ref.sumstats.gz"


#########
# Hunt
######


python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/AgeMenarch/AgeMenarch_chr*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/hunt/agemenarche" \
    --ldsc-ref $refsample \
    --toest "direct_paternal_maternal_averageparental_population" \
    --rsid_readfrombim "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/bimfiles/Eduhunt_results_chr*.bim,0,2,1, "


