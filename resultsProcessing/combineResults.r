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


combineResults <- function() {

if (is.null(opt$numParts)) {

	resBin = loadResult(paste(opt$resDir,"results-logistic-binary-all.txt",sep=""), "LOGISTIC-BINARY");
	resMulL = loadResult(paste(opt$resDir,"results-multinomial-logistic-all.txt",sep=""), "MULTINOMIAL-LOGISTIC");
	
        # we store all the results in the multinomial model (for all categories) but here we only display the overall result (i.e. the model p value)
        resMulL = resMulL[which(resMulL$beta==-999),];

	resOrdL = loadResult(paste(opt$resDir,"results-ordered-logistic-all.txt",sep=""), "ORDERED-LOGISTIC");
	resLin = loadResult(paste(opt$resDir,"results-linear-all.txt",sep=""), "LINEAR");

	resultsAll <<- rbind.data.frame(resBin, resMulL, resOrdL, resLin);	

} else {

for (i in 1:opt$numParts) {

	resBin = loadResult(paste(opt$resDir,"results-logistic-binary-",i,"-",opt$numParts,".txt",sep=""), "LOGISTIC-BINARY");
        resMulL	= loadResult(paste(opt$resDir,"results-multinomial-logistic-",i,"-",opt$numParts,".txt",sep=""), "MULTINOMIAL-LOGISTIC");

        # we store all the results in the multinomial model (for all categories) but here we only display the overall result (i.e. the model p value)
        resMulL = resMulL[which(resMulL$beta==-999),];

        resOrdL	= loadResult(paste(opt$resDir,"results-ordered-logistic-",i,"-",opt$numParts,".txt",sep=""), "ORDERED-LOGISTIC");
        resLin = loadResult(paste(opt$resDir,"results-linear-",i,"-",opt$numParts,".txt",sep=""), "LINEAR");

	# new data frame if first file
        if (i==1) {
                resultsAll <<- rbind.data.frame(resBin, resMulL, resOrdL, resLin);
        }
	else {
              	resultsAll <<- rbind.data.frame(resultsAll, resBin, resMulL, resOrdL, resLin);
        }

}
}

}



loadResult <- function(filename, resultType) {

	if (file.exists(filename)) {
        	resBin = read.table(filename, header=1, sep=",", comment.char="", colClasses=c("character","character","character","character","character","character","numeric"));
        	resBin$resType = rep(resultType, nrow(resBin));
		return(resBin);
	}
	else {
		return(data.frame())
	}
}
