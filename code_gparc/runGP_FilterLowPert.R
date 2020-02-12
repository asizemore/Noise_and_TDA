## The Broad Institute
## SOFTWARE COPYRIGHT NOTICE AGREEMENT
## This software and its documentation are copyright (2013) by the
## Broad Institute/Massachusetts Institute of Technology. All rights are
## reserved.
##
## This software is supplied without any warranty or guaranteed support
## whatsoever. Neither the Broad Institute nor MIT can be responsible for its
## use, misuse, or functionality.

print("Beginning runGP_FilterLowPert")

args <- commandArgs(trailingOnly=TRUE)

vers <- "2.15"            # R version
libdir <- args[1]
server.dir <- args[2]
patch.dir <- args[3]

source(file.path(libdir, "loadRLibrary.R"))
load.packages(libdir, patch.dir, server.dir, vers)

print("Packages loaded")

option_list <- list(
  make_option("--GCT.files", dest="GCT.files"),
  make_option("--extension", dest="extension")
)

opt <- parse_args(OptionParser(option_list=option_list), positional_arguments=TRUE, args=args)
print(opt)
opts <- opt$options

print("Beginning to source all R scripts")

source(file.path(libdir, "read_gct.R"))
source(file.path(libdir, "PertdataAchilles.R"))
source(file.path(libdir, "writeGCTresults.R"))
source(file.path(libdir, "FilterLowPert.R"))
source(file.path(libdir, "AchillesTeam_common.R"))

print("All R scripts sourced")

sessionInfo()

print("Beginning Function")

gctFiles <- readLines(opts$GCT.files)
gctFile1 <- gctFiles[1]
gctFile2 <- NULL
gctFile3 <- NULL
gctFile4 <- NULL
gctFile5 <- NULL
gctFile6 <- NULL
gctFile7 <- NULL

if(length(gctFiles) == 2){
  gctFile2 <- gctFiles[2]
} else if(length(gctFiles) == 3){
  gctFile2 = gctFiles[2]
  gctFile3 <- gctFiles[3]
} else if(length(gctFiles) == 4){
  gctFile2 = gctFiles[2]
  gctFile3 = gctFiles[3]
  gctFile4 = gctFiles[4]
} else if(length(gctFiles) == 5){
  gctFile2 = gctFiles[2]
  gctFile3 = gctFiles[3]
  gctFile4 = gctFiles[4]
  gctFile5 = gctFiles[5]
} else if(length(gctFiles) == 6){
  gctFile2 = gctFiles[2]
  gctFile3 = gctFiles[3]
  gctFile4 = gctFiles[4]
  gctFile5 = gctFiles[5]
  gctFile6 = gctFiles[6]
} else if(length(gctFiles) == 7){
  gctFile2 = gctFiles[2]
  gctFile3 = gctFiles[3]
  gctFile4 = gctFiles[4]
  gctFile5 = gctFiles[5]
  gctFile6 = gctFiles[6]
  gctFile7 = gctFiles[7]
}

FilterLowPert(gctFile1, opts$extension, gctFile2, gctFile3, gctFile4, gctFile5, gctFile6, gctFile7)