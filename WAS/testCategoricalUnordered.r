# Tests an unordered categorical phenotype with multinomial regression
# and saves this result in the multinomial logistic results file
testCategoricalUnordered <- function(varName, varType, thisdata) {

	pheno = thisdata[,phenoStartIdx:ncol(thisdata)]
	geno = thisdata[,"geno"]

	numNotNA = length(which(!is.na(pheno)))
	if (numNotNA<500) {
		cat("CATUNORD-SKIP-500 (", numNotNA, ") || ",sep="");
		incrementCounter("unordCat.500")
	}
	else {

		phenoFactor = chooseReferenceCategory(pheno);
		reference = levels(phenoFactor)[1];
		
		sink()
		sink("/dev/null"); # hide output of model fitting
		require(nnet)
		geno = scale(thisdata[,"geno"])
		#cat("genoMean=", mean(geno), " genoSD=", sd(geno), " || ", sep="")
		
		confounders=thisdata[,2:numPreceedingCols];
		fit <- multinom(phenoFactor ~ geno + ., data=confounders)

		## baseline model with only confounders, to which we compare the model above
		fitB <- multinom(phenoFactor ~ ., data=confounders)

		## compare model to baseline model
		require(lmtest)
		lres = lrtest(fit, fitB)
		modelP = lres[2,"Pr(>Chisq)"];
		
		## save result to file
		maxFreq = length(which(phenoFactor==reference));
		numNotNA = length(which(!is.na(pheno)))
	    	write(paste(paste(varName,"-",reference,sep=""), varType, paste(maxFreq,"/",numNotNA,sep=""), -999, -999, -999, modelP, sep=","), file=paste(opt$resDir,"results-multinomial-logistic-",opt$varTypeArg,".txt",sep=""), append="TRUE")

		sink()
		sink(resLogFile, append=TRUE)	
		
		sumx <- summary(fit)
		
		z <- sumx$coefficients/sumx$standard.errors
		p = (1 - pnorm(abs(z), 0, 1))*2			

		## get result for each variable category
		uniqVar = unique(na.omit(pheno))
		for (u in uniqVar) {
		
			## no coef for baseline value, and values <0 are assumed to be missing
			if (u == reference || u<0) {
				next
			}

			pvalue = p[paste(eval(u),sep=""),"geno"]				
			beta = sumx$coefficients[paste(eval(u),sep=""),"geno"]
			se = sumx$standard.errors[paste(eval(u),sep=""),"geno"]
	        	lower = beta - 1.96 * se
			upper = beta + 1.96 * se
							
			numThisValue = length(which(phenoFactor==u));

			## save result to file
			write(paste(paste(varName,"-",reference,"#",u,sep=""), varType, paste(maxFreq,"#",numThisValue,sep=""), beta, lower, upper, pvalue, sep=","), file=paste(opt$resDir,"results-multinomial-logistic-",opt$varTypeArg,".txt",sep=""), append="TRUE")
			
		}

		cat("SUCCESS results-notordered-logistic ");
		incrementCounter("success.unordCat")

		isExposure = getIsExposure(varName)
                if (isExposure == TRUE) {
                        incrementCounter("success.exposure.unordCat")
                }

	}
}

# find reference category - category with most number of examples
chooseReferenceCategory <- function(pheno) {

	uniqVar = unique(na.omit(pheno));
	phenoFactor = factor(pheno)

	maxFreq=0;
	maxFreqVar = "";
	for (u in uniqVar) {
		withValIdx = which(pheno==u)
		numWithVal = length(withValIdx);
		if (numWithVal>maxFreq) {
			maxFreq = numWithVal;
			maxFreqVar = u;
		}
	}

	cat("reference: ", maxFreqVar,"=",maxFreq, " || ", sep="");
		
	## choose reference (category with largest frequency)
	phenoFactor <- relevel(phenoFactor, ref = paste("",maxFreqVar,sep=""))
	
	return(phenoFactor);
}




