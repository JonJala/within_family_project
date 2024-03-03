library(data.table)
library(dplyr)
library(ggplot2)
library(readxl)
library(stringr)
library(ggrepel)
library(magrittr)
library(ggpubr)
library(latex2exp)
library(RColorBrewer)
theme_set(theme_pubr())

## --------------------------------------------------------------------------------
## create h2 plot
## --------------------------------------------------------------------------------

h2_plot <- function(save = TRUE) {

    # read in datra
    dat = read_excel(
    "/var/genetics/proj/within_family/within_family_project/processed/package_output/meta_results.xlsx"
    )

    # filter on direct SE < 0.25
    dat %<>% filter(h2_se_direct < 0.25, h2_direct > 0)

    # filter on median direct Neff > 5000
    dat %<>% filter(n_eff_median_direct > 5000)

    # rename phenotypes
    dat %<>%
        mutate(phenotype = case_when(phenotype %in% c("adhd", "bmi", "copd", "ea") ~ toupper(phenotype),
                                phenotype == "nonhdl" ~ "Non-HDL cholesterol",
                                phenotype == "hdl" ~ "HDL cholesterol",
                                phenotype == "fev" ~ "FEV1",
                                phenotype == "agemenarche" ~ "Age-at-menarche",
                                phenotype == "bps" ~ "Blood pressure (systolic)",
                                phenotype == "bpd" ~ "Blood pressure (diastolic)",
                                phenotype == "cognition" ~ "Cognitive performance",
                                phenotype == "depsymp" ~ "Depressive symptoms",
                                phenotype == "eversmoker" ~ "Ever-smoker",
                                phenotype == "dpw" ~ "Drinks-per-week",
                                phenotype == "hayfever" ~ "Allergic rhinitis",
                                phenotype == "health" ~ "Self-rated health",
                                phenotype == "hhincome" ~ "Household income",
                                phenotype == "swb" ~ "Subjective well-being",
                                phenotype == "nchildren" ~ "Number of children",
                                phenotype == "nearsight" ~ "Myopia",
                                phenotype == "aud" ~ "Alcohol use disorder",
                                phenotype == "cpd" ~ "Cigarettes per day",
                                phenotype == "aafb" ~ "Age at first birth (women)",
                                phenotype == "morningperson" ~ "Morning person",
                                phenotype == "income" ~ "Individual income",
                                phenotype %in% c("asthma", "cannabis", "depression", "eczema", "extraversion", "height", "migraine", "neuroticism", "nchildren", "agemenarche", "eczema", "hayfever", "eversmoker", "morningperson", "asthma", "nearsight", "height", "migraine", "income", "extraversion", "hypertension") ~ str_to_title(phenotype)))

    # significant points to be labelled
    sig_points <- read_excel("/var/genetics/proj/within_family/within_family_project/processed/genomic_sem/h2_diff_results.xlsx")
    sig_points %<>% filter(p_adj < 0.05)
    dat_points <- dat %>% filter(phenotype %in% sig_points$phenotype)

    # get colour palette
    set.seed(42)
    n <- length(unique(dat$phenotype))
    palette1 <- c("#E93993", "#CCEBDE", "#B2BFDC", "#C46627", "#10258A", "#E73B3C", "#DDDDDD",
                    "#FF8F1F", "#FCD3E6", "#B9E07A", "#A3F6FF", "#FFFF69", "#47AA42", "#A0DBD0",
                    "#5791C2", "#E9B82D", "#FC9284", "#7850A4", "#CEB8D7", "#FDC998", "#ADADAD",
                    "#00441B", "#028189", "#67001F", "#525252", "#FE69FC", "#A0D99B", "#4B1DB7")
    qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
    col_vector = unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))
    palette2 <- sample(col_vector, n-length(palette1), replace = F)
    palette <- c(palette1, palette2)

    # plot
    dat %>%
        ggplot() +
        geom_point(aes(x = h2_population, y = h2_direct, colour=phenotype, shape=phenotype), alpha=0.6) +
        geom_label_repel(data = dat_points, aes(x = h2_population, y = h2_direct, label = phenotype), xlim = c(0.18, NA), box.padding = 1.2) +
        geom_linerange(aes(x=h2_population, ymin = h2_direct-h2_se_direct, ymax=h2_direct+h2_se_direct, color = phenotype), alpha=0.6) +
        geom_linerange(aes(y=h2_direct, xmin = h2_population-h2_se_population, xmax=h2_population+h2_se_population, color = phenotype), alpha=0.6) +
        geom_abline(intercept=0, slope=1, linetype="solid", color="gray") +
        geom_hline(yintercept=0, linetype="dotted", color="black") +
        geom_vline(xintercept=0, linetype="dotted", color="black") +
        scale_colour_manual(values = palette) +
        scale_shape_manual(values = c(seq(1, 25), seq(1, n-25))) +
        labs(y = TeX("SNP $\\textit{h^2}$ (direct)"), x = TeX("SNP $\\textit{h^2}$ (population)")) +
        theme(legend.position = "bottom", legend.title = element_blank()) +
        guides(colour=guide_legend(nrow = 5))

    # save
    if (save) {
        ggsave("/var/genetics/proj/within_family/within_family_project/processed/figures/h2_plot.pdf",
        height = 10, width = 12)
    }

}

# plot
h2_plot(save = TRUE)
