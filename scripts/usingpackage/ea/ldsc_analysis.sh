#!/usr/bin/bash

# ldscpath="/var/genetics/pub/software/ldsc"
ldscpath="/homes/nber/harij/ldsc"
ldscmodpath="/homes/nber/harij/ssgac/ldsc_mod"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
within_family_path="/var/genetics/proj/within_family/within_family_project"
hm3snps="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"
scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"

echo "Munging!!"


${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/ea/ea_meta_analysis.sumstats \
--out ${within_family_path}/processed/package_output/ea/meta_analysis_new_qc_dir \
--N-col direct_N --p direct_pval --signed-sumstats direct_z,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/ea/ea_meta_analysis.sumstats \
--out ${within_family_path}/processed/package_output/ea/meta_analysis_new_qc_pop \
--N-col population_N --p population_pval --signed-sumstats population_z,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/ea/ea_meta_analysis.sumstats \
--out ${within_family_path}/processed/package_output/ea/meta_analysis_new_qc_paternal \
--N-col direct_N --p paternal_pval --signed-sumstats paternal_z,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/ea/ea_meta_analysis.sumstats \
--out ${within_family_path}/processed/package_output/ea/meta_analysis_new_qc_maternal \
--N-col direct_N --p maternal_pval --signed-sumstats maternal_z,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0

echo "Calcualting RG of population effect with reference EA sample"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/ea/meta_analysis_new_qc_pop.sumstats.gz,${within_family_path}/processed/reference_samples/ea_ref/GWAS_EA_excl23andMe.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/ea/ea_reference_sample
# 1.034 (0.0158)

echo "Calculating rg between population and direct effects"
Rscript $scriptpath/estimate_marginal_correlations_meta.R \
--file "/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/ea_meta_analysis.sumstats" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/"
# -Direct-population: r=0.6781 S.E.=0.024
# -Direct-average parental: r=0.0939 S.E.=0.0637


${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/ea/meta_analysis_new_qc_paternal.sumstats.gz,${within_family_path}/processed/package_output/ea/meta_analysis_new_qc_maternal.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/ea/maternal_vs_paternal
# -0.0501 (0.3567)