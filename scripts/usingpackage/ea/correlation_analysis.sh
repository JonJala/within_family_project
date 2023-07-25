#!/usr/bin/bash

## TO DO:
### check which are not parsum!!!: gs, eb, hunt, geisinger, dt, qimr

within_family_path="/var/genetics/proj/within_family/within_family_project"
snipar_path="/var/genetics/proj/within_family/snipar_simulate/snipar"
basepath="/var/genetics/proj/within_family/within_family_project/scripts/package"
pheno="ea"

source /var/genetics/proj/within_family/snipar_venv/bin/activate

## cohorts

# raw sumstats
gs="/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/14/chr_*.sumstatschr_clean.hdf5"
ft="/var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/EA.chr*.hdf5"
str="/var/genetics/data/str/public/latest/raw/sumstats/fgwas/eduYears/eduYears_chr*.hdf5"
geisinger="/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/OUTPUT/fGWAS.OUT.GHS145k.hg38.GSA.OMNI.EUR.sampleQC.PCA.WF_GWAS.Edu_Years.chr*.sumstats.hdf5"
moba="/var/genetics/data/moba/private/v1/raw/sumstats/hdf5/edu_chr*.hdf5"
hunt="/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/edu/edu_chr*.sumstats.hdf5" # chrposid
dutch_twin="/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Education/NTR_Education_CHR*.sumstats.hdf5" # chrposid
qimr="/var/genetics/data/qimr/private/v1/raw/pgs/QIMR_FamilyGWAS/Education/Edu_Chr*.sumstats.hdf5" # chrposid
minn_twins="/var/genetics/data/minn_twins/public/latest/raw/sumstats/fgwas/sumstats/ED_chr*.sumstats.hdf5" # chrposid

# cohorts that don't need processing
ukb="/var/genetics/data/ukb/private/v3/processed/proj/within_family/sumstats/EA/EA.sumstats.gz"
lifelines="/disk/genetics/data/lifelines/public/latest/raw/sumstats/fgwas/fgwas_ll_edu.sumstats.gz"
estonian_biobank="/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/newresults/EduYears/controls/EduYears_ext/EduYears_chr*_results.sumstats.gz"

# cohorts that use chrposids 
chrposid_cohorts="hunt dutch_twin qimr minn_twins"

# processed sumstats 
declare -A all_cohorts=( ["gs"]="/var/genetics/data/gen_scotland/public/latest/processed/sumstats/fgwas/14/gz/chr_@.sumstatschr_clean" 
["moba"]="/var/genetics/data/moba/private/v1/processed/sumstats/gz/edu_chr@" 
["hunt"]="/var/genetics/data/hunt/public/latest/processed/sumstats/fgwas/edu/gz/edu_chr@" 
["dutch_twin"]="/var/genetics/data/dutch_twin/public/latest/processed/sumstats/fgwas/Education/gz/NTR_Education_CHR@" 
["qimr"]="/var/genetics/data/qimr/private/v1/processed/pgs/QIMR_FamilyGWAS/Education/gz/Edu_Chr@" 
["minn_twins"]="/var/genetics/data/minn_twins/public/latest/processed/sumstats/fgwas/sumstats/gz/ED_chr@" 
["str"]="/var/genetics/data/str/public/latest/processed/sumstats/fgwas/eduYears/gz/eduYears_chr@"
["ft"]="/var/genetics/data/finn_twin/public/latest/processed/sumstats/fgwas/gz/EA.chr@" 
["geisinger"]="/var/genetics/data/geisinger/public/latest/processed/sumstats/fgwas/OUTPUT/gz/fGWAS.OUT.GHS145k.hg38.GSA.OMNI.EUR.sampleQC.PCA.WF_GWAS.Edu_Years.chr@"
["ukb"]="/var/genetics/data/ukb/private/v3/processed/proj/within_family/sumstats/EA/EA" 
["lifelines"]="/disk/genetics/data/lifelines/public/latest/raw/sumstats/fgwas/fgwas_ll_edu" 
["estonian_biobank"]="/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/newresults/EduYears/controls/EduYears_ext/EduYears_chr@_results" 
)

## process sumstats

# convert hdf5 to gz
hdf5_sumstats="${gs} ${moba} ${str} ${ft} ${geisinger}" # file paths
for sumstats in ${hdf5_sumstats}
do
    python3 /var/genetics/proj/within_family/within_family_project/scripts/package/format_sumstats.py \
        --sumstats ${sumstats}
done

# # convert snp id to chrposid
# chrposid_sumstats="${hunt} ${dutch_twin} ${qimr} ${minn_twins}" # file paths
# for sumstats in ${chrposid_sumstats}
# do
#     python3 /var/genetics/proj/within_family/within_family_project/scripts/package/format_sumstats.py \
#         --sumstats ${sumstats} \
#         --chrposid
# done


# ## calculate direct-pop correlation for each cohort
# for cohort in "${!all_cohorts[@]}"
# do
#     echo $cohort
#     if [[ " $chrposid_cohorts " =~ " $cohort " ]]; then
#         echo "Using chr:pos IDs"
#         ldscores="/disk/genetics/data/alkesgroup/public/v1/processed/ld_scores/eur_w_ld_chr/chrposid/@"
#     else
#         ldscores="/disk/genetics/data/alkesgroup/public/v1/raw/ld_scores/eur_w_ld_chr/@"
#     fi

#     ${snipar_path}/scripts/correlate.py "${all_cohorts[$cohort]}" \
#         "${within_family_path}/processed/qc/${cohort}/${pheno}/marginal" \
#         --ldscores "${ldscores}"
# done


# ## compile correlation estimates into excel spreadsheet
# python ${basepath}/compile_correlation_estimates.py \
#     --pheno ${pheno} \
#     --cohorts "${cohorts}"

