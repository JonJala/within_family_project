#!/usr/bin/bash
# check rg_dir_pop and rg_dir_avgpar in cohorts

within_family_path="/var/genetics/proj/within_family/within_family_project"
hm3snps="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"

############
# EA
#############
# Rscript /var/genetics/proj/within_family/within_family_project/scripts/package/estimate_marginal_correlations_meta.R \
# --file /var/genetics/proj/within_family/within_family_project/processed/qc/ukb/ea/CLEANED.out.gz \
# --outprefix /var/genetics/proj/within_family/within_family_project/processed/qc/ukb/ea/ \
# --dir_pop_rg_name rg_direct_population --dir_avgpar_rg_name rg_direct_averageparental \
# --dirbeta "theta_direct" --popbeta "theta_population" --avgparbeta "theta_averageparental" \
# --dirse "se_direct" --popse "se_population" --avgparse "se_averageparental" \
# --freq f --chromosome CHR --pos BP \
# --merge_alleles ${hm3snps}
# "r=0.7549 S.E.=0.1022"
# "r=0.3787 S.E.=0.2598"
# hm3
# "r=0.7549 S.E.=0.1022"


# Rscript /var/genetics/proj/within_family/within_family_project/scripts/package/estimate_marginal_correlations_meta.R \
# --file /var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/ea/controls/CLEANED.out.gz \
# --outprefix /var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/ea/controls/ \
# --dir_pop_rg_name rg_direct_population --dir_avgpar_rg_name rg_direct_averageparental \
# --dirbeta "theta_direct" --popbeta "theta_population" --avgparbeta "theta_averageparental" \
# --dirse "se_direct" --popse "se_population" --avgparse "se_averageparental" \
# --freq f --chromosome CHR --pos BP \
# --merge_alleles ${hm3snps}
# # r=0.6675 S.E.=0.0378
# # hm3
# # "r=0.6646 S.E.=0.0381"

# Rscript /var/genetics/proj/within_family/within_family_project/scripts/package/estimate_marginal_correlations_meta.R \
# --file /var/genetics/proj/within_family/within_family_project/processed/qc/lifelines/ea/CLEANED.out.gz \
# --outprefix /var/genetics/proj/within_family/within_family_project/processed/qc/lifelines/ea/ \
# --dir_pop_rg_name rg_direct_population --dir_avgpar_rg_name rg_direct_averageparental \
# --dirbeta "theta_direct" --popbeta "theta_population" --avgparbeta "theta_averageparental" \
# --dirse "se_direct" --popse "se_population" --avgparse "se_averageparental" \
# --freq f --chromosome CHR --pos BP \
# --merge_alleles ${hm3snps}
# "r=0.9259 S.E.=1.5162"
# "r=0.919 S.E.=1.3888"

# Rscript /var/genetics/proj/within_family/within_family_project/scripts/package/estimate_marginal_correlations_meta.R \
# --file /var/genetics/proj/within_family/within_family_project/processed/qc/ft/ea/CLEANED.out.gz \
# --outprefix /var/genetics/proj/within_family/within_family_project/processed/qc/ft/ea/ \
# --dir_pop_rg_name rg_direct_population --dir_avgpar_rg_name rg_direct_averageparental \
# --dirbeta "theta_direct" --popbeta "theta_population" --avgparbeta "theta_averageparental" \
# --dirse "se_direct" --popse "se_population" --avgparse "se_averageparental" \
# --freq f --chromosome CHR --pos BP \
# --merge_alleles ${hm3snps}

# Rscript /var/genetics/proj/within_family/within_family_project/scripts/package/estimate_marginal_correlations_meta.R \
# --file /var/genetics/proj/within_family/within_family_project/processed/qc/geisinger/ea/CLEANED.out.gz \
# --outprefix /var/genetics/proj/within_family/within_family_project/processed/qc/geisinger/ea/ \
# --dir_pop_rg_name rg_direct_population --dir_avgpar_rg_name rg_direct_averageparental \
# --dirbeta "theta_direct" --popbeta "theta_population" --avgparbeta "theta_averageparental" \
# --dirse "se_direct" --popse "se_population" --avgparse "se_averageparental" \
# --freq f --chromosome CHR --pos BP \
# --merge_alleles ${hm3snps}

# Rscript /var/genetics/proj/within_family/within_family_project/scripts/package/estimate_marginal_correlations_meta.R \
# --file /var/genetics/proj/within_family/within_family_project/processed/qc/gs/ea/CLEANED.out.gz \
# --outprefix /var/genetics/proj/within_family/within_family_project/processed/qc/gs/ea/ \
# --dir_pop_rg_name rg_direct_population --dir_avgpar_rg_name rg_direct_averageparental \
# --dirbeta "theta_direct" --popbeta "theta_population" --avgparbeta "theta_averageparental" \
# --dirse "se_direct" --popse "se_population" --avgparse "se_averageparental" \
# --freq f --chromosome CHR --pos BP \
# --merge_alleles ${hm3snps}

# Rscript /var/genetics/proj/within_family/within_family_project/scripts/package/estimate_marginal_correlations_meta.R \
# --file /var/genetics/proj/within_family/within_family_project/processed/qc/hunt/ea/CLEANED.out.gz \
# --outprefix /var/genetics/proj/within_family/within_family_project/processed/qc/hunt/ea/ \
# --dir_pop_rg_name rg_direct_population --dir_avgpar_rg_name rg_direct_averageparental \
# --dirbeta "theta_direct" --popbeta "theta_population" --avgparbeta "theta_averageparental" \
# --dirse "se_direct" --popse "se_population" --avgparse "se_averageparental" \
# --freq f --chromosome CHR --pos BP \
# --merge_alleles ${hm3snps}

# Rscript /var/genetics/proj/within_family/within_family_project/scripts/package/estimate_marginal_correlations_meta.R \
# --file /var/genetics/proj/within_family/within_family_project/processed/qc/minn_twins/ea/CLEANED.out.gz \
# --outprefix /var/genetics/proj/within_family/within_family_project/processed/qc/minn_twins/ea/ \
# --dir_pop_rg_name rg_direct_population --dir_avgpar_rg_name rg_direct_averageparental \
# --dirbeta "theta_direct" --popbeta "theta_population" --avgparbeta "theta_averageparental" \
# --dirse "se_direct" --popse "se_population" --avgparse "se_averageparental" \
# --freq f --chromosome CHR --pos BP \
# --merge_alleles ${hm3snps}


# Rscript /var/genetics/proj/within_family/within_family_project/scripts/package/estimate_marginal_correlations_meta.R \
# --file /var/genetics/proj/within_family/within_family_project/processed/qc/moba/ea/CLEANED.out.gz \
# --outprefix /var/genetics/proj/within_family/within_family_project/processed/qc/moba/ea/ \
# --dir_pop_rg_name rg_direct_population --dir_avgpar_rg_name rg_direct_averageparental \
# --dirbeta "theta_direct" --popbeta "theta_population" --avgparbeta "theta_averageparental" \
# --dirse "se_direct" --popse "se_population" --avgparse "se_averageparental" \
# --freq f --chromosome CHR --pos BP \
# --merge_alleles ${hm3snps}


# Rscript /var/genetics/proj/within_family/within_family_project/scripts/package/estimate_marginal_correlations_meta.R \
# --file /var/genetics/proj/within_family/within_family_project/processed/qc/str/ea/CLEANED.out.gz \
# --outprefix /var/genetics/proj/within_family/within_family_project/processed/qc/str/ea/ \
# --dir_pop_rg_name rg_direct_population --dir_avgpar_rg_name rg_direct_averageparental \
# --dirbeta "theta_direct" --popbeta "theta_population" --avgparbeta "theta_averageparental" \
# --dirse "se_direct" --popse "se_population" --avgparse "se_averageparental" \
# --freq f --chromosome CHR --pos BP \
# --merge_alleles ${hm3snps}


############
# BMI
#############
# Rscript /var/genetics/proj/within_family/within_family_project/scripts/package/estimate_marginal_correlations_meta.R \
# --file /var/genetics/proj/within_family/within_family_project/processed/qc/ukb/bmi/CLEANED.out.gz \
# --outprefix /var/genetics/proj/within_family/within_family_project/processed/qc/ukb/bmi/ \
# --dir_pop_rg_name rg_direct_population --dir_avgpar_rg_name rg_direct_averageparental \
# --dirbeta "theta_direct" --popbeta "theta_population" --avgparbeta "theta_averageparental" \
# --dirse "se_direct" --popse "se_population" --avgparse "se_averageparental" \
# --freq f --chromosome CHR --pos BP \
# --merge_alleles ${hm3snps}
# "r=0.9274 S.E.=0.0363"
# hm3
# "r=0.9274 S.E.=0.0363"

# Rscript /var/genetics/proj/within_family/within_family_project/scripts/package/estimate_marginal_correlations_meta.R \
# --file /var/genetics/proj/within_family/within_family_project/processed/qc/lifelines/bmi/CLEANED.out.gz \
# --outprefix /var/genetics/proj/within_family/within_family_project/processed/qc/lifelines/bmi/ \
# --dir_pop_rg_name rg_direct_population --dir_avgpar_rg_name rg_direct_averageparental \
# --dirbeta "theta_direct" --popbeta "theta_population" --avgparbeta "theta_averageparental" \
# --dirse "se_direct" --popse "se_population" --avgparse "se_averageparental" \
# --freq f --chromosome CHR --pos BP \
# --merge_alleles ${hm3snps}
# "r=0.9506 S.E.=0.0772"
# hm3
# "r=0.9508 S.E.=0.0779"


Rscript /var/genetics/proj/within_family/within_family_project/scripts/package/estimate_marginal_correlations_meta.R \
--file /var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/bmi/CLEANED.out.gz \
--outprefix /var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/bmi/ \
--dir_pop_rg_name rg_direct_population --dir_avgpar_rg_name rg_direct_averageparental \
--dirbeta "theta_direct" --popbeta "theta_population" --avgparbeta "theta_averageparental" \
--dirse "se_direct" --popse "se_population" --avgparse "se_averageparental" \
--freq f --chromosome CHR --pos BP \
--merge_alleles ${hm3snps}
# r=0.8811 S.E.=0.0309
# "r=0.0155 S.E.=0.1258"
# hm3
# "r=0.6845 S.E.=0.0185"

Rscript /var/genetics/proj/within_family/within_family_project/scripts/package/estimate_marginal_correlations_meta.R \
--file /var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/bmi/controls/CLEANED.out.gz \
--outprefix /var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/bmi/controls/ \
--dir_pop_rg_name rg_direct_population --dir_avgpar_rg_name rg_direct_averageparental \
--dirbeta "theta_direct" --popbeta "theta_population" --avgparbeta "theta_averageparental" \
--dirse "se_direct" --popse "se_population" --avgparse "se_averageparental" \
--freq f --chromosome CHR --pos BP \
--merge_alleles ${hm3snps}
# hm3 "r=0.8793 S.E.=0.0196"

# Rscript /var/genetics/proj/within_family/within_family_project/scripts/package/estimate_marginal_correlations_meta.R \
# --file /var/genetics/proj/within_family/within_family_project/processed/qc/geisinger/bmi/CLEANED.out.gz \
# --outprefix /var/genetics/proj/within_family/within_family_project/processed/qc/geisinger/bmi/ \
# --dir_pop_rg_name rg_direct_population --dir_avgpar_rg_name rg_direct_averageparental \
# --dirbeta "theta_direct" --popbeta "theta_population" --avgparbeta "theta_averageparental" \
# --dirse "se_direct" --popse "se_population" --avgparse "se_averageparental" \
# --freq f --chromosome CHR --pos BP \
# --merge_alleles ${hm3snps}
# r=0.8329
# hm3
# "r=0.8344 S.E.=0.0304"




# Rscript /var/genetics/proj/within_family/within_family_project/scripts/package/estimate_marginal_correlations_meta.R \
# --file /var/genetics/proj/within_family/within_family_project/processed/qc/gs/bmi/CLEANED.out.gz \
# --outprefix /var/genetics/proj/within_family/within_family_project/processed/qc/gs/bmi \
# --dir_pop_rg_name rg_direct_population --dir_avgpar_rg_name rg_direct_averageparental \
# --dirbeta "theta_direct" --popbeta "theta_population" --avgparbeta "theta_averageparental" \
# --dirse "se_direct" --popse "se_population" --avgparse "se_averageparental" \
# --freq f --chromosome CHR --pos BP \
# --merge_alleles ${hm3snps}
# # "r=0.914 S.E.=0.0793"
# hm3
#  "r=0.914 S.E.=0.0793"


# Rscript /var/genetics/proj/within_family/within_family_project/scripts/package/estimate_marginal_correlations_meta.R \
# --file /var/genetics/proj/within_family/within_family_project/processed/qc/moba/bmi/CLEANED.out.gz \
# --outprefix /var/genetics/proj/within_family/within_family_project/processed/qc/moba/bmi/ \
# --dir_pop_rg_name rg_direct_population --dir_avgpar_rg_name rg_direct_averageparental \
# --dirbeta "theta_direct" --popbeta "theta_population" --avgparbeta "theta_averageparental" \
# --dirse "se_direct" --popse "se_population" --avgparse "se_averageparental" \
# --freq f --chromosome CHR --pos BP \
# --merge_alleles ${hm3snps}
# # "r=0.827 S.E.=0.0341"
# hm3
#  "r=0.8287 S.E.=0.0326"


# Rscript /var/genetics/proj/within_family/within_family_project/scripts/package/estimate_marginal_correlations_meta.R \
# --file /var/genetics/proj/within_family/within_family_project/processed/qc/ft/bmi/CLEANED.out.gz \
# --outprefix /var/genetics/proj/within_family/within_family_project/processed/qc/ft/bmi \
# --dir_pop_rg_name rg_direct_population --dir_avgpar_rg_name rg_direct_averageparental \
# --dirbeta "theta_direct" --popbeta "theta_population" --avgparbeta "theta_averageparental" \
# --dirse "se_direct" --popse "se_population" --avgparse "se_averageparental" \
# --freq f --chromosome CHR --pos BP \
# --merge_alleles ${hm3snps}
# "r=1.0277 S.E.=0.226"
# hm3
# "r=1.0289 S.E.=0.2155"

############
# Height
#############

# Rscript /var/genetics/proj/within_family/within_family_project/scripts/package/estimate_marginal_correlations_meta.R \
# --file /var/genetics/proj/within_family/within_family_project/processed/qc/ukb/height/CLEANED.out.gz \
# --outprefix /var/genetics/proj/within_family/within_family_project/processed/qc/ukb/height/ \
# --dir_pop_rg_name rg_direct_population --dir_avgpar_rg_name rg_direct_averageparental \
# --dirbeta "theta_direct" --popbeta "theta_population" --avgparbeta "theta_averageparental" \
# --dirse "se_direct" --popse "se_population" --avgparse "se_averageparental" \
# --freq f --chromosome CHR --pos BP \
# --merge_alleles ${hm3snps}
# # # r=0.9861 S.E.=0.0194"
# # hm3
# # "r=0.9861 S.E.=0.0194"

# Rscript /var/genetics/proj/within_family/within_family_project/scripts/package/estimate_marginal_correlations_meta.R \
# --file /var/genetics/proj/within_family/within_family_project/processed/qc/lifelines/height/CLEANED.out.gz \
# --outprefix /var/genetics/proj/within_family/within_family_project/processed/qc/lifelines/height/ \
# --dir_pop_rg_name rg_direct_population --dir_avgpar_rg_name rg_direct_averageparental \
# --dirbeta "theta_direct" --popbeta "theta_population" --avgparbeta "theta_averageparental" \
# --dirse "se_direct" --popse "se_population" --avgparse "se_averageparental" \
# --freq f --chromosome CHR --pos BP \
# --merge_alleles ${hm3snps}
# # # "r=0.8601 S.E.=0.0679"
# # hm3
# #  "r=0.8616 S.E.=0.0667"


# Rscript /var/genetics/proj/within_family/within_family_project/scripts/package/estimate_marginal_correlations_meta.R \
# --file /var/genetics/proj/within_family/within_family_project/processed/qc/hunt/height/CLEANED.out.gz \
# --outprefix /var/genetics/proj/within_family/within_family_project/processed/qc/hunt/height/ \
# --dir_pop_rg_name rg_direct_population --dir_avgpar_rg_name rg_direct_averageparental \
# --dirbeta "theta_direct" --popbeta "theta_population" --avgparbeta "theta_averageparental" \
# --dirse "se_direct" --popse "se_population" --avgparse "se_averageparental" \
# --freq f --chromosome CHR --pos BP \
# --merge_alleles ${hm3snps}
# # "r=0.7891 S.E.=0.0096"
# # hm3
# # "r=0.7892 S.E.=0.0098"


# Rscript /var/genetics/proj/within_family/within_family_project/scripts/package/estimate_marginal_correlations_meta.R \
# --file /var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/height/controls/CLEANED.out.gz \
# --outprefix /var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/height/controls/ \
# --dir_pop_rg_name rg_direct_population --dir_avgpar_rg_name rg_direct_averageparental \
# --dirbeta "theta_direct" --popbeta "theta_population" --avgparbeta "theta_averageparental" \
# --dirse "se_direct" --popse "se_population" --avgparse "se_averageparental" \
# --freq f --chromosome CHR --pos BP \
# --merge_alleles ${hm3snps}

# Rscript /var/genetics/proj/within_family/within_family_project/scripts/package/estimate_marginal_correlations_meta.R \
# --file /var/genetics/proj/within_family/within_family_project/processed/qc/ft/height/CLEANED.out.gz \
# --outprefix /var/genetics/proj/within_family/within_family_project/processed/qc/ft/height/ \
# --dir_pop_rg_name rg_direct_population --dir_avgpar_rg_name rg_direct_averageparental \
# --dirbeta "theta_direct" --popbeta "theta_population" --avgparbeta "theta_averageparental" \
# --dirse "se_direct" --popse "se_population" --avgparse "se_averageparental" \
# --freq f --chromosome CHR --pos BP \
# --merge_alleles ${hm3snps}

# Rscript /var/genetics/proj/within_family/within_family_project/scripts/package/estimate_marginal_correlations_meta.R \
# --file /var/genetics/proj/within_family/within_family_project/processed/qc/geisinger/height/CLEANED.out.gz \
# --outprefix /var/genetics/proj/within_family/within_family_project/processed/qc/geisinger/height/ \
# --dir_pop_rg_name rg_direct_population --dir_avgpar_rg_name rg_direct_averageparental \
# --dirbeta "theta_direct" --popbeta "theta_population" --avgparbeta "theta_averageparental" \
# --dirse "se_direct" --popse "se_population" --avgparse "se_averageparental" \
# --freq f --chromosome CHR --pos BP \
# --merge_alleles ${hm3snps}

# Rscript /var/genetics/proj/within_family/within_family_project/scripts/package/estimate_marginal_correlations_meta.R \
# --file /var/genetics/proj/within_family/within_family_project/processed/qc/gs/height/CLEANED.out.gz \
# --outprefix /var/genetics/proj/within_family/within_family_project/processed/qc/gs/height/ \
# --dir_pop_rg_name rg_direct_population --dir_avgpar_rg_name rg_direct_averageparental \
# --dirbeta "theta_direct" --popbeta "theta_population" --avgparbeta "theta_averageparental" \
# --dirse "se_direct" --popse "se_population" --avgparse "se_averageparental" \
# --freq f --chromosome CHR --pos BP \
# --merge_alleles ${hm3snps}

# Rscript /var/genetics/proj/within_family/within_family_project/scripts/package/estimate_marginal_correlations_meta.R \
# --file /var/genetics/proj/within_family/within_family_project/processed/qc/minn_twins/height/CLEANED.out.gz \
# --outprefix /var/genetics/proj/within_family/within_family_project/processed/qc/minn_twins/height/ \
# --dir_pop_rg_name rg_direct_population --dir_avgpar_rg_name rg_direct_averageparental \
# --dirbeta "theta_direct" --popbeta "theta_population" --avgparbeta "theta_averageparental" \
# --dirse "se_direct" --popse "se_population" --avgparse "se_averageparental" \
# --freq f --chromosome CHR --pos BP \
# --merge_alleles ${hm3snps}

# Rscript /var/genetics/proj/within_family/within_family_project/scripts/package/estimate_marginal_correlations_meta.R \
# --file /var/genetics/proj/within_family/within_family_project/processed/qc/moba/height/CLEANED.out.gz \
# --outprefix /var/genetics/proj/within_family/within_family_project/processed/qc/moba/height/ \
# --dir_pop_rg_name rg_direct_population --dir_avgpar_rg_name rg_direct_averageparental \
# --dirbeta "theta_direct" --popbeta "theta_population" --avgparbeta "theta_averageparental" \
# --dirse "se_direct" --popse "se_population" --avgparse "se_averageparental" \
# --freq f --chromosome CHR --pos BP \
# --merge_alleles ${hm3snps}



# Rscript /var/genetics/proj/within_family/within_family_project/scripts/package/estimate_marginal_correlations_meta.R \
# --file /var/genetics/proj/within_family/within_family_project/processed/qc/str/height/CLEANED.out.gz \
# --outprefix /var/genetics/proj/within_family/within_family_project/processed/qc/str/height/ \
# --dir_pop_rg_name rg_direct_population --dir_avgpar_rg_name rg_direct_averageparental \
# --dirbeta "theta_direct" --popbeta "theta_population" --avgparbeta "theta_averageparental" \
# --dirse "se_direct" --popse "se_population" --avgparse "se_averageparental" \
# --freq f --chromosome CHR --pos BP \
# --merge_alleles ${hm3snps}