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
dataset <- opt$dataset

print(phenotype)

# phenofile <- fread("/disk/genetics3/data_dirs/mcs/private/v1/raw/downloaded/NCDS_SFTP_1TB_1/imputed/phen/eczema/pheno.pheno")
# pgs <- fread("/disk/genetics3/data_dirs/mcs/private/v1/processed/pgs/fpgs/eczema/prscs/direct_full.pgs.txt")
# phenotype <- "eczema"
# outpath <- "/var/genetics/proj/within_family/within_family_project/processed/fpgs/eczema/prscs/direct"

# phenofile <- fread("/var/genetics/data/ukb/private/latest/processed/proj/within_family/phen/asthma/pheno.pheno")
# pgs <- fread("/var/genetics/data/ukb/private/latest/processed/proj/within_family/pgs/fpgs/asthma/prscs/direct_full.pgs.txt")
# phenotype <- "asthma"
# outpath <- "/var/genetics/proj/within_family/within_family_project/processed/fpgs/asthma/prscs/direct"

## clean phenofile
names(phenofile) <- c("FID", "IID", "phenotype")
phenofile %<>% select(-FID)

## merge pgs file with phenotype
p <- merge(pgs, phenofile, by.x="IID", by.y="IID")

## Standardize pgs variances
p[,c('proband','paternal','maternal')] = p[,c('proband','paternal','maternal')]/sd(p$proband)

## rename PCs if ukb
if (dataset == "ukb") {
  p <- p %>% 
        rename(V1 = PC1, V2 = PC2, V3 = PC3, V4 = PC4, V5 = PC5, V6 = PC6, V7 = PC7, V8 = PC8, V9 = PC9, V10 = PC10, V11 = PC11, V12 = PC12, V13 = PC13, V14 = PC14, V15 = PC15, V16 = PC16, V17 = PC17, V18 = PC18, V19 = PC19, V20 = PC20)
}

## standardize age, sex, and pcs
p <- p %>% 
      mutate(age = (age-mean(age))/sd(age),
      sex = (sex-mean(sex))/sd(sex),
      age2 = age^2,
      agesex = age * sex,
      age2sex = age2 * sex,
      V1 = (V1-mean(V1))/sd(V1),
      V2 = (V2-mean(V2))/sd(V2),
      V3 = (V3-mean(V3))/sd(V3),
      V4 = (V4-mean(V4))/sd(V4),
      V5 = (V5-mean(V5))/sd(V5),
      V6 = (V6-mean(V6))/sd(V6),
      V7 = (V7-mean(V7))/sd(V7),
      V8 = (V8-mean(V8))/sd(V8),
      V9 = (V9-mean(V9))/sd(V9),
      V10 = (V10-mean(V10))/sd(V10),
      V11 = (V11-mean(V11))/sd(V11),
      V12 = (V12-mean(V12))/sd(V12),
      V13 = (V13-mean(V13))/sd(V13),
      V14 = (V14-mean(V14))/sd(V14),
      V15 = (V15-mean(V15))/sd(V15),
      V16 = (V16-mean(V16))/sd(V16),
      V17 = (V17-mean(V17))/sd(V17),
      V18 = (V18-mean(V18))/sd(V18),
      V19 = (V19-mean(V19))/sd(V19),
      V20 = (V20-mean(V20))/sd(V20))

## 1 gen logistic linear mixed model fit
glmm = glmer(phenotype ~ proband+(1|FID)+age+sex+agesex+V1+V2+V3+V4+V5+V6+V7+V8+V9+V10,data=p,family=binomial(link='logit'),nAGQ=1,glmerControl(optimizer="bobyqa"))
write.table(summary(glmm)$coefficients,paste0(outpath,'.1.effects.txt'),quote=F)
write.table(as.matrix(vcov(glmm)),paste0(outpath,'.1.vcov.txt'),quote=F) 

## 2 gen logistic linear mixed model fit
g2 = try({glmm = glmer(phenotype ~ proband+paternal+maternal+(1|FID)+age+sex+agesex+V1+V2+V3+V4+V5+V6+V7+V8+V9+V10,data=p,family=binomial(link='logit'),nAGQ=1,glmerControl(optimizer="bobyqa"))})
if (class(g2)=='try-error'){
    print('2 gen failed')
    glmm = glm(phenotype ~ proband+paternal+maternal+age+sex+agesex+V1+V2+V3+V4+V5+V6+V7+V8+V9+V10,data=p,family=binomial(link='logit'))
}
write.table(summary(glmm)$coefficients,paste0(outpath,'.2.effects.txt'),quote=F)
write.table(as.matrix(vcov(glmm)),paste0(outpath,'.2.vcov.txt'),quote=F)