#!/usr/bin/bash

sniparpath="/homes/nber/harij/gitrepos/SNIPar"
within_family_path="/homes/nber/harij/within_family"
ldscpath="/homes/nber/harij/ldsc"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
merge_alleles="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"
cohorts=(str hunt gen_scotland finn_twin estonian_biobank)


# == Running SNIPAR estimator == #

# == STR == #
# echo "Estimating BMI for: ${cohorts[0]}. Which is already direct + avg_parental"
# echo "Not converting estimates - i.e keeping it as Direct + Average Parental"
# python ${sniparpath}/ldsc_reg/run_estimates.py \
# "/var/genetics/data/${cohorts[0]}/public/latest/raw/sumstats/fgwas/bmi/bmi_chr*.hdf5" \
# -ldsc "${eur_w_ld_chr}/*[0-9].l2.ldscore.gz" \
# -l "/var/genetics/data/${cohorts[0]}/public/latest/raw/sumstats/fgwas/bmi/bmi_snipar_avgparental.log" \
# -e "full" \
# -maf 1 
# x: array([ 1.00000000e-06,  1.27607400e-02, -8.43500007e-01])

# echo "Converting estimates to direct + population"
# python ${sniparpath}/ldsc_reg/run_estimates.py \
# "/var/genetics/data/${cohorts[0]}/public/latest/raw/sumstats/fgwas/bmi/bmi_chr*.hdf5" \
# -ldsc "${eur_w_ld_chr}/*[0-9].l2.ldscore.gz" \
# -l "/var/genetics/data/${cohorts[0]}/public/latest/raw/sumstats/fgwas/bmi/bmi_snipar_pop.log" \
# -e "avgparental_to_population" \
# -maf 1 
# x: array([0.00094371, 0.01590708, 0.87386424])

# echo "Estimating eduYears for: ${cohorts[0]}. Which is already direct + avg_parental"
# echo "Not converting estimates - i.e keeping it as Direct + Average Parental"
# python ${sniparpath}/ldsc_reg/run_estimates.py \
# "/var/genetics/data/${cohorts[0]}/public/latest/raw/sumstats/fgwas/eduYears/eduYears_chr*.hdf5" \
# -ldsc "${eur_w_ld_chr}/*[0-9].l2.ldscore.gz" \
# -l "/var/genetics/data/${cohorts[0]}/public/latest/raw/sumstats/fgwas/eduYears/eduYears_snipar_avgparental.log" \
# -e "full" \
# -maf 1 
# x: array([ 1.00000000e-06,  3.16225477e-02, -7.77461570e-01])

# echo "Converting estimates to direct + population"
# python ${sniparpath}/ldsc_reg/run_estimates.py \
# "/var/genetics/data/${cohorts[0]}/public/latest/raw/sumstats/fgwas/eduYears/eduYears_chr*.hdf5" \
# -ldsc "${eur_w_ld_chr}/*[0-9].l2.ldscore.gz" \
# -l "/var/genetics/data/${cohorts[0]}/public/latest/raw/sumstats/fgwas/eduYears/eduYears_snipar_pop.log" \
# -e "avgparental_to_population" \
# -maf 1 
# x: array([0.00215927, 0.03854842, 0.84928004])

# == HUNT == #
# BIm files dont all have all rsids so matching using BPIDs
# echo "Converting estimates to direct + avg par"
# python ${sniparpath}/ldsc_reg/run_estimates.py \
# "/var/genetics/data/${cohorts[1]}/public/latest/raw/sumstats/fgwas/ea/Eduhunt_results_chr*.hdf5" \
# -ldsc "${eur_w_ld_chr}/*[0-9].l2.ldscore.gz" \
# -l "/var/genetics/data/${cohorts[1]}/public/latest/raw/sumstats/fgwas/ea/Eduhunt_snipar_avgparental.log" \
# -e "direct_plus_averageparental" \
# -Nname N -bim_bp 2 -bim_a1 3 -bim_a2 4 \
# --rsid_readfrombim "/var/genetics/data/${cohorts[1]}/public/latest/raw/sumstats/fgwas/ea/Eduhunt_results_chr*.bim,2,1, " \
# -maf 1 
#  x: array([ 0.16299682,  0.55486579, -0.0334146 ])

# echo "Converting estimates to direct + avg par - using BPs"
# python ${sniparpath}/ldsc_reg/run_estimates.py \
# "/var/genetics/data/${cohorts[1]}/public/latest/raw/sumstats/fgwas/ea/Eduhunt_results_chr*.hdf5" \
# -ldsc "${eur_w_ld_chr}/*[0-9].l2.ldscore.gz" \
# -l "/var/genetics/data/${cohorts[1]}/public/latest/raw/sumstats/fgwas/ea/Eduhunt_snipar_avgparental_bps.log" \
# -e "direct_plus_averageparental" \
# -N N -bim_bp 2 -bim_a1 3 -bim_a2 4 \
# -maf 1 
# x: array([ 0.17450543,  0.60752195, -0.03813116])


# echo "Converting estimates to direct + population"
# python ${sniparpath}/ldsc_reg/run_estimates.py \
# "/var/genetics/data/${cohorts[1]}/public/latest/raw/sumstats/fgwas/ea/Eduhunt_results_chr*.hdf5" \
# -ldsc "${eur_w_ld_chr}/*[0-9].l2.ldscore.gz" \
# -l "/var/genetics/data/${cohorts[1]}/public/latest/raw/sumstats/fgwas/ea/Eduhunt_snipar_pop.log" \
# -e "direct_plus_population" \
# -N N -bim_bp 2 -bim_a1 3 -bim_a2 4 \
# --rsid_readfrombim "/var/genetics/data/${cohorts[1]}/public/latest/raw/sumstats/fgwas/ea/Eduhunt_results_chr*.bim,2,1, " \
# -maf 1 
# x: array([0.16298903, 0.6977662 , 0.45353668])

# echo "Converting estimates to direct + population - using BPs"
# python ${sniparpath}/ldsc_reg/run_estimates.py \
# "/var/genetics/data/${cohorts[1]}/public/latest/raw/sumstats/fgwas/ea/Eduhunt_results_chr*.hdf5" \
# -ldsc "${eur_w_ld_chr}/*[0-9].l2.ldscore.gz" \
# -l "/var/genetics/data/${cohorts[1]}/public/latest/raw/sumstats/fgwas/ea/Eduhunt_snipar_pop_bps.log" \
# -e "direct_plus_population" \
# -N N -bim_bp 2 -bim_a1 3 -bim_a2 4 \
# -maf 1 
# x: array([0.17463408, 0.7572781 , 0.44597232])

# == Generation Scotland == #
# echo "run for direct + average parental effects"
# for dir in /var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/[0-9]*/
# do
#     traitno=$(echo ${dir:54:3} | tr -dc '0-9')
#     echo $traitno 
#     echo $dir
#     python ${sniparpath}/ldsc_reg/run_estimates.py "$dir/chr_*chr_clean.hdf5" \
#         -ldsc "/disk/genetics4/ukb/alextisyoung/GS20k_sumstats/ldscores/*[0-9].l2.ldscore.gz" \
#         -l "$dir/snipar_avgparental.log" \
#         -e "direct_plus_averageparental" \
#         -N N -bim_bp 2 -bim_a1 3 -bim_a2 4 \
#         --rsid_readfrombim "/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/SNPs/chr_*_rsids.txt,3,1, " \
#         -maf 1

#     python ${sniparpath}/ldsc_reg/run_estimates.py "$dir/chr_*chr_clean.hdf5" \
#         -ldsc "/disk/genetics4/ukb/alextisyoung/GS20k_sumstats/ldscores/*[0-9].l2.ldscore.gz" \
#         -l "$dir/snipar_pop.log" \
#         -e "direct_plus_population" \
#         -N N -bim_bp 2 -bim_a1 3 -bim_a2 4 \
#         --rsid_readfrombim "/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/SNPs/chr_*_rsids.txt,3,1, " \
#         -maf 1
# done
# EA (10) avg parental x: array([0.10463673, 1.00433384, 0.63285095])
# EA (10) pop: x: array([0.10394749, 1.5194291 , 0.77821312])
# BMi (6) avg parental: : array([6.55312002, 6.13142661, 0.59913399])
# BMI (6) pop: x: array([ 6.55278057, 20.28081261,  0.89788982])
# BMI probably isnt standardized


# == Finnish Twins == #
# echo "Converting estimates to direct + population"
# python ${sniparpath}/ldsc_reg/run_estimates.py \
# "/var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/EA.chr*.hdf5" \
# -ldsc "${eur_w_ld_chr}/*[0-9].l2.ldscore.gz" \
# -l "/var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/EA_avgparental.log" \
# -e "full" \
# -N N -bim_bp 2 -bim_a1 3 -bim_a2 4 \
# -maf 1 
# x: array([0.14810845, 1.03902293, 0.64007968])

# python ${sniparpath}/ldsc_reg/run_estimates.py \
# "/var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/EA.chr*.hdf5" \
# -ldsc "${eur_w_ld_chr}/*[0-9].l2.ldscore.gz" \
# -l "/var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/EA_pop.log" \
# -e "avgparental_to_population" \
# -N N -bim_bp 2 -bim_a1 3 -bim_a2 4 \
# -maf 1 
# x: array([0.13580569, 1.69037535, 0.81297797])

# echo "Converting estimates to direct + population"
# python ${sniparpath}/ldsc_reg/run_estimates.py \
# "/var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/BMI.chr*.hdf5" \
# -ldsc "${eur_w_ld_chr}/*[0-9].l2.ldscore.gz" \
# -l "/var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/BMI_avgparental.log" \
# -e "full" \
# -N N -bim_bp 2 -bim_a1 3 -bim_a2 4 \
# -maf 1 
# x: array([ 2.81894141,  0.39585035, -0.16894924])

# python ${sniparpath}/ldsc_reg/run_estimates.py \
# "/var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/BMI.chr*.hdf5" \
# -ldsc "${eur_w_ld_chr}/*[0-9].l2.ldscore.gz" \
# -l "/var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/BMI_pop.log" \
# -e "avgparental_to_population" \
# -N N -bim_bp 2 -bim_a1 3 -bim_a2 4 \
# -maf 1 
# x: array([2.81692874, 2.85901688, 0.9307031 ])


# == Estonian Bioback == #
# python ${sniparpath}/ldsc_reg/run_estimates.py \
# "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/bmi/BMI_chr*_results.hdf5" \
# -ldsc "${eur_w_ld_chr}/*[0-9].l2.ldscore.gz" \
# -l "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/bmi_snipar_avgparental.log" \
# -e "direct_plus_averageparental" \
# -N N -bim_bp 2 -bim_a1 3 -bim_a2 4 \
# -maf 1
# x: array([ 0.91632764,  0.22126374, -0.02531346])

# python ${sniparpath}/ldsc_reg/run_estimates.py \
# "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/bmi/BMI_chr*_results.hdf5" \
# -ldsc "${eur_w_ld_chr}/*[0-9].l2.ldscore.gz" \
# -l "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/bmi_snipar_pop.log" \
# -e "direct_plus_population" \
# -N N -bim_bp 2 -bim_a1 3 -bim_a2 4 \
# -maf 1 
# x: array([0.95017501, 0.5082639 , 1.        ])

# == UKB == #
# 13 = bmi
# python ${sniparpath}/ldsc_reg/run_estimates.py \
# "/var/genetics/data/ukb/public/latest/raw/sumstats/fgwas/13/chr_*.sumstats.hdf5" \
# -ldsc "${eur_w_ld_chr}/*[0-9].l2.ldscore.gz" \
# -l "/var/genetics/data/ukb/public/latest/raw/sumstats/fgwas/13/snipar_bmi_avgparental.log" \
# -e "direct_plus_averageparental" \
# -bim_rsid 1 -bim_bp 2 -bim_a1 3 -bim_a2 4 \
# -maf 1
# # x: array([0.21739314, 0.0372846 , 0.00706374])

# python ${sniparpath}/ldsc_reg/run_estimates.py \
# "/var/genetics/data/ukb/public/latest/raw/sumstats/fgwas/13/chr_*.sumstats.hdf5" \
# -ldsc "${eur_w_ld_chr}/*[0-9].l2.ldscore.gz" \
# -l "/var/genetics/data/ukb/public/latest/raw/sumstats/fgwas/13/snipar_bmi_pop.log" \
# -e "direct_plus_population" \
# -bim_rsid 1 -bim_bp 2 -bim_a1 3 -bim_a2 4 \
# -maf 1
# # array([0.21739542, 0.25594159, 0.92430632])


# # 21 = ea
# python ${sniparpath}/ldsc_reg/run_estimates.py \
# "/var/genetics/data/ukb/public/latest/raw/sumstats/fgwas/21/chr_*.sumstats.hdf5" \
# -ldsc "${eur_w_ld_chr}/*[0-9].l2.ldscore.gz" \
# -l "/var/genetics/data/ukb/public/latest/raw/sumstats/fgwas/21/snipar_ea_avgparental.log" \
# -e "direct_plus_averageparental" \
# -bim_rsid 1 -bim_bp 2 -bim_a1 3 -bim_a2 4 \
# -maf 1
# # x: array([1.58614413, 3.36186749, 0.41335096])

# python ${sniparpath}/ldsc_reg/run_estimates.py \
# "/var/genetics/data/ukb/public/latest/raw/sumstats/fgwas/21/chr_*.sumstats.hdf5" \
# -ldsc "${eur_w_ld_chr}/*[0-9].l2.ldscore.gz" \
# -l "/var/genetics/data/ukb/public/latest/raw/sumstats/fgwas/21/snipar_ea_pop.log" \
# -e "direct_plus_population" \
# -bim_rsid 1 -bim_bp 2 -bim_a1 3 -bim_a2 4 \
# -maf 1
# x: array([1.58608322, 6.85733895, 0.77059096])


# Estonian Biobank depression
python ${sniparpath}/ldsc_reg/run_estimates.py \
"/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/mdd/MDD_chr*_results.sumstats.hdf5" \
-ldsc "${eur_w_ld_chr}/*[0-9].l2.ldscore.gz" \
-e "direct_plus_population" \
-bim_bp 2 -bim_a1 3 -bim_a2 4 \
-maf 1
