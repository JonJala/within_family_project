library(data.table)
library(dplyr)
library(ggplot2)
library(readxl)
library(stringr)
library(ggpubr)
library(latex2exp)
library(ggrepel)
library(magrittr)
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

# filter on direct neff
meta <- read_excel("/var/genetics/proj/within_family/within_family_project/processed/package_output/meta_results.xlsx")
neff_phenos <- meta %<>% 
                    filter(n_eff_median_direct > 5000) %>%
                    select(phenotype)

# get all pheno pairings
all_phenos <- neff_phenos$phenotype
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
    dat <- reformat_matrix(dat)
    if (!is.na(filter_pheno)) {
        phenos <- phenos[grepl(paste0(filter_pheno,"_|_",filter_pheno), phenos)]
    }
    # filter out pairs where direct_rg_se > 0.25
    dat <- dat %>% 
        filter(!is.na(direct_rg_se) & direct_rg_se < 0.25 & phenotype %in% phenos)
    # +- 95% CI bounds
    dat %<>%
        mutate(direct_rg_lo = direct_rg - 1.96*direct_rg_se,
                direct_rg_hi = direct_rg + 1.96*direct_rg_se,
                pop_rg_lo = pop_rg - 1.96*pop_rg_se,
                pop_rg_hi = pop_rg + 1.96*pop_rg_se)
    return(dat)
}

## --------------------------------------------------------------------------------
## create scatterplot
## --------------------------------------------------------------------------------

create_scatterplot <- function(phenos, palette = NA, save = TRUE, save_suffix = NA, filter_pheno = NA) {

    # process data
    dat = process_data(phenos, filter_pheno = filter_pheno)
    dat %<>% mutate(pheno1 = str_split(phenotype, "_", simplify = TRUE)[,1],
                    pheno2 = str_split(phenotype, "_", simplify = TRUE)[,2])
    dat %<>% mutate(pheno1 = case_when(pheno1 %in% c("adhd", "bmi", "copd", "ea") ~ toupper(pheno1),
                                pheno1 == "nonhdl" ~ "Non-HDL cholesterol",
                                pheno1 == "hdl" ~ "HDL cholesterol",
                                pheno1 == "fev" ~ "FEV1",
                                pheno1 == "agemenarche" ~ "Age-at-menarche",
                                pheno1 == "bps" ~ "Blood pressure (systolic)",
                                pheno1 == "bpd" ~ "Blood pressure (diastolic)",
                                pheno1 == "cognition" ~ "Cognitive performance",
                                pheno1 == "depsymp" ~ "Depressive symptoms",
                                pheno1 == "eversmoker" ~ "Ever-smoker",
                                pheno1 == "dpw" ~ "Drinks-per-week",
                                pheno1 == "hayfever" ~ "Allergic rhinitis",
                                pheno1 == "health" ~ "Self-rated health",
                                pheno1 == "hhincome" ~ "Household income",
                                pheno1 == "swb" ~ "Subjective well-being",
                                pheno1 == "nchildren" ~ "Number of children",
                                pheno1 == "nearsight" ~ "Myopia",
                                pheno1 == "aud" ~ "Alcohol use disorder",
                                pheno1 == "cpd" ~ "Cigarettes per day",
                                pheno1 == "aafb" ~ "Age at first birth (women)",
                                pheno1 == "morningperson" ~ "Morning person",
                                pheno1 == "income" ~ "Individual income",
                                pheno1 %in% c("asthma", "cannabis", "depression", "eczema", "extraversion", "height", "migraine", "neuroticism", "nchildren", "agemenarche", "eczema", "hayfever", "eversmoker", "morningperson", "asthma", "nearsight", "height", "migraine", "income", "extraversion", "hypertension") ~ str_to_title(pheno1)),
                    pheno2 = case_when(pheno2 %in% c("adhd", "bmi", "copd", "ea") ~ toupper(pheno2),
                                pheno2 == "nonhdl" ~ "Non-HDL cholesterol",
                                pheno2 == "hdl" ~ "HDL cholesterol",
                                pheno2 == "fev" ~ "FEV1",
                                pheno2 == "agemenarche" ~ "Age-at-menarche",
                                pheno2 == "bps" ~ "Blood pressure (systolic)",
                                pheno2 == "bpd" ~ "Blood pressure (diastolic)",
                                pheno2 == "cognition" ~ "Cognitive performance",
                                pheno2 == "depsymp" ~ "Depressive symptoms",
                                pheno2 == "eversmoker" ~ "Ever-smoker",
                                pheno2 == "dpw" ~ "Drinks-per-week",
                                pheno2 == "hayfever" ~ "Allergic rhinitis",
                                pheno2 == "health" ~ "Self-rated health",
                                pheno2 == "hhincome" ~ "Household income",
                                pheno2 == "swb" ~ "Subjective well-being",
                                pheno2 == "nchildren" ~ "Number of children",
                                pheno2 == "nearsight" ~ "Myopia",
                                pheno2 == "aud" ~ "Alcohol use disorder",
                                pheno2 == "cpd" ~ "Cigarettes per day",
                                pheno2 == "aafb" ~ "Age at first birth (women)",
                                pheno2 == "morningperson" ~ "Morning person",
                                pheno2 == "income" ~ "Individual income",
                                pheno2 %in% c("asthma", "cannabis", "depression", "eczema", "extraversion", "height", "migraine", "neuroticism", "nchildren", "agemenarche", "eczema", "hayfever", "eversmoker", "morningperson", "asthma", "nearsight", "height", "migraine", "income", "extraversion", "hypertension") ~ str_to_title(pheno2)),
                    pheno_label = paste0(pheno1, "_", pheno2))

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

    xlim <- max(c(abs(min(dat$pop_rg_lo)), max(dat$pop_rg_hi)), na.rm = T)
    ylim <- max(c(abs(min(dat$direct_rg_lo)), max(dat$direct_rg_hi)), na.rm = T)

    # plot
    dat %>%
        ggplot() +
        geom_point(aes(pop_rg, direct_rg, colour=pheno_label, shape=pheno_label), alpha=0.6) +
        geom_linerange(aes(x=pop_rg, ymin = direct_rg_lo, ymax=direct_rg_hi, color = pheno_label), alpha=0.6) +
        geom_linerange(aes(y=direct_rg, xmin = pop_rg_lo, xmax=pop_rg_hi, color = pheno_label), alpha=0.6) +
        geom_abline(intercept=0, slope=1, linetype="solid", color="gray") +
        geom_hline(yintercept=0, linetype="dotted") +
        geom_vline(xintercept=0, linetype="dotted") +
        ylim(-ylim, ylim) +
        xlim(-xlim, xlim) +
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

## generate scatterplot filtering on each phenotype
for (pheno in all_phenos) {
    print(pheno)
    create_scatterplot(phenos, save = TRUE, save_suffix = pheno, filter_pheno = pheno)
}

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
            xlim(-0.5, 0.5) +
            ylim(-0.5, 0.5) +
            xlab("Genetic correlation (population)") +
            ylab("Genetic correlation (direct)") +
            geom_point(dat = dat_points, aes(pop_rg, direct_rg, colour=phenotype, shape=phenotype), alpha=0.6) +
            geom_label_repel(data = dat_points, aes(pop_rg, direct_rg, label=phenotype), box.padding = 1) +
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

## create density plot with points for pairs where adj pval for difference between direct and pop rg is < 0.01
results <- read_xlsx("/var/genetics/proj/within_family/within_family_project/processed/genomic_sem/cross_trait/cross_trait_results.xlsx")
results <- results %>%
            filter(p_adj < 0.01) %>%
            mutate(pheno_pair = paste0(pheno1, "_", pheno2))
sig_phenos <- tolower(results$pheno_pair) %>%
                str_replace("cigarettes per day", "cpd") %>%
                str_replace("-", "") %>%
                str_replace("cognitive performance", "cognition") %>%
                str_replace("1", "") %>%
                str_replace("number of children", "nchildren") %>%
                str_replace("age at first birth", "aafb") %>%
                str_replace("selfrated health", "health") %>%
                str_replace("household income", "hhincome") %>%
                str_replace("ever-smoker", "eversmoker") %>%
                str_replace("aafb \\(women\\)", "aafb") %>%
                str_replace("nonhdl cholesterol", "nonhdl") %>%
                str_replace("drinksper-week", "dpw") %>%
                str_replace("alcohol use disorder", "aud")
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
                            str_replace("neuroticism", "Neuroticism") %>%
                            str_replace("nchildren", "Number of children") %>%
                            str_replace("nonhdl", "Non-HDL") %>%
                            str_replace("hhincome", "Household income") %>%
                            str_replace("aafb", "Age at first birth (women)") %>%
                            str_replace("health", "Self-rated health") %>%
                            str_replace("aud", "Alcohol use disorder") %>%
                            str_replace("bps", "BPS")
create_density_plot(phenos,
                    dat_points = dat_points,
                    save_suffix = "sig",
                    save = TRUE)
