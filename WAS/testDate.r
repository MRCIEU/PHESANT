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


# Performs preprocessing of Date fields, namely:
# 1. convert date to binary - whether a participant has a date value or not
# 2) Checking derived variable has at least 10 cases in each group
# 3) Calling binaryLogisticRegression function for this derived binary variable
testDate <- function(varName, varType, thisdata) {
	cat("DATE || ")

	# convert to binary variable - whether a participant has a date value or not

	pheno = thisdata[,phenoStartIdx:ncol(thisdata)]

#	print(head(thisdata))
#	print(head(pheno))
	

	idxForVar = which(pheno!="")

	varBinary = rep.int(0,nrow(thisdata))
	varBinary[idxForVar] = 1;
	varBinaryFactor = factor(varBinary)

	incrementCounter("date.binary")


	##
	## check at least 10 in each category
	## and test with logistic regression

	facLevels = levels(varBinaryFactor)

	idxTrue = length(which(varBinaryFactor==facLevels[1]))
	idxFalse = length(which(varBinaryFactor==facLevels[2]))

	if (idxTrue<opt$mincase || idxFalse<opt$mincase) {
		cat("DATE-SKIP-10 (", idxTrue, " vs ", idxFalse, ") || ", sep="");
		incrementCounter("date.10")
	}
	else {

		isExposure = getIsExposure(varName)

		cat("DATE TO BINARY || ");
		incrementCounter("date.over10")


		newthisdata = cbind.data.frame(thisdata[,1:numPreceedingCols], varBinaryFactor)

	     	# binary - so logistic regression
		binaryLogisticRegression(varName, varType, newthisdata, isExposure)
	}
	
}


