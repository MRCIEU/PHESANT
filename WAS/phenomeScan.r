# The MIT License (MIT)
# Copyright (c) 2017 Louise AC Millard, MRC Integrative Epidemiology Unit, University of Bristol
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
# documentation files (the "Software"), to deal in the Software without restriction, including without 
# limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of 
# the Software, and to permit persons to whom the Software is furnished to do so, subject to the following 
# conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions 
# of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
# TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
# DEALINGS IN THE SOFTWARE.

##
## main phenome scan file


# allow script to be run from other directories
initial.options <- commandArgs(trailingOnly = FALSE)
file.arg.name <- "--file="
script.name <- sub(file.arg.name, "", initial.options[grep(file.arg.name, initial.options)])
script.basename <- dirname(script.name)
setwd(script.basename)


library("optparse")

option_list = list(
  make_option(c("-f", "--phenofile"), type="character", default=NULL, help="Phenotype dataset file name", metavar="character"),
  make_option(c("-g", "--traitofinterestfile"), type="character", default=NULL, help="Trait of interest dataset file name", metavar="character"),
  make_option(c("-v", "--variablelistfile"), type="character", default=NULL, help="variablelistfile file name (should be tab separated)", metavar="character"),
  make_option(c("-d", "--datacodingfile"), type="character", default=NULL, help="datacodingfile file name (should be comma separated)", metavar="character"),
  make_option(c("-e", "--traitofinterest"), type="character", default=NULL, help="traitofinterest option should specify trait of interest variable name", metavar="character"),
  make_option(c("-r", "--resDir"), type="character", default=NULL, help="resDir option should specify directory where results files should be stored", metavar="character"),
  make_option(c("-u", "--userId"), type="character", default="userId", help="userId option should specify user ID column in trait of interest and phenotype files [default= %default]", metavar="character"),
  make_option(c("-t", "--test"), action="store_true", default=FALSE, help="Run test phenome scan on test data (see test subfolder) [default= %default]"),
  make_option(c("-s", "--sensitivity"), action="store_true", default=FALSE, help="Run sensitivity phenome scan [default= %default]"),
  make_option(c("-a", "--partIdx"), type="integer", default=NULL, help="Part index of phenotype (used to parellise)"),
  make_option(c("-b", "--numParts"), type="integer", default=NULL, help="Number of phenotype parts (used to parellise)"),
  make_option(c("-j", "--genetic"), action="store", default=TRUE, help="Trait of interest is genetic, e.g. a SNP or genetic risk score [default= %default]"),
  make_option(c("-z", "--save"), action="store_true", default=FALSE, help="Save generated phenotypes to a file rather than testing associations [default= %default]"),
  make_option(c("-c", "--confounderfile"), type="character", default=NULL, help="Confounder file name", metavar="character"),
  make_option(c("-i", "--confidenceintervals"), type="logical", default=TRUE, help="Whether confidence intervals should be calculated [default= %default]"),
  make_option(c("-k", "--standardise"), action="store", default=TRUE, help="Trait of interest is standardised to have mean=0 and std=1 [default= %default]"),
  make_option(c("-m", "--mincase"), type="integer", default=10, help="Minimum number of cases for categorical outcomes"),
  make_option(c("-p", "--tab"), action="store", default=FALSE, help="Phenotype (outcome) file is tab rather than comma seperated [default= %default]")
);
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

source("processArgs.r")
processArgs();

source("initFunctions.r")
loadSource();

## load the files we write to and use
counters=initCounters();
if (opt$save==FALSE) {
	initResultsFiles();
}
vl=initVariableLists();

## load data
d <- loadData()
data=d$datax
confounders=d$confounders
indicatorFields=d$inds

numPreceedingCols = ncol(confounders)-1+2; # confounders,minus id column, plus trait of interest and user ID
phenoStartIdx = numPreceedingCols+1;

print("LOADING DONE")

phenoVars=colnames(data);
# remove user id and age and sex columns
phenoVars = phenoVars[-c(1,2)]; # first and second columns are the id and snpScore, respectively, as determined in loadData.r

currentVar="";
currentVarShort="";
first=TRUE;

if (opt$save == TRUE) {

	derivedBinary <- data.frame(userID=data$userID)
        derivedCont <- data.frame(userID=data$userID)
        derivedCatOrd <- data.frame(userID=data$userID)
        derivedCatUnord <- data.frame(userID=data$userID)

	resLogFile = paste(opt$resDir,"data-log-",opt$varTypeArg,".txt",sep="")
        sink(resLogFile)
} else {
	modelFitLogFile = paste(opt$resDir,"modelfit-log-",opt$varTypeArg,".txt",sep="")
	sink(modelFitLogFile)
	sink()

	resLogFile = paste(opt$resDir,"results-log-",opt$varTypeArg,".txt",sep="")
	sink(resLogFile)
}


phenoIdx=0; # zero because then the idx is the position of the previous variable, i.e. the var in currentVar
for (var in phenoVars) { 


	sink()
#	print(var)
	sink(resLogFile, append=TRUE)

	varx = gsub("^x", "", var);
        varx = gsub("_[0-9]+$", "", varx);
	varxShort = gsub("^x", "", var);
        varxShort = gsub("_[0-9]+_[0-9]+$", "", varxShort);

	## test this variable
	if (currentVar == varx) {
		thisCol = data[,eval(var)]
		thisCol = replaceNaN(thisCol)
		currentVarValues = cbind.data.frame(currentVarValues, thisCol);
	}
	else if (currentVarShort == varxShort) {
		## different time point of this var so skip
	}
	else {
		## new variable so run test for previous (we have collected all the columns now)
		if (first==FALSE) {

			thisdata = makeTestDataFrame(data, confounders, currentVarValues)
			testAssociations(currentVar, currentVarShort, thisdata)
		}
		
		first=FALSE;
		
		## new variable so set values
		currentVar = varx;
		currentVarShort = varxShort;

		currentVarValues = data[,eval(var)]
		currentVarValues = replaceNaN(currentVarValues)
	}

	phenoIdx = phenoIdx + 1;
}

if (phenoIdx>0){
	# last variable so test association
	thisdata = makeTestDataFrame(data, confounders, currentVarValues)
	testAssociations(currentVar, currentVarShort, thisdata)
}

sink()

# save counters of each path in variable flow
saveCounts()

if (opt$save == TRUE) {
	write.table(derivedBinary, file=paste(opt$resDir,"data-binary-",opt$varTypeArg,".txt", sep=""), append=FALSE, quote=FALSE, sep=",", na="", row.names=FALSE, col.names=TRUE);
	write.table(derivedCont, file=paste(opt$resDir,"data-cont-",opt$varTypeArg,".txt", sep=""), append=FALSE, quote=FALSE, sep=",", na="", row.names=FALSE, col.names=TRUE);
	write.table(derivedCatOrd, file=paste(opt$resDir,"data-catord-",opt$varTypeArg,".txt", sep=""), append=FALSE, quote=FALSE, sep=",", na="", row.names=FALSE, col.names=TRUE);
	write.table(derivedCatUnord, file=paste(opt$resDir,"data-catunord-",opt$varTypeArg,".txt", sep=""), append=FALSE, quote=FALSE, sep=",", na="", row.names=FALSE, col.names=TRUE);
}

warnings()



