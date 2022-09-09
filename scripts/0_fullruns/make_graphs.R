library(data.table)
library(dplyr)
library(ggplot2)
library(readxl)
library(stringr)
library(ggpubr)
library(latex2exp)
theme_set(theme_pubr())


reformat_matrix = function(rgmat){


    phenotypes = c()
    direct_rgs = c()
    direct_rg_ses = c()
    pop_rgs = c()
    pop_rg_ses = c()

    for (i in 1:nrow(rgmat)){
        for (j in 2:ncol(rgmat)){

            if (i < j-1) {
                phenotype1 = rgmat[i, "phenotype"] %>% pull
                phenotype2 = names(rgmat)[j]
                phenotype_comb = paste(phenotype1, phenotype2, sep="_")
                phenotypes = c(phenotypes, phenotype_comb)

                direct_rgs_whole = str_split(rgmat[phenotype == phenotype1, phenotype2, with=FALSE], "\\(")
                direct_rgs_whole[[1]][2] = str_replace_all(direct_rgs_whole[[1]][2], "\\)", "")
                direct_rgs = c(direct_rgs, as.numeric(direct_rgs_whole[[1]][1]))
                direct_rg_ses = c(direct_rg_ses, as.numeric(direct_rgs_whole[[1]][2]))

                pop_rgs_whole = str_split(rgmat[phenotype == phenotype2, phenotype1, with=FALSE], "\\(")
                pop_rgs_whole[[1]][2] = str_replace_all(pop_rgs_whole[[1]][2], "\\)", "")
                pop_rgs = c(pop_rgs, as.numeric(pop_rgs_whole[[1]][1]))
                pop_rg_ses = c(pop_rg_ses, as.numeric(pop_rgs_whole[[1]][2]))
            }
        }
    }
    datout = data.table(
        phenotype = phenotypes,
        direct_rg = direct_rgs,
        direct_rg_se = direct_rg_ses,
        pop_rg = pop_rgs,
        pop_rg_se = pop_rg_ses
    )

    return(datout)
}

dat = read_excel(
    "/var/genetics/proj/within_family/within_family_project/processed/package_output/direct_population_rg_matrix.xlsx"
)

setDT(dat)
setnames(dat, names(dat)[1], 'phenotype')
dat = reformat_matrix(dat)

# filter out pairs where direct_rg_se > 0.25
dat = dat %>% filter(!is.na(direct_rg_se) & direct_rg_se < 0.25)

dat[, `:=`(
    direct_rg_lo = direct_rg - 1.96 * direct_rg_se,
    direct_rg_hi = direct_rg + 1.96 * direct_rg_se,
    pop_rg_lo = pop_rg - 1.96 * pop_rg_se,
    pop_rg_hi = pop_rg + 1.96 * pop_rg_se
)]

# graphing
dat %>%
    ggplot() +
    geom_point(aes(pop_rg, direct_rg, color=phenotype), alpha=0.6) +
    # geom_linerange(aes(x=pop_rg, ymin = direct_rg_lo, ymax=direct_rg_hi, color = phenotype), alpha=0.6) +
    # geom_linerange(aes(y=direct_rg, xmin = pop_rg_lo, xmax=pop_rg_hi, color = phenotype), alpha=0.6) +
    geom_abline(intercept=0, slope=1, linetype="solid", color="gray") +
    geom_hline(yintercept=0, linetype="dotted") +
    geom_vline(xintercept=0, linetype="dotted") +
    # geom_text(aes(label = phenotype, x = pop_rg, y = direct_rg), hjust = 0, vjust = 0) +
    ylim(-0.6, 0.6) +
    xlim(-0.6, 0.6) +
    scale_color_viridis_d() +
    labs(y = TeX("Direct $\\textit{r_g}$"), x = TeX("Population $\\textit{r_g}")) +
    guides(color="none")

ggsave("/var/genetics/proj/within_family/within_family_project/processed/package_output/direct_pop_rg.pdf",
height = 7, width = 9)
