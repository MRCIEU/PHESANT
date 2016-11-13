#install.packages("optparse");
library("optparse")

option_list = list(
  make_option(c("-f", "--outcomefile"), type="character", default=NULL, help="phenotype dataset file name", metavar="character"),
  make_option(c("-g", "--exposurefile"), type="character", default=NULL, help="exposure dataset file name", metavar="character"),
  make_option(c("-v", "--variablelistfile"), type="character", default=NULL, help="variablelistfile file name (should be tab separated)", metavar="character"),
  make_option(c("-d", "--datacodingfile"), type="character", default=NULL, help="datacodingfile file name (should be comma separated)", metavar="character"),
  make_option(c("-e", "--exposurevariable"), type="character", default=NULL, help="exposurevariable option should specify exposure variable name", metavar="character"),
  make_option(c("-r", "--resDir"), type="character", default=NULL, help="resDir option should specify directory where results files should be stored", metavar="character"),
  make_option(c("-u", "--userId"), type="character", default="userId", help="userId option should specify user ID column in exposure and outcome files [default= %default]", metavar="character"),
  make_option(c("-t", "--test"), action="store_true", default=FALSE, help="run test pheWAS on test data (see test subfolder) [default= %default]"),
  make_option(c("-s", "--sensitivity"), action="store_true", default=FALSE, help="run sensitivity pheWAS [default= %default]"),
#  make_option(c("-x", "--varTypeArg"), help="variable type to run pheWAS on (0:integer, 1:continuous, 2:categorical single, 3: categorical multiple)")
  make_option(c("-a", "--partIdx"), type="integer", default=NULL, help="part index of phenotype (used to parellise)"),
  make_option(c("-b", "--numParts"), type="integer", default=NULL, help="number of phenotype parts (used to parellise)")
);
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

source("processArgs.r")
processArgs();

source("initFunctions.r")
loadSource();

## load the files we write to and use
count=initCounters();
initResultsFiles();
vl=initVariableLists();

print("LOADING")

## load data
d <- loadData();
data=d$datax;
confounders=d$confounders;
numPreceedingCols = ncol(confounders)+1;
phenoStartIdx = numPreceedingCols+1;

print("LOADING DONE")

phenoVars=colnames(data);
# remove user id and age and sex columns
#phenoVars = phenoVars[-c(1,2,3,4)];
phenoVars = phenoVars[-c(1,2)]; # first and second columns are the id and snpScore, respectively, as determined in loadData.r

## this decides on the start and end idxs of phentypes that we test, so that we can parallelise into multiple jobs
if (opt$varTypeArg!="all") {
	partSize = ceiling(length(phenoVars)/opt$numParts);
	partStart = (opt$partIdx-1)*partSize + 1;

	if (opt$partIdx == opt$numParts) {
		partEnd = length(phenoVars);
	} else {
		partEnd = partStart + partSize - 1;
	}

} else {
	partStart = 1;
	partEnd = length(phenoVars);
}
print(paste(partStart, '-', partEnd));

currentVar="";
currentVarShort="";
first=TRUE;

resLogFile = paste(opt$resDir,"results-log-",opt$varTypeArg,".txt",sep="")
sink(resLogFile)

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
			thisdata = cbind.data.frame(data$geno, confounders, currentVarValues);
			colnames(thisdata)[1] = "geno";

			if (phenoIdx>=partStart && phenoIdx<=partEnd) { # only start new variable processing if first column of it is within the idx range for this part
				testAssociations(currentVar, currentVarShort, thisdata);
			}
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

# last variable so test association
thisdata = cbind.data.frame(data$geno, confounders, currentVarValues);
colnames(thisdata)[1] =	"geno";
if (phenoIdx>=partStart && phenoIdx<=partEnd) {
	testAssociations(currentVar, currentVarShort, thisdata);
}

sink()

# save counters of each path in variable flow
saveCounts()


warnings()




