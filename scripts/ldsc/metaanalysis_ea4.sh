######
# Estimates sample overlap between meta analyzed
# estimates (excluding EA4) and EA4.
# Used for combining meta analysis and EA4
# results accounting for sample overlap
######

within_family_path="/var/genetics/proj/within_family/within_family_project"
ldsc_path="/homes/nber/harij/ldsc"
ldscmod_path="/homes/nber/harij/ssgac/ldscmod"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
merge_alleles="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"

# Munge
# python ${ldsc_path}/munge_sumstats.py \
# --sumstats /var/genetics/proj/within_family/within_family_project/processed/ea4/ea4_excl_ukb_str_gs_2020_08_21.txt \
# --merge-alleles ${merge_alleles} \
# --out /var/genetics/proj/within_family/within_family_project/processed/ea4/ea4_excl_ukb_str_gs_2020_08_21

# python ${ldsc_path}/munge_sumstats.py \
# --sumstats /var/genetics/proj/within_family/within_family_project/processed/package_output/ea/ea_meta_analysis_amat.csv \
# --merge-alleles ${merge_alleles} \
# --signed-sumstats z_dir,0 --N-col N_dir --p pval_dir \
# --out /var/genetics/proj/within_family/within_family_project/processed/package_output/ea/ea_meta_analysis_amat_dir

# python ${ldsc_path}/munge_sumstats.py \
# --sumstats /var/genetics/proj/within_family/within_family_project/processed/package_output/ea/ea_meta_analysis_amat.csv \
# --merge-alleles ${merge_alleles} \
# --signed-sumstats z_avgparental,0 --N-col N_avgparental --p pval_avgparental \
# --out /var/genetics/proj/within_family/within_family_project/processed/package_output/ea/ea_meta_analysis_amat_avgparental

# LDSC
python ${ldsc_path}/ldsc.py \
--rg /var/genetics/proj/within_family/within_family_project/processed/ea4/ea4_excl_ukb_str_gs_2020_08_21.sumstats.gz,/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/ea_meta_analysis_amat_dir.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out /var/genetics/proj/within_family/within_family_project/processed/ldsc/metaanalysis_ea4/ea4_dir

python ${ldsc_path}/ldsc.py \
--rg /var/genetics/proj/within_family/within_family_project/processed/ea4/ea4_excl_ukb_str_gs_2020_08_21.sumstats.gz,/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/ea_meta_analysis_amat_avgparental.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out /var/genetics/proj/within_family/within_family_project/processed/ldsc/metaanalysis_ea4/ea4_avgparental


