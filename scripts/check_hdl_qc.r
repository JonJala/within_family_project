library(data.table)
library(ggplot2)

#-----------------------------------------------------------------------------------------------------------------------------------
# calculate variance of direct z scores
#-----------------------------------------------------------------------------------------------------------------------------------

geisinger <- fread("/var/genetics/proj/within_family/within_family_project/processed/qc/geisinger/hdl/CLEANED.out.gz")
hunt <- fread("/var/genetics/proj/within_family/within_family_project/processed/qc/hunt/hdl/CLEANED.out.gz")

var(geisinger$z_direct)
var(hunt$z_direct)

#-----------------------------------------------------------------------------------------------------------------------------------
# calculate direct to population vs direct to avg parental correlations
#-----------------------------------------------------------------------------------------------------------------------------------

plot(x = geisinger$rg_direct_population, y = geisinger$rg_direct_averageparental, pch = 19)
plot(x = hunt$rg_direct_population, y = hunt$rg_direct_averageparental, pch = 19)
