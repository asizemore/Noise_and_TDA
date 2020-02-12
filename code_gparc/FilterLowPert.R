FilterLowPert <- function(AchillesFile1, extension, AchillesFile2 = NULL, AchillesFile3 = NULL, AchillesFile4 = NULL, AchillesFile5 = NULL, AchillesFile6 = NULL, AchillesFile7 = NULL) {
  
  #read in Achilles File
  print("Reading in First File")
  Achilles1 <- read_gct(AchillesFile1)
  #obtain sequences
  Achilles1sequences <- Achilles1[,1]
  
  #obtain column names, mean of DNA levels, and assign NaN to low shRNAs for ACHILLES1FILE
  Data <- PertdataAchilles(Achilles1)
  colNames1 <- Data$colNames
  meanDNA1 <- Data$meanDNA
  LowAchilles1 <- Data$LowAchilles
  print("Finished assigning NaN to low sequences")
  
  #change NA and NaN in Description column to empty strings
  LowAchilles1[is.nan(Achilles1[,"Description"]),"Description"] <- ""
  LowAchilles1[is.na(Achilles1[,"Description"]),"Description"] <- ""
  removedAchilles <- LowAchilles1
  
  #make matrix with repeating meanDNA1 for all cell lines (same dimensions as Achilles1)
  print("Starting to make DNArefs matrix")
  DNAreferences1 <- matrix(rep(meanDNA1, dim(Achilles1)[2]-2), ncol=dim(Achilles1)[2]-2, byrow = FALSE)
  #Concatenate sequences(Name column), Description column, with DNAreferences
  DNAreferences1 <- cbind(Achilles1sequences, Achilles1[,2], DNAreferences1)
  #assign column names to DNAreferences
  colnames(DNAreferences1) <- colNames1
  print("Finished DNArefs matrix")
  
  removedDNAreferences <- DNAreferences1
  
  #check to see if user inputted a second file
  if (!is.null(AchillesFile2)){
    print("Yes, there is a second file.")
    #read in Achilles File
    Achilles2 <- read_gct(AchillesFile2)
    #remove description column 
    Achilles2 <- Achilles2[,-which(names(Achilles2) %in% c("Description"))]
    
    #check for identical sequences in both files
    Achilles2sequences <- Achilles2[,1]
    diff <- setdiff(Achilles1sequences, Achilles2sequences)
    if (length(diff) != 0){
      stop("The shNRAs in the files are not identical.")
    }
    else{
      print("The shRNAs in the files are identical.")
    }
    
    #obtain column names, mean of DNA levels, and assign NaN to low shRNAs for ACHILLES2FILE
    Data <- PertdataAchilles(Achilles2)
    colNames2 <- Data$colNames
    meanDNA2 <- Data$meanDNA
    LowAchilles2 <- Data$LowAchilles
    print("set low sequences to NaN and beginning to combine to matrices")
    #merge two Achilles datasets by sequence in Name column
    combinedAchilles <- merge(LowAchilles1, LowAchilles2, by="Name")
    print("finished combining matrices")
    
    #find indices of combinedAchilles where the sequence is NaN in both datasets
    print("starting to find indices where NaN in whole row")
    #in order to use is.nan: remove Name and Description column to make combinedAchilles a matrix
    RowIndicesNaN <- rowSums(is.nan(as.matrix(combinedAchilles[,-which(names(combinedAchilles) %in% c("Name","Description"))]))) < ncol(combinedAchilles)-2
    print("starting to remove rows")
    #remove rows with all NaNs from combinedAchilles
    removedAchilles <- combinedAchilles[RowIndicesNaN, ]
    #removedAchilles <- format(removedAchilles, digits = 6)
    print("finished removing rows")
    
    print("starting to make DNA references matrix")
    #make matrix with repeating meanDNA2 for all cell lines (same dimensions as Achilles1)
    DNAreferences2 <- matrix(rep(meanDNA2, dim(Achilles2)[2]-1), ncol = dim(Achilles2)[2]-1, byrow = FALSE)
    #Concatenate sequences(Name column), Description column, with DNAreferences
    DNAreferences2 <- cbind(Achilles2sequences, DNAreferences2)
    #assign column names to DNAreferences
    colnames(DNAreferences2) <- colNames2
    
    print("Combining DNA reference matrices")
    combinedDNAreferences <- cbind(DNAreferences1[order(DNAreferences1[,"Name"]),],DNAreferences2[order(DNAreferences2[,"Name"]),])
      
    #remove duplicate name column
    NameIndex <- grep("Name",colnames(combinedDNAreferences))[2]
    combinedDNAreferences <- combinedDNAreferences[,-NameIndex]
    combinedDNAreferences[is.na(combinedDNAreferences[,"Description"]),"Description"] <- ""
    
    #remove rows where DNA level is low
    removedDNAreferences <- combinedDNAreferences[RowIndicesNaN, ]
    #removedDNAreferences <- format(removedDNAreferences, digits = 6)
    
  }
  
  #check to see if user inputted a third file
  if (!is.null(AchillesFile3)){
    print("Yes, there is a third file.")
    Achilles3 <- read_gct(AchillesFile3)
    Achilles3 <- Achilles3[,-which(names(Achilles3) %in% c("Description"))]
    
    #check for identical sequences in all 3 files
    Achilles3sequences <- Achilles3[,1]
    diff13 <- setdiff(Achilles1sequences, Achilles3sequences)
    diff23 <- setdiff(Achilles2sequences, Achilles3sequences)
    if (length(diff13) != 0 && length(diff23) != 0){
      stop("The sequencess in the files are not identical.")
    }
    else{
      print("The sequences in the files are identical.")
    }
    
    #obtain column names, mean of DNA levels, and assign NaN to low sequences for ACHILLES3FILE
    Data <- PertdataAchilles(Achilles3)
    colNames3 <- Data$colNames
    meanDNA3 <- Data$meanDNA
    LowAchilles3 <- Data$LowAchilles
    print("Finished setting NaN to low sequences")
    
    print("Beginning to merge datasets")
    #merge three Achilles datasets by sequence in Name column
    combinedAchilles <- merge(combinedAchilles, LowAchilles3, by="Name")
    print("Finished merging datasets")
    
    #find indices of combinedAchilles where the sequence is NaN in all 3 datasets
    print("Finding indices")
    #in order to use is.nan: remove Name and Description column to make combinedAchilles a matrix
    RowIndicesNaN <- rowSums(is.nan(as.matrix(combinedAchilles[,-which(names(combinedAchilles) %in% c("Name","Description"))]))) < ncol(combinedAchilles)-2
    
    print("starting to remove rows with all NaNs")
    #remove rows with all NaNs from combinedAchilles
    removedAchilles <- combinedAchilles[RowIndicesNaN, ]
    #removedAchilles <- format(removedAchilles, digits = 6)
    
    #make matrix with repeating meanDNA3 for all cell lines (same dimensions as Achilles3)
    DNAreferences3 <- matrix(rep(meanDNA3, dim(Achilles3)[2]-1), ncol = dim(Achilles3)[2]-1, byrow = FALSE)
    #Concatenate sequences(Name column), Description column, with DNAreferences
    DNAreferences3 <- cbind(Achilles3sequences, DNAreferences3)
    #assign column names to DNAreferences
    colnames(DNAreferences3) <- colNames3
    
    print("Combining DNA reference matrices")
    combinedDNAreferences <- cbind(combinedDNAreferences[order(combinedDNAreferences[,"Name"]),],DNAreferences3[order(DNAreferences3[,"Name"]),])
    
    #remove duplicate name column
    NameIndex <- grep("Name",colnames(combinedDNAreferences))[2]
    combinedDNAreferences <- combinedDNAreferences[,-NameIndex]
    combinedDNAreferences[is.na(combinedDNAreferences[,"Description"]),"Description"] <- ""
    
    #remove rows where DNA level is low
    removedDNAreferences <- combinedDNAreferences[RowIndicesNaN, ]
    #removedDNAreferences <- format(removedDNAreferences, digits = 6)
    
  }
  
  
  #check to see if user inputted a fourth file
  if (!is.null(AchillesFile4)){
    print("Yes, there is a fourth file.")
    Achilles4 <- read_gct(AchillesFile4)
    Achilles4 <- Achilles4[,-which(names(Achilles4) %in% c("Description"))]
    
    #check for identical sequences in all 4 files
    Achilles4sequences <- Achilles4[,1]
    diff14 <- setdiff(Achilles1sequences, Achilles4sequences)
    diff24 <- setdiff(Achilles2sequences, Achilles4sequences)
    if (length(diff14) != 0 && length(diff24) != 0){
      stop("The sequencess in the files are not identical.")
    }
    else{
      print("The sequences in the files are identical.")
    }
    
    #obtain column names, mean of DNA levels, and assign NaN to low sequences for ACHILLES4FILE
    Data <- PertdataAchilles(Achilles4)
    colNames4 <- Data$colNames
    meanDNA4 <- Data$meanDNA
    LowAchilles4 <- Data$LowAchilles
    print("Finished setting NaN to low sequences")
    
    print("Beginning to merge datasets")
    #merge three Achilles datasets by sequence in Name column
    combinedAchilles <- merge(combinedAchilles, LowAchilles4, by="Name")
    print("Finished merging datasets")
    
    #find indices of combinedAchilles where the sequence is NaN in all 4 datasets
    print("Finding indices")
    #in order to use is.nan: remove Name and Description column to make combinedAchilles a matrix
    RowIndicesNaN <- rowSums(is.nan(as.matrix(combinedAchilles[,-which(names(combinedAchilles) %in% c("Name","Description"))]))) < ncol(combinedAchilles)-2
    
    print("starting to remove rows with all NaNs")
    #remove rows with all NaNs from combinedAchilles
    removedAchilles <- combinedAchilles[RowIndicesNaN, ]
    #removedAchilles <- format(removedAchilles, digits = 6)
    
    #make matrix with repeating meanDNA4 for all cell lines (same dimensions as Achilles4)
    DNAreferences4 <- matrix(rep(meanDNA4, dim(Achilles4)[2]-1), ncol = dim(Achilles4)[2]-1, byrow = FALSE)
    #Concatenate sequences(Name column), Description column, with DNAreferences
    DNAreferences4 <- cbind(Achilles4sequences, DNAreferences4)
    #assign column names to DNAreferences
    colnames(DNAreferences4) <- colNames4
    
    print("Combining DNA reference matrices")
    combinedDNAreferences <- cbind(combinedDNAreferences[order(combinedDNAreferences[,"Name"]),],DNAreferences4[order(DNAreferences4[,"Name"]),])
    
    #remove duplicate name column
    NameIndex <- grep("Name",colnames(combinedDNAreferences))[2]
    combinedDNAreferences <- combinedDNAreferences[,-NameIndex]
    combinedDNAreferences[is.na(combinedDNAreferences[,"Description"]),"Description"] <- ""
    
    #remove rows where DNA level is low
    removedDNAreferences <- combinedDNAreferences[RowIndicesNaN, ]
    #removedDNAreferences <- format(removedDNAreferences, digits = 6)
    
  }
  
  #check to see if user inputted a fifth file
  if (!is.null(AchillesFile5)){
    print("Yes, there is a fifth file.")
    Achilles5 <- read_gct(AchillesFile5)
    Achilles5 <- Achilles5[,-which(names(Achilles5) %in% c("Description"))]
    
    #check for identical sequences in all 5 files
    Achilles5sequences <- Achilles5[,1]
    diff15 <- setdiff(Achilles1sequences, Achilles5sequences)
    diff25 <- setdiff(Achilles2sequences, Achilles5sequences)
    if (length(diff15) != 0 && length(diff25) != 0){
      stop("The sequencess in the files are not identical.")
    }
    else{
      print("The sequences in the files are identical.")
    }
    
    #obtain column names, mean of DNA levels, and assign NaN to low sequences for ACHILLES5FILE
    Data <- PertdataAchilles(Achilles5)
    colNames5 <- Data$colNames
    meanDNA5 <- Data$meanDNA
    LowAchilles5 <- Data$LowAchilles
    print("Finished setting NaN to low sequences")
    
    print("Beginning to merge datasets")
    #merge three Achilles datasets by sequence in Name column
    combinedAchilles <- merge(combinedAchilles, LowAchilles5, by="Name")
    print("Finished merging datasets")
    
    #find indices of combinedAchilles where the sequence is NaN in all 5 datasets
    print("Finding indices")
    #in order to use is.nan: remove Name and Description column to make combinedAchilles a matrix
    RowIndicesNaN <- rowSums(is.nan(as.matrix(combinedAchilles[,-which(names(combinedAchilles) %in% c("Name","Description"))]))) < ncol(combinedAchilles)-2
    
    print("starting to remove rows with all NaNs")
    #remove rows with all NaNs from combinedAchilles
    removedAchilles <- combinedAchilles[RowIndicesNaN, ]
    #removedAchilles <- format(removedAchilles, digits = 6)
    
    #make matrix with repeating meanDNA5 for all cell lines (same dimensions as Achilles5)
    DNAreferences5 <- matrix(rep(meanDNA5, dim(Achilles5)[2]-1), ncol = dim(Achilles5)[2]-1, byrow = FALSE)
    #Concatenate sequences(Name column), Description column, with DNAreferences
    DNAreferences5 <- cbind(Achilles5sequences, DNAreferences5)
    #assign column names to DNAreferences
    colnames(DNAreferences5) <- colNames5
    
    print("Combining DNA reference matrices")
    combinedDNAreferences <- cbind(combinedDNAreferences[order(combinedDNAreferences[,"Name"]),],DNAreferences5[order(DNAreferences5[,"Name"]),])
    
    #remove duplicate name column
    NameIndex <- grep("Name",colnames(combinedDNAreferences))[2]
    combinedDNAreferences <- combinedDNAreferences[,-NameIndex]
    combinedDNAreferences[is.na(combinedDNAreferences[,"Description"]),"Description"] <- ""
    
    #remove rows where DNA level is low
    removedDNAreferences <- combinedDNAreferences[RowIndicesNaN, ]
    #removedDNAreferences <- format(removedDNAreferences, digits = 6)
    
  }
  
  
  #check to see if user inputted a sixth file
  if (!is.null(AchillesFile6)){
    print("Yes, there is a sixth file.")
    Achilles6 <- read_gct(AchillesFile6)
    Achilles6 <- Achilles6[,-which(names(Achilles6) %in% c("Description"))]
    
    #check for identical sequences in all 6 files
    Achilles6sequences <- Achilles6[,1]
    diff16 <- setdiff(Achilles1sequences, Achilles6sequences)
    diff26 <- setdiff(Achilles2sequences, Achilles6sequences)
    if (length(diff16) != 0 && length(diff26) != 0){
      stop("The sequencess in the files are not identical.")
    }
    else{
      print("The sequences in the files are identical.")
    }
    
    #obtain column names, mean of DNA levels, and assign NaN to low sequences for ACHILLES6FILE
    Data <- PertdataAchilles(Achilles6)
    colNames6 <- Data$colNames
    meanDNA6 <- Data$meanDNA
    LowAchilles6 <- Data$LowAchilles
    print("Finished setting NaN to low sequences")
    
    print("Beginning to merge datasets")
    #merge three Achilles datasets by sequence in Name column
    combinedAchilles <- merge(combinedAchilles, LowAchilles6, by="Name")
    print("Finished merging datasets")
    
    #find indices of combinedAchilles where the sequence is NaN in all 6 datasets
    print("Finding indices")
    #in order to use is.nan: remove Name and Description column to make combinedAchilles a matrix
    RowIndicesNaN <- rowSums(is.nan(as.matrix(combinedAchilles[,-which(names(combinedAchilles) %in% c("Name","Description"))]))) < ncol(combinedAchilles)-2
    
    print("starting to remove rows with all NaNs")
    #remove rows with all NaNs from combinedAchilles
    removedAchilles <- combinedAchilles[RowIndicesNaN, ]
    #removedAchilles <- format(removedAchilles, digits = 6)
    
    #make matrix with repeating meanDNA6 for all cell lines (same dimensions as Achilles6)
    DNAreferences6 <- matrix(rep(meanDNA6, dim(Achilles6)[2]-1), ncol = dim(Achilles6)[2]-1, byrow = FALSE)
    #Concatenate sequences(Name column), Description column, with DNAreferences
    DNAreferences6 <- cbind(Achilles6sequences, DNAreferences6)
    #assign column names to DNAreferences
    colnames(DNAreferences6) <- colNames6
    
    print("Combining DNA reference matrices")
    combinedDNAreferences <- cbind(combinedDNAreferences[order(combinedDNAreferences[,"Name"]),],DNAreferences6[order(DNAreferences6[,"Name"]),])
    
    #remove duplicate name column
    NameIndex <- grep("Name",colnames(combinedDNAreferences))[2]
    combinedDNAreferences <- combinedDNAreferences[,-NameIndex]
    combinedDNAreferences[is.na(combinedDNAreferences[,"Description"]),"Description"] <- ""
    
    #remove rows where DNA level is low
    removedDNAreferences <- combinedDNAreferences[RowIndicesNaN, ]
    #removedDNAreferences <- format(removedDNAreferences, digits = 6)
    
  }
  
  
  
  #check to see if user inputted a seventh file
  if (!is.null(AchillesFile7)){
    print("Yes, there is a seventh file.")
    Achilles7 <- read_gct(AchillesFile7)
    Achilles7 <- Achilles7[,-which(names(Achilles7) %in% c("Description"))]
    
    #check for identical sequences in all 7 files
    Achilles7sequences <- Achilles7[,1]
    diff17 <- setdiff(Achilles1sequences, Achilles7sequences)
    diff27 <- setdiff(Achilles2sequences, Achilles7sequences)
    if (length(diff17) != 0 && length(diff27) != 0){
      stop("The sequencess in the files are not identical.")
    }
    else{
      print("The sequences in the files are identical.")
    }
    
    #obtain column names, mean of DNA levels, and assign NaN to low sequences for ACHILLES7FILE
    Data <- PertdataAchilles(Achilles7)
    colNames7 <- Data$colNames
    meanDNA7 <- Data$meanDNA
    LowAchilles7 <- Data$LowAchilles
    print("Finished setting NaN to low sequences")
    
    print("Beginning to merge datasets")
    #merge three Achilles datasets by sequence in Name column
    combinedAchilles <- merge(combinedAchilles, LowAchilles7, by="Name")
    print("Finished merging datasets")
    
    #find indices of combinedAchilles where the sequence is NaN in all 7 datasets
    print("Finding indices")
    #in order to use is.nan: remove Name and Description column to make combinedAchilles a matrix
    RowIndicesNaN <- rowSums(is.nan(as.matrix(combinedAchilles[,-which(names(combinedAchilles) %in% c("Name","Description"))]))) < ncol(combinedAchilles)-2
    
    print("starting to remove rows with all NaNs")
    #remove rows with all NaNs from combinedAchilles
    removedAchilles <- combinedAchilles[RowIndicesNaN, ]
    #removedAchilles <- format(removedAchilles, digits = 6)
    
    #make matrix with repeating meanDNA7 for all cell lines (same dimensions as Achilles7)
    DNAreferences7 <- matrix(rep(meanDNA7, dim(Achilles7)[2]-1), ncol = dim(Achilles7)[2]-1, byrow = FALSE)
    #Concatenate sequences(Name column), Description column, with DNAreferences
    DNAreferences7 <- cbind(Achilles7sequences, DNAreferences7)
    #assign column names to DNAreferences
    colnames(DNAreferences7) <- colNames7
    
    print("Combining DNA reference matrices")
    combinedDNAreferences <- cbind(combinedDNAreferences[order(combinedDNAreferences[,"Name"]),],DNAreferences7[order(DNAreferences7[,"Name"]),])
    
    #remove duplicate name column
    NameIndex <- grep("Name",colnames(combinedDNAreferences))[2]
    combinedDNAreferences <- combinedDNAreferences[,-NameIndex]
    combinedDNAreferences[is.na(combinedDNAreferences[,"Description"]),"Description"] <- ""
    
    #remove rows where DNA level is low
    removedDNAreferences <- combinedDNAreferences[RowIndicesNaN, ]
    #removedDNAreferences <- format(removedDNAreferences, digits = 6)
    
  }
  
  
  gct1 <- {}
  gct1$data <- removedDNAreferences[, 3:dim(removedDNAreferences)[2]]
  rownames(gct1$data) <- removedDNAreferences[, 1]
  gct1$row.descriptions <- removedDNAreferences[, 1]
  gct1$rows <- removedDNAreferences[, 2]
  
  
  gct2 <- {}
  gct2$data <- removedAchilles[, 3:dim(removedAchilles)[2]]
  rownames(gct2$data) <- removedAchilles[, 1]
  gct2$row.descriptions <- removedAchilles[, 1]
  gct2$rows <- removedAchilles[, 2]
  #write removedDNAreferences and removedAchilles to GCT file
  write.gct(gct1, paste(extension,"DNAreferences_filtered_DNAref.gct",sep = "_"))
  write.gct(gct2, paste(extension,"Achilles_filtered.gct",sep = "_"))
  #return(removedDNAreferences)

}

