
## General functions for AchillesTeam



## Tic Toc matlab functions
tic <- function(){
  start <- proc.time()[3]
  
  function(){
    elapsed = proc.time()[3] - start
    print(paste("Elapsed time", elapsed, "seconds.", sep = " "))
    
  }
}



## Clean names
clean_names <- function(name){
  
  # very brute force. A more elegant cleaning method would be preferred.
  
  name = strsplit(name,"311CAS")[[1]][1]
  name = strsplit(name,"311Cas")[[1]][1]
  name = strsplit(name,"311cas")[[1]][1]
  name = strsplit(name,"311-CAS")[[1]][1]
  name = strsplit(name,"311-Cas")[[1]][1]
  name = strsplit(name,"311-cas")[[1]][1]
  name = strsplit(name,"Rep")[[1]][1]
  name = strsplit(name,"REP")[[1]][1]
  name = strsplit(name,"rep")[[1]][1]
  name = strsplit(name,"AVANA")[[1]][1]
  name = strsplit(name,"Avana")[[1]][1]
  name = strsplit(name,"avana")[[1]][1] 
  name = strsplit(name,"101Cas")[[1]][1]
  
  clean = name
  clean = gsub('_','',clean)
  clean = gsub('-','',clean)
  clean = gsub(' ','',clean)
  clean = gsub('/','',clean,fixed = TRUE)
  clean = gsub(';','',clean,fixed = TRUE)
  clean = gsub(')','',clean,fixed = TRUE)
  clean = gsub('(','',clean,fixed = TRUE)
  clean = gsub('.','',clean,fixed = TRUE)
  
  
  return(clean) 
}


## For removing an unwanted string pattern at the end of a sting.
remove_trailing <- function(string,pattern){
  
  last_char = nchar(string)
  
  # Does the last character equal the pattern?
  if(substr(string,last_char,last_char)==pattern){
    
    #if yes, remove it
    string = substr(string,1,last_char-1)
    
  }
  return(string)
  
}




zeros <- function(nrows,ncols){
  
outmat <- matrix(0,nrow = nrows, ncol = ncols)

return(outmat)

}


ones <- function(nrows,ncols){
  
  outmat <- matrix(1,nrow = nrows, ncol = ncols)
  return(outmat)
}




eye <- function(n){
  
  identityMat <- zeros(n,n)
  
  for(k in 1:n){
    identityMat[k,k] = 1
  }
  
  return(identityMat)
}




















################### THE FOLLOWING ARE FROM ACHILLES_COMMON.R ##################

readChipFile <- function(chip.file) {
  df <- read.delim(chip.file, stringsAsFactors=FALSE)
  #shRNA <- gsub("\\w_\\w*", "", df[,1])
  shRNAs <- df[,1]
  geneIds <- df[,3]
  type = colnames(df[1])
  retval <- data.frame(stringsAsFactors = FALSE,
                       geneIds = df[,3],
                       #shRNA = gsub("\\w_\\w*", "", df[,1]),
                       shRNAs = df[,1],
                       geneSymbols = df[,2] ,
                       type = colnames(df[1]))		
}


write.gct.nan<- function (gct, filename) {
  rows <- dim(gct$data)[1]
  columns <- dim(gct$data)[2]
  m <- cbind(gct$rows, gct$row.descriptions, gct$data)
  f <- file(filename, "w")
  on.exit(close(f))
  cat("#1.2", "\n", file=f, append=TRUE, sep="")
  cat(rows, "\t", columns, "\n", file=f, append=TRUE, sep="")
  cat("Name", "\t", file=f, append=TRUE, sep="")
  cat("Description", file=f, append=TRUE, sep="")
  names <- colnames(gct$data)
  for(j in 1:length(names)) {
    cat("\t", names[j], file=f, append=TRUE, sep="")
  }
  cat("\n", file=f, append=TRUE, sep="")
  write.table(m, file=f, append=TRUE, quote=FALSE, na="NaN",sep="\t", col.names=FALSE, row.names=FALSE)
  return(filename)
}



MSIG.Gct2Frame.rownames <- function(filename = "NULL") { 
  #
  # Reads a gene expression dataset in GCT format and converts it into an R data frame
  # allows row.names column to be specified
  
  ds <- read.delim(filename, header=T, sep="\t", row.names=NULL ,quote = "\"", skip=2,blank.lines.skip=T, comment.char="", as.is=T, na.strings = "", check.names=FALSE)
  row.names <- ds[,1]
  descs <- ds[,2]
  ds <- ds[c(-1,-2)]
  
  names <- names(ds)
  return(list(ds = ds, row.names = row.names, descs = descs, names = names))
}











####################### THE FOLLOWING ARE FROM common2.R ##########################

# The Broad Institute
# SOFTWARE COPYRIGHT NOTICE AGREEMENT
# This software and its documentation are copyright (2003-2006) by the
# Broad Institute/Massachusetts Institute of Technology. All rights are
# reserved.

# This software is supplied without any warranty or guaranteed support
# whatsoever. Neither the Broad Institute nor MIT can be responsible for its
# use, misuse, or functionality.

DEBUG <<- FALSE
options("warn"=-1)

info <- function(...) {
  if(DEBUG) {
    args <- list(...)
    for(i in 1:length(args)) {
      cat(paste(args[[i]], sep=''))
    }
    cat("\n", sep='')
  }
}

# extension e.g. '.gct'
check.extension <- function(file.name, extension) {
  ext <- regexpr(paste(extension,"$",sep=""), tolower(file.name))
  if(ext[[1]] == -1) {
    file.name <- paste(file.name, extension, sep="") 
  }
  return(file.name)
}

read.dataset <- function(file) {
  result <- regexpr(paste(".gct","$",sep=""), tolower(file))
  if(result[[1]] != -1)
    return(read.gct(file))
  result <- regexpr(paste(".res","$",sep=""), tolower(file))
  if(result[[1]] != -1)
    return(read.res(file))
  
  stop("Input is not a res or gct file.")	
}

read.gct <- function(file) {
  if (is.character(file)) 
    if (file == "") 
      file <- stdin()
    else {
      file <- file(file, "r")
      on.exit(close(file))
    }
    if (!inherits(file, "connection")) 
      stop("argument `file' must be a character string or connection")
    
    # line 1 version
    version <- readLines(file, n=1) 
    
    # line 2 dimensions
    dimensions <- scan(file, what=list("integer", "integer"), nmax=1, quiet=TRUE)   
    rows <- dimensions[[1]]
    columns <- dimensions[[2]]
    # line 3 Name\tDescription\tSample names...
    column.names <- read.table(file, header=FALSE, quote='', nrows=1, sep="\t", fill=FALSE, comment.char='', check.names=FALSE) 
    column.names <-column.names[3:length(column.names)]
    
    
    if(length(column.names)!=columns) {
      stop(paste("Number of sample names", length(column.names), "not equal to the number of columns", columns, "."))	
    }
    
    colClasses <- c(rep(c("character"), 2), rep(c("double"), columns))
    
    x <- read.table(file, header=FALSE, quote="", row.names=NULL, comment.char="", sep="\t", colClasses=colClasses, fill=FALSE)
    row.descriptions <- as.character(x[,2]) 
    data <- as.matrix(x[seq(from=3, to=dim(x)[2], by=1)])
    
    column.names <- column.names[!is.na(column.names)]
    
    colnames(data) <- column.names
    row.names(data) <- x[,1]
    return(list(row.descriptions=row.descriptions, data=data))
}

read.res <- function(filename)
{
  # read line 1: sample names
  headings <- read.table( filename, header=FALSE, nrows=1, sep="\t", fill=FALSE, comment.char='', check.names=FALSE)
  # delete the NA entries for the tab-tab columns
  headings <- headings[!is.na(headings)]
  colNames <- headings[3:length(headings)]
  
  # read line 2: sample descriptions
  descriptions <- scan(filename, skip=1, nlines=1, sep="\t", fill=F, blank.lines.skip=F, quiet=T, what="character")
  
  # delete the NA entries for the tab-tab columns
  
  if(length(descriptions) > 0) {
    descriptions <- descriptions[seq(from = 2, to = length(descriptions), by=2)]
  }
  # handle optionally missing number of lines (not used, but need to decide whether to ignore before actual data)  
  numLines <- as.list(read.table(filename, header=FALSE, skip=2, nrows=1, sep="\t", fill=FALSE, comment.char=''))
  numLines <- numLines[!is.na(numLines)] # remove NA entries
  skip <- (3 - ifelse(length(numLines) == 1, 0, 1)) # skip 3 lines if line number is present, 2 otherwise
  
  columns <- length(headings) - 2 # substract 2 for gene description and name 
  colClasses <- c(c("character", "character"), rep(c("double", "character"), columns))
  
  
  x <- .my.read.table(filename, header=FALSE, sep="\t", comment.char="", skip=skip, colClasses=colClasses, row.names=NULL, quote=NULL, fill=FALSE)
  
  data <- as.matrix(x[c(seq(from=3,length=(dim(x)[2]-3)/2, by=2))])
  calls <- as.matrix(x[c(seq(from=4,length=(dim(x)[2]-3)/2, by=2))])
  
  row.names <- x[,2]
  row.names(data) <- row.names
  row.names(calls) <- row.names
  row.descriptions <- as.character(x[, 1])
  colnames(data) <- colNames
  colnames(calls) <- colNames
  return(list(row.descriptions=row.descriptions, column.descriptions=descriptions, data=data, calls=calls))
}

# like read.table, but doesn't check to make sure all rows have same number of columns
.my.read.table <- function (file, header = FALSE, sep = "", quote = "\"'", dec = ".", row.names, col.names, as.is = FALSE, na.strings = "NA", colClasses, nrows = -1, skip = 0, check.names = TRUE, fill = !blank.lines.skip, strip.white = FALSE, blank.lines.skip = TRUE, comment.char = "") 
{
  if (is.character(file)) {
    file <- file(file, "r")
    on.exit(close(file))
  }
  if (!inherits(file, "connection")) 
    stop("argument `file' must be a character string or connection")
  if (!isOpen(file)) {
    open(file, "r")
    on.exit(close(file))
  }
  if (skip > 0) 
    readLines(file, skip)
  
  first <- readLines(file, n=1) 
  pushBack(first, file)
  temp <- strsplit(first, "\t") 
  cols <- as.integer(length(temp[[1]])) # number of columns
  
  if (missing(col.names)) 
    col.names <- paste("V", 1:cols, sep = "")
  
  what <- rep(list(""), cols)
  names(what) <- col.names
  colClasses[colClasses %in% c("real", "double")] <- "numeric"
  known <- colClasses %in% c("logical", "integer", "numeric", "complex", "character")
  what[known] <- sapply(colClasses[known], do.call, list(0))
  
  data <- scan(file = file, what = what, sep = sep, quote = quote, dec = dec, nmax = nrows, skip = 0, na.strings = na.strings, quiet = TRUE, fill = fill, strip.white = strip.white, blank.lines.skip = blank.lines.skip, multi.line = FALSE, comment.char = comment.char)
  nlines <- length(data[[1]])
  if (cols != length(data)) {
    warning(paste("cols =", cols, " != length(data) =", length(data)))
    cols <- length(data)
  }
  if (is.logical(as.is)) {
    as.is <- rep(as.is, length = cols)
  }
  else if (is.numeric(as.is)) {
    if (any(as.is < 1 | as.is > cols)) 
      stop("invalid numeric as.is expression")
    i <- rep(FALSE, cols)
    i[as.is] <- TRUE
    as.is <- i
  }
  else if (is.character(as.is)) {
    i <- match(as.is, col.names, 0)
    if (any(i <= 0)) 
      warning("not all columns named in as.is exist")
    i <- i[i > 0]
    as.is <- rep(FALSE, cols)
    as.is[i] <- TRUE
  }
  else if (length(as.is) != cols) 
    stop(paste("as.is has the wrong length", length(as.is), 
               "!= cols =", cols))
  if (missing(row.names)) {
    if (rlabp) {
      row.names <- data[[1]]
      data <- data[-1]
    }
    else row.names <- as.character(seq(len = nlines))
  }
  else if (is.null(row.names)) {
    row.names <- as.character(seq(len = nlines))
  }
  else if (is.character(row.names)) {
    if (length(row.names) == 1) {
      rowvar <- (1:cols)[match(col.names, row.names, 0) == 
                           1]
      row.names <- data[[rowvar]]
      data <- data[-rowvar]
    }
  }
  else if (is.numeric(row.names) && length(row.names) == 1) {
    rlabp <- row.names
    row.names <- data[[rlabp]]
    data <- data[-rlabp]
  }
  else stop("invalid row.names specification")
  class(data) <- "data.frame"
  row.names(data) <- row.names
  data
}

write.res <-
  #
  # write a res structure as a file
  #
  function(res, filename, check.file.extension=TRUE)
  {	
    calls <- res$calls
    if(is.null(calls)) {
      exit("No calls found")
    }
    # write the data
    if(!is.null(res$row.descriptions) && res$row.descriptions!='') {
      if(length(res$row.descriptions) != NROW(res$data)) {
        exit("invalid length of row.descriptions")
      }
    } 
    
    if(check.file.extension) {
      filename <- check.extension(filename, ".res")
    }
    f <- file(filename, "w")
    on.exit(close(f))
    # write the labels
    cat("Description\tAccession\t", file=f, append=TRUE)
    cat(colnames(res$data), sep="\t\t", file=f, append=TRUE)
    cat("\n", file=f, append=TRUE)
    
    # write the descriptions
    if(!is.null(res$column.descriptions)) {
      cat("\t", file=f, append=TRUE)
      cat(res$column.descriptions, sep="\t\t", file=f, append=TRUE)
    } 
    cat("\n", file=f, append=TRUE)
    
    # write the number of rows
    cat(NROW(res$data), "\n", sep="", file=f, append=TRUE)
    
    m <- cbind(res$row.descriptions, row.names(res$data))
    
    #s <- integer(0)
    #s <- c(1, 2)
    #cols <- NCOL(res$data)
    #offset <- 2
    #for(i in 1:NCOL(res$data)) {
    #	s <- c(s, i + offset)
    #	s <- c(s, cols+i + offset)
    #}
    #m <- cbind(res$data, calls)
    
    # combine matrices
    for(i in 1:NCOL(res$data)) {
      m <- cbind(m, res$data[,i])
      m <- cbind(m, as.character(calls[,i]))
    }
    
    write.table(m, file=f, col.names=FALSE, row.names=FALSE, append=TRUE, quote=FALSE, sep="\t", eol="\n")
    return(filename)
  }

read.cls <- function(file) {
  # returns a list containing the following components: 
  # labels the factor of class labels
  # names the names of the class labels if present
  
  if (is.character(file)) 
    if (file == "") 
      file <- stdin()
    else {
      file <- file(file, "r")
      on.exit(close(file))
    }
    if (!inherits(file, "connection")) 
      stop("argument `file' must be a character string or connection")
    
    line1 <- scan(file, nlines=1, what="character", quiet=TRUE)
    
    numberOfDataPoints <- as.integer(line1[1])
    numberOfClasses <- as.integer(line1[2])
    
    line2 <- scan(file, nlines=1, what="character", quiet=TRUE)
    
    classNames <- NULL
    if(line2[1] =='#') { # class names are given
      classNames <- as.vector(line2[2:length(line2)])
      line3 <- scan(file, what="character", nlines=1, quiet=TRUE)
    } else {
      line3 <- line2
    }
    
    if(is.null(classNames)) {
      labels <- as.factor(line3)
      classNames <- levels(labels)
    } else {
      labels <- factor(line3, labels=classNames)
    }
    if(numberOfDataPoints!=length(labels)) {
      stop("Incorrect number of data points") 	
    }
    r <- list(labels=labels,names=classNames)
    r
}

# writes a factor to a cls file
write.factor.to.cls <- function(factor, filename, check.file.extension=TRUE)
{
  if(check.file.extension) {
    filename <- check.extension(filename, ".cls")
  }
  file <- file(filename, "w")
  on.exit(close(file))
  codes <- unclass(factor)
  cat(file=file, length(codes), length(levels(factor)), "1\n")
  
  levels <- levels(factor)
  
  cat(file=file, "# ")
  num.levels <- length(levels)
  
  for(i in 1:(num.levels-1)) {
    cat(file=file, levels[i])
    cat(file=file, " ")
  }
  cat(file=file, levels[num.levels])
  cat(file=file, "\n")
  
  num.samples <- length(codes)
  for(i in 1:(num.samples-1)) {
    cat(file=file, codes[i]-1)
    cat(file=file, " ")
  }
  cat(file=file, codes[num.samples]-1)
  return(filename) 
}

write.cls <-
  #
  # writes a cls result to a file. A cls results is a list containing names and labels
  function(cls, filename, check.file.extension=TRUE)
  {
    if(check.file.extension) {
      filename <- check.extension(filename, ".cls")
    }
    file <- file(filename, "w")
    on.exit(close(file))
    
    cat(file=file, length(cls$labels), length(levels(cls$labels)), "1\n")
    
    # write cls names
    if(length(cls$names) > 0) {
      cat(file=file, "# ")
      i <- 1
      while(i < length(cls$names)) {
        cat(file=file, cls$names[i])
        cat(file=file, " ")
        
        i <- i+1
      }
      cat(file=file, cls$names[length(cls$names)])
      cat(file=file, "\n")
    }
    
    # write cls labels
    i <-1
    while(i < length(cls$labels)){
      cat(file=file, as.numeric(cls$labels[[i]])-1)
      cat(file=file, " ")
      
      i <- i+1
    }
    cat(file=file, as.numeric(cls$labels[[length(cls$labels)]])-1)
    
    return(filename)
  }

write.gct <-
  #
  # save a GCT result to a file, ensuring the filename has the extension .gct
  #
  function(gct, filename, check.file.extension=TRUE)
  {
    if(check.file.extension) {
      filename <- check.extension(filename, ".gct") 
    }
    if(is.null(gct$data)) {
      exit("No data given.")
    }
    if(is.null(row.names(gct$data))) {
      exit("No row names given.")
    }
    if(is.null(colnames(gct$data))) {
      exit("No column names given.")
    }
    
    rows <- dim(gct$data)[1]
    columns <- dim(gct$data)[2]
    
    if(rows!=length(row.names(gct$data))) {
      exit("Number of data rows (", rows, ") not equal to number of row names (", length(row.names(gct$data)), ").")
    }
    if(columns!=length(colnames(gct$data))) {
      exit("Number of data columns (", columns , " not equal to number of column names (", length(colnames(gct$data)), ").")
    }
    
    if(!is.null(gct$row.descriptions) && gct$row.descriptions!='') {
      if(length(gct$row.descriptions)!=rows) {
        exit("Number of row descriptions (", length(gct$row.descriptions), ") not equal to number of row names (", rows, ").")
      }
    } else {
      gct$row.descriptions <- ''
    }
    
    m <- cbind(row.names(gct$data), gct$row.descriptions, gct$data)
    f <- file(filename, "w")
    on.exit(close(f))
    
    cat("#1.2", "\n", file=f, append=TRUE, sep="")
    cat(rows, "\t", columns, "\n", file=f, append=TRUE, sep="")
    cat("Name", "\t", file=f, append=TRUE, sep="")
    cat("Description", file=f, append=TRUE, sep="")
    names <- colnames(gct$data)
    
    for(j in 1:length(names)) {
      cat("\t", names[j], file=f, append=TRUE, sep="")
    }
    
    cat("\n", file=f, append=TRUE, sep="")
    write.table(m, file=f, append=TRUE, quote=FALSE, sep="\t", eol="\n", col.names=FALSE, row.names=FALSE)
    return(filename)
  }

is.package.installed <- function(libdir, pkg) {
  f <- paste(libdir, pkg, sep='')
  return(file.exists(f) && file.info(f)[["isdir"]])
}


install.package <- function(dir, windows, mac, other) {
  isWindows <- Sys.info()[["sysname"]]=="Windows"
  isMac <- Sys.info()[["sysname"]]=="Darwin" 
  if(isWindows) {
    f <- paste(dir, windows, sep="")
    .install.windows(f)
  } else if(isMac) {
    f <- paste(dir, mac, sep="")
    .install.unix(f)
  } else { # install from source
    f <- paste(dir, other, sep="")
    .install.unix(f)
  }	
}

.install.windows <- function(pkg) {
  if(DEBUG) {
    info("Installing windows package ", pkg)
  }
  install.packages(pkg, .libPaths()[1], repos=NULL)
}

.install.unix <- function(pkg) {
  if(DEBUG) {
    info("Installing package ", pkg)
  }
  lib <- .libPaths()[1]
  # cmd <- paste(file.path(R.home(), "bin", "R"), "CMD INSTALL --with-package-versions")
  cmd <- paste(file.path(R.home(), "bin", "R"), "CMD INSTALL")
  cmd <- paste(cmd, "-l", lib)
  cmd <- paste(cmd, " '", pkg, "'", sep = "")
  status <- system(cmd)
  if (status != 0) 
    cat("\tpackage installation failed\n")
}

trim <- function(s) {
  sub(' +$', '', s, extended = TRUE) 
}

setLibPath <- function(libdir) {
  libPath <- libdir
  if(!file.exists(libdir)) {
    # remove trailing /
    libPath <- substr(libdir, 0, nchar(libdir)-1)
  }
  .libPaths(libPath)
}

yes.no.to.boolean <- function(s) {
  if(s=="yes") {
    return(TRUE)	
  }
  return(FALSE)
}

exit <- function(...) {
  args <- list(...)
  s <- paste(args)
  stop(s, call. = FALSE)
}

isWindows <- function() {
  Sys.info()[["sysname"]]=="Windows"
}


isMac <- function() {
  Sys.info()[["sysname"]]=="Darwin" 
}

unzip <- function(zip.filename, dest) {
  if(is.null(dest)) {
    dest = getwd()
  }
  if(isWindows()) {
    zip.unpack(zip.filename, dest=dest)
  } else {
    unzip <- getOption("unzip")
    system(paste(unzip, "-q", zip.filename, "-d", dest))
  }
}

get.arg <- function(key, args, default.value='') {
  if(is.null(args[key])) {
    return(default.value)
  }
  return(args[key])
}

parse.command.line <- function(args) {
  result <- list()
  for(i in 1:length(args)) {
    flag <- substring(args[[i]], 0, 2)
    value <- substring(args[[i]], 3, nchar(args[[i]]))
    if(flag=='') {
      next
    }	
    result[flag] <- value
  }
}


MISG.Res2Gct <- function(
  res.file,
  gct.file) {
  
  dataset <- MSIG.Res2Frame(filename = res.file)  # read RES file
  A <- dataset$ds
  row.names(A) <- dataset$row.names
  colnames(A) <- dataset$names
  descs <- dataset$descs
  write.gct(gct.data.frame = A, descs = descs, filename = gct.file)  
}

MSIG.ReadPhenFile <- function(file = "NULL") { 
  #
  # Reads a matrix of class vectors from a CLS file and defines phenotype and class labels vectors
  #  (numeric and character) for the samples in a gene expression file (RES or GCT format)
  #
  # The Broad Institute
  # SOFTWARE COPYRIGHT NOTICE AGREEMENT
  # This software and its documentation are copyright 2003 by the
  # Broad Institute/Massachusetts Institute of Technology.
  # All rights are reserved.
  #
  # This software is supplied without any warranty or guaranteed support
  # whatsoever. Neither the Broad Institute nor MIT can be responsible for
  # its use, misuse, or functionality.
  
  cls.cont <- readLines(file)
  num.lines <- length(cls.cont)
  temp <- unlist(strsplit(cls.cont[[1]], " "))
  if (length(temp) == 3) {
    phen.names <- NULL
    col.phen <- NULL
  } else {
    l.phen.names <- match("phen.names:", temp)
    l.col.phen <- match("col.phen:", temp)
    phen.names <- temp[(l.phen.names + 1):(l.col.phen - 1)]
    col.phen <- temp[(l.col.phen + 1):length(temp)]
  }
  temp <- unlist(strsplit(cls.cont[[2]], " "))
  phen.list <- temp[2:length(temp)]
  
  for (k in 1:(num.lines - 2)) {
    temp <- unlist(strsplit(cls.cont[[k + 2]], " "))
    if (k == 1) {
      len <- length(temp)
      class.list <- matrix(0, nrow = num.lines - 2, ncol = len)
      class.v <- matrix(0, nrow = num.lines - 2, ncol = len)
      phen <- NULL
    }
    class.list[k, ] <- temp
    classes <- unique(temp)
    class.v[k, ] <- match(temp, classes)
    phen[[k]] <- classes
  }
  if (num.lines == 3) {
    class.list <- as.vector(class.list)
    class.v <- as.vector(class.v)
    phen <- unlist(phen)
  }
  return(list(phen.list = phen.list, phen = phen, phen.names = phen.names, col.phen = col.phen,
              class.v = class.v, class.list = class.list))
}

MSIG.Gct2Frame <- function(filename = "NULL") { 
  #
  # Reads a gene expression dataset in GCT format and converts it into an R data frame
  #
  # The Broad Institute
  # SOFTWARE COPYRIGHT NOTICE AGREEMENT
  # This software and its documentation are copyright 2003 by the
  # Broad Institute/Massachusetts Institute of Technology.
  # All rights are reserved.
  #
  # This software is supplied without any warranty or guaranteed support
  # whatsoever. Neither the Broad Institute nor MIT can be responsible for
  # its use, misuse, or functionality.
  
  ds <- read.delim(filename, header=T, sep="\t", skip=2, row.names=1, blank.lines.skip=T, comment.char="", as.is=T, na.strings = "", check.names=FALSE)
  descs <- ds[,1]
  ds <- ds[-1]
  row.names <- row.names(ds)
  names <- names(ds)
  return(list(ds = ds, row.names = row.names, descs = descs, names = names))
}

MSIG.Res2Frame <- function(filename = "NULL") {
  #
  # Reads a gene expression dataset in RES format and converts it into an R data frame
  #
  # The Broad Institute
  # SOFTWARE COPYRIGHT NOTICE AGREEMENT
  # This software and its documentation are copyright 2003 by the
  # Broad Institute/Massachusetts Institute of Technology.
  # All rights are reserved.
  #
  # This software is supplied without any warranty or guaranteed support
  # whatsoever. Neither the Broad Institute nor MIT can be responsible for
  # its use, misuse, or functionality.
  
  # read line 1: sample names
  headings <- read.table( filename, header=FALSE, nrows=1, sep="\t", fill=FALSE, comment.char='')
  # delete the NA entries for the tab-tab columns
  headings <- headings[!is.na(headings)]
  colNames <- headings[3:length(headings)]
  
  # read line 2: sample descriptions
  descriptions <- scan(filename, skip=1, nlines=1, sep="\t", fill=F, blank.lines.skip=T, quiet=T, what="character")
  
  # delete the NA entries for the tab-tab columns
  
  if(length(descriptions) > 0) {
    descriptions <- descriptions[seq(from = 2, to = length(descriptions), by=2)]
  }
  # handle optionally missing number of lines (not used, but need to decide whether to ignore before actual data)  
  numLines <- as.list(read.table(filename, header=FALSE, skip=2, nrows=1, sep="\t", fill=FALSE, comment.char=''))
  numLines <- numLines[!is.na(numLines)] # remove NA entries
  skip <- (3 - ifelse(length(numLines) == 1, 0, 1)) # skip 3 lines if line number is present, 2 otherwise
  
  columns <- length(headings) - 2 # substract 2 for gene description and name 
  colClasses <- c(c("character", "character"), rep(c("double", "character"), columns))
  
  
  x <- .my.read.table(filename, header=FALSE, sep="\t", comment.char="", skip=skip, colClasses=colClasses, row.names=NULL, quote=NULL, fill=FALSE)
  
  #   descs <- ds[,1]
  #   ds <- ds[-1]
  #   row.names <- row.names(ds)
  # names <- names(ds)
  #   return(list(ds = ds, row.names = row.names, descs = descs, names = names))
  
  data <- as.matrix(x[c(seq(from=3,length=(dim(x)[2]-3)/2, by=2))])
  calls <- as.matrix(x[c(seq(from=4,length=(dim(x)[2]-3)/2, by=2))])
  names <- headings
  row.names <- x[,2]
  row.names(data) <- row.names
  row.names(calls) <- row.names
  descs <- as.character(x[, 1])
  colnames(data) <- colNames
  colnames(calls) <- colNames
  return(list(descs=descs, row.names = row.names, names=names, ds=data, calls=calls))
}

MSIG.ReadClsFile <- function(file = "NULL") { 
  #
  # Reads a class vector CLS file and defines phenotype and class labels vectors (numeric and character) for the samples in a gene expression file (RES or GCT format)
  #
  # The Broad Institute
  # SOFTWARE COPYRIGHT NOTICE AGREEMENT
  # This software and its documentation are copyright 2003 by the
  # Broad Institute/Massachusetts Institute of Technology.
  # All rights are reserved.
  #
  # This software is supplied without any warranty or guaranteed support
  # whatsoever. Neither the Broad Institute nor MIT can be responsible for
  # its use, misuse, or functionality.
  
  cls.cont <- readLines(file)
  num.lines <- length(cls.cont)
  class.list <- unlist(strsplit(cls.cont[[3]], " "))
  s <- length(class.list)
  t <- table(class.list)
  l <- length(t)
  phen <- vector(length=l, mode="character")
  class.v <- vector(length=s, mode="numeric")
  
  current.label <- class.list[1]
  current.number <- 1
  class.v[1] <- current.number
  phen[1] <- current.label
  phen.count <- 1
  
  if (length(class.list) > 1) {
    for (i in 2:s) {
      if (class.list[i] == current.label) {
        class.v[i] <- current.number
      } else {
        phen.count <- phen.count + 1
        current.number <- current.number + 1
        current.label <- class.list[i]
        phen[phen.count] <- current.label
        class.v[i] <- current.number
      }
    }
  }
  return(list(phen = phen, class.v = class.v, class.list = class.list))
}

