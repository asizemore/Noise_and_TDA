writeGCTresults <- function(DataMatrix,filename,extension){
  
  outfile = paste(extension, filename, sep='_')
  print(outfile)
  file.create(outfile)
  fileConn <- file(outfile)
  writeLines(c("#1.2",paste(nrow(DataMatrix),'\t',ncol(DataMatrix)-2)), fileConn, sep='\n')
  close(fileConn)
  write.table(DataMatrix,outfile,sep='\t',append = TRUE, quote = FALSE, row.names=FALSE, eol = '\n')
  
  return()  
}