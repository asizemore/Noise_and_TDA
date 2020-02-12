## Making achilles network from Avana v3.3.8

source("code_gparc/read_gct.R")
## Read in gct


AchillesFile1 <- "Data/Achilles_v3.3.8.Gs.gct"
Achilles1 <- read_gct(AchillesFile1)
ach_data <- Achilles1[ ,3:35]

# Rows are gene names and we have 33 cell lines
# Make correlation matrix

corr_mat <- cor(t(ach_data))

# Write corr_mat to file for julia
write.csv(corr_mat,"corr_mat.csv",quote = F, sep = "\t")
write.table(corr_mat,"corr_mat.txt",row.names = F,col.names = F, sep = "\t", quote = F)
