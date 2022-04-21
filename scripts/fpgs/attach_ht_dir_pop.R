library(data.table)

dirpgs = fread("/var/genetics/proj/within_family/within_family_project/processed/fpgs/height/direct.pgs.txt")
poppgs = fread("/var/genetics/proj/within_family/within_family_project/processed/fpgs/height/population_full.pgs.txt")


dat = merge(dirpgs, poppgs, by=c("FID", "IID"), suffixes = c("_direct", "_population"))

fwrite(dat, "/var/genetics/proj/within_family/within_family_project/processed/fpgs/height/dir_pop.pgs.txt", sep = " ")
