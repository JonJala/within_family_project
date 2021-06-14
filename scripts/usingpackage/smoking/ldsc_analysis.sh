#!/usr/bin/bash

ldscpath="/var/genetics/pub/software/ldsc"
ldscmodpath="/homes/nber/harij/ssgac/ldsc_mod"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
within_family_path="/var/genetics/proj/within_family/within_family_project"
hm3snps="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"


echo "Calculating rg between population and direct effects"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/smoking_ref/Smokinginit.sumstats.gz,/var/genetics/data/estonian_biobank/public/latest/processed/sumstats/fgwas/smoke_dir.sumstats \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/smoking/smoke_ref