library(rhdf5)
library(data.table)
library(optparse)

estimate_r = function(d,effect_1,effect_2,ld,n_blocks=200, return_delete=F){
  # Match LD scores
  d$ld = ld[match(d$SNP,ld$SNP),'L2', with=TRUE]
  d = d[!is.na(d$ld),]
  # Weights
  d$w = (2*d$freq*(1-d$freq))/d$ld
  # Order by chromosome and position
  d = d[order(d$chromosome,d$pos),]
  print(paste('Using',dim(d)[1],' SNPs for estimation'))
  # Find effects and correlations
  d$b1 = d[[paste(effect_1,'Beta',sep='_')]]
  d$s1 = d[[paste(effect_1,'SE',sep='_')]]
  d$b2 = d[[paste(effect_2,'Beta',sep='_')]]
  d$s2 = d[[paste(effect_2,'SE',sep='_')]]
  d$rs = d[[paste(effect_1,effect_2,'rg',sep='_')]]
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
  make_option(c("--dir_pop_rg_name"),  type="character", default="direct_population_rg", help="Name of direct-population-rg col", metavar="character"),
  make_option(c("--dir_avgpar_rg_name"),  type="character", default="direct_avg_parental_rg", help="Name of direct-avgparental-rg col", metavar="character"),
  make_option(c("--dir_name"),  type="character", default="direct", help="Name of direct effects", metavar="character"),
  make_option(c("--pop_name"),  type="character", default="population", help="Name of direct-avgparental-rg col", metavar="character"),
  make_option(c("--avgpar_name"),  type="character", default="avg_parental", help="Name of direct-avgparental-rg col", metavar="character")
)
opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)

d=fread(opt$file)

# Remove SNPs with outlying correlations
print('Removing SNPs with outlying sampling correlations between direct and population effects')

delta_b_corr_Z = as.numeric(scale(d[[opt$dir_pop_rg_name]]))
delta_eta_corr_Z = as.numeric(scale(d[[opt$dir_avgpar_rg_name]]))
bad_snps = abs(delta_b_corr_Z)>6 | abs(delta_eta_corr_Z)>6
n_bad_snps = sum(bad_snps)

if (n_bad_snps>0){
  print(paste('Removing',n_bad_snps,'SNPs with outlying sampling correlations'))
  d = d[!bad_snps]
}

ld_dir = '/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/'
## Read LD scores for weights
print('Reading LD scores')
ld =fread(paste(ld_dir,'/1.l2.ldscore.gz',sep=''))
for (i in 2:22){
  ld=rbind(ld,fread(paste(ld_dir,'/',i,'.l2.ldscore.gz',sep='')))}

print('Computing correlation between direct and population effects')
r_delta_beta = estimate_r(d,opt$dir_name,opt$pop_name,ld,return_delete=T)
print(paste('r=',round(r_delta_beta$r,4),' S.E.=',round(r_delta_beta$SE,4),sep=''))
print('Computing correlation between direct effects and non-transmitted coefficients')
r_delta_eta = estimate_r(d,opt$dir_name,opt$avgpar_name,ld,return_delete=T)
print(paste('r=',round(r_delta_eta$r,4),' S.E.=',round(r_delta_eta$SE,4),sep=''))

outresults = data.frame(direct_population=c(r_delta_beta$r,r_delta_beta$SE),
                        direct_nontransmitted=c(r_delta_eta$r,r_delta_eta$SE))
dimnames(outresults)[[1]] = c('correlation','S.E')
write.table(t(outresults),paste(opt$outprefix,'/marginal_correlations.txt',sep=''),quote=F)


