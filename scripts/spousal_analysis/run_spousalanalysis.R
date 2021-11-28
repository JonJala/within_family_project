t0 <- proc.time()

cat("Start time:\n", t0)
library(data.table)
library(dplyr)
library(rlang)
library(ggplot2)
library(ggpubr)
library(optparse)
library(stringr)
theme_set(theme_pubr())

standardize = function(x){
    
    x_std = (x - mean(x, na.rm = TRUE))/sd(x, na.rm = TRUE)
    
    return(x_std)
    
}


get_estimates = function(df, pheno1name, pheno2name,
                        pgi1name, pgi2name){
    
    
    pgi_pheno.1 = cor(df[[pheno1name]], df[[pgi1name]], use="complete.obs")
    pgi_pheno.2 = cor(df[[pheno2name]], df[[pgi2name]], use="complete.obs")
    spousal_pheno_corr = cor(df[[pheno1name]], df[[pheno2name]], use = "complete.obs")
    
    expected_pgi_corr = pgi_pheno.1 * pgi_pheno.2 * spousal_pheno_corr
    
    spousal_pgi_corr = cor.test(df[[pgi1name]], df[[pgi2name]], use="complete.obs")
    spousal_pgi_corr_ci = as.numeric(spousal_pgi_corr$conf.int)
    spousal_pgi_corr_est = as.numeric(spousal_pgi_corr$estimate)
    
    df_out <- tibble(
        estimate = c(spousal_pgi_corr_est),
        ci_lo = c(spousal_pgi_corr_ci[1]),
        ci_hi = c(spousal_pgi_corr_ci[2]),
        expected = c(expected_pgi_corr)
    )
    
    return(df_out)
}


option_list = list(
    
    make_option(c("--pgi"),  type="character", default=NULL, help="Path of file going through PGIs for each individual", metavar="character"),
    make_option(c("--pgi_col_name"), type="character", default="PGI", help="name of PGI column", metavar="character"),
    make_option(c("--pheno"),  type="character", default=NULL, help="Path of file going through phenotype observations for each individual", metavar="character"),
    make_option(c("--pheno_col_name"),  type="character", default="pheno", help="name of phenotype column name", metavar="character"),
    make_option(c("--pheno_iid"),  type="character", default="", help="name of IID name in phenotype file", metavar="character"),
    make_option(c("--pedigree"),  type="character", default=NULL, help="Path of file listing each proband IID and going
detailing their parental IDs. Has to have columns FID, IDD, FATHER_ID, MOTHER_ID", metavar="character"),
    make_option(c("--standarize_pgi"),  action="store_true", default=FALSE, help="Standarizes PGI to mean 1 var 0",  metavar="character"),
    make_option(c("--standarize_pheno"),  action="store_true", default=FALSE, help="Standarizes Phenotype to mean 1 var 0",  metavar="character"),
    make_option(c("--outprefix"),  type="character", default=NULL, help="Outprefix for data output",  metavar="character"),
    make_option(c("--subsample"), type="character", default='', help='The subsample you want to use')
)


opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)

dat = fread(opt$pgi)
pheno = fread(opt$pheno, col.names=c('IID', 'FID', opt$pheno_col_name))
dat = dat[pheno, on = "IID"]

if (opt$subsample != ''){
    subsample = fread(opt$subsample, col.names = c("IID", "FID"))
    dat = dat[dat$IID %in% subsample$IID]
}

print(str(dat))

if (isTRUE(opt$standarize_pgi)){
    dat[,get(opt$pgi_col_name) := standardize(get(opt$pgi_col_name))]
}

if (isTRUE(opt$standardize_pheno)) {
    dat[,get(opt$pheno_col_name) := standardize(get(opt$pheno_col_name))]
}

dat_pedig <- fread(opt$pedigree)

dat_pedig[, spousal_pair := case_when(complete.cases(FATHER_ID) & complete.cases(MOTHER_ID) ~ 1,
                                     TRUE ~ 0)]

spousalpairs = dat_pedig[spousal_pair == 1, .(FATHER_ID, MOTHER_ID)]
spousalpairs = unique(spousalpairs)

dat_fathers = dat[dat$IID %in% spousalpairs$FATHER_ID]
dat_mothers = dat[dat$IID %in% spousalpairs$MOTHER_ID]

dat_mothers = merge(dat_mothers, spousalpairs, by.x = "IID", by.y = "MOTHER_ID", how = "left")

dat_spousal = merge(dat_fathers, dat_mothers, by.x = "IID", by.y = "FATHER_ID", how = "inner",
                   suffixes = c(".father", ".mother"))

df_toplot = get_estimates(dat_spousal, paste0(opt$pheno_col_name ,".father"), 
                          paste0(opt$pheno_col_name ,".mother"), 
                          paste0(opt$pgi_col_name ,".father"),
                          paste0(opt$pgi_col_name ,".mother"))


df_toplot %>%
    fwrite(paste0(opt$outprefix, ".txt"))

if (file.exists(paste0(opt$outprefix, ".txt"))){
cat(paste0("File outputted to: ", opt$outprefix, ".txt\n"))
cat("======================================================\n")
}