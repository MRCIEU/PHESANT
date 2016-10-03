testContinuous <- function(varName, varType, thisdata) {
	cat("CONTINUOUS || ");

	pheno = thisdata[,phenoStartIdx:ncol(thisdata)]

	if (!is.null(dim(pheno))) {
		phenoAvg = rowMeans(pheno, na.rm=TRUE)
	}
	else {
		phenoAvg = pheno
	}

	## recode NaN to NA, which is generated if all cols of pheno are NA for a given person
	idxNan = which(is.nan(phenoAvg))
	phenoAvg[idxNan] = NA;
	numNotNA=length(na.omit(phenoAvg));

	## check whether >20% examples with same value
	uniqVar = unique(na.omit(phenoAvg))
	valid = TRUE
	for (uniq in uniqVar) {
		numWithValue = length(which(phenoAvg==uniq))
		if (numWithValue/numNotNA >=0.2) {
			valid = FALSE;
			break
		}
	}

	if (valid == FALSE) {

		## treat as ordinal categorical
		cat(">20% IN ONE CATEGORY || ");
		
		#cat(unique(phenoAvg))
		#cat(length(which(phenoAvg==0)))
		#cat(length(which(phenoAvg==1)))
		#cat(length(which(phenoAvg==2)))
		
		## remove categories if < 10 examples
	    phenoAvg = testNumExamples(phenoAvg)

		#cat(unique(phenoAvg))


		## binary if 2 distinct values, else ordered categorical
        phenoFactor = factor(phenoAvg)
        numLevels = length(levels(phenoFactor))

        if (numLevels<=1) {
            cat("SKIP (number of levels: ",numLevels,")",sep="")
			count$cont.onevalue <<- count$cont.onevalue + 1;
        }
        else if (numLevels==2) {
	        # binary
			count$cont.case2 <<- count$cont.case2 + 1;
        	thisdatanew = cbind.data.frame(thisdata[,1:numPreceedingCols], phenoFactor);			
        	binaryLogisticRegression(varName, varType, thisdatanew);
        }
        else {
			count$cont.case3 <<- count$cont.case3 + 1;

			## equal sized bins
			phenoBinned = equalSizedBins(phenoAvg);
            thisdatanew = cbind.data.frame(thisdata[,1:numPreceedingCols], phenoBinned);
			testCategoricalOrdered(varName, varType, thisdatanew);
		}
	}
	else {		
		cat("IRNT || ");
		count$cont.main <<- count$cont.main + 1;

		numNotNA = length(which(!is.na(phenoAvg)))
		if (numNotNA<500) {
            cat("SKIP (", numNotNA, "< 500 examples) || ",sep="");
			count$cont.main.500 <<- count$cont.main.500 + 1;
		}
		else {
		
			## inverse rank normal transformation
			phenoIRNT = irnt(phenoAvg)
		
			## do regression
			geno = thisdata[,"geno"] 
			confounders=thisdata[,2:numPreceedingCols];
			invisible(fit <- lm(phenoIRNT ~ geno + ., data=confounders))
			cis = confint(fit, level=0.95)
			sumx = summary(fit)

			pvalue = sumx$coefficients['geno','Pr(>|t|)']
			beta = sumx$coefficients["geno","Estimate"]
			lower = cis["geno", "2.5 %"]
			upper = cis["geno", "97.5 %"]

			numNotNA = length(which(!is.na(phenoIRNT)))

			## save result to file
			write(paste(varName, varType, numNotNA, beta, lower, upper, pvalue, sep=","), file=paste(opt$resDir,"results-linear-",opt$varTypeArg,".txt", sep=""), append="TRUE");
			cat("SUCCESS results-linear");
			count$continuous.success <<- count$continuous.success + 1;
		}
	}
}

irnt <- function(pheno) {
	set.seed(1234)
	numPhenos = length(which(!is.na(pheno)))
	quantilePheno = (rank(pheno, na.last="keep", ties.method="random")-0.5)/numPhenos
	phenoIRNT = qnorm(quantilePheno)	
	return(phenoIRNT);
}

