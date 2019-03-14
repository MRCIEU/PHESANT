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


# create new results files and headers
initResultsFiles <- function(opt) {

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
initVariableLists <- function(opt) {

	phenoInfo=read.table(opt$variablelistfile,sep="\t",header=1,comment.char="",quote="");

	dataCodeInfo=read.table(opt$datacodingfile,sep=",", header=1);

	vars=list(phenoInfo=phenoInfo, dataCodeInfo=dataCodeInfo);
	return(vars);
}











