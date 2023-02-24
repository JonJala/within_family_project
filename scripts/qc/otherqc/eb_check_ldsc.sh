#!/usr/bin/bash

# ldscpath="/var/genetics/pub/software/ldsc"
ldscpath="/var/genetics/pub/software/ldsc"
ldscmodpath="/var/genetics/proj/within_family/ssgac/ldsc_mod"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
within_family_path="/var/genetics/proj/within_family/within_family_project"
hm3snps="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"

# ${ldscpath}/munge_sumstats.py \
# --sumstats ${within_family_path}/processed/qc/estonian_biobank/ea/controls/CLEANED.out.gz \
# --out ${within_family_path}/processed/qc/estonian_biobank/ea/controls/munged_dir \
# --N-col n_direct --p PVAL_direct --signed-sumstats z_direct,0 \
# --merge-alleles ${hm3snps} \
# --n-min 1.0

# ${ldscpath}/ldsc.py \
# --rg ${within_family_path}/processed/qc/estonian_biobank/ea/controls/munged_dir.sumstats.gz,${within_family_path}/processed/qc/estonian_biobank/ea/controls/munged_ecf.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out  ${within_family_path}/processed/qc/estonian_biobank/ea/controls/dir_v_population


