#!/usr/bin/env Rscript

t0 <- proc.time()

# import packages
import_packages <- function(packages) {
    for (i in package_list) {
        if (i %in% installed.packages()) {
            print(paste("Required package", i, "is installed."))
        }
        else {
            stop(paste(
                "Required package", i, "is not installed. Ask for installation."
            ))
        }
    }
    lapply(package_list, library, character.only = TRUE)
}

# Import validation bed file.
import_validation_bed <- function(rds_file, bed_file) {
    if (!file.exists(rds_file)) {
        print("Reading Bed File")
        bigsnpr::snp_readBed(bed_file)
    } else {
        print("Bed file already read.")
    }
}

# Match variants between the sumstats and genotype files.
match_variants <- function(bigsnp_object, sumstats_object) {
    map <- bigsnp_object$map[-(2:3)]
    names(map) <- c("chr", "pos", "a0", "a1")
    return(bigsnpr::snp_match(sumstats_object, map))
    print("Matched variants.")
}

package_list <- c(
    "bigsnpr", "bigreadr", "bigparallelr", "ggplot2", "data.table", "magrittr"
)

import_packages(package_list)

# Define key file/phenotype names
phenotype <- "height"

method <- "inf"

bed_file <- paste(
    "/disk/genetics/ukb/mbennett/prediction_pipeline",
    "/data/ldpred2/validation_fileset/",
    phenotype, ".bed",
    sep = ""
)

rds_file <- paste(
    "/disk/genetics/ukb/mbennett/prediction_pipeline",
    "/data/ldpred2/validation_fileset/",
    phenotype, ".rds",
    sep = ""
)

sumstats_file <- paste(
    "/disk/genetics/ukb/mbennett/prediction_pipeline",
    "/data/ldpred2/sumstats/", phenotype, ".txt",
    sep = ""
)

import_validation_bed(rds_file, bed_file)

# Attach validation rds file
obj_bigsnp <- snp_attach(rds_file)

# View object
str(obj_bigsnp, max.level = 2, strict.width = "cut")

# Get aliases for useful slots and impute missing genotypes
genotypes <- obj_bigsnp$genotypes <- snp_fastImputeSimple(
    obj_bigsnp$genotypes,
    method = "random", ncores = nb_cores()
)
chromosome <- obj_bigsnp$map$chromosome
position <- obj_bigsnp$map$physical.pos
y <- obj_bigsnp$fam$affection
n_cores <- nb_cores()
bigparallelr::set_blas_ncores(n_cores)


# Read external summary statistics
sumstats <- bigreadr::fread2(sumstats_file)
str(sumstats)

# Select training subsample
set.seed(1)
ind_val <- sample(nrow(genotypes), 5000)
ind_test <- setdiff(rows_along(genotypes), ind_val)
print("Selected Training subsample")

# Matching variants
info_snp <- match_variants(obj_bigsnp, sumstats)

# Load genetic positions
position2 <- bigsnpr::snp_asGeneticPos(
    chromosome, position,
    ncores = n_cores
)
print("Loaded genetic positions.")

# Make y a data.table
y <- data.table::as.data.table(y)

# Copy y for all individuals in the validation set
indep <- data.table::copy(y[ind_val])
# Copy y for all individuals in the test set
test <- data.table::copy(y[ind_test])
# Create a placeholder polygenic score variable
test <- test[, prs := 0]

# Calculate the prediction r^2 for ldpred2_grid
for (chr in 1:22) {
    # Choose which snps to include
    ind_chr <- which(info_snp$chr == chr)
    df_beta <- info_snp[ind_chr, c("beta", "beta_se", "n_eff")]
    ind_chr2 <- info_snp$`_NUM_ID_`[ind_chr]

    # Calculate the correlation matrix for selected SNPs
    print(paste0("Computing correlation matrix for chromosome ", chr, "."))
    corr0 <- bigsnpr::snp_cor(
        genotypes,
        ind.col = ind_chr2, ncores = n_cores,
        infos.pos = position2[ind_chr2], size = 3 / 1000
    )
    corr <- bigsparser::as_SFBM(as(corr0, "dgCMatrix"))
    print(paste0("Computed correlation matrix for chromosome ", chr, "."))

    # LD Score regression
    ldsc <- snp_ldsc2(corr0, df_beta)
    rm(corr0)
    h2_est <- ldsc[["h2"]]
    print(
        paste0(
            "The estimate of heritability for ", phenotype,
            " on chromosome ", chr, " is ", h2_est, "."
        )
    )

    # Fit one of the available models
    if (method == "grid") {
        h2_seq <- round(h2_est * c(0.7, 1, 1.4), 4)
        p_seq <- signif(seq_log(1e-4, 1, length.out = 17), 2)
        params <- as.data.table(
            expand.grid(p = p_seq, h2 = h2_seq, sparse = c(FALSE, TRUE))
        )

        print(paste0("Fitting grid of models for chromosome ", chr, "."))
        beta_grid <- snp_ldpred2_grid(
            corr, df_beta, params,
            burn_in = 50, num_iter = 50, ncores = n_cores
        )
        rm(corr)
        print(paste0("Grid of models fitted for chromsome ", chr, "."))

        # Generate polygenic scores for each individual (row) and parameter set
        # (column)
        pred_grid <- big_prodMat(
            genotypes, beta_grid,
            ind.col = ind_chr2
        )
        print(
            paste0(
                "Grid of polygenic scores generated for chromosome ", chr, "."
            )
        )

        # Calculate r2 for each parameter set
        max_r2 <- 0
        max_id <- 0
        pred_grid_val <- pred_grid[ind_val, ]
        r2 <- matrix(, nrow = ncol(pred_grid_val), )
        for (i in seq_len(ncol(pred_grid_val))) {
            indep[, prs := pred_grid_val[, i]]
            model <- lm(y ~ prs, data = indep)
            r2[i, ] <- summary(model)$r.squared
            if (r2[i, ] > max_r2) {
                max_r2 <- r2[i, ]
                max_id <- i
            }
        }
        params$r2 <- r2
        rm(r2)
        # Add polygenic scores to the test data.table
        test <- test[, prs := prs + pred_grid[ind_test, max_id]]

        # Produce model selection plot
        hyperplot <- ggplot(params, aes(x = p, y = r2, color = as.factor(h2))) +
            theme_bigstatsr() +
            geom_point() +
            geom_line() +
            scale_x_log10(breaks = 10^(-5:0), minor_breaks = params$p) +
            facet_wrap(~sparse, labeller = label_both) +
            labs(y = "Model r2", color = "h2") +
            theme(legend.position = "top", panel.spacing = unit(1, "lines"))

        plot_file <- paste0(
            "/disk/genetics/ukb/mbennett/prediction_pipeline",
            "/out/ldpred2/", phenotype, "_chr", chr, ".png"
        )

        ggplot2::ggsave(plot_file)
    } else if (method == "auto") {
        print(paste0("Fitting auto model for chromosme ", chr, "."))
        multi_auto <- bigsnpr::snp_ldpred2_auto(
            corr,
            df_beta,
            h2_est,
            vec_p_init = bigsnpr::seq_log(
                1e-4, 0.9,
                length.out = floor(n_cores / 2)
            ),
            burn_in = 500,
            num_iter = 500,
            ncores = floor(n_cores / 2)
        )
        rm(corr)
        beta_auto <- sapply(multi_auto, function(auto) auto$beta_est)
        pred_auto <- bigstatsr::big_prodMat(
            genotypes, beta_auto,
            ind.row = ind_test, ind.col = ind_chr2
        )
        final_pred_auto <- rowMeans(pred_auto)
        test <- test[, prs := prs + final_pred_auto]
    } else if (method == "inf") {
        print(paste0("Fitting inf method for chromosome ", chr, "."))
        beta_inf <- bigsnpr::snp_ldpred2_inf(
            corr,
            df_beta,
            h2_est
        )
        rm(corr)
        pred_inf <- bigstatsr::big_prodVec(
            genotypes, beta_inf,
            ind.row = ind_test, ind.col = ind_chr2
        )
        test <- test[, prs := prs + pred_inf]
    } else {
        stop(paste0(method, " is not a vaild method."))
    }
}


model <- summary(lm(y ~ prs, data = test))
result <- model$r.squared

print(model)

print(result)

print(
    paste0(
        "The r_squared for the chosen ", method, " model for ", phenotype,
        " is ", result, "."
    )
)

t1 <- proc.time()
time <- t1 - t0
print(time)

time