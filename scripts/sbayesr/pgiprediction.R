library(data.table)
library(dplyr)
library(optparse)


option_list = list(
  make_option(c("--pheno"),  type="character", default=NULL, help="Phenotype file", metavar="character"),
  make_option(c("--pgi"),  type="character", default=NULL, help="PGI File", metavar="character"),
  make_option(c("--iid_pheno"),  type="character", default="IID", help="IID col name in phenotype file", metavar="character"),
  make_option(c("--fid_pheno"),  type="character", default=NULL, help="FID col name in phenotype file", metavar="character"),
  make_option(c("--covariates"),  type="character", default=NULL, help="File with covariates", metavar="character"),
  make_option(c("--pheno_name"),  type="character", default="phenotype", help="Phenotype col in phenotype file", metavar="character"),
  make_option(c("--outprefix"),  type="character", default="", help="Outprefix to save regression results.", metavar="character")
)
opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)


pheno = fread(opt$pheno)
if (!(opt$pheno_name %in% colnames(pheno))) {

    if (opt$pheno_name == "cognition") {
        opt$pheno_name <- "cog"
    } else if (opt$pheno_name == "ea") {
        opt$pheno_name <- "cog" # read from cog col
    } else {
        stop("There is no match for this pheno name.")
    }
}

if (is.null(opt$fid_pheno)) {
    setnames(pheno, old = c(opt$iid_pheno, opt$pheno_name), new=c("IID", "phenotype"))

    pheno[,FID:=IID]

} else {
    setnames(pheno, old = c(opt$iid_pheno, opt$fid_pheno, opt$pheno_name), new=c("IID", "FID", "phenotype"))
}

pgifile = fread(opt$pgi)
dat = pgifile[pheno, on = c("FID", "IID")]

if (!is.null(opt$covariates)){
    covar = fread(opt$covariates)
    covarnames = names(covar)[!(names(covar) %in% c("FID", "IID"))]
    dat = dat[covar, on=c("FID", "IID")]
} else {
    covarnames = c()
}

dat[, SCORE := SCORE/sd(SCORE, na.rm=TRUE)]
dat[,phenotype := phenotype/sd(phenotype, na.rm=TRUE)]
print(sd(dat$SCORE, na.rm=TRUE))

nmatches = sum(complete.cases(dat$SCORE) & complete.cases(dat$phenotype), na.rm = TRUE)
print(paste("Number of non missing scores and phenotypes after match:", nmatches))

pgimodelbase <- paste0(covarnames, collapse="+") %>%
    paste("phenotype", ., sep="~") %>%
    as.formula() %>%
    lm(., data = dat) %>%
    summary

pgi.model.1 <- paste0(covarnames, collapse="+") %>%
    paste("phenotype~SCORE", ., sep="+") %>%
    as.formula() %>%
    lm(., data = dat) %>%
    summary


regout = data.table(
    pgicoeff = pgi.model.1$coefficients["SCORE", "Estimate"],
    pgise = pgi.model.1$coefficients["SCORE", "Std. Error"],
    r2 =  pgi.model.1$r.squared,
    icr.r2 = pgi.model.1$r.squared - pgimodelbase$r.squared
)

print(regout)
regout %>% fwrite(paste0(opt$outprefix, ".regresults"))
print(paste("Model outputted to", paste0(opt$outprefix, ".regresults")))