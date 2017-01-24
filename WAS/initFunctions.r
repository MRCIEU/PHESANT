

# load the required r files
loadSource <- function() {
	source("loadData.r")
	source("reassignValue.r")
	source("validateInput.r")
	source("testNumExamples.r")
	source("binaryLogisticRegression.r")
	source("equalSizedBins.r")
	source("fixOddFieldsToCatMul.r")
	source("replaceMissingCodes.r")
	source("replaceNaN.r")
	source("testAssociations.r")
	source("testCatMultiple.r")
	source("testCatSingle.r")
	source("testContinuous.r")
	source("testInteger.r")
	source("testCategoricalOrdered.r")
	source("testCategoricalUnordered.r")
	source("saveCounts.r")
	source("incrementCounter.r")
	source("getIsCatMultExposure.r")
	source("getIsExposure.r")
}

# init the counters used to determine how many variables took each path in the variable processing flow.
initCounters <- function() {
	counters = data.frame(name=character(),countValue=integer(), stringsAsFactors=FALSE)
	return(counters);
}

# create new results files and headers
initResultsFiles <- function() {

	## only linear and continuous fields can create linear results
	file.create(paste(opt$resDir,"results-linear-",opt$varTypeArg,".txt",sep=""));
	write("varName,varType,n,beta,lower,upper,pvalue", file=paste(opt$resDir,"results-linear-",opt$varTypeArg,".txt",sep=""), append="TRUE");

	## all field types can create binary results	
	file.create(paste(opt$resDir,"results-logistic-binary-",opt$varTypeArg,".txt",sep=""));
	write("varName,varType,n,beta,lower,upper,pvalue", file=paste(opt$resDir,"results-logistic-binary-",opt$varTypeArg,".txt",sep=""), append="TRUE");

	## only categorical multiple cannot generate order categorical results
	file.create(paste(opt$resDir,"results-ordered-logistic-",opt$varTypeArg,".txt",sep=""));
	write("varName,varType,n,beta,lower,upper,pvalue", file=paste(opt$resDir,"results-ordered-logistic-",opt$varTypeArg,".txt",sep=""), append="TRUE");
	
	## only categorical single fields can generate unordered categorical results
	file.create(paste(opt$resDir,"results-multinomial-logistic-",opt$varTypeArg,".txt",sep=""));
	write("varName,varType,n,beta,lower,upper,pvalue", file=paste(opt$resDir,"results-multinomial-logistic-",opt$varTypeArg,".txt",sep=""), append="TRUE");
	
}

# load the variable information and data code information files
initVariableLists <- function() {

	phenoInfo=read.table(opt$variablelistfile,sep="\t",header=1,comment.char="",quote="");

	dataCodeInfo=read.table(opt$datacodingfile,sep=",", header=1);

	vars=list(phenoInfo=phenoInfo, dataCodeInfo=dataCodeInfo);
	return(vars);
}











