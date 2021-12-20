library(data.table)
library(dplyr)
library(optparse)


option_list = list(
  make_option(c("--pheno"),  type="character", default=NULL, help="Phenotype file", metavar="character"),
  make_option(c("--pgi"),  type="character", default=NULL, help="PGI File", metavar="character"),
  make_option(c("--iid_pheno"),  type="character", default="IID", help="IID col name in phenotype file", metavar="character"),
  make_option(c("--fid_pheno"),  type="character", default=NULL, help="FID col name in phenotype file", metavar="character"),
  make_option(c("--pheno_name"),  type="character", default="phenotype", help="Phenotype col in phenotype file", metavar="character")
)
opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)


pheno = fread(opt$pheno)
if (is.null(opt$fid_pheno)){
    setnames(pheno, old = c(opt$iid_pheno, opt$pheno_name), new=c("IID", "phenotype"))
    pheno[,IID:= paste(IID, IID, sep="_")]
    pheno[,FID:=IID]

} else {
    setnames(pheno, old = c(opt$iid_pheno, opt$fid_pheno, opt$pheno_name), new=c("IID", "FID", "phenotype"))
}

head(pheno)

pgifile = fread(opt$pgi)

dat = pgifile[pheno, on = c("FID", "IID")]

nmatches = sum(complete.cases(dat$SCORE) & complete.cases(dat$phenotype), na.rm = TRUE)
print(paste("Number of non missing scores and phenotypes after match:", nmatches))

pgi.model.1 <- as.formula("phenotype~SCORE") %>%
    lm(., data = dat) %>%
    summary
print(pgi.model.1)