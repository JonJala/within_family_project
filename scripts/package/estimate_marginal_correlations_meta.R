library(rhdf5)
library(data.table)
library(optparse)
library(stringr)

estimate_r = function(d, beta1, beta2, se1, se2, rg ,ld,n_blocks=200, return_delete=F,
                freq="freq", chromosome="chromosome", pos="pos"){
  # Match LD scores
  d$ld = ld[match(d$SNP,ld$SNP),'L2', with=TRUE]
  d = d[!is.na(d$ld),]
  print(paste0("Number of observations with complete LD Scores: ", nrow(d)))
  # Weights
  d$w = (2*d[[freq]]*(1-d[[freq]]))/d$ld
  # Order by chromosome and position
  ord = order(d[[chromosome]],d[[pos]])
  d = d[ord]
  print(paste('Using',dim(d)[1],' SNPs for estimation'))
  # Find effects and correlations
  d$b1 = d[[beta1]]
  d$s1 = d[[se1]]
  d$b2 = d[[beta2]]
  d$s2 = d[[se2]]
  d$rs = d[[rg]]
  r_est = estimate_r_given_d(d)
  jack_est = block_jacknife(d,n_blocks=n_blocks,return_delete=return_delete)
  if (return_delete){
    return(list(r=r_est,SE=jack_est$SE,delete=jack_est$delete))
  } else {
    return(c(r_est,jack_est))
  }
}

estimate_r_given_d = function(d){
  v1 = sum(d$w*(d$b1^2-d$s1^2))
  v2 = sum(d$w*(d$b2^2-d$s2^2))
  c12 = sum(d$w*(d$b1*d$b2-d$rs*d$s1*d$s2))
  r=c12/sqrt(v1*v2)
  return(r)
}

block_jacknife = function(d,n_blocks=200,return_delete=F){
  block_size = floor(dim(d)[1]/n_blocks)
  r_out = rep(NA,length(n_blocks))
  remove_start = 1
  for (i in 1:(n_blocks-1)){
    remove_end = remove_start+block_size
    r_out[i] = estimate_r_given_d(d[-c(remove_start:remove_end),])
    remove_start = remove_end+1
  }
  remove_end = dim(d)[1]
  r_out[n_blocks] = estimate_r_given_d(d[-c(remove_start:remove_end),])
  r_var = ((n_blocks-1)/n_blocks)*sum((r_out-mean(r_out))^2)
  if (return_delete){
    return(list(SE=sqrt(r_var),
                delete=r_out))
  } else {
    return(sqrt(r_var))}
}


option_list = list(
  make_option(c("--file"),  type="character", default=NULL, help="Within family meta file path", metavar="character"),
  make_option(c("--outprefix"),  type="character", default=".", help="Out prefix", metavar="character"),
  make_option(c("--notmeta"), action="store_true", default=FALSE, help="Is file an output of meta analysis? if not script does some preprocessing"),
  make_option(c("--dir_pop_rg_name"),  type="character", default="r_direct_population", help="Name of direct-population-rg col", metavar="character"),
  make_option(c("--dir_avgpar_rg_name"),  type="character", default="r_direct_avg_NTC", help="Name of direct-avgparental-rg col", metavar="character"),
  make_option(c("--dirbeta"),  type="character", default="direct_Beta", help="Name of direct beta col", metavar="character"),
  make_option(c("--popbeta"),  type="character", default="population_Beta", help="Name of population beta col", metavar="character"),
  make_option(c("--avgparbeta"),  type="character", default="avg_NTC_Beta", help="Name of avgparental beta col", metavar="character"),
  make_option(c("--dirse"),  type="character", default="direct_SE", help="Name of direct se col", metavar="character"),
  make_option(c("--popse"),  type="character", default="population_SE", help="Name of population se col", metavar="character"),
  make_option(c("--avgparse"),  type="character", default="avg_NTC_SE", help="Name avg parental se col", metavar="character"),
  make_option(c("--chromosome"),  type="character", default="chromosome", help="Name of chromosome col", metavar="character"),
  make_option(c("--pos"),  type="character", default="pos", help="Name of bp/position col", metavar="character"),
  make_option(c("--freq"),  type="character", default="freq", help="Name of frequency col", metavar="character"),
  make_option(c("--merge_alleles"),  type="character", default="", help="Path to  subset snplist. If not passed all SNPs are used", metavar="character")

)
opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)
cat("========================================\n")
print(paste("Reading data:", opt$file))
d=fread(opt$file)
print(paste("Number of SNPS:", nrow(d)))
if (opt$merge_alleles != ""){
  hm3 = fread(opt$merge_alleles)
  idx = d$SNP %in% hm3$SNP
  print(paste("Common SNPs from merge-alleles:", sum(idx, na.rm=TRUE)))
  d = d[idx]
}


# Remove SNPs with outlying correlations
print('Removing SNPs with outlying sampling correlations between direct and population effects')

delta_b_corr_Z = as.numeric(scale(d[[opt$dir_pop_rg_name]]))

if (opt$dir_avgpar_rg_name %in% names(d)){
  delta_eta_corr_Z = as.numeric(scale(d[[opt$dir_avgpar_rg_name]]))
  bad_snps = abs(delta_b_corr_Z)>6 | abs(delta_eta_corr_Z)>6
} else {
  bad_snps = abs(delta_b_corr_Z)>6 
}
n_bad_snps = sum(bad_snps, na.rm=TRUE)
print(paste('Removing',n_bad_snps,'SNPs with outlying sampling correlations'))
if (n_bad_snps>0){
  d = d[!bad_snps]
}

ld_dir = '/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/'
## Read LD scores for weights
print('Reading LD scores')
ld =fread(paste(ld_dir,'/1.l2.ldscore.gz',sep=''))
for (i in 2:22){
  ld=rbind(ld,fread(paste(ld_dir,'/',i,'.l2.ldscore.gz',sep='')))}

print('Computing correlation between direct and population effects')
r_delta_beta = estimate_r(d, opt$dirbeta, opt$popbeta, opt$dirse, opt$popse, opt$dir_pop_rg_name,
                        ld,return_delete=T,
                        chromosome=opt$chromosome, pos=opt$pos, freq=opt$freq)
print(paste('r=',round(r_delta_beta$r,4),' S.E.=',round(r_delta_beta$SE,4),sep=''))
print('Computing correlation between direct effects and non-transmitted coefficients')

if (opt$avgparbeta %in% names(d)){
  r_delta_eta = estimate_r(d,opt$dirbeta, opt$avgparbeta, opt$dirse, opt$avgparse, opt$dir_avgpar_rg_name,
                        ld,return_delete=T,
                          chromosome=opt$chromosome, pos=opt$pos, freq=opt$freq)
  print(paste('r=',round(r_delta_eta$r,4),' S.E.=',round(r_delta_eta$SE,4),sep=''))
} else {
  r_delta_eta = list(r = NA, SE = NA)
}

outresults = data.frame(direct_population=c(r_delta_beta$r,r_delta_beta$SE),
                        direct_nontransmitted=c(r_delta_eta$r,r_delta_eta$SE))
dimnames(outresults)[[1]] = c('correlation','S.E')
write.table(t(outresults),paste(opt$outprefix,'marginal_correlations.txt',sep=''),quote=F)


