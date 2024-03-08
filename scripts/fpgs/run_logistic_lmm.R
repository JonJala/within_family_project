library(optparse)
library(data.table)
library(dplyr)
library(magrittr)
require(lme4)

###########################################################
### run logistic linear mixed model for binary phenotypes
###########################################################

## read in args
option_list = list(
  make_option(c("--pgs"),  type="character", default=NULL, help="Path to fPGS output", metavar="character"),
  make_option(c("--phenofile"),  type="character", default=NULL, help="Path to phenotype file", metavar="character"),
  make_option(c("--phenoname"),  type="character", default=NULL, help="Phenotype name", metavar="character"),
  make_option(c("--dataset"),  type="character", default=NULL, help="Validation cohort", metavar="character"),
  make_option(c("--outpath"),  type="character", default=NULL, help="Out directory", metavar="character")
)
opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)

## read in data
phenofile <- fread(opt$phenofile)
pgs <- fread(opt$pgs)
phenotype <- opt$phenoname
outpath <- opt$outpath

## clean phenofile
names(phenofile) <- c("FID", "IID", "phenotype")
phenofile %<>% select(-FID)

## merge pgs file with phenotype
p <- merge(pgs, phenofile, by.x="IID", by.y="IID")

## Standardize pgs variances
p[,c('proband','paternal','maternal')] = p[,c('proband','paternal','maternal')]/sd(p$proband)

## 1 gen logistic linear mixed model fit
glmm = glmer(phenotype ~ proband+(1|FID)+age+sex+age2+age3+agesex+age2sex+age3sex+V1+V2+V3+V4+V5+V6+V7+V8+V9+V10+V11+V12+V13+V14+V15+V16+V17+V18+V19+V20,data=p,family=binomial(link='logit'),nAGQ=2,glmerControl(optimizer="bobyqa"))
write.table(summary(glmm)$coefficients,paste0(outpath,'.1.effects.test.txt'),quote=F)
write.table(as.matrix(vcov(glmm)),paste0(outpath,'.1.vcov.test.txt'),quote=F) 

## 2 gen logistic linear mixed model fit
g2 = try({glmm = glmer(phenotype ~ proband+paternal+maternal+(1|FID)+age+sex+age2+age3+agesex+age2sex+age3sex+V1+V2+V3+V4+V5+V6+V7+V8+V9+V10+V11+V12+V13+V14+V15+V16+V17+V18+V19+V20,data=p,family=binomial(link='logit'),nAGQ=2,glmerControl(optimizer="bobyqa"))})
if (class(g2)=='try-error'){
    print('2 gen failed')
    glmm = glm(phenotype ~ proband+paternal+maternal+age+sex+age2+age3+agesex+age2sex+age3sex+V1+V2+V3+V4+V5+V6+V7+V8+V9+V10+V11+V12+V13+V14+V15+V16+V17+V18+V19+V20,data=p,family=binomial(link='logit'))
}
write.table(summary(glmm)$coefficients,paste0(outpath,'.2.effects.test.txt'),quote=F)
write.table(as.matrix(vcov(glmm)),paste0(outpath,'.2.vcov.test.txt'),quote=F)