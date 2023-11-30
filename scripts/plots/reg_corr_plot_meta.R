#!/usr/bin/bash Rscript

## copied and modified from alex's script (saved in wf folder in dropbox)

library(gridExtra)
library(ggplot2)
library(ggrepel)
library(readxl)
library(dplyr)
library(tidyverse)
library(magrittr)

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

# plot direct to pop corr
cor_results$phenotype = factor(cor_results$phenotype,levels=cor_results$phenotype[order(cor_results$dir_pop_rg)])
ggplot(cor_results %>% filter(!is.na(dir_pop_rg), dir_pop_rg < 1 & dir_pop_rg > -1),aes(x=phenotype,y=dir_pop_rg,colour=phenotype,label=phenotype))+
  geom_point(size=3)+
  geom_errorbar(aes(ymin=dir_pop_rg-qnorm(0.025)*dir_pop_rg_se,ymax=dir_pop_rg+qnorm(0.025)*dir_pop_rg_se),width=0.25)+
  geom_hline(yintercept=1.0)+
  theme_bw()+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),axis.text.x = element_text(angle = 45,vjust=1,hjust=1),legend.position = "none")+
  xlab('phenotype')+ylab('Correlation between direct and population effects')+
  scale_y_continuous(breaks=c(0,0.25,0.5,0.75,1,1.25,1.5))
ggsave(filename='/var/genetics/proj/within_family/within_family_project/processed/figures/direct_population_correlations.pdf',width=9,height=6,device=cairo_pdf)

# plot direct to ntc corr
cor_results$phenotype = factor(cor_results$phenotype,cor_results$phenotype[order(cor_results$dir_ntc_rg)])
ggplot(cor_results %>% filter(!is.na(dir_ntc_rg), dir_ntc_rg < 1 & dir_ntc_rg > -1),aes(x=phenotype,y=dir_ntc_rg,colour=phenotype,label=phenotype))+geom_point(size=3)+
  geom_errorbar(aes(ymin=dir_ntc_rg-qnorm(0.025)*dir_ntc_rg_se,ymax=dir_ntc_rg+qnorm(0.025)*dir_ntc_rg_se),width=0.25)+theme_bw()+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),axis.text.x = element_text(angle = 45,vjust=1,hjust=1),legend.position = "none")+
  xlab('phenotype')+ylab('Correlation between direct effects and average NTCs')+geom_hline(yintercept=1.0)+
  geom_hline(yintercept=-1.0)+geom_hline(yintercept=0,linetype='dashed')+
  scale_y_continuous(breaks=c(-1,0,1))
ggsave(filename='/var/genetics/proj/within_family/within_family_project/processed/figures/direct_avg_ntc_correlations.pdf',width=9,height=6,device=cairo_pdf)
