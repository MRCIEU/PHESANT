# Processing integer fields, namely:
# 1) Reassigning values as specified in the data code information file
# 2) Generate a single value if there are several values (arrays) by taking the mean
# 3) Treating this field as continuous if at least 20 distinct values.
# Otherwise treat as binary or ordered categorical if 2 or more than two values. 
testInteger <- function(varName, varType, thisdata) {
	cat("INTEGER || ");

	pheno = thisdata[,phenoStartIdx:ncol(thisdata)]
	isExposure = getIsExposure(varName)

	if (!is.numeric(as.matrix(pheno))) {
		cat("SKIP Integer type but not numeric",sep="");
		return(NULL)
	}

	pheno = reassignValue(pheno, varName)

	## average if multiple columns
	if (!is.null(dim(pheno))) {
                phenoAvg = rowMeans(pheno, na.rm=TRUE)
		
		# if participant only has NA values then NaN is generated so we convert back to NA
		phenoAvg = replaceNaN(phenoAvg)
        }
	else {
                phenoAvg = pheno
        }

	uniqVar = unique(na.omit(phenoAvg))

	# if >=20 separate values then treat as continuous
	if (length(uniqVar)>=20) {
		
		thisdatanew = cbind.data.frame(thisdata[,1:numPreceedingCols], phenoAvg);
		testContinuous2(varName, varType, thisdatanew)
		incrementCounter("int.continuous")
	}
	else {
		
		## remove categories if < 10 examples
	    	phenoAvg = testNumExamples(phenoAvg)
	    
		## binary if 2 distinct values, else ordered categorical
		phenoFactor = factor(phenoAvg)
		numLevels = length(levels(phenoFactor))
		if (numLevels<=1) {
			cat("SKIP (number of levels: ",numLevels,")",sep="");
			incrementCounter("int.onevalue")
		}
		else if (numLevels==2) {
			incrementCounter("int.binary")

			# binary
			thisdatanew = cbind.data.frame(thisdata[,1:numPreceedingCols], phenoFactor);
			binaryLogisticRegression(varName, varType, thisdatanew, isExposure);
		}
		else {
			incrementCounter("int.catord")
			cat("3-20 values || ")

			# we don't use equal sized bins just the original integers (that have >=10 examples) as categories
			thisdatanew = cbind.data.frame(thisdata[,1:numPreceedingCols], phenoFactor);

			# treat as ordinal categorical
			testCategoricalOrdered(varName, varType, thisdatanew);
		}
	}
}
