#!/usr/bin/env Rscript

## ---------------------------------------------------------------------
## description: create plots of fpgs results
## ---------------------------------------------------------------------

list.of.packages <- c("data.table", "tidyr", "dplyr", "magrittr", "tidyverse", "readxl", "stringr", "optparse")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos = "http://cran.rstudio.com/")
lapply(list.of.packages, library, character.only = TRUE)

## ---------------------------------------------------------------------
## define and parse options
## ---------------------------------------------------------------------

option_list = list(
  make_option(c("--filepath"),  type="character", default=NULL, help="Path to fPGS output", metavar="character")
)
opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)

## ---------------------------------------------------------------------
## define functions
## ---------------------------------------------------------------------

## functions copied and modified from https://github.com/AlexTISYoung/snipar/blob/grandpar/meta/grandparental_meta_analysis.R

# Approximate variance of ratio 
var_ratio_approx = function(x,y,vx,vy,cxy){
  x2 = x^2; y2 = y^2
  return((x2/y2)*(vx/x2-2*cxy/(x*y)+vy/y2))
}

# Read gen models 1-3 function modified to only require 2 gen
read_gen_models = function(effect,gen1_effects,gen2_effects,gen2_vcov,savepath,gen3_effects=NA,gen3_vcov=NA,sign_flip=FALSE,lme4=FALSE){
  ## Estimates to output
  parameter_names = c('population','direct','paternal_NTC','maternal_NTC','average_NTC','maternal_minus_paternal','maternal_minus_paternal_direct_ratio',
  'direct_3','paternal','maternal','parental','grandpaternal','grandmaternal','grandparental',
  'parental_direct_ratio','paternal_direct_ratio','maternal_direct_ratio')
  results = matrix(NA,nrow=length(parameter_names),ncol=2)
  dimnames(results)[[1]] = parameter_names
  dimnames(results)[[2]] = c('estimates','SE')
  ## Check files exist
  if (!file.exists(gen1_effects)){
    print(paste(gen1_effects,'does not exist'))
    return(results)
  } else if (!file.exists(gen2_effects)){
    print(paste(gen2_effects,'does not exist'))
    return(results)
  } else if (!file.exists(gen2_vcov)){
    print(paste(gen2_vcov,'does not exist'))
    return(results)
  } else {
  ## Get population effect
  if (lme4){
    results_1gen = read.table(gen1_effects,skip=1,header=F,row.names=1)
  } else {results_1gen = read.table(gen1_effects,row.names=1)}
  results['population',1:2] = as.matrix(results_1gen['proband',1:2])
  ## Get non-transmitted coefficients
  if (lme4){
   results_2gen = read.table(gen2_effects,row.names=1,skip=1,header=F) 
  } else {results_2gen = read.table(gen2_effects,row.names=1)}
  results_2gen = results_2gen[c('proband','paternal','maternal'),1:2]
  results_2gen_vcov = read.table(gen2_vcov,row.names=1)
  results_2gen_vcov = results_2gen_vcov[c('proband','paternal','maternal'),c('proband','paternal','maternal')]
  # Transform
  A_ntc = matrix(0,nrow=5,ncol=3)
  A_ntc[1:3,1:3] = diag(3)
  A_ntc[4,] = c(0,0.5,0.5)
  A_ntc[5,] = c(0,-1,1)
  results_2gen_vcov = A_ntc%*%as.matrix(results_2gen_vcov)%*%t(A_ntc)
  gen2_effects = c('direct','paternal_NTC','maternal_NTC','average_NTC','maternal_minus_paternal')
  dimnames(results_2gen_vcov)[[1]] = gen2_effects
  dimnames(results_2gen_vcov)[[2]] = gen2_effects
  results[gen2_effects,1] = A_ntc%*%as.matrix(results_2gen[,1])
  results[gen2_effects,2] = sqrt(diag(results_2gen_vcov))
  # Maternal minus paternal direct ratio
  results['maternal_minus_paternal_direct_ratio',1] = results['maternal_minus_paternal',1]/results['direct_3',1]
  results['maternal_minus_paternal_direct_ratio',2] = sqrt(var_ratio_approx(results['maternal_minus_paternal',1],results['direct',1],
                                                        results['maternal_minus_paternal',2]^2,results['direct',2]^2,
                                                        results_2gen_vcov['maternal_minus_paternal','direct']))

  # Compute indirect to direct ratios
  # Parental direct ratio
  results['parental_direct_ratio',1] = results['average_NTC',1]/results['direct',1]
  results['parental_direct_ratio',2] = sqrt(var_ratio_approx(results['average_NTC',1],results['direct',1],
                                                        results['average_NTC',2]^2,results['direct',2]^2,
                                                        results_2gen_vcov['average_NTC','direct']))
  # Paternal direct ratio
  results['paternal_direct_ratio',1] = results['paternal_NTC',1]/results['direct',1]
  results['paternal_direct_ratio',2] = sqrt(var_ratio_approx(results['paternal_NTC',1],results['direct',1],
                                                        results['paternal_NTC',2]^2,results['direct',2]^2,
                                                        results_2gen_vcov['paternal_NTC','direct']))
  # Maternal direct ratio
  results['maternal_direct_ratio',1] = results['maternal_NTC',1]/results['direct',1]
  results['maternal_direct_ratio',2] = sqrt(var_ratio_approx(results['maternal_NTC',1],results['direct',1],
                                                        results['maternal_NTC',2]^2,results['direct',2]^2,
                                                        results_2gen_vcov['maternal_NTC','direct']))                               

  if (sign_flip){results[,1] = -results[,1]}

  # save
  fwrite(as.data.table(results, keep.rownames = T), paste0(savepath, "/ntc_ratios_", effect, ".txt"), quote = F, sep = "\t", row.names = FALSE, col.names = TRUE, na = "NA")
  }
}

## ---------------------------------------------------------------------
## execute function
## ---------------------------------------------------------------------

read_gen_models(effect = "direct",
                gen1_effects = paste0(opt$filepath, "/direct.1.effects.txt"),
                gen2_effects = paste0(opt$filepath, "/direct.2.effects.txt"),
                gen2_vcov = paste0(opt$filepath, "/direct.2.vcov.txt"),
                savepath = opt$filepath)

read_gen_models(effect = "population",
                gen1_effects = paste0(opt$filepath, "/population.1.effects.txt"),
                gen2_effects = paste0(opt$filepath, "/population.2.effects.txt"),
                gen2_vcov = paste0(opt$filepath, "/population.2.vcov.txt"),
                savepath = opt$filepath)
