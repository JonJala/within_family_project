#!/usr/bin/bash Rscript

## copied and modified from alex's script (saved in wf folder in dropbox)

library(gridExtra)
library(ggplot2)
library(ggrepel)
library(readxl)
library(dplyr)
library(tidyverse)
library(magrittr)
library(reshape2)
library(RColorBrewer)

# read in data
cor_results = read_excel("/var/genetics/proj/within_family/within_family_project/processed/package_output/meta_results.xlsx")

# format pheno names
cor_results %<>% 
  filter(n_eff_median_direct > 5000) %>%
  arrange(n_eff_median_direct) %>%
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
cor_results %<>% filter(phenotype != "ADHD")

# direct-pop ldsc v.s. snipar comparison
correlate <- cor_results %>%
              select(phenotype, dir_pop_rg, dir_pop_rg_se) %>%
              mutate(Source = "snipar")
ldsc <- cor_results %>%
                select(phenotype, dir_pop_rg_ldsc, dir_pop_rg_se_ldsc) %>%
                mutate(Source = "LDSC") %>%
                rename(dir_pop_rg = dir_pop_rg_ldsc, dir_pop_rg_se = dir_pop_rg_se_ldsc)
results <- rbind(correlate, ldsc) %>%
            filter(dir_pop_rg_se < 0.25)
results$Source <- factor(results$Source, levels = c("snipar", "LDSC"))

# colour palette -- modified version of RColorBrewer "Set1"
palette <- rep(c("#E41A1C", "#377EB8",  "#A65628", "#4DAF4A", "#FF7F00", "#984EA3", "#999999", "#F781BF"), 4)

# plot direct to pop corr
results$phenotype = factor(results$phenotype,levels=unique(results$phenotype[order(results$dir_pop_rg)]))
p <- ggplot(results %>% filter(!is.na(dir_pop_rg)),aes(x=factor(phenotype, levels = cor_results$phenotype),y=dir_pop_rg,colour=factor(phenotype, levels = cor_results$phenotype),label=phenotype, group = Source))+
      geom_point(aes(shape = factor(Source, levels = c("LDSC", "snipar"))), position = position_dodge(width = 0.5), size=2)+
      geom_errorbar(aes(x = phenotype, ymin=dir_pop_rg-qnorm(0.025)*dir_pop_rg_se,ymax=dir_pop_rg+qnorm(0.025)*dir_pop_rg_se),width=0.25, position = position_dodge(width = 0.5))+
      geom_hline(yintercept=1.0)+
      guides(shape = guide_legend(title = "Source")) +
      theme_bw()+
      theme(axis.text.x = element_text(angle = 45,vjust=1,hjust=1),legend.position = "bottom")+
      xlab('Phenotype')+ylab('Correlation between direct and population effects')+
      scale_y_continuous(breaks=c(0,0.25,0.5,0.75,1,1.25,1.5)) +
      scale_colour_manual(values = palette, guide = "none") +
      coord_flip()
ggsave(filename='/var/genetics/proj/within_family/within_family_project/processed/figures/direct_population_correlations.pdf', p, width=9,height=7,device=cairo_pdf)

# plot direct to ntc corr
cor_results$phenotype = factor(cor_results$phenotype,cor_results$phenotype[order(cor_results$dir_ntc_rg)])
ggplot(cor_results %>% filter(!is.na(dir_ntc_rg), dir_ntc_rg < 1 & dir_ntc_rg > -1),aes(x=phenotype,y=dir_ntc_rg,colour=phenotype,label=phenotype))+geom_point(size=3)+
  geom_errorbar(aes(ymin=dir_ntc_rg-qnorm(0.025)*dir_ntc_rg_se,ymax=dir_ntc_rg+qnorm(0.025)*dir_ntc_rg_se),width=0.25)+theme_bw()+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),axis.text.x = element_text(angle = 45,vjust=1,hjust=1),legend.position = "none")+
  xlab('phenotype')+ylab('Correlation between direct effects and average NTCs')+geom_hline(yintercept=1.0)+
  geom_hline(yintercept=-1.0)+geom_hline(yintercept=0,linetype='dashed')+
  scale_y_continuous(breaks=c(-1,0,1))
ggsave(filename='/var/genetics/proj/within_family/within_family_project/processed/figures/direct_avg_ntc_correlations.pdf',width=9,height=6,device=cairo_pdf)
