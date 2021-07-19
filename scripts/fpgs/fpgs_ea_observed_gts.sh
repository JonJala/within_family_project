#!/usr/bin/env bash
within_family_path="/var/genetics/proj/within_family/within_family_project"
snipar_path="/homes/nber/harij/gitrepos/SNIPar"
bedfilepath="/disk/genetics/sibling_consortium/GS20k/alextisyoung/HM3/genotypes/chr_~"
impfilespath="/disk/genetics/sibling_consortium/GS20k/alextisyoung/HM3/imputed_phased/chr_~"


############################################################
# Only obs with observed (not imputed) parental genotypes
# Not working currently
############################################################

# == Calculate PGIs == #
# Direct effects
python $snipar_path/fPGS.py \
    $within_family_path/processed/fpgs/direct_ea_obspar \
    --bedfiles $within_family_path/processed/fpgs/observed_gts_gs/chr_~ \
    --impfiles $impfilespath \
    --weights $within_family_path/processed/ldpred2/ea_pgi_dir.wt.txt \
    --scale_pgs

python $snipar_path/fPGS.py $within_family_path/processed/fpgs/direct_ea_obspar \
    --pgs $within_family_path/processed/fpgs/direct_ea_obspar.pgs.txt \
    --phenofile $within_family_path/processed/fpgs/ea.pheno \
    --pgsreg-r2


# # Population Effects
# python $snipar_path/fPGS.py \
#     $within_family_path/processed/fpgs/pop_ea_obspar \
#     --bedfiles $within_family_path/processed/fpgs/observed_gts_gs/chr_~  \
#     --impfiles $impfilespath \
#     --weights $within_family_path/processed/ldpred2/ea_pgi_pop.wt.txt \
#     --scale_pgs

# python $snipar_path/fPGS.py $within_family_path/processed/fpgs/pop_ea_obspar \
#     --pgs $within_family_path/processed/fpgs/pop_ea_obspar.pgs.txt \
#     --phenofile $within_family_path/processed/fpgs/ea.pheno \
#     --scale_pgs \
#     --pgsreg-r2
