#!/usr/bin/bash

# ldscpath="/var/genetics/pub/software/ldsc"
ldscpath="/var/genetics/pub/software/ldsc"
ldscmodpath="/var/genetics/proj/within_family/ssgac/ldsc_mod"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
within_family_path="/var/genetics/proj/within_family/within_family_project"
hm3snps="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"


echo "Munging!!"

# ${ldscpath}/munge_sumstats.py \
# --sumstats ${within_family_path}/processed/package_output/ea/eb_nocontrol/ea_meta_analysis_newqc_ebnocontrol.csv \
# --out ${within_family_path}/processed/package_output/ea/eb_nocontrol/dir_munge \
# --N-col dir_N --p dir_pval --signed-sumstats dir_z,0 \
# --merge-alleles ${hm3snps} \
# --n-min 1.0

# ${ldscpath}/munge_sumstats.py \
# --sumstats ${within_family_path}/processed/package_output/ea/eb_nocontrol/ea_meta_analysis_newqc_ebnocontrol.csv \
# --out ${within_family_path}/processed/package_output/ea/eb_nocontrol/pop_munge \
# --N-col population_N --p population_pval --signed-sumstats population_z,0 \
# --merge-alleles ${hm3snps} \
# --n-min 1.0

echo "Calcualting RG of population effect with reference EA sample"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/ea/eb_nocontrol/pop_munge.sumstats.gz,${within_family_path}/processed/reference_samples/ea_ref/GWAS_EA_excl23andMe.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/ea/eb_nocontrol/ea_reference_sample


${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/ea/eb_nocontrol/pop_munge.sumstats.gz,${within_family_path}/processed/package_output/ea/eb_nocontrol/dir_munge.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/ea/eb_nocontrol/dir_vs_pop \
--intercept-h2 1.0,1.0 \
--intercept-gencov 0.6663745940604221,0.6663745940604221
# 0.5576 (0.019)

${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/ea/eb_nocontrol/dir_munge.sumstats.gz,${within_family_path}/processed/package_output/bmi/meta_analysis_neq_qc_dir.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/ea/eb_nocontrol/ea_vs_bmi_dir
# -0.2524 (0.0598)

${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/ea/eb_nocontrol/pop_munge.sumstats.gz,${within_family_path}/processed/package_output/bmi/meta_analysis_neq_qc_pop.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/ea/eb_nocontrol/ea_vs_bmi_pop
# -0.3225 (0.0247)