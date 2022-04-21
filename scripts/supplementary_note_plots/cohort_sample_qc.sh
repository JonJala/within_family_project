#!/usr/bin/bash

within_family_path="/var/genetics/proj/within_family/within_family_project"
ssgac_path="/homes/nber/harij/ssgac"

# Make QQplots for UKB EA

python ${ssgac_path}/plotting/qqplot.py \
--meta "${within_family_path}/processed/qc/ukb/ea/CLEANED.out.gz" \
--title "" \
--p "PVAL_direct" \
--lambda_xpos 3 --lambda_ypos 5 \
--out "${within_family_path}/doc/exampleplots/ukb_ea_direct.png"

python ${ssgac_path}/plotting/qqplot.py \
--meta "${within_family_path}/processed/qc/ukb/ea/CLEANED.out.gz" \
--title "" \
--p "PVAL_population" \
--lambda_xpos 3 --lambda_ypos 5 \
--out "${within_family_path}/doc/exampleplots/ukb_ea_population.png"

# Make SE-F plot
# hackily use R

# echo "
# library(data.table)
# library(ggplot2)
# library(dplyr)
# library(latex2exp)
# theme_set(theme_bw())

# dat = fread('${within_family_path}/processed/qc/ukb/ea/CLEANED.out.gz')

# dat %>%
#     mutate(normalized_f = sqrt(f * (1-f))) %>%
#     ggplot() +
#     geom_point(aes(normalized_f, se_direct)) +
#     labs(x = TeX('$\\\\sqrt{f (1-f)}$'), y = 'Standard Error of Direct Effects', title = 'SE-F Plot')

# ggsave('/var/genetics/proj/within_family/within_family_project/doc/exampleplots/sefplot_ukb.png', width = 9, height = 6)
# " | R --slave

# # Make UKB rg plot
# python "/var/genetics/proj/within_family/within_family_project/scratch/example_plots/ukb_rg_plot.py"