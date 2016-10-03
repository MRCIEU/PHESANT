testInteger <- function(varName, varType, thisdata) {
	cat("INTEGER || ");

	pheno = thisdata[,phenoStartIdx:ncol(thisdata)]

	## average if multiple columns
	if (!is.null(dim(pheno))) {
                phenoAvg = rowMeans(pheno, na.rm=TRUE)
        }
	else {
                phenoAvg = pheno
        }

	uniqVar = unique(na.omit(phenoAvg))

	# if >=20 separate values then treat as continuous
	if (length(uniqVar)>=20) {
		
		thisdatanew = cbind.data.frame(thisdata[,1:numPreceedingCols], phenoAvg);
		testContinuous(varName, varType, thisdatanew)
		count$int.case1 <<- count$int.case1 + 1;
	}
	else {
		
		## remove categories if < 10 examples
	    phenoAvg = testNumExamples(phenoAvg)
	    
		## binary if 2 distinct values, else ordered categorical
		phenoFactor = factor(phenoAvg)
		numLevels = length(levels(phenoFactor))
		if (numLevels<=1) {
			cat("SKIP (number of levels: ",numLevels,")",sep="");
			count$int.onevalue <<- count$int.onevalue + 1;
		}
		else if (numLevels==2) {
			count$int.case2 <<- count$int.case2 + 1;

			# binary
			thisdatanew = cbind.data.frame(thisdata[,1:numPreceedingCols], phenoFactor);
			binaryLogisticRegression(varName, varType, thisdatanew);
		}
		else {
			count$int.case3 <<- count$int.case3 + 1;
			# we don't use equal sized bins just the original integers as categories
#			phenoBinned = equalSizedBins(phenoAvg);
#			thisdatanew = cbind.data.frame(thisdata[,1:numPreceedingCols], phenoBinned);
			thisdatanew = cbind.data.frame(thisdata[,1:numPreceedingCols], phenoFactor);

			# treat as ordinal categorical
			testCategoricalOrdered(varName, varType, thisdatanew);
		}
	}
}
