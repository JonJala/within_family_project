library(data.table)
library(dplyr)
library(ggplot2)
library(readxl)
library(stringr)
library(magrittr)
library(ggpubr)
library(latex2exp)
library(RColorBrewer)
theme_set(theme_pubr())

## --------------------------------------------------------------------------------
## create h2 plot
## --------------------------------------------------------------------------------

h2_plot <- function(save = TRUE) {

    dat = read_excel(
    "/var/genetics/proj/within_family/within_family_project/processed/package_output/meta_results.xlsx"
    )
    dat %<>% filter(h2_se_direct < 0.25, h2_direct > 0)

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
        geom_linerange(aes(x=h2_population, ymin = h2_direct-h2_se_direct, ymax=h2_direct+h2_se_direct, color = phenotype), alpha=0.6) +
        geom_linerange(aes(y=h2_direct, xmin = h2_population-h2_se_population, xmax=h2_population+h2_se_population, color = phenotype), alpha=0.6) +
        geom_abline(yintercept=0, slope=1, linetype="solid", color="gray") +
        geom_hline(yintercept=0, linetype="dotted", color="black") +
        geom_vline(xintercept=0, linetype="dotted", color="black") +
        scale_colour_manual(values = palette) +
        scale_shape_manual(values = seq(1, n)) +
        labs(y = TeX("SNP $\\textit{h^2}$ (direct)"), x = TeX("SNP $\\textit{h^2}$ (population)")) +
        theme(legend.position = "bottom", legend.title = element_blank()) +
        guides(colour=guide_legend(nrow = 5))

    # save
    if (save) {
        ggsave("/var/genetics/proj/within_family/within_family_project/processed/figures/h2_plot.pdf",
        height = 8, width = 10)
    }

}

h2_plot(save = TRUE)
