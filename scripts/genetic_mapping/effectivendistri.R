library(dplyr)
library(ggplot2)
library(data.table)


dat = fread("rsid_segments.txt.gz")

dat = dat[, .(direct_N = max(direct_N, na.rm=TRUE),
        population_N = max(population_N, na.rm=TRUE)),
    by=segmentid]

dat %>%
    ggplot() +
    geom_density(aes(direct_N, color = "Direct")) + 
    geom_density(aes(population_N, color = "Population")) + 
    scale_color_brewer(palette = "Dark2")

ggsave("effectiven_segments.pdf", width=9, height=6)
