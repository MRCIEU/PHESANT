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


# Performs preprocessing of categorical (multiple) fields, namely:
# 1) Reassigning values as specified in data coding file
# 2) Generating binary variable for each category in field, restricting to correct set of participants as specified
# in CAT_MULT_INDICATOR_FIELDS field of variable info file (either NO_NAN, ALL or a field ID)
# 3) Checking derived variable has at least 10 cases in each group
# 4) Calling binaryLogisticRegression function for this derived binary variable
testCategoricalMultiple <- function(varName, varType, thisdata) {
	cat("CAT-MULTIPLE || ");

	pheno = thisdata[,phenoStartIdx:ncol(thisdata), drop=FALSE]
	pheno = reassignValue(pheno, varName)

	## get unique values from all columns of this variable
	uniqueValues = unique(na.omit(pheno[,1]));
	numCols = ncol(pheno);
	numRows = nrow(pheno);
	if (numCols>1) {
		for (num in 2:numCols) {
			u = unique(na.omit(pheno[,num]))
			uniqueValues = union(uniqueValues,u);
		}
	}

	## for each value create a binary variable and test this
	for (variableVal in uniqueValues) {

		## numeric negative values we assume are missing - check this
		if(is.numeric(variableVal) & variableVal<0) {
			cat("SKIP_val:", variableVal," < 0", sep="");
			next;
		}
	
		# make variable for this value
		idxForVar = which(pheno == variableVal, arr.ind=TRUE)
		idxsTrue = idxForVar[,"row"]

		cat(" CAT-MUL-BINARY-VAR ", variableVal, " || ", sep="");
		incrementCounter("catMul.binary")
		
		# make zero vector and set 1s for those with this variable value
		varBinary = rep.int(0,numRows);
		varBinary[idxsTrue] = 1;
		varBinaryFactor = factor(varBinary)

		## data for this new binary variable
		newthisdata = cbind.data.frame(thisdata[,1:numPreceedingCols], varBinaryFactor)

		## one of 3 ways to decide which examples are negative
        	idxsToRemove = restrictSample(varName, pheno, variableVal, thisdata[,"userID", drop=FALSE])

		if (!is.null(idxsToRemove) & length(idxsToRemove) > 0) {
			newthisdata = newthisdata[-idxsToRemove,]
		}

		facLevels = levels(newthisdata[,phenoStartIdx])		
		idxTrue = length(which(newthisdata[,phenoStartIdx]==facLevels[1]))
	        idxFalse = length(which(newthisdata[,phenoStartIdx]==facLevels[2]))
                
	        if (idxTrue<opt$mincase || idxFalse<opt$mincase) {
	                cat("CAT-MULT-SKIP-10 (", idxTrue, " vs ", idxFalse, ") || ", sep="");
			incrementCounter("catMul.10")
	        }
		else {
			isExposure = getIsCatMultExposure(varName, variableVal)

			incrementCounter("catMul.over10")
		     	# binary - so logistic regression
			binaryLogisticRegression(paste(varName, variableVal,sep="#"), varType, newthisdata, isExposure)
		}
	}
}

# restricts sample based on value in CAT_MULT_INDICATOR_FIELDS column of variable info file,
# either NO_NAN, ALL or a field ID
# returns idx's that should be removed from the sample
restrictSample <- function(varName,pheno,variableVal, userID) {

	# get definition for sample for this variable either NO_NAN, ALL or a variable ID
	varIndicator = vl$phenoInfo$CAT_MULT_INDICATOR_FIELDS[which(vl$phenoInfo$FieldID==varName)]

	return(restrictSample2(varName,pheno,varIndicator,variableVal, userID))
}


restrictSample2 <- function(varName,pheno, varIndicator,variableVal, userID) {
	
	if (varIndicator=="NO_NAN") { # remove NAs
		## remove all people with no value for this variable

		# row indexes with NA in all columns of this cat mult field		
		ind <- apply(pheno, 1, function(x) all(is.na(x)))
		naIdxs = which(ind==TRUE)
		cat("NO_NAN Remove NA participants ", length(naIdxs), " || ", sep="");
	}
	else if (varIndicator=="ALL") {

		# use all people (no missing assumed) so return empty vector
		# e.g. hospital data and death registry
		naIdxs = cbind()
		cat("ALL || ")
	}
	else if (varIndicator!="") {
		# remove people who have no value for indicator variable

		# this is so we can have indicator field that aren't instance 0 and array 0
		if (startsWith(as.character(varIndicator), 'x')) {
			indName = as.character(varIndicator)
		}
		else {
			indName = paste("x",varIndicator,"_0_0",sep="");
		}

		cat("Indicator name ", indName, " || ", sep="");
		indvarx = merge(userID, indicatorFields, by="userID", all.x=TRUE, all.y=FALSE, sort=FALSE)		
		indicatorVar = indvarx[,indName]

		# remove participants with NA value in this related field
		indicatorVar = replaceNaN(indicatorVar)
		naIdxs = which(is.na(indicatorVar))

		cat("Remove indicator var NAs: ", length(naIdxs), " || ", sep="");

		if (is.numeric(as.matrix(indicatorVar))) {
			# remove participants with value <0 in this related field - assumed missing indicators
			lessZero = which(indicatorVar<0)
			naIdxs = union(naIdxs, lessZero)
			cat("Remove indicator var <0: ", length(lessZero), " || ", sep="")
		}
	}
	else {
		stop("Categorical multiples variables need a value for CAT_MULT_INDICATOR_FIELDS", call.=FALSE)
	}

	## remove people with pheno<0 if they aren't a positive example for this variable indicator
	## because we can't know if they are a negative example or not
	if (is.numeric(as.matrix(pheno))) {
		idxForVar = which(pheno == variableVal, arr.ind=TRUE)
		idxMissing = which(pheno < 0, arr.ind=TRUE)

		# all people with <0 value and not variableVal
		naMissing = setdiff(idxMissing,idxForVar)
		
		# add these people with unknowns to set to remove from sample
		naIdxs = union(naIdxs, naMissing)
		
		cat(paste("Removed ", length(naMissing) ," examples != ", variableVal, " but with missing value (<0) || ", sep=""));
	}
	else {
		cat("Not numeric || ")
	}
	
	return(naIdxs);

}

