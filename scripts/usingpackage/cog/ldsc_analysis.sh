#!/usr/bin/bash

ldscpath="/homes/nber/harij/ldsc"
ldscmodpath="/homes/nber/harij/ssgac/ldsc_mod"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
within_family_path="/var/genetics/proj/within_family/within_family_project"
hm3snps="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"
scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"

echo "Munging!!"

# ${ldscpath}/munge_sumstats.py \
# --sumstats ${within_family_path}/processed/package_output/cog/meta.sumstats \
# --out ${within_family_path}/processed/package_output/cog/directmunged \
# --N-col direct_N --p direct_pval --signed-sumstats direct_z,0 \
# --merge-alleles ${hm3snps} \
# --n-min 1.0

# ${ldscpath}/munge_sumstats.py \
# --sumstats ${within_family_path}/processed/package_output/cog/meta.sumstats \
# --out ${within_family_path}/processed/package_output/cog/populationmunged \
# --N-col population_N --p population_pval --signed-sumstats population_z,0 \
# --merge-alleles ${hm3snps} \
# --n-min 1.0

# ${ldscpath}/munge_sumstats.py \
# --sumstats ${within_family_path}/processed/package_output/cog/meta.sumstats \
# --out ${within_family_path}/processed/package_output/cog/maternalmunged \
# --N-col direct_N --p maternal_pval --signed-sumstats maternal_z,0 \
# --merge-alleles ${hm3snps} \
# --n-min 1.0

# ${ldscpath}/munge_sumstats.py \
# --sumstats ${within_family_path}/processed/package_output/cog/meta.sumstats \
# --out ${within_family_path}/processed/package_output/cog/paternalmunged \
# --N-col direct_N --p paternal_pval --signed-sumstats paternal_z,0 \
# --merge-alleles ${hm3snps} \
# --n-min 1.0



# echo "Calcualting RG of population effect with reference Cognition sample"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/cog/populationmunged.sumstats.gz,${within_family_path}/processed/reference_samples/intelligence_ref/intelligence_ref.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/cog/population_reference_sample

${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/cog/directmunged.sumstats.gz,${within_family_path}/processed/reference_samples/intelligence_ref/intelligence_ref.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/cog/direct_reference_sample

echo "Calculating rg between population and direct effects"
Rscript $scriptpath/estimate_marginal_correlations_meta.R \
--file "/var/genetics/proj/within_family/within_family_project/processed/package_output/cog/meta.sumstats" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/cog/" \
--merge_alleles ${hm3snps}

${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/cog/maternalmunged.sumstats.gz,${within_family_path}/processed/package_output/cog/paternalmunged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/cog/maternal_vs_paternal

${ldscpath}/ldsc.py \
--h2 ${within_family_path}/processed/package_output/cog/directmunged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/cog/direct_h2

${ldscpath}/ldsc.py \
--h2 ${within_family_path}/processed/package_output/cog/populationmunged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/cog/population_h2