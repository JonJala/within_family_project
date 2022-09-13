library(dplyr)
library(ggplot2)
library(data.table)


dat = fread("/var/genetics/proj/within_family/within_family_project/processed/genetic_mapping/rsid_segments.txt.gz")
sumstats = fread('/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/meta.sumstats.gz')
sumstats = sumstats[sumstats$SNP %in% dat$SNP]

sumstats %>%
    ggplot() +
    geom_density(aes(direct_N, color = "Direct")) + 
    geom_density(aes(population_N, color = "Population")) + 
    scale_color_brewer(palette = "Dark2") +
    labs(color = "") +
    theme_minimal() +
    theme(
        axis.line = element_line(color="black")
    )

ggsave("/var/genetics/proj/within_family/within_family_project/processed/genetic_mapping/effectiven_segments.pdf", width=9, height=6)
