######
# Checks genetic correlation for our meta
# estimates with reference panels
######

within_family_path="/var/genetics/proj/within_family/within_family_project"
ldsc_path="/homes/nber/harij/ldsc"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
merge_alleles="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"


# Munge
# python ${ldsc_path}/munge_sumstats.py \
# --sumstats ${within_family_path}/processed/package_output/ea/ea_meta_analysis.csv \
# --signed-sumstats z_dir,0 --N-col wt_dir --p pval_dir \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/sanity_checks/moba/meta_checks/dir_excl_gs

# python ${ldsc_path}/munge_sumstats.py \
# --sumstats ${within_family_path}/processed/package_output/ea/ea_meta_analysis.csv \
# --signed-sumstats z_population,0 --N-col wt_2 --p pval_population \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/sanity_checks/moba/meta_checks/pop_excl_gs


# python ${ldsc_path}/munge_sumstats.py \
# --sumstats ${within_family_path}/processed/mtag/inputs/ea4_excl_ukb_gs_str.sumstats \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/sanity_checks/moba/meta_checks/ea4_excl_gs


# Estimating RG
python ${ldsc_path}/ldsc.py \
--rg ${within_family_path}/processed/sanity_checks/moba/meta_checks/dir_excl_gs.sumstats.gz,${within_family_path}/processed/sanity_checks/moba/meta_checks/ea4_excl_gs.sumstats.gz  \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/sanity_checks/moba/meta_checks/dir_ea4_excl_gs \
--intercept-h2 1,1

python ${ldsc_path}/ldsc.py \
--rg ${within_family_path}/processed/sanity_checks/moba/meta_checks/dir_excl_gs.sumstats.gz,${within_family_path}/processed/sanity_checks/moba/meta_checks/pop_excl_gs.sumstats.gz  \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/sanity_checks/moba/meta_checks/dir_pop_excl_gs \
--intercept-h2 1,1

python ${ldsc_path}/ldsc.py \
--rg ${within_family_path}/processed/sanity_checks/moba/meta_checks/ea4_excl_gs.sumstats.gz,${within_family_path}/processed/sanity_checks/moba/meta_checks/pop_excl_gs.sumstats.gz  \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/sanity_checks/moba/meta_checks/pop_ea4_excl_gs \
--intercept-h2 1,1
