#!/usr/bin/bash
ldscpath="/homes/nber/harij/ldsc"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
hm3snps="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"

source /disk/genetics/pub/python_env/anaconda2/bin/activate /disk/genetics/pub/python_env/anaconda2/envs/ldsc

for chr in {1..22}; do
    echo $chr
    python ${ldscpath}/ldsc.py \
        --bfile /var/genetics/data/ukb/private/latest/processed/user/harij/projects/within_family/data/chr/chr_$chr \
        --l2 \
        --ld-wind-cm 1 \
        --out /var/genetics/data/ukb/private/latest/processed/user/harij/projects/within_family/data/ldscores/${chr} \
        --yes-really
done