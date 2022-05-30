library(tidyverse)
library(data.table)
library(stargazer)
library(ggpubr)


qcpaths = "/var/genetics/proj/within_family/within_family_project/processed/qc/"
paths = Sys.glob(paste0(qcpaths, "*"))
paths = paths[paths != "/var/genetics/proj/within_family/within_family_project/processed/qc/cohortqcfilters.csv"]
datout = list()
i = 1
for (path in paths){
    if (grepl("ea4", path, fixed=TRUE) | (grepl("otherqc", path, fixed=TRUE))){
        print("Skipping")
    } else {
        cohort = tail(strsplit(path, "/")[[1]], 1)
        clean.rep = paste0(path, "/ea/clean.rep")
        dat = fread(clean.rep)
        n = dat[['numSNPsIn']]
        dat = dat[, -c("AlleleChange", "Checked", "StrandChange", 
                    "AlleleMatch", "n4AlleleMatch", "AFCHECK.cor_EAF.ref_f", 
                    "NotInIn", "numSNPsIn", "numSNPsOut", 
                    "CPTID.frommap", "CPTID.from_chrpos_format", "CPTID.from_chr_pos")]
        datm = melt(dat, id.vars="fileInShortName")
        datm = datm[(value %in% tail(sort(datm$value), 5)) & (value != 0), .(variable, value)]
        datm[, cohort := cohort]
        datm[, frac := value/n]
        datout[[i]] <- datm
        i <- i + 1
    }
}
datout = reduce(datout, rbind)
datout %>% 
    fwrite("/var/genetics/proj/within_family/within_family_project/processed/qc/cohortqcfilters.csv")
