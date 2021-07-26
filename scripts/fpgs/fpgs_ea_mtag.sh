#!/usr/bin/env bash
within_family_path="/var/genetics/proj/within_family/within_family_project"
snipar_path="/homes/nber/harij/gitrepos/SNIPar"
bedfilepath="/disk/genetics/sibling_consortium/GS20k/alextisyoung/HM3/genotypes/chr_~"
impfilespath="/disk/genetics/sibling_consortium/GS20k/alextisyoung/HM3/imputed_phased/chr_~"


# # format ldpred2 weight files for fpgs
# python ${within_family_path}/scripts/fpgs/format_weights.py \
#     ${within_family_path}/processed/ldpred2/ea_pgi_mtag_dir.wt.txt \
#     --sep " " \
#     --outfileprefix ${within_family_path}/processed/ldpred2/ea_pgi_mtag_dir.wt \
#     --sid-as-chrpos

# python ${within_family_path}/scripts/fpgs/format_weights.py \
#     ${within_family_path}/processed/ldpred2/ea_pgi_mtag_pop.wt.txt \
#     --sep " " \
#     --outfileprefix ${within_family_path}/processed/ldpred2/ea_pgi_mtag_pop.wt \
#     --sid-as-chrpos

# python ${within_family_path}/scripts/fpgs/format_weights.py \
#     ${within_family_path}/processed/ldpred2/ea_pgi_mtag_avgparental.wt.txt \
#     --sep " " \
#     --outfileprefix ${within_family_path}/processed/ldpred2/ea_pgi_mtag_avgparental.wt \
#     --sid-as-chrpos

# python ${within_family_path}/scripts/fpgs/format_weights.py \
#     ${within_family_path}/processed/ldpred2/ea_dir_avgparental_ea4_mtag_dir.wt.txt \
#     --sep " " \
#     --outfileprefix ${within_family_path}/processed/ldpred2/ea_dir_avgparental_ea4_mtag_dir.wt \
#     --sid-as-chrpos

# python ${within_family_path}/scripts/fpgs/format_weights.py \
#     ${within_family_path}/processed/ldpred2/ea4_ref.wt.txt\
#     --sep " " \
#     --outfileprefix ${within_family_path}/processed/ldpred2/ea4_ref.wt \
#     --sid-as-chrpos

python ${within_family_path}/scripts/fpgs/format_weights.py \
    ${within_family_path}/processed/ldpred2/ea_dir_ea4_sldsc_mtag_dir.wt.txt \
    --sep " " \
    --outfileprefix ${within_family_path}/processed/ldpred2/ea_dir_ea4_sldsc_mtag_dir.wt \
    --sid-as-chrpos


# python ${within_family_path}/scripts/fpgs/format_weights.py \
#     ${within_family_path}/processed/ldpred2/ea_dir_avgparental_ea4_mtag_avgparental.wt.txt \
#     --sep " " \
#     --outfileprefix ${within_family_path}/processed/ldpred2/ea_dir_avgparental_ea4_mtag_avgparental.wt \
#     --sid-as-chrpos

# # == Calculate FPGS == #
# # Direct effect 
# python $snipar_path/fPGS.py \
#     $within_family_path/processed/fpgs/ea_dir_avgparental_ea4_mtag_dir \
#     --bedfiles $bedfilepath \
#     --impfiles $impfilespath \
#     --weights $within_family_path/processed/ldpred2/ea_dir_avgparental_ea4_mtag_dir.wt.txt \
#     --scale_pgs

# python $snipar_path/fPGS.py $within_family_path/processed/fpgs/ea_dir_avgparental_ea4_mtag_dir \
#     --pgs $within_family_path/processed/fpgs/ea_dir_avgparental_ea4_mtag_dir.pgs.txt \
#     --phenofile $within_family_path/processed/fpgs/ea.pheno \
#     --pgsreg-r2

# python $snipar_path/fPGS.py \
#     $within_family_path/processed/fpgs/direct_base_mtag_ea \
#     --bedfiles $bedfilepath \
#     --impfiles $impfilespath \
#     --weights $within_family_path/processed/ldpred2/ea_pgi_mtag_dir.wt.txt \
#     --scale_pgs

# python $snipar_path/fPGS.py $within_family_path/processed/fpgs/direct_base_mtag_ea \
#     --pgs $within_family_path/processed/fpgs/direct_base_mtag_ea.pgs.txt \
#     --phenofile $within_family_path/processed/fpgs/ea.pheno \
#     --pgsreg-r2

# # Population effect 
# python $snipar_path/fPGS.py \
#     $within_family_path/processed/fpgs/pop_mtag_ea \
#     --bedfiles $bedfilepath \
#     --impfiles $impfilespath \
#     --weights $within_family_path/processed/ldpred2/ea_pgi_mtag_pop.wt.txt \
#     --scale_pgs

# python $snipar_path/fPGS.py $within_family_path/processed/fpgs/pop_mtag_ea \
#     --pgs $within_family_path/processed/fpgs/pop_mtag_ea.pgs.txt \
#     --phenofile $within_family_path/processed/fpgs/ea.pheno \
#     --pgsreg-r2

# # Average Parental effect 
# python $snipar_path/fPGS.py \
#     $within_family_path/processed/fpgs/avgparental_mtag_ea \
#     --bedfiles $bedfilepath \
#     --impfiles $impfilespath \
#     --weights $within_family_path/processed/ldpred2/ea_dir_avgparental_ea4_mtag_avgparental.wt.txt \
#     --scale_pgs

# python $snipar_path/fPGS.py $within_family_path/processed/fpgs/avgparental_mtag_ea \
#     --pgs $within_family_path/processed/fpgs/avgparental_mtag_ea.pgs.txt \
#     --phenofile $within_family_path/processed/fpgs/ea.pheno \
#     --pgsreg-r2

# Direct effects for proband and average parental effects for parents
# python /var/genetics/proj/within_family/within_family_project/scripts/fpgs/combine_dir_avgpar.py \
#     --direff "$within_family_path/processed/fpgs/direct_base_mtag_ea.pgs.txt" \
#     --avgpar_eff "$within_family_path/processed/fpgs/avgparental_mtag_ea.pgs.txt" \
#     --out_prefix "${within_family_path}/processed/fpgs/dir_avgparental_ea_mtag.pgs"

# python $snipar_path/fPGS.py $within_family_path/processed/fpgs/dir_avgparental_mtag_ea \
#     --pgs ${within_family_path}/processed/fpgs/dir_avgparental_ea_mtag.pgs.txt \
#     --phenofile $within_family_path/processed/fpgs/ea.pheno \
#     --pgsreg-r2

# Baseline EA4 (excluding gs, str and ukb)
# python $snipar_path/fPGS.py \
#     $within_family_path/processed/fpgs/ea4_ref \
#     --bedfiles $bedfilepath \
#     --impfiles $impfilespath \
#     --weights ${within_family_path}/processed/ldpred2/ea4_ref.wt.txt \
#     --scale_pgs

# python $snipar_path/fPGS.py $within_family_path/processed/fpgs/ea4_ref \
#     --pgs $within_family_path/processed/fpgs/ea4_ref.pgs.txt \
#     --phenofile $within_family_path/processed/fpgs/ea.pheno \
#     --pgsreg-r2


# Direct effect (mtagged) + baseline ea4
python ${within_family_path}/scripts/fpgs/combine_2_datasets.py \
    --df1 $within_family_path/processed/fpgs/direct_base_mtag_ea.pgs.txt \
    --df2 $within_family_path/processed/fpgs/ea4_ref.pgs.txt \
    --out_prefix $within_family_path/processed/fpgs/dir_mtag_ea4_ref.pgs

python $snipar_path/fPGS.py $within_family_path/processed/fpgs/dir_mtag_ea4_ref \
    --pgs $within_family_path/processed/fpgs/dir_mtag_ea4_ref.pgs.txt \
    --phenofile $within_family_path/processed/fpgs/ea.pheno \
    --pgsreg-r2


## Direct effects mtagged with EA4 using sldsc var-cov matrix
python $snipar_path/fPGS.py \
    $within_family_path/processed/fpgs/ea_dir_ea4_sldsc_mtag_dir \
    --bedfiles $bedfilepath \
    --impfiles $impfilespath \
    --weights ${within_family_path}/processed/ldpred2/ea_dir_ea4_sldsc_mtag_dir.wt.txt \
    --scale_pgs

python $snipar_path/fPGS.py $within_family_path/processed/fpgs/ea_dir_ea4_sldsc_mtag_dir \
    --pgs $within_family_path/processed/fpgs/ea_dir_ea4_sldsc_mtag_dir.pgs.txt \
    --phenofile $within_family_path/processed/fpgs/ea.pheno \
    --pgsreg-r2

