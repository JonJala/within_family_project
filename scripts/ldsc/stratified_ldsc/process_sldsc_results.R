## based off hari's EA4 sldsc script

## ---------------------------------------------------------------------
## description: create plots of sldsc results
## ---------------------------------------------------------------------

list.of.packages <- c("tidyverse", "scales", "readxl", "ggforce", "ggpubr", "latex2exp", 
                        "ggplot2", "dplyr", "magrittr", "readr")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos = "http://cran.rstudio.com/")
lapply(list.of.packages, library, character.only = TRUE)

## ---------------------------------------------------------------------
## define functions
## ---------------------------------------------------------------------

# function to process baseline sldsc data
process_baseline_results <- function(effect, basepath, needed_annotations) {

    # read in baseline results
    baseline <- read_delim(paste0(basepath, effect, ".baselineLD.results"),
                        delim = "\t") %>% 
        mutate(n = row_number())

    # cleaning baseline
    baseline <- baseline %>% 
                    mutate(Category = case_when(
                        Category == "baseL2_0" ~ "base",
                        Category == "Coding_UCSCL2_0" ~ "Coding",
                        Category == "Coding_UCSC.extend.500L2_0" ~ "Coding + 500 bp",
                        Category == "Conserved_LindbladTohL2_0" ~ "Conserved (Lindblad-Toh)",
                        Category == "Conserved_LindbladToh.extend.500L2_0" ~ "Conserved (Lindblad-Toh) + 500 bp",
                        Category == "CTCF_HoffmanL2_0" ~ "CTCF",
                        Category == "CTCF_Hoffman.extend.500L2_0" ~ "CTCF + 500 bp",
                        Category == "DGF_ENCODEL2_0" ~ "DGF",
                        Category == "DGF_ENCODE.extend.500L2_0" ~ "DGF + 500 bp",
                        Category == "DHS_peaks_TrynkaL2_0" ~ "DHS peaks",
                        Category == "DHS_TrynkaL2_0" ~ "DHS",
                        Category == "DHS_Trynka.extend.500L2_0" ~ "DHS + 500 bp",
                        Category == "Enhancer_AnderssonL2_0" ~ "Enhancer (Andersson)",
                        Category == "Enhancer_Andersson.extend.500L2_0" ~ "Enhancer (Andersson) + 500 bp",
                        Category == "Enhancer_HoffmanL2_0" ~ "Enhancer (Hoffman)",
                        Category == "Enhancer_Hoffman.extend.500L2_0" ~ "Enhancer (Hoffman) + 500 bp",
                        Category == "FetalDHS_TrynkaL2_0" ~ "Fetal DHS",
                        Category == "FetalDHS_Trynka.extend.500L2_0" ~ "Fetal DHS + 500 bp",
                        Category == "H3K27ac_HniszL2_0" ~ "H3K27ac",
                        Category == "H3K27ac_Hnisz.extend.500L2_0" ~ "H3K27ac + 500 bp",
                        Category == "H3K27ac_PGC2L2_0" ~ "HCK27ac", # have to recheck this
                        Category == "H3K27ac_PGC2.extend.500L2_0" ~ "HCK27ac + 500 bp",
                        Category == "H3K4me1_peaks_TrynkaL2_0" ~ "H3K4me1 peaks",
                        Category == "H3K4me1_TrynkaL2_0" ~ "H3K4me1",
                        Category == "H3K4me1_Trynka.extend.500L2_0" ~ "H3K4me1 + 500 bp",
                        Category == "H3K4me3_peaks_TrynkaL2_0" ~ "H3K4me3 peaks",
                        Category == "H3K4me3_TrynkaL2_0" ~ "H3K4me3",
                        Category == "H3K4me3_Trynka.extend.500L2_0" ~ "H3K4me3 + 500 bp",
                        Category == "H3K9ac_peaks_TrynkaL2_0" ~ "H3K9ac peaks",
                        Category == "H3K9ac_TrynkaL2_0" ~ "H3K9ac",
                        Category == "H3K9ac_Trynka.extend.500L2_0" ~ "H3K9ac + 500 bp",
                        Category == "Intron_UCSCL2_0" ~ "Intron",
                        Category == "Intron_UCSC.extend.500L2_0" ~ "Intron + 500 bp",
                        Category == "PromoterFlanking_HoffmanL2_0" ~ "Promoter flanking",
                        Category == "PromoterFlanking_Hoffman.extend.500L2_0" ~ "Promoter flanking + 500 bp",
                        Category == "Promoter_UCSCL2_0" ~ "Promoter",
                        Category == "Promoter_UCSC.extend.500L2_0" ~ "Promoter + 500 bp",
                        Category == "Repressed_HoffmanL2_0" ~ "Repressed",
                        Category == "Repressed_Hoffman.extend.500L2_0" ~ "Repressed + 500 bp",
                        Category == "SuperEnhancer_HniszL2_0" ~ "Super enhancer (Hnisz)",
                        Category == "SuperEnhancer_Hnisz.extend.500L2_0" ~ "Super enhancer (Hnisz) + 500 bp",
                        Category == "TFBS_ENCODEL2_0" ~ "Transcription factor binding site",
                        Category == "TFBS_ENCODE.extend.500L2_0" ~ "Transcription factor binding site + 500 bp",
                        Category == "Transcr_HoffmanL2_0" ~ "Transcribed",
                        Category == "Transcr_Hoffman.extend.500L2_0" ~ "Transcribed + 500 bp",
                        Category == "TSS_HoffmanL2_0" ~ "Transcription start site",
                        Category == "TSS_Hoffman.extend.500L2_0" ~ "Transcription start site + 500 bp",
                        Category == "UTR_3_UCSCL2_0" ~ "3' UTR",
                        Category == "UTR_3_UCSC.extend.500L2_0" ~ "3' UTR + 500 bp",
                        Category == "UTR_5_UCSCL2_0" ~ "5' UTR",
                        Category == "UTR_5_UCSC.extend.500L2_0" ~ "5' UTR + 500 bp",
                        Category == "WeakEnhancer_HoffmanL2_0" ~ "Weak enhancer",
                        Category == "WeakEnhancer_Hoffman.extend.500L2_0" ~ "Weak enhancer + 500 bp",
                        Category == "Super_Enhancer_VahediL2_0" ~ "Super enhancer (Vehadi)",
                        Category == "Super_Enhancer_Vahedi.extend.500L2_0" ~ "Super enhancer (Vehadi) + 500 bp",
                        Category == "Typical_Enhancer_VahediL2_0" ~ "Typical enhancer",
                        Category == "Typical_Enhancer_Vahedi.extend.500L2_0" ~ "Typical enhancer + 500 bp",
                        Category == "GERP.NSL2_0" ~ "Conserved (GERP NS)",
                        Category == "GERP.RSsup4L2_0" ~ "Conserved (GERP RS > 4)",
                        Category == "MAFbin1L2_0" ~ "MAF bin 1",
                        Category == "MAFbin2L2_0" ~ "MAF bin 2",
                        Category == "MAFbin3L2_0" ~ "MAF bin 3",
                        Category == "MAFbin4L2_0" ~ "MAF bin 4",
                        Category == "MAFbin5L2_0" ~ "MAF bin 5",
                        Category == "MAFbin6L2_0" ~ "MAF bin 6",
                        Category == "MAFbin7L2_0" ~ "MAF bin 7",
                        Category == "MAFbin8L2_0" ~ "MAF bin 8",
                        Category == "MAFbin9L2_0" ~ "MAF bin 9",
                        Category == "MAFbin10L2_0" ~ "MAF bin 10",
                        Category == "MAF_Adj_Predicted_Allele_AgeL2_0" ~ "MAF-adjusted predicted allele age",
                        Category == "MAF_Adj_LLD_AFRL2_0" ~ "MAF-adjusted level of LD in Africans",
                        Category == "Recomb_Rate_10kbL2_0" ~ "Recombination rate (10 kb)",
                        Category == "Nucleotide_Diversity_10kbL2_0" ~ "Nucleotide diversity (10 kb)",
                        Category == "Backgrd_Selection_StatL2_0" ~ "Background selection statistic",
                        Category == "CpG_Content_50kbL2_0" ~ "CpG content (50 kb)"
                        ))

    # add 95% CIs
    baseline <- baseline %>%
        mutate(enrich_lo = Enrichment - 1.96 * Enrichment_std_error,
            enrich_hi = Enrichment + 1.96 * Enrichment_std_error) %>%
        filter(Category %in% needed_annotations)

    return(baseline)

}

# function to process cahoy 1 results
process_cahoy1 <- function(effect, basepath, control = FALSE) {
    
    # control vs not control
    if (control) {
        filepath <- paste0(basepath, effect, ".cahoy.1.control.results")
    } else {
        filepath <- paste0(basepath, effect, ".cahoy.1.results")
    }

    # read and process data
    cahoy1 <- read_delim(filepath,
                                delim = "\t") %>% 
                mutate(Category = case_when(Category == "L2_0" ~ "Astrocytes",
                                            TRUE ~ Category),
                    n = row_number())

    return(cahoy1)

}

# function to process cahoy 2 results
process_cahoy2 <- function(effect, basepath, control = FALSE) {
    
    # control vs not control
    if (control) {
        filepath <- paste0(basepath, effect, ".cahoy.2.control.results")
    } else {
        filepath <- paste0(basepath, effect, ".cahoy.2.results")
    }

    # read and process data
    cahoy2 <- read_delim(filepath, delim = "\t") %>%
                    mutate(Category = case_when(Category == "L2_0" ~ "Oligodendrocytes",
                                                TRUE ~ Category),
                            n = row_number())

    return(cahoy2)

}

# function to process cahoy 3 results
process_cahoy3 <- function(effect, basepath, control = FALSE) {
    
    # control vs not control
    if (control) {
        filepath <- paste0(basepath, effect, ".cahoy.3.control.results")
    } else {
        filepath <- paste0(basepath, effect, ".cahoy.3.results")
    }

    # read and process data
    cahoy3 <- read_delim(filepath, delim = "\t") %>% 
                    mutate(Category = case_when(Category == "L2_0" ~ "Neurons",
                                                TRUE ~ Category),
                            n = row_number())

    return(cahoy3)

}

## function to process all cahoy results
process_cahoy <- function(basepath, needed_annotations) {

    ## process cahoy 1
    cahoy1_direct <- process_cahoy1("direct", basepath)
    cahoy1_direct_control <- process_cahoy1("direct", basepath, control = TRUE) %>% 
                                filter(Category == "Astrocytes")
    cahoy1_population <- process_cahoy1("population", basepath)
    cahoy1_population_control <- process_cahoy1("population", basepath, control = TRUE) %>%
                                    filter(Category == "Astrocytes")

    ## process cahoy 2
    cahoy2_direct <- process_cahoy2("direct", basepath)
    cahoy2_direct_control <- process_cahoy2("direct", basepath, control = TRUE) %>%
                                filter(Category == "Oligodendrocytes")
    cahoy2_population <- process_cahoy2("population", basepath)
    cahoy2_population_control <- process_cahoy2("population", basepath, control = TRUE) %>%
                                    filter(Category == "Oligodendrocytes")

    ## process cahoy 3
    cahoy3_direct <- process_cahoy3("direct", basepath)
    cahoy3_direct_control <- process_cahoy3("direct", basepath, control = TRUE) %>%
                                filter(Category == "Neurons")
    cahoy3_population <- process_cahoy3("population", basepath)
    cahoy3_population_control <- process_cahoy3("population", basepath, control = TRUE) %>%
                                    filter(Category == "Neurons")

    ## combine
    cahoy_direct <- reduce(list(cahoy1_direct_control, cahoy2_direct_control, cahoy3_direct_control),
                        bind_rows) %>% 
                        mutate(effect = "Direct")
    cahoy_population <- reduce(list(cahoy1_population_control, cahoy2_population_control, cahoy3_population_control),
                        bind_rows) %>% 
                        mutate(effect = "Population")

    ## rbind and add CIs
    cahoy_in <- cahoy_direct %>% 
        bind_rows(cahoy_population) %>% 
        mutate(enrich_lo = Enrichment - 1.96 * Enrichment_std_error,
            enrich_hi = Enrichment + 1.96 * Enrichment_std_error) %>%
        filter(Category %in% needed_annotations)

    return(cahoy_in)

}


## ---------------------------------------------------------------------
## process sldsc data
## ---------------------------------------------------------------------

# Needed annotations
needed_annotations <- c(
    "Coding",
    "Conserved (Lindblad-Toh)",
    "CTCF",
    "DGF",
    "DHS",
    "Enhancer (Andersson)",
    "Enhancer (Hoffman)",
    "Fetal DHS",
    "H3K27ac",
    "HCK27ac",
    "H3K4me1",
    "H3K4me3",
    "H3K9ac",
    "Intron",
    "Promoter flanking",
    "Promoter",
    "Repressed",
    "Super enhancer (Hnisz)",
    "Transcription factor binding site",
    "Transcribed",
    "Transcription start site",
    "3' UTR",
    "5' UTR",
    "Weak enhancer",
    "Super enhancer (Vehadi)",
    "Typical enhancer",
    "Conserved (GERP NS)"
    # "MAF-adjusted predicted allele age",
    # "MAF-adjusted level of LD in Africans",
    # "Recombination rate (10 kb)",
    # "Nucleotide diversity (10 kb)",
    # "Background selection statistic",
    # "CpG content (50 kb)"
)

pheno <- "ea"
basepath <- paste0("/var/genetics/proj/within_family/within_family_project/processed/ldsc/stratified_ldsc/", pheno, "/")

## process baseline
baseline_direct <- process_baseline_results("direct", basepath, needed_annotations)
baseline_population <- process_baseline_results("population", basepath, needed_annotations)

baseline_in <- baseline_direct %>%
    mutate(effect = "Direct") %>% 
    bind_rows(baseline_population %>% mutate(effect = "Population"))

## process cahoy
cahoy_in <- process_cahoy(basepath, needed_annotations)

## combine
data <- rbind(baseline_in, cahoy_in) %>%
            mutate(cahoy_id = case_when(Category %in% c("Astrocytes", "Oligodendrocytes", "Neurons") ~ "Cahoy et al. (2008) Annotations",
                    TRUE ~ "Baseline Annotations")) %>%
            mutate(cahoy_id = factor(cahoy_id,
                    levels = c("Cahoy et al. (2008) Annotations", "Baseline Annotations")))


## ---------------------------------------------------------------------
## plot enrichment
## ---------------------------------------------------------------------

data %>%
    ggplot() +
    geom_col(aes(Enrichment, reorder(Category, -n),
                 fill = effect),
             position = position_dodge()) +
    geom_errorbar(aes(xmin = enrich_lo,
                       xmax = enrich_hi,
                      y = Category,
                      group = effect),
                  position = position_dodge()) +
    geom_vline(xintercept = 1.0, linetype = "dashed") +
    facet_col(~cahoy_id, scale = "free_y", space = "free") +
    theme_pubr() +
    theme(legend.position = c(0.8, 0.5),
          legend.background = element_rect(color = "black"),
          legend.text = element_text(size = 14),
          legend.margin =margin(r=8,l=8,t=2,b=8),
          strip.text = element_text(size = 12)) +
    scale_x_continuous(breaks = scales::pretty_breaks(n = 15)) +
    labs(fill = NULL, y = "")

ggsave(paste0("/var/genetics/proj/within_family/within_family_project/processed/ldsc/stratified_ldsc/", pheno, "_baseline_enrich.png"),
       height = 8, width = 10)


## ---------------------------------------------------------------------
## plot proportion h2
## ---------------------------------------------------------------------

h2_data <- data %>% 
            mutate(
                proph2 = case_when(
                    complete.cases(Prop._h2) ~ Prop._h2
                ),
                proph2_se = case_when(
                    complete.cases(Prop._h2_std_error) ~ Prop._h2_std_error
                )
            ) %>% 
            mutate(proph2_lo = proph2 - 1.96 * proph2_se,
                proph2_hi = proph2 + 1.96 * proph2_se)


# plotting
h2_data %>% 
    mutate(cahoy_id = case_when(
        Category %in% c("Astrocytes", "Oligodendrocytes", "Neurons") ~ "Cahoy et al. (2008) Annotations",
        TRUE ~ "Baseline Annotations")
    ) %>% 
    mutate(cahoy_id = factor(cahoy_id,
                             levels = c("Cahoy et al. (2008) Annotations", "Baseline Annotations"))) %>% 
    ggplot() +
    geom_col(aes(proph2, reorder(Category, -n),
                 fill = effect),
             position = position_dodge()) +
    geom_errorbar(aes(xmin = proph2_lo,
                      xmax = proph2_hi,
                      y = Category,
                      group = effect),
                  position = position_dodge()) +
    facet_col(~cahoy_id, scale = "free_y", space = "free") +
    theme_pubr() +
    theme(legend.position = c(0.8, 0.5),
          legend.background = element_rect(color = "black"),
          legend.text = element_text(size = 14),
          legend.margin =margin(r=8,l=8,t=2,b=8),
          strip.text = element_text(size = 12)) +
    scale_x_continuous(breaks = scales::pretty_breaks(n = 15)) +
    labs(fill = NULL, y = "", x = TeX("Proportion of $\\textit{h^2}$"))

ggsave(paste0("/var/genetics/proj/within_family/within_family_project/processed/ldsc/stratified_ldsc/", pheno, "_baseline_prop_h2.png"),
       height = 8, width = 10)
