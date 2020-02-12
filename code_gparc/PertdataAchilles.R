PertdataAchilles <- function(AchillesData){
  Achilleseqs <- AchillesData[,1]
  
  #obtain column names (cell lines)
  colNames <- colnames(AchillesData)
  
  #obtain pDNA columns
  DNA <- AchillesData[grep("pDNA", colNames)]
  
  #calculate mean of pDNA columns for each row
  meanDNA <- rowMeans(DNA)
  meanDNA <- format(meanDNA, digits = 6)
  
  #calculate median of pDNA columns for each row
  medianDNA <- apply(DNA,1,median)
  
  #indices of rows where median of pDNA columns is less than one
  lowRows <- medianDNA < 1
  
  #set all elements of lowRows to NaN
  AchillesData[lowRows, -1] <- NaN
  
  return(list("colNames" = colNames, "meanDNA" = meanDNA, "LowAchilles" = AchillesData))
  
}