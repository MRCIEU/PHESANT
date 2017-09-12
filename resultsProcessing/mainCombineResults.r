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
## this file sorts the results by -
## 1) combining results if they were run in parts
## 2) combining the flow counts files into one flow, if they were run in parts
## 3) adding the descriptions of the variables from the variable info file

#install.packages("optparse");
library("optparse")

option_list = list(
	make_option(c("-t", "--test"), action="store_true", default=FALSE, help="run test pheWAS on test data (see test subfolder) [default= %default]"),
  	make_option(c("-r", "--resDir"), type="character", default=NULL, help="resDir option should specify directory where results files should be stored", metavar="character"),
	make_option(c("-b", "--numParts"), type="integer", default=NULL, help="number of phenotype parts (used to parellise)"),
	make_option(c("-v", "--variablelistfile"), type="character", default=NULL, help="variablelistfile file name (should be tab separated)", metavar="character")
);
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);
  
if (opt$test==TRUE) {
	
	opt$resDir = '../testWAS/results/';
	opt$variablelistfile = '../testWAS/variable-lists/outcome-info.tsv';
  	
} else {
	
	if (is.null(opt$variablelistfile)){
          print_help(opt_parser)
          stop("variablelistfile argument must be supplied", call.=FALSE)
        }
	if (is.null(opt$resDir)){
          print_help(opt_parser)
          stop("resDir argument must be supplied", call.=FALSE)
        }	
}

source("combineFlowCounts.r")
combineFlowCounts();
print("Finished flow counts")

source("combineResults.r")
combineResults();
print("Finished combining results")

# add the name of the variable as listed in the phenotype info file
source("addVariableDescriptions.r");
addVariableDescriptions();

# sort
resultsAll <<- resultsAll[order(resultsAll$pvalue),];

print("Finished adding variable descriptions to results listing")

write.table(resultsAll, file=paste(opt$resDir,"results-combined.txt",sep=""), row.names=FALSE, quote=FALSE, sep="\t", na="");

source("makeQQPlot.r")
makeQQPlot(opt$resDir,resultsAll) 

source("makeForestPlots.r")
junk <- makeForestPlots(opt$resDir,resultsAll)



