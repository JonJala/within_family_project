#!/usr/bin/bash

## calculate finngen genetic correlation with reference using finnish LD scores computed by alex

# pheno="bmi"
pheno="height"
sumstats="/var/genetics/proj/within_family/within_family_project/processed/qc/finngen/${pheno}/CLEANED.out.gz"
# ldsc_ref="/var/genetics/proj/within_family/within_family_project/processed/reference_samples/bmi_ref/Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED.sumstats.gz" ## bmi ref
ldsc_ref="/var/genetics/proj/within_family/within_family_project/processed/reference_samples/ht_ref/Meta-analysis_Wood_et_al+UKBiobank_2018.sumstats.gz" ## height ref
ldscores="/disk/genetics/data/finngen/private/v1/processed/ld_scores/"    
merge_alleles="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"
ldsc_path="/var/genetics/tools/ldsc/ldsc"
outpath="/var/genetics/proj/within_family/within_family_project/processed/qc/finngen/${pheno}"

act="/disk/genetics/pub/python_env/anaconda2/bin/activate"
pyenv="/disk/genetics/pub/python_env/anaconda2/envs/ldsc"

# Activating ldsc environment
source ${act} ${pyenv}

# munging data
python ${ldsc_path}/munge_sumstats.py \
    --sumstats ${sumstats} \
    --merge-alleles ${merge_alleles} \
    --out ${outpath}/munged_ecf \
    --signed-sumstats z_population,0 --p PVAL_population --N-col n_population

# calculate rg
python ${ldsc_path}/ldsc.py \
    --rg ${outpath}/munged_ecf.sumstats.gz,${ldsc_ref} \
    --ref-ld-chr ${ldscores} \
    --w-ld-chr ${ldscores} \
    --out ${outpath}/refldsc


