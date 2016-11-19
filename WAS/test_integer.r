testInteger <- function(varName, varType, thisdata) {
	cat("INTEGER || ");

	pheno = thisdata[,phenoStartIdx:ncol(thisdata)]

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

			cat("3-20 values || ")
			# we don't use equal sized bins just the original integers as categories
			thisdatanew = cbind.data.frame(thisdata[,1:numPreceedingCols], phenoFactor);

			# treat as ordinal categorical
			testCategoricalOrdered(varName, varType, thisdatanew);
		}
	}
}
