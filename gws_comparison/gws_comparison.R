
# Function to compute regression of direct_Beta on BETA adjusted for error in BETA
boot_adj_reg <- function(data, idx) {
  d <- data[idx, ]
  adj <- var(d$BETA)/(var(d$BETA) - mean(d$SE^2))
  if (adj<0){
    return(NA)
  } else {
    return(  coef(lm(direct_Beta ~BETA, weights = 1/direct_SE^2, data = d))[2] * adj)
  }
}

# Function to calculate measurement error adjusted correlation
boot_fn_corr <- function(data, idx) {
  d <- data[idx, ]
  r = cov(d$BETA, d$direct_Beta) 
  v_beta = var(d$BETA)-mean(d$SE^2)
  v_direct = var(d$direct_Beta)-mean(d$direct_SE^2)
    if (v_beta <= 0 || v_direct <= 0) {
    return(NA)
  } else {
    return(r / sqrt(v_beta * v_direct)) 
}
}

## Plot against one another 
# Read in the merged data
merged = fread("~/Dropbox/Within-Family Project/gws_comparison/height_gws_merged_sumstats.tsv", header = TRUE)
# Plot the results
pop_reg = lm(population_Beta ~ BETA, data = merged, weights=merged$population_SE^(-2))
direct_reg = lm(direct_Beta ~ BETA, data = merged, weights=merged$direct_SE^(-2))
fwrite(merged, file = "height_gws_merged_sumstats.tsv", sep = "\t", row.names = FALSE)

direct_pop_plot = function(merged,direct_pop_results,outprefix){
    require(viridis)
    require(scales)
    require(ggplot2)
    # Helper function to get density of points in 2 dimensions
    get_density <- function(x, y, ...) {
    # Calculate the joint density of the points
    dens <- MASS::kde2d(x, y, ...)
    # Find the density at the location of each original point
    ix <- findInterval(x, dens$x)
    iy <- findInterval(y, dens$y)
    ii <- cbind(ix, iy)
    return(dens$z[ii])
    }
    # Add a 'density' column to our dataframe
    # n=100 increases the resolution of the density grid for more accurate values
    merged$density <- get_density(merged$BETA, merged$direct_Beta, n = 100)
    # Define outliers as the 10% of points with the lowest density
    outlier_threshold <- quantile(merged$density, 0.10)
    outliers_df <- merged[merged$density < outlier_threshold, ]
    # Define density color palette with white for outliers
    n_colors <- 10
    base_palette <- viridis_pal(option = "rocket")(n_colors)
    final_palette <- scales::alpha(base_palette, 0.9)
    final_palette[1] <- "#00000000" 
    # Create the plot
    comparison_plot <- ggplot(merged, aes(x = BETA, y = direct_Beta)) +
    # Add horizontal/vertical lines at zero first
    geom_vline(xintercept = 0, color = "#cccccc") + 
    geom_hline(yintercept = 0, color = "#cccccc") +
    # 1. Add the filled density map.
    #    **Crucially, remove the global alpha argument from here.**
    geom_density_2d_filled(bins = n_colors) +
    # 2. Add contour lines
    geom_density_2d(color = "white", linewidth = 0.2) +
    # 3. Add the outlier points
    geom_point(data = outliers_df, color = "white", shape = 21, size = 2,
                fill = "firebrick", stroke = 0.5) +     
    # 4. Add the reference and regression lines
    geom_abline(intercept = 0, slope = 1, color = "#000000", linetype = "dashed", linewidth = 0.7) +
    geom_abline(
        intercept = 0,
        slope = direct_pop_results['direct_pop_slope', 'value'],
        color = "firebrick",
        linewidth = 1.2
    ) +
    scale_fill_manual(values = final_palette) +
    labs(
        x = "BOLT-LMM Population Effect",
        y = "Meta-analysis Direct Genetic Effect (DGE)"
    ) +
    # Use a clean theme and ensure plot is scaled correctly
    theme_bw() +
    coord_fixed(ratio = 1) +
    # Hide the fill legend
    guides(fill = "none")
    # Save results
    ggsave(paste0(outprefix, "_comparison_plot.pdf"), plot = comparison_plot, 
        device = "pdf", width = 7, height = 7, units = "in")
    return(comparison_plot)
}

gws_comparison <- function(merged=NA,clumped=NA,bolt=NA,fgwas=NA,outprefix='',boot_samples=1e4,flipped=FALSE) {
    require(data.table)
    require(ggplot2)
    require(MASS)
    require(boot)
    require(viridis)
    require(scales)
    if (is.na(merged)){
        if (is.na(clumped) || is.na(bolt) || is.na(fgwas)){
            stop("If merged is not provided, clumped, bolt, and fgwas must be provided")
        }
        # Clumps
        clumps = fread(clumped, header = TRUE)
        print('Read clumps')
        # unrelated BOLT sumstats
        bolt = fread(bolt, header = TRUE)
        print('Read BOLT sumstats')
        bolt = bolt[bolt$SNP%in%clumps$SNP,]
        print(paste0('Filtered BOLT sumstats to ', nrow(bolt), ' variants in clumps'))
        # get fgwas meta sumstats
        fgwas = fread(fgwas, header = TRUE)
        print('Read fgwas sumstats')
        # Merge bolt and fgwas summary statistics and harmonize alleles and effect directions
        merged = merge(bolt, fgwas, by = "SNP", suffixes = c(".bolt", ".fgwas"))
        print(paste0('Merged BOLT and fgwas sumstats to ', nrow(merged), ' variants'))
    } else {
        merged = fread(merged, header = TRUE)
        print(paste0('Read merged sumstats with ', nrow(merged), ' variants'))
    }
    # Harmonize alleles
    if (!flipped){
        merged = merged[!is.na(merged$ALLELE1) & !is.na(merged$ALLELE0) & !is.na(merged$A1) & !is.na(merged$A2),]
        allele_match = merged$ALLELE1 == merged$A1 & merged$ALLELE0 == merged$A2
        print(paste0('Found ', sum(allele_match), ' variants with matching alleles'))
        allele_flip = merged$ALLELE1 == merged$A2 & merged$ALLELE0 == merged$A1
        print(paste0('Found ', sum(allele_flip), ' variants with flipped alleles'))
        allele_mismatch = !(allele_match | allele_flip)
        print(paste0('Found ', sum(allele_mismatch), ' variants with mismatched alleles'))
        merged[allele_flip,c('BETA')] = -merged[allele_flip,c('BETA')]
        merged = merged[!allele_mismatch,]
        print(paste0('After harmonization, ', nrow(merged), ' variants remain'))} else {
            print('Sumstats alleles already aligned')
        }
    ## Calculate statistics comparing direct to population effects
    direct_pop_results = data.frame(value = c(NA, NA),
                                    se = c(NA, NA))
    rownames(direct_pop_results) <- c('direct_pop_slope', 'direct_pop_corr')
    # Calculate adjusted regression coefficient
    b <- boot(merged, statistic = boot_adj_reg, R = boot_samples)
    direct_pop_slope   <- mean(b$t,na.rm=T)
    direct_pop_slope_se    <- sd(b$t,na.rm=T)
    print(paste0('Direct to population slope: ', direct_pop_slope, ' S.E. ', direct_pop_slope_se))
    direct_pop_results['direct_pop_slope', 1:2] <- c(direct_pop_slope, direct_pop_slope_se)
    # Calculate adjusted correlation
    b <- boot(merged, statistic = boot_fn_corr, R = boot_samples)
    direct_pop_corr   <- mean(b$t,na.rm=T)
    direct_pop_corr_se    <- sd(b$t,na.rm=T)
    print(paste0('Direct to population correlation: ', direct_pop_corr, ' S.E. ', direct_pop_corr_se))
    direct_pop_results['direct_pop_corr', 1:2] <- c(direct_pop_corr, direct_pop_corr_se)
    # Make plot
    dir_pop_plot = direct_pop_plot(merged, direct_pop_results, outprefix)
    # Save results
    fwrite(direct_pop_results, file = paste0(outprefix, "_direct_pop_results.tsv"), sep = "\t", row.names = TRUE)
    fwrite(merged, file = paste0(outprefix, "_gws_merged_sumstats.tsv"), sep = "\t", row.names = FALSE)
    return(list(merged = merged, direct_pop_results = direct_pop_results, dir_pop_plot = dir_pop_plot))
}

## Height
height <- gws_comparison(merged="~/Dropbox/Within-Family Project/gws_comparison/height_gws_merged_sumstats.tsv",
            outprefix='~/Dropbox/Within-Family Project/gws_comparison/height',
            flipped=TRUE)

height <- gws_comparison("height_clumped.clumped",
            "/var/genetics/data/ukb/private/v3/processed/sumstats/unrelated_gwas/height.sumstats.txt",
            "/var/genetics/proj/within_family/within_family_project/processed/package_output/height/meta.sumstats.gz",
            '~/Dropbox/Within-Family Project/gws_comparison/height')
