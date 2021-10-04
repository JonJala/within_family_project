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

i = 1
for (effect in c("dir", "pop")){

    file = paste0("/disk/genetics/data/estonian_biobank/public/latest/processed/sumstats/fgwas/ea_", effect, ".sumstats")        
    print(paste0("Reading in file: ", file))
    dat = fread(file)

    incolnames = c("SNP", "chr", "pos", "A1", "A2", "beta", "SE", "P", "EAF", "N")
    dat = dat[, incolnames, with = FALSE]

    setnames(
        dat,
        incolnames,
        c("SNP", "chromosome", "pos", "A1", "A2", "beta", "SE",  "P", "freq", "N")
    )

    head(dat)

    fileout = paste0("/var/genetics/proj/within_family/within_family_project/processed/easyqc/estonian_biobank/eduyears.",
              effect, ".sumstats")
    print(paste0("ECF File: ", fileout))
    fwrite(
        dat, 
        fileout, 
        sep="\t"
    )
    ecffile = paste0(
      "/var/genetics/proj/within_family/within_family_project/scripts/qc/easyqc_pipeline/estonian_biobank/eb.",
      effect, ".ecf"
    )
    EasyQC(ecffile)
}