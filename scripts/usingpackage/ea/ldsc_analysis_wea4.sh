#!/usr/bin/bash

# ldscpath="/var/genetics/pub/software/ldsc"
ldscpath="/homes/nber/harij/ldsc"
ldscmodpath="/homes/nber/harij/ssgac/ldsc_mod"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
within_family_path="/var/genetics/proj/within_family/within_family_project"
hm3snps="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"
scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"

echo "Munging!!"


# ${ldscpath}/munge_sumstats.py \
# --sumstats ${within_family_path}/processed/package_output/ea/ea_meta_analysis_ea4.sumstats \
# --out ${within_family_path}/processed/package_output/ea/meta_analysis_dir_wea4 \
# --N-col direct_N --p direct_pval --signed-sumstats direct_z,0 \
# --merge-alleles ${hm3snps} \
# --n-min 1.0

# ${ldscpath}/munge_sumstats.py \
# --sumstats ${within_family_path}/processed/package_output/ea/ea_meta_analysis_ea4.sumstats \
# --out ${within_family_path}/processed/package_output/ea/meta_analysis_pop_wea4 \
# --N-col population_N --p population_pval --signed-sumstats population_z,0 \
# --merge-alleles ${hm3snps} \
# --n-min 1.0

# ${ldscpath}/munge_sumstats.py \
# --sumstats ${within_family_path}/processed/package_output/ea/ea_meta_analysis_ea4.sumstats \
# --out ${within_family_path}/processed/package_output/ea/meta_analysis_paternal_wea4 \
# --N-col direct_N --p paternal_pval --signed-sumstats paternal_z,0 \
# --merge-alleles ${hm3snps} \
# --n-min 1.0

# ${ldscpath}/munge_sumstats.py \
# --sumstats ${within_family_path}/processed/package_output/ea/ea_meta_analysis_ea4.sumstats \
# --out ${within_family_path}/processed/package_output/ea/meta_analysis_maternal_wea4 \
# --N-col direct_N --p maternal_pval --signed-sumstats maternal_z,0 \
# --merge-alleles ${hm3snps} \
# --n-min 1.0



${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/ea/ea_meta_analysis_ea4.sumstats \
--out ${within_family_path}/processed/package_output/ea/meta_analysis_avgpar_wea4 \
--N-col direct_N --p avg_parental_pval --signed-sumstats avg_parental_z,0 \
--merge-alleles ${hm3snps}

# echo "Calcualting RG of population effect with reference EA sample"
# ${ldscpath}/ldsc.py \
# --rg ${within_family_path}/processed/package_output/ea/meta_analysis_pop_wea4.sumstats.gz,${within_family_path}/processed/reference_samples/ea_ref/GWAS_EA_excl23andMe.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/package_output/ea/ea_wea4_reference_sample
# # 0.9274 (0.004)

# echo "Calculating rg between population and direct effects"
# Rscript $scriptpath/estimate_marginal_correlations_meta.R \
# --file "/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/ea_meta_analysis_ea4.sumstats" \
# --outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/wea4" \
# --merge_alleles ${hm3snps}
# # -Direct-population: r=0.6781 S.E.=0.024
# # -Direct-average parental: r=0.0939 S.E.=0.0637
# # hm3 "r=0.6405 S.E.=0.0183"

# ${ldscpath}/ldsc.py \
# --rg ${within_family_path}/processed/package_output/ea/meta_analysis_paternal_wea4.sumstats.gz,${within_family_path}/processed/package_output/ea/meta_analysis_maternal_wea4.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/package_output/ea/wea4_maternal_vs_paternal
# -0.12 (0.3343)


${ldscpath}/ldsc.py \
--h2 ${within_family_path}/processed/package_output/ea/meta_analysis_dir_wea4.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/ea/meta_analysis_dir_wea4_h2
# 0.0714 (0.0056)

${ldscpath}/ldsc.py \
--h2 ${within_family_path}/processed/package_output/ea/meta_analysis_avgpar_wea4.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/ea/meta_analysis_avgpar_wea4_h2
# 0.0266 (0.0048)

Rscript $scriptpath/estimate_marginal_correlations_meta.R \
--file "/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/ea_meta_analysis_ea4.sumstats" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/" \
--dir_pop_rg_name "paternal_maternal_rg" --dirbeta "paternal_Beta" --popbeta "maternal_Beta" \
--dirse "paternal_SE" --popse "maternal_SE" \
--merge_alleles ${hm3snps}
# "r=2.2437 S.E.=0.3554"