


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
}


initCounters <- function() {

	# data flow counters 
	count = list(
	cont=0, int=0, catSin=0, catMul=0,
	notinphenofile=0,
	cont.main=0, cont.main.500=0,
	cont.onevalue=0, cont.case2=0, cont.case3=0,
	int.case1=0, int.case2=0, int.case3=0,
	int.onevalue=0, 
	catSin.case1=0, catSin.case2=0, catSin.case3=0, catSin.binaryorexcluded=0, catSin.onevalue=0,
	ordCat=0, ordCat.500=0,
	unordCat.500=0,
	catMul.binary=0, catMul.10=0, catMul.over10=0,
	binary.500=0,
	continuous.success=0,ordCat.success=0,unordCat.success=0,binary.success=0,
	excluded.int=0,excluded.cont=0, excluded.catSin=0, excluded.catMul=0)
	
	return(count);

}

initResultsFiles <- function() {

	## create new results files and headers
	## only particular result types can be generated depending on the initial field type (continuous, integer, categorical single or categorical multiple)
	
#	if (opt$varTypeArg==0 || opt$varTypeArg==1) {
		file.create(paste(opt$resDir,"results-linear-",opt$varTypeArg,".txt",sep=""));
		write("varName,varType,n,beta,lower,upper,pvalue", file=paste(opt$resDir,"results-linear-",opt$varTypeArg,".txt",sep=""), append="TRUE");
#	}

	## all field types can create binary results	
	file.create(paste(opt$resDir,"results-logistic-binary-",opt$varTypeArg,".txt",sep=""));
	write("varName,varType,n,beta,lower,upper,pvalue", file=paste(opt$resDir,"results-logistic-binary-",opt$varTypeArg,".txt",sep=""), append="TRUE");

	## only categorical multiple cannot generate order categorical results
#	if (opt$varTypeArg==0 || opt$varTypeArg==1 || opt$varTypeArg==2) {
		file.create(paste(opt$resDir,"results-ordered-logistic-",opt$varTypeArg,".txt",sep=""));
		write("varName,varType,n,beta,lower,upper,pvalue", file=paste(opt$resDir,"results-ordered-logistic-",opt$varTypeArg,".txt",sep=""), append="TRUE");
#	}
	
	## only categorical single fields can generate unordered categorical results
#	if (opt$varTypeArg==2) {
		file.create(paste(opt$resDir,"results-multinomial-logistic-",opt$varTypeArg,".txt",sep=""));
		write("varName,varType,n,beta,lower,upper,pvalue", file=paste(opt$resDir,"results-multinomial-logistic-",opt$varTypeArg,".txt",sep=""), append="TRUE");
#	}
	
}

initVariableLists <- function() {

	phenoInfo=read.table(opt$variablelistfile,sep="\t",header=1,comment.char="",quote="");

	dataCodeInfo=read.table(opt$datacodingfile,sep=",", header=1);

	vars=list(phenoInfo=phenoInfo, dataCodeInfo=dataCodeInfo);
	return(vars);
}











