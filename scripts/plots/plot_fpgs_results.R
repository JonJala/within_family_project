
### NOTE: THIS IS AN OLD SCRIPT! WE NOW USE plot_fpgs_results.r

library(data.table)
library(dplyr)
library(ggplot2)
library(ggpubr)
library(latex2exp)
library(forcats)
library(purrr)
library(stringr)
library(ggforce)


theme_set(theme_minimal() +
              theme(
                  axis.line.y = element_line(),
                  legend.title = element_text(size = 11),
                  legend.box.background = element_rect(colour = "black"),
                  legend.background = element_blank(),
                  panel.grid.major.x = element_blank(),
                  panel.grid.minor.x = element_blank(),
                  axis.text = element_text(size = 11),
                  axis.title = element_text(size = 13),
                  legend.text = element_text(size=11)
              ))


dat = fread("/var/genetics/proj/within_family/within_family_project/processed/fpgs/effects.table")

dat[, ci_lo := estimate - 1.96 * se]
dat[, ci_hi := estimate + 1.96 * se]
dat[, regvariable := factor(regvariable,
                            levels = c("population", "proband", "maternal", "paternal"))]
dat[, meta_effect_regvariable := factor(paste(meta_effect, regvariable, sep = "-"),
                                        levels = c(
                                            "dir-population", "pop-population",
                                            "dir-proband", "pop-proband",
                                            "dir-maternal", "pop-maternal",
                                            "dir-paternal", "pop-paternal"
                                        ))]

p1 = dat %>% 
    mutate(regvariable = fct_relabel(regvariable, ~case_when(
        . == "population" ~ "theta_population",
        . == "proband" ~ "theta_direct",
        . == "maternal" ~ "theta_maternal",
        . == "paternal" ~ "theta_paternal",)),
            meta_effect = fct_relabel(
                meta_effect, ~ ifelse(. == "dir", 
                                      "PGI constructed from Direct Effects", 
                                      "PGI constructed from Population Effects") 
                )) %>%
    ggplot(aes(group = meta_effect_regvariable)) +
    geom_col(aes(phenotype, estimate, fill = regvariable),
             width = 0.5, color = "black",
             position = position_dodge(width=0.5)) +
    geom_errorbar(aes(x = phenotype, ymin = ci_lo, ymax = ci_hi),
                  position = position_dodge(width=0.5),
                  width = 0.3) +
    facet_row(~meta_effect, scales='free') +
    geom_hline(yintercept = 0, color = "black") +
    scale_fill_brewer(palette = "Dark2") +
    labs(fill = "Coefficient", x = "", y = "Estimate", alpha = "PGI Constructed From") +
    scale_x_discrete(labels = c("BMI", "EA")) +
    ylim(-0.03, 0.25)

ggsave(
    '/var/genetics/proj/within_family/within_family_project/processed/fpgs/plots/coefficients.png', 
    plot = p1,
    height = 5, width = 9
)



p2 = dat %>% 
    filter(regvariable %in% c("population", "proband")) %>%
    mutate(regvariable = fct_relabel(regvariable, ~ ifelse(. == "population", "Proband only", "Full Model")),
            regvariable = fct_relevel(regvariable, "Proband only", "Full Model"),
             meta_effect = fct_relabel( meta_effect, ~ ifelse(. == "dir", 
                                        "PGI constructed from Direct Effects", 
                                        "PGI constructed from Population Effects") 
                )) %>%
    ggplot(aes(group = meta_effect_regvariable)) +
    geom_col(aes(phenotype, r2, fill = regvariable),
             width = 0.5, color = "black",
             position = position_dodge(width=0.5)) +
    facet_row(~meta_effect, scales='free') +
    geom_hline(yintercept = 0, color = "black") +
    scale_fill_brewer(palette = "Dark2") +
    labs(fill = "Model Used", x = "", y = TeX("$\\textit{R}^2$ (%)"),  alpha = "PGI Constructed From") +
    scale_x_discrete(labels = c("BMI", "EA")) +
    scale_y_continuous(labels = function(x) x * 100, limits = c(0, .08))



ggsave(
    '/var/genetics/proj/within_family/within_family_project/processed/fpgs/plots/r2.png', 
    plot = p2,
    height = 5, width = 9
)

############################
# Ratio of coefficients
############################


transform.effects = function(estimates, vcov, T=cbind(c(1, 0, 0), c(1, 0.5, 0.5))){
    
    estimates.out = estimates %*% T
    vcov.out = t(T) %*% vcov %*% T
    
    transformed.effects = list(
        "estimates" = estimates.out,
        "vcov" = vcov.out
    )
    
    return(transformed.effects)
    
}
ratio.estimate.se = function(effect.list, phenotype = "NAN", effect = "NAN"){
    
    # http://www.stat.cmu.edu/~hseltman/files/ratio.pdf
    
    mu_1 = effect.list$estimates[1]
    mu_2 = effect.list$estimates[2]
    
    sigma_sq_1 = effect.list$vcov[1, 1]
    sigma_sq_2 = effect.list$vcov[2, 2]
    sigma_12 = effect.list$vcov[1, 2]
    
    # check if off diagonals are the same
    stopifnot(near(sigma_12, effect.list$vcov[2, 1]))
    
    var.ratio = (mu_1^2/mu_2^2) * ((sigma_sq_1/mu_1^2) + (sigma_sq_2/mu_2^2) - 2 * (sigma_12/(mu_1 * mu_2)))
    
    se.ratio = sqrt(var.ratio)
    
    estimate = mu_1/mu_2
    
    estimate.out = data.table(
        phenotype = phenotype,
        effect = effect,
        estimate = estimate,
        se = se.ratio
    )
    
    estimate.out[, ci_lo := estimate - 1.96 * se]
    estimate.out[, ci_hi := estimate + 1.96 * se]

    return(estimate.out)
    
}

# ea dir
ea_dir_mat = as.matrix(dat[(phenotype == "ea" & meta_effect == "dir" & regvariable != 'population'), estimate])
ea_dir_vcov = as.matrix(fread("/var/genetics/proj/within_family/within_family_project/processed/fpgs/direct_ea.pgs_vcov.txt",
                               header = FALSE))

effects.transform = transform.effects(t(ea_dir_mat), ea_dir_vcov)
ea.dir.pgi.ratio = ratio.estimate.se(effects.transform, 'EA', 'Direct')


# ea pop
ea_pop_mat = as.matrix(dat[(phenotype == "ea" & meta_effect == "pop" & regvariable != 'population'), estimate])
ea_pop_vcov = as.matrix(fread("/var/genetics/proj/within_family/within_family_project/processed/fpgs/population_ea.pgs_vcov.txt",
                               header = FALSE))
effects.transform = transform.effects(t(ea_pop_mat), ea_pop_vcov)
ea.pop.pgi.ratio = ratio.estimate.se(effects.transform, 'EA', 'Population')

# bmi dir
bmi_dir_mat = as.matrix(dat[(phenotype == "bmi" & meta_effect == "dir" & regvariable != 'population'), estimate])
bmi_dir_vcov = as.matrix(fread("/var/genetics/proj/within_family/within_family_project/processed/fpgs/direct_ea.pgs_vcov.txt",
                               header = FALSE))

effects.transform = transform.effects(t(bmi_dir_mat), bmi_dir_vcov)
bmi.dir.pgi.ratio = ratio.estimate.se(effects.transform, 'BMI', 'Direct')


# bmi pop
bmi_pop_mat = as.matrix(dat[(phenotype == "bmi" & meta_effect == "pop" & regvariable != 'population'), estimate])
bmi_pop_vcov = as.matrix(fread("/var/genetics/proj/within_family/within_family_project/processed/fpgs/population_ea.pgs_vcov.txt",
                               header = FALSE))
effects.transform = transform.effects(t(bmi_pop_mat), bmi_pop_vcov)
bmi.pop.pgi.ratio = ratio.estimate.se(effects.transform, 'BMI', 'Population')

dat.ratios = reduce(
    list(ea.dir.pgi.ratio, ea.pop.pgi.ratio, bmi.dir.pgi.ratio, bmi.pop.pgi.ratio),
    bind_rows
)

p3 = dat.ratios %>% 
    ggplot(aes(group = effect)) +
    geom_point(aes(phenotype, estimate, color = effect),
             position = position_dodge(width=0.5),
             size = 4) +
    geom_errorbar(aes(x = phenotype, ymin = ci_lo, ymax = ci_hi),
                  position = position_dodge(width=0.5),
                  width = 0.3) +
    scale_color_brewer(palette = "Dark2") +
    labs(fill = "", x = "", y = "Coefficient Ratios", color = "PGI Constructed From") +
    scale_alpha_manual(values = c(0.5, 1)) +
    theme(
        axis.line = element_line()
    )


ggsave(
    '/var/genetics/proj/within_family/within_family_project/processed/fpgs/plots/ratios.png', 
    plot = p3,
    height = 6, width = 9
)