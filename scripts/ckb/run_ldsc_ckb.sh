#!/usr/bin/bash

ldsc_path="/var/genetics/tools/ldsc/ldsc"
act="/disk/genetics/pub/python_env/anaconda2/bin/activate"
pyenv="/disk/genetics/pub/python_env/anaconda2/envs/ldsc"
ckb_ld_chr="/var/genetics/data/ckb/private/v1/processed/ld_scores/snipar_generated/"

# Activating ldsc environment
source ${act} ${pyenv}

for pheno in "bmi" "height" "bps" "bpd" "agemenarche" "asthma" "cpd" "depsymp" "dpw" "ea" "eversmoker" "fev" "health" "nchildren" "swb"
do

    filein="/var/genetics/proj/within_family/within_family_project/processed/qc/ckb/${pheno}/CLEANED.out.gz" # qc'd ckb sumstats for munging
    reffile="/var/genetics/proj/within_family/within_family_project/processed/reference_samples/bbj_ref/${pheno}_ref/${pheno}_ref.sumstats.gz" # BBJ reference sumstats
    outprefix="/var/genetics/proj/within_family/within_family_project/processed/qc/ckb/${pheno}" # path where ldsc output is saved

    # munge ckb sumstats for population effects 
    python ${ldsc_path}/munge_sumstats.py \
        --sumstats ${filein} \
        --out ${outprefix}/munged_ecf \
        --signed-sumstats z_population,0 --p PVAL_population --N-col n_population

    # munge ckb sumstats for direct effects 
    python ${ldsc_path}/munge_sumstats.py \
        --sumstats ${filein} \
        --out ${outprefix}/munged_ecf_direct \
        --signed-sumstats z_direct,0 --p PVAL_direct --N-col n_direct

    # calculate population h2
    python ${ldsc_path}/ldsc.py \
        --h2 ${outprefix}/munged_ecf.sumstats.gz \
        --ref-ld-chr ${ckb_ld_chr} \
        --w-ld-chr ${ckb_ld_chr} \
        --out ${outprefix}/h2_population

    # calculate direct h2
    python ${ldsc_path}/ldsc.py \
        --h2 ${outprefix}/munged_ecf_direct.sumstats.gz \
        --ref-ld-chr ${ckb_ld_chr} \
        --w-ld-chr ${ckb_ld_chr} \
        --out ${outprefix}/h2_direct

done

# calculate rg with reference for phenos where we have BBJ ref sumstats
for pheno in "bmi" "height" "bpd" "bps"
do

    reffile="/var/genetics/proj/within_family/within_family_project/processed/reference_samples/bbj_ref/${pheno}_ref/${pheno}_ref.sumstats.gz" # BBJ reference sumstats
    outprefix="/var/genetics/proj/within_family/within_family_project/processed/qc/ckb/${pheno}" # path where ldsc output is saved

    python ${ldsc_path}/ldsc.py \
        --rg ${outprefix}/munged_ecf.sumstats.gz,${reffile} \
        --ref-ld-chr ${ckb_ld_chr} \
        --w-ld-chr ${ckb_ld_chr} \
        --out ${outprefix}/refldsc

done