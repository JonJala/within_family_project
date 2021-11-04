#!/usr/bin/bash

# ldscpath="/var/genetics/pub/software/ldsc"
ldscpath="/homes/nber/harij/ldsc"
ldscmodpath="/homes/nber/harij/ssgac/ldsc_mod"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
within_family_path="/var/genetics/proj/within_family/within_family_project"
hm3snps="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"

# ${ldscpath}/munge_sumstats.py \
# --sumstats ${within_family_path}/processed/qc/estonian_biobank/ea/controls/CLEANED.out.gz \
# --out ${within_family_path}/processed/qc/estonian_biobank/ea/controls/munged_dir \
# --N-col n_direct --p PVAL_direct --signed-sumstats z_direct,0 \
# --merge-alleles ${hm3snps} \
# --n-min 1.0

# ${ldscpath}/munge_sumstats.py \
# --sumstats ${within_family_path}/processed/qc/estonian_biobank/ea/CLEANED.out.gz \
# --out ${within_family_path}/processed/qc/estonian_biobank/ea/munged_dir \
# --N-col n_direct --p PVAL_direct --signed-sumstats z_direct,0 \
# --merge-alleles ${hm3snps} \
# --n-min 1.0


# echo "Calcualting RG of population effect with reference EA sample"
# ${ldscpath}/ldsc.py \
# --rg ${within_family_path}/processed/qc/estonian_biobank/ea/controls/munged_dir.sumstats.gz,${within_family_path}/processed/qc/estonian_biobank/ea/munged_dir.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out  ${within_family_path}/processed/qc/estonian_biobank/ea/controls/direffect_controlvnocontrol

# ${ldscpath}/ldsc.py \
# --rg ${within_family_path}/processed/qc/estonian_biobank/ea/controls/munged_dir.sumstats.gz,${within_family_path}/processed/qc/estonian_biobank/ea/controls/munged_ecf.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out  ${within_family_path}/processed/qc/estonian_biobank/ea/controls/dir_v_population

${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/qc/estonian_biobank/ea/controls/munged_dir.sumstats.gz,${within_family_path}/processed/package_output/ea/meta_analysis_dir.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out  ${within_family_path}/processed/qc/estonian_biobank/ea/controls/dir_vs_old

# ${ldscpath}/ldsc.py \
# --rg ${within_family_path}/processed/qc/estonian_biobank/ea/munged_dir.sumstats.gz,${within_family_path}/processed/qc/estonian_biobank/ea/munged_ecf.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out  ${within_family_path}/processed/qc/estonian_biobank/ea/dir_v_population

