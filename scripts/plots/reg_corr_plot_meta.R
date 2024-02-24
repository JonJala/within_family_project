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
  mutate(phenotype = case_when(phenotype == "aafb" ~ "Age at first birth",
                               phenotype == "aud" ~ "Alcohol use disorder",
                               phenotype == "bpd" ~ "Diastolic blood pressure",
                               phenotype == "bps" ~ "Systolic blood pressure",
                               phenotype == "cpd" ~ "Cigarettes per day",
                               phenotype == "dpw" ~ "Drinks per week",
                               phenotype == "fev" ~ "FEV1",
                               phenotype == "swb" ~ "Subjective well-being",
                               phenotype == "nonhdl" ~ "Non-HDL",
                               phenotype %in% c("adhd", "bmi", "copd", "ea", "hdl") ~ toupper(phenotype),
                               phenotype %in% c("cannabis", "hhincome", "cognition", "depsymp", "health", "depression", "neuroticism", "nchildren", "agemenarche", "eczema", "hayfever", "eversmoker", "morningperson", "asthma", "nearsight", "height", "migraine", "income", "extraversion", "hypertension") ~ str_to_title(phenotype)))  

# direct-pop ldsc v.s. snipar comparison
correlate <- cor_results %>%
              select(phenotype, dir_pop_rg, dir_pop_rg_se) %>%
              mutate(source = "SNIPar")
ldsc <- cor_results %>%
                select(phenotype, dir_pop_rg_ldsc, dir_pop_rg_se_ldsc) %>%
                mutate(source = "LDSC") %>%
                rename(dir_pop_rg = dir_pop_rg_ldsc, dir_pop_rg_se = dir_pop_rg_se_ldsc)
results <- rbind(correlate, ldsc)
results %<>% filter(phenotype != "ADHD", phenotype != "COPD")

# colour palette
set.seed(42)
n <- length(unique(results$phenotype))
palette1 <- c("#E93993", "#CCEBDE", "#B2BFDC", "#C46627", "#10258A", "#E73B3C", "#DDDDDD",
                "#FF8F1F", "#FCD3E6", "#B9E07A", "#A3F6FF", "#47AA42", "#A0DBD0",
                "#5791C2", "#E9B82D", "#FC9284", "#7850A4", "#CEB8D7", "#FDC998", "#ADADAD",
                "#00441B", "#028189", "#67001F", "#525252", "#FE69FC", "#A0D99B", "#4B1DB7")
qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
col_vector = unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))
palette2 <- sample(col_vector, n-length(palette1), replace = F)
palette <- c(palette1, palette2)

# plot direct to pop corr
results$phenotype = factor(results$phenotype,levels=unique(results$phenotype[order(results$dir_pop_rg)]))
p <- ggplot(results %>% filter(!is.na(dir_pop_rg)),aes(x=phenotype,y=dir_pop_rg,colour=phenotype,label=phenotype, group = dir_pop_rg))+
      geom_point(aes(shape = source), position = position_dodge(width = 0.5), size=2)+
      geom_errorbar(aes(x = phenotype, ymin=dir_pop_rg-qnorm(0.025)*dir_pop_rg_se,ymax=dir_pop_rg+qnorm(0.025)*dir_pop_rg_se),width=0.25, position = position_dodge(width = 0.5))+
      geom_hline(yintercept=1.0)+
      theme_bw()+
      theme(axis.text.x = element_text(angle = 45,vjust=1,hjust=1),legend.position = "bottom")+
      xlab('phenotype')+ylab('Correlation between direct and population effects')+
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
