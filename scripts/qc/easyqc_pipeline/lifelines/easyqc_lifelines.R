library(data.table)

# Import EasyQC package (from online source if necessary)
tryCatch(library("EasyQC"),
  error = function(e) {
    dir.create("easyqc_libraries", showWarnings=FALSE)
    .libPaths("easyqc_libraries")
    install.packages(pkgs="http://homepages.uni-regensburg.de/~wit59712/easyqc/EasyQC_9.2.tar.gz",
                     lib="easyqc_libraries/", repo=NULL, type="source")
    library("EasyQC")
  })


neff = function(f, se, phvar = 1){

    # return effective N
    N = round(phvar*(2*f*(1-f)*se^2)^(-1))
    return(N)
}


dat = fread("/disk/genetics/data/lifelines/public/latest/raw/sumstats/fgwas/fgwas_ll_bmi.sumstats")

incolnames = c("SNP", "chromosome", "pos", "A1", "A2", "direct_Beta", "direct_SE", "direct_log10_P", "freq")
dat = dat[, incolnames, with = FALSE]

setnames(
    dat,
    incolnames,
    c("SNP", "chromosome", "pos", "A1", "A2", "beta", "se",  "direct_log10_P", "freq")
)

dat[, P := 10^(-direct_log10_P)]
dat[, direct_log10_P := NULL]


dat = dat[ , .(SNP, chromosome, pos, A1, A2, beta, se, P, freq)]

head(dat)

dat[, N := neff(freq, se)]

head(dat)

fwrite(
    dat, 
    "/var/genetics/proj/within_family/within_family_project/processed/easyqc/lifelines/bmi.sumstats", 
    sep="\t"
)


EasyQC("/var/genetics/proj/within_family/within_family_project/scripts/qc/easyqc_pipeline/lifelines/lifelines.ecf")