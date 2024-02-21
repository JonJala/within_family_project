library(data.table)
library(dplyr)
library(ggplot2)
library(readxl)
library(stringr)
library(ggpubr)
library(latex2exp)
library(ggrepel)
library(RColorBrewer)
theme_set(theme_pubr())

## --------------------------------------------------------------------------------
## function to format rg matrix
## --------------------------------------------------------------------------------

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

## --------------------------------------------------------------------------------
## read in and process data
## --------------------------------------------------------------------------------

# get all pheno pairings
all_phenos = c('aafb', 'adhd', 'agemenarche', 'asthma', 'aud', 'bmi', 'bpd', 'bps', 'cannabis', 'cognition', 'copd', 'cpd', 'depression',
                 'depsymp', 'dpw', 'ea', 'eczema', 'eversmoker', 'extraversion', 'fev', 'hayfever', 'hdl', 'health', 'height', 'hhincome', 'hypertension', 'income', 
                 'migraine', 'morningperson', 'nchildren', 'nearsight', 'neuroticism', 'nonhdl', 'swb')
phenos = c()
for (pheno1 in all_phenos) {
    for (pheno2 in all_phenos) {
        phenos = append(phenos, paste0(pheno1, "_", pheno2))
    }
}

# function to process data
process_data <- function(phenos, filter_pheno = NA) {
    dat = read_excel(
    "/var/genetics/proj/within_family/within_family_project/processed/package_output/direct_population_rg_matrix.xlsx"
    )
    setDT(dat)
    dat <- cbind(names(dat), dat)
    setnames(dat, names(dat)[1], 'phenotype')
    dat = reformat_matrix(dat)
    if (!is.na(filter_pheno)) {
        phenos <- phenos[grepl(paste0(filter_pheno,"_|_",filter_pheno), phenos)]
    }
    # filter out pairs where direct_rg_se > 0.25
    dat = dat %>% 
        filter(!is.na(direct_rg_se) & direct_rg_se < 0.25 & phenotype %in% phenos)
    # +- 1 SE bounds
    dat[, `:=`(
        direct_rg_lo = direct_rg - direct_rg_se,
        direct_rg_hi = direct_rg + direct_rg_se,
        pop_rg_lo = pop_rg - pop_rg_se,
        pop_rg_hi = pop_rg + pop_rg_se
    )]
    return(dat)
}

## --------------------------------------------------------------------------------
## create scatterplot
## --------------------------------------------------------------------------------

create_scatterplot <- function(phenos, palette = NA, save = TRUE, save_suffix = NA, filter_pheno = NA) {

    # process data
    dat = process_data(phenos, filter_pheno = filter_pheno)

    # get colour palette
    if (is.na(palette)) {
        set.seed(23)
        n <- length(unique(dat$phenotype))
        if (n < 29) {
            palette <- c("#E93993", "#CCEBDE", "#B2BFDC", "#C46627", "#10258A", "#E73B3C", "#DDDDDD",
                        "#FF8F1F", "#FCD3E6", "#B9E07A", "#A3F6FF", "#FFFF69", "#47AA42", "#A0DBD0",
                        "#5791C2", "#E9B82D", "#FC9284", "#7850A4", "#CEB8D7", "#FDC998", "#ADADAD",
                        "#00441B", "#028189", "#67001F", "#525252", "#FE69FC", "#A0D99B", "#4B1DB7")
        } else {
            palette1 <- c("#E93993", "#CCEBDE", "#B2BFDC", "#C46627", "#10258A", "#E73B3C", "#DDDDDD",
                            "#FF8F1F", "#FCD3E6", "#B9E07A", "#A3F6FF", "#FFFF69", "#47AA42", "#A0DBD0",
                            "#5791C2", "#E9B82D", "#FC9284", "#7850A4", "#CEB8D7", "#FDC998", "#ADADAD",
                            "#00441B", "#028189", "#67001F", "#525252", "#FE69FC", "#A0D99B", "#4B1DB7")
            qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
            col_vector = unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))
            palette2 <- sample(col_vector, n-length(palette1), replace = F)
            palette <- c(palette1, palette2)
        }
    }

    # plot
    dat %>%
        ggplot() +
        geom_point(aes(pop_rg, direct_rg, colour=phenotype, shape=phenotype), alpha=0.6) +
        geom_linerange(aes(x=pop_rg, ymin = direct_rg_lo, ymax=direct_rg_hi, color = phenotype), alpha=0.6) +
        geom_linerange(aes(y=direct_rg, xmin = pop_rg_lo, xmax=pop_rg_hi, color = phenotype), alpha=0.6) +
        geom_abline(intercept=0, slope=1, linetype="solid", color="gray") +
        geom_hline(yintercept=0, linetype="dotted") +
        geom_vline(xintercept=0, linetype="dotted") +
        ylim(-0.9, 0.9) +
        xlim(-0.9, 0.9) +
        scale_colour_manual(values = palette) +
        scale_shape_manual(values = seq(1, n)) +
        labs(y = TeX("Direct $\\textit{r_g}$"), x = TeX("Population $\\textit{r_g}")) +
        theme(legend.position = "bottom", legend.title = element_blank()) +
        guides(colour=guide_legend(ncol = 4))

    # save
    if (save & is.na(save_suffix)) {
        ggsave("/var/genetics/proj/within_family/within_family_project/processed/figures/rg_figures/direct_pop_rg.pdf",
        height = 7, width = 9)
    } else if (save & !is.na(save_suffix)) {
        ggsave(paste0("/var/genetics/proj/within_family/within_family_project/processed/figures/rg_figures/direct_pop_rg_", save_suffix, ".pdf"),
        height = 7, width = 9)
    }

}

# ## generate scatterplot filtering on each phenotype
# for (pheno in all_phenos) {
#     print(pheno)
#     create_scatterplot(phenos, save = TRUE, save_suffix = pheno, filter_pheno = pheno)
# }

## --------------------------------------------------------------------------------
## create density plot
## --------------------------------------------------------------------------------

create_density_plot <- function(phenos, dat_points = NULL, save = TRUE, save_suffix = NA, palette = NA) {

    # process data
    dat = process_data(phenos)
    
    if (is.null(dat_points)) {
        # plot points with direct rg SE < 0.07
        dat_points = dat %>%
                filter(!is.na(direct_rg_se) & direct_rg_se < 0.07 & phenotype %in% phenos)
    }

    # get colour palette
    if (is.na(palette)) {
        set.seed(23)
        n <- length(unique(dat$phenotype))
        if (n < 29) {
            palette <- c("#E93993", "#CCEBDE", "#B2BFDC", "#C46627", "#10258A", "#E73B3C", "#DDDDDD",
                        "#FF8F1F", "#FCD3E6", "#B9E07A", "#A3F6FF", "#FFFF69", "#47AA42", "#A0DBD0",
                        "#5791C2", "#E9B82D", "#FC9284", "#7850A4", "#CEB8D7", "#FDC998", "#ADADAD",
                        "#00441B", "#028189", "#67001F", "#525252", "#FE69FC", "#A0D99B", "#4B1DB7")
        } else {
            palette1 <- c("#E93993", "#FF8F1F", "#00441B", "#7850A4", "#028189", "#67001F",
                        "#CCEBDE", "#B2BFDC", "#C46627", "#10258A", "#E73B3C", "#DDDDDD",
                            "#FCD3E6", "#B9E07A", "#A3F6FF", "#FFFF69", "#47AA42", "#A0DBD0",
                            "#5791C2", "#E9B82D", "#FC9284", "#CEB8D7", "#FDC998", "#ADADAD",
                            "#525252", "#FE69FC", "#A0D99B", "#4B1DB7")
            qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
            col_vector = unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))
            palette2 <- sample(col_vector, n-length(palette1), replace = T)
            palette <- c(palette1, palette2)
        }
    }

    # plot
    p <- ggplot(dat, aes(x=pop_rg, y=direct_rg) ) +
            stat_density_2d(aes(fill = ..level..), geom = "polygon", show.legend = FALSE) +
            scale_fill_distiller(palette="Greys", direction=1) +
            geom_abline(intercept=0, slope=1, linetype="solid", color="gray") +
            geom_hline(yintercept=0, linetype="dotted") +
            geom_vline(xintercept=0, linetype="dotted") +
            xlim(-0.9, 0.9) +
            ylim(-0.9, 0.9) +
            xlab("Genetic correlation (population)") +
            ylab("Genetic correlation (direct)") +
            geom_point(dat = dat_points, aes(pop_rg, direct_rg, colour=phenotype, shape=phenotype), alpha=0.6) +
            geom_label_repel(data = dat_points, aes(pop_rg, direct_rg, label=phenotype), box.padding = 1.3) +
            geom_linerange(dat = dat_points, aes(x=pop_rg, ymin = direct_rg_lo, ymax=direct_rg_hi, color = phenotype), alpha=0.6) +
            geom_linerange(dat = dat_points, aes(y=direct_rg, xmin = pop_rg_lo, xmax=pop_rg_hi, color = phenotype), alpha=0.6) +  
            scale_colour_manual(values = c(palette, palette("Paired"))) +
            scale_shape_manual(values = seq(1, nrow(dat_points))) +
            theme(legend.position = "none")

    # save
    if (save & is.na(save_suffix)) {
        ggsave("/var/genetics/proj/within_family/within_family_project/processed/figures/rg_figures/direct_pop_rg_density.pdf",
        height = 7, width = 9)
    } else if (save & !is.na(save_suffix)) {
        ggsave(paste0("/var/genetics/proj/within_family/within_family_project/processed/figures/rg_figures/direct_pop_rg_density_", save_suffix, ".pdf"),
        height = 7, width = 9)
    }

}

# ## create density plot with points for pairs with direct rg SE < 0.07
# create_density_plot(phenos, save = TRUE)

## create density plot with points for pairs where direct rg and pop rg are statistically significantly different from each other
results <- read_xlsx("/var/genetics/proj/within_family/within_family_project/processed/genomic_sem/cross_trait/cross_trait_results.xlsx")
results <- results %>%
            filter(p_adj < 0.05) %>%
            mutate(pheno_pair = paste0(pheno1, "_", pheno2))
sig_phenos <- tolower(results$pheno_pair) %>%
                str_replace("cigarettes per day", "cpd") %>%
                str_replace("-", "") %>%
                str_replace("cognitive performance", "cognition") %>%
                str_replace("1", "")
dat_points <- process_data(phenos) %>%
                filter(phenotype %in% sig_phenos)
dat_points$phenotype <- dat_points$phenotype %>% 
                            str_replace("_", " x ") %>%
                            str_replace("ea", "EA") %>%
                            str_replace("asthma", "Asthma") %>%
                            str_replace("bmi", "BMI") %>%
                            str_replace("eversmoker", "Ever-smoker") %>%
                            str_replace("height", "Height") %>%
                            str_replace("cognition", "Cognitive performance") %>%
                            str_replace("fev", "FEV1") %>%
                            str_replace("neuroticism", "Neuroticism")
create_density_plot(phenos,
                    dat_points = dat_points,
                    save_suffix = "sig",
                    save = TRUE)
