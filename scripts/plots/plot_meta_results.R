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
cor_results[2:ncol(cor_results)] = lapply(cor_results[2:ncol(cor_results)], as.numeric) # convert to numeric, force NAs

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

# colour palette -- modified version of RColorBrewer "Set1"
palette <- rep(c("#E41A1C", "#377EB8",  "#A65628", "#4DAF4A", "#FF7F00", "#984EA3", "#999999", "#F781BF"), 4)

## --------------------------------------------------------------------------------
## direct-pop ldsc v.s. snipar comparison
## --------------------------------------------------------------------------------

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

# plot direct to pop corr
results$phenotype = factor(results$phenotype,levels=unique(results$phenotype[order(results$dir_pop_rg)]))
p <- ggplot(results %>% filter(!is.na(dir_pop_rg)),aes(x=factor(phenotype, levels = cor_results$phenotype),y=dir_pop_rg,colour=factor(phenotype, levels = cor_results$phenotype),label=phenotype, group = Source))+
      geom_point(aes(shape = factor(Source, levels = c("LDSC", "snipar"))), position = position_dodge(width = 0.5), size=2)+
      geom_errorbar(aes(x = phenotype, ymin=dir_pop_rg-qnorm(0.025)*dir_pop_rg_se,ymax=dir_pop_rg+qnorm(0.025)*dir_pop_rg_se),width=0.25, position = position_dodge(width = 0.5))+
      geom_hline(yintercept=1.0)+
      guides(shape = guide_legend(title = "Source")) +
      theme_bw()+
      theme(axis.text.x = element_text(angle = 45,vjust=1,hjust=1),legend.position = "bottom")+
      xlab('Phenotype')+ylab('Correlation between direct genetic effects and population effects')+
      scale_y_continuous(breaks=c(0,0.25,0.5,0.75,1,1.25,1.5)) +
      scale_colour_manual(values = palette, guide = "none") +
      coord_flip()
ggsave(filename='/var/genetics/proj/within_family/within_family_project/processed/figures/direct_population_correlations.pdf', p, width=9,height=7,device=cairo_pdf)

# check how many are statistically significant
results %<>%
    mutate(z = (dir_pop_rg - 1) / dir_pop_rg_se,
          p = pnorm(abs(z), lower.tail = FALSE))
ldsc_results <- results %>% 
                  filter(Source == "LDSC") %>%
                  mutate(adj_p = p.adjust(p, method = "BH"))
ldsc_sig <- sum(ldsc_results$adj_p < 0.05)
print(paste0(ldsc_sig, " significant results out of ", nrow(ldsc_results), " for LDSC"))
snipar_results <- results %>% 
                  filter(Source == "snipar") %>%
                  mutate(adj_p = p.adjust(p, method = "BH"))
snipar_sig <- sum(snipar_results$adj_p < 0.05)
print(paste0(snipar_sig, " significant results out of ", nrow(snipar_results), " for snipar"))


## --------------------------------------------------------------------------------
## direct-ntc correlations
## --------------------------------------------------------------------------------

snipar <- cor_results %>%
              select(phenotype, dir_ntc_rg, dir_ntc_rg_se) %>%
              mutate(Source = "snipar")
ldsc <- cor_results %>%
                select(phenotype, dir_avgntc_rg_ldsc, dir_avgntc_rg_se_ldsc) %>%
                mutate(Source = "LDSC") %>%
                rename(dir_ntc_rg = dir_avgntc_rg_ldsc, dir_ntc_rg_se = dir_avgntc_rg_se_ldsc)
results <- rbind(snipar, ldsc) %>%
            filter(dir_ntc_rg_se < 0.25)
results$Source <- factor(results$Source, levels = c("snipar", "LDSC"))

# plot direct-average NTC corr
results$phenotype = factor(results$phenotype,levels=unique(results$phenotype[order(results$dir_ntc_rg)]))
p <- ggplot(results %>% filter(!is.na(dir_ntc_rg)),aes(x=factor(phenotype, levels = cor_results$phenotype),y=dir_ntc_rg,colour=factor(phenotype, levels = cor_results$phenotype),label=phenotype, group = Source))+
      geom_point(aes(shape = factor(Source, levels = c("LDSC", "snipar"))), position = position_dodge(width = 0.5), size=2)+
      geom_errorbar(aes(x = phenotype, ymin=dir_ntc_rg-qnorm(0.025)*dir_ntc_rg_se,ymax=dir_ntc_rg+qnorm(0.025)*dir_ntc_rg_se),width=0.25, position = position_dodge(width = 0.5))+
      geom_hline(yintercept=0)+
      guides(shape = guide_legend(title = "Source")) +
      theme_bw()+
      theme(axis.text.x = element_text(angle = 45,vjust=1,hjust=1),legend.position = "bottom")+
      xlab('Phenotype')+ylab('Correlation between direct genetic effects and average NTCs')+
      scale_colour_manual(values = palette, guide = "none") +
      coord_flip()
ggsave(filename='/var/genetics/proj/within_family/within_family_project/processed/figures/direct_avg_ntc_correlations.pdf', p, width=9,height=7,device=cairo_pdf)

# check how many are statistically significantly different from 0
results %<>%
    mutate(z = (dir_ntc_rg) / dir_ntc_rg_se,
          p = pnorm(abs(z), lower.tail = FALSE))
ldsc_results <- results %>% 
                  filter(Source == "LDSC") %>%
                  mutate(adj_p = p.adjust(p, method = "BH"))
ldsc_sig <- sum(ldsc_results$adj_p < 0.05)
print(paste0(ldsc_sig, " significant results out of ", nrow(ldsc_results), " for LDSC"))
snipar_results <- results %>% 
                  filter(Source == "snipar") %>%
                  mutate(adj_p = p.adjust(p, method = "BH"))
snipar_sig <- sum(snipar_results$adj_p < 0.05)
print(paste0(snipar_sig, " significant results out of ", nrow(snipar_results), " for snipar"))

## --------------------------------------------------------------------------------
## regression pop v.s. direct
## --------------------------------------------------------------------------------

# plot direct to ntc corr
reg_results <- cor_results %>%
                  select(phenotype, reg_population_direct, reg_population_direct_se) %>%
                  filter(reg_population_direct_se < 0.25)
reg_results$phenotype = factor(reg_results$phenotype,levels=unique(reg_results$phenotype[order(reg_results$reg_population_direct)]))
p <- ggplot(reg_results %>% filter(!is.na(reg_population_direct)),aes(x=factor(phenotype, levels = cor_results$phenotype),y=reg_population_direct,colour=factor(phenotype, levels = cor_results$phenotype),label=phenotype))+
      geom_point()+
      geom_errorbar(aes(x = phenotype, ymin=reg_population_direct-qnorm(0.025)*reg_population_direct_se,ymax=reg_population_direct+qnorm(0.025)*reg_population_direct_se),width=0.25, position = position_dodge(width = 0.5))+
      geom_hline(yintercept=1)+
      theme_bw()+
      theme(axis.text.x = element_text(angle = 45,vjust=1,hjust=1),legend.position = "none")+
      xlab('Phenotype')+ylab('Regression of slope of population effects on direct genetic effects')+
      scale_colour_manual(values = palette, guide = "none") +
      coord_flip()
ggsave(filename='/var/genetics/proj/within_family/within_family_project/processed/figures/reg_direct_population.pdf', p, width=9,height=7,device=cairo_pdf)

# check how many are statistically significantly different from 0
reg_results %<>%
    mutate(z = (reg_population_direct-1) / reg_population_direct_se,
          p = 2*pnorm(abs(z), lower.tail = FALSE),
          adj_p = p.adjust(p, method = "BH"))
n_sig <- sum(reg_results$adj_p < 0.05)
sig <- reg_results %>% filter(adj_p < 0.05)

## --------------------------------------------------------------------------------
## prop non-sampling variance in pop due to stratification bias
## --------------------------------------------------------------------------------

prop_var_results <- cor_results %>%
                  select(phenotype, v_population_uncorr_direct, v_population_uncorr_direct_se) %>%
                  filter(v_population_uncorr_direct_se < 0.25)
prop_var_results$phenotype = factor(prop_var_results$phenotype,levels=unique(prop_var_results$phenotype[order(prop_var_results$v_population_uncorr_direct)]))
p <- ggplot(prop_var_results %>% filter(!is.na(v_population_uncorr_direct)),aes(x=factor(phenotype, levels = cor_results$phenotype),y=v_population_uncorr_direct,colour=factor(phenotype, levels = cor_results$phenotype),label=phenotype))+
      geom_point()+
      geom_errorbar(aes(x = phenotype, ymin=v_population_uncorr_direct-qnorm(0.025)*v_population_uncorr_direct_se,ymax=v_population_uncorr_direct+qnorm(0.025)*v_population_uncorr_direct_se),width=0.25, position = position_dodge(width = 0.5))+
      geom_hline(yintercept=0)+
      theme_bw()+
      theme(axis.text.x = element_text(angle = 45,vjust=1,hjust=1),legend.position = "none")+
      xlab('Phenotype')+ylab('Proportion of variance in population effects uncorrelated with direct genetic effects')+
      scale_colour_manual(values = palette, guide = "none") +
      coord_flip()
ggsave(filename='/var/genetics/proj/within_family/within_family_project/processed/figures/prop_non_sampling_var.pdf', p, width=9,height=7,device=cairo_pdf)

# check how many are statistically significantly different from 0
prop_var_results %<>%
    mutate(z = v_population_uncorr_direct / v_population_uncorr_direct_se,
          p = 2*pnorm(abs(z), lower.tail = FALSE),
          adj_p = p.adjust(p, method = "BH"))
n_sig <- sum(prop_var_results$adj_p < 0.05)
sig <- prop_var_results %>% filter(adj_p < 0.05)
sig$phenotype
