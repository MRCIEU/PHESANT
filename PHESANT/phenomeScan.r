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

## Updated by Quanli Wang 

library(PHESANT)
library("optparse")

args <- commandArgs(T)
if (length(args) == 0) {
  load(file = "opt_only.RData")
} else {
  opt_parser = OptionParser(option_list=option_list);
  opt = parse_args(opt_parser);
  processArgs();
}

## load the files we write to and use
counters=initCounters();
if (opt$save==FALSE) {
	initResultsFiles();
}
vl=initVariableLists();

## load data
d <- loadData(vl)
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
			testAssociations(vl, currentVar, currentVarShort, thisdata)
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
	testAssociations(vl, currentVar, currentVarShort, thisdata)
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



