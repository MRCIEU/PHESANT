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


# Performs ordered logistic regression test and saves results in ordered logistic results file
testCategoricalOrdered <- function(varName, varType, thisdata, orderStr="") {

	
	pheno = thisdata[,phenoStartIdx:ncol(thisdata)]
	geno = thisdata[,"geno"]

	cat("CAT-ORD || ");
	incrementCounter("ordCat")

	doCatOrdAssertions(pheno)

	uniqVar = unique(na.omit(pheno));

	# log the ordering of categories used
	orderStr = setOrderString(orderStr, uniqVar);
	cat("order: ", orderStr, " || ",  sep="");

	# check sample size
	numNotNA = length(which(!is.na(pheno)))
	if (numNotNA<500) {
		cat("CATORD-SKIP-500 (", numNotNA, ") || ",sep="");
		incrementCounter("ordCat.500")
	}
	else {
		# test this cat ordered variable with ordered logistic regression	

	        phenoFactor = factor(pheno)

		cat("num categories: ", length(unique(na.omit(phenoFactor))), " || ", sep="");

		if (opt$save == TRUE) {
			# add pheno to dataframe
			storeNewVar(thisdata[,"userID"], phenoFactor, varName, 'catOrd')
			cat("SUCCESS results-ordered-logistic");
			incrementCounter("success.ordCat")
                }
                else {

		# ordinal logistic regression
		sink()
		sink(modelFitLogFile, append=TRUE)
		print("--------------")
		print(varName)

		require(MASS)
		require(lmtest)

		### BEGIN TRYCATCH
		tryCatch({
		confounders=thisdata[,3:numPreceedingCols, drop = FALSE]


		if (opt$standardise==TRUE) {
			geno = scale(geno)
                }

		fitB <- polr(phenoFactor ~ ., data=confounders, Hess=TRUE) 

		fit <- polr(phenoFactor ~ geno + ., data=confounders, Hess=TRUE)

		# only save results if model converged
		if (fit$convergence == 0 & fitB$convergence == 0) {

		ctable <- coef(summary(fit))
		sink()
		sink(resLogFile, append=TRUE)

		ct = coeftest(fit)

		# model p value compares model to baseline model
                lres = anova(fit, fitB)
		pvalue = pchisq(lres[2,"LR stat."], df=lres[2,"   Df"], lower.tail=FALSE)

		beta = ctable["geno", "Value"];

		if (opt$confidenceintervals == TRUE) {
			se = ctable["geno", "Std. Error"]
			lower = beta - 1.96*se;
	                upper = beta + 1.96*se;
                }
                else {
                        lower = NA
                        upper = NA
                }

		write(paste(paste0("\"", varName, "\""), varType, numNotNA, beta, lower, upper, pvalue, sep=","), file=paste(opt$resDir,"results-ordered-logistic-",opt$varTypeArg,".txt",sep=""), append="TRUE");
		cat("SUCCESS results-ordered-logistic");
		incrementCounter("success.ordCat")

		isExposure = getIsExposure(varName)
                if (isExposure == TRUE) {
                        incrementCounter("success.exposure.ordCat")
                }
	
		}
		else {
			sink()
	                sink(resLogFile, append=TRUE)

			cat("MODEL DID NOT CONVERGE")
                        incrementCounter("ordCat.noconverge")
		}

		### END TRYCATCH
		}, error = function(e) {
			sink()
                        sink(resLogFile, append=TRUE)
                        cat(paste("ERROR:", varName,gsub("[\r\n]", "", e), sep=" "))
                        incrementCounter("ordCat.error")
                })
		}

	}
}

# check that the phenotype is valid - that there are more than two categories
# and that these all have at least 10 cases
# something has gone wrong if this is the case
doCatOrdAssertions <- function(pheno) {

	# assert variable has only one column    
    	if (!is.null(dim(pheno))) stop("More than one column for categorical ordered")

		uniqVar = unique(na.omit(pheno));
	
		# assert more than 2 categories
		if (length(uniqVar)<=1) stop("1 or zero values")
		if (length(uniqVar)==2) stop("this variable is binary")

		# assert each value has >= 10 examples
		for (u in uniqVar) {
     			withValIdx = which(pheno==u)
        		numWithVal = length(withValIdx);
		
			if (numWithVal<opt$mincase) stop("value with <",opt$mincase," examples")
		}
}

# If data coding file does not specify an order then we use the default order as in coding defined by Biobank
# and this function just generates a string with this order for logging purposes
setOrderString <- function(orderStr, uniqVar) {

	if (is.na(orderStr) || nchar(orderStr)==0) {

		orderStr="";

		# create order str by appending each value
                uniqVarSorted = sort(uniqVar);
                first=1;
                for (i in uniqVarSorted) {
                        if (first==0) {
                                orderStr = paste(orderStr, "|",	sep="");
                        }
			if (i>=0) # ignore missing values
                        	orderStr = paste(orderStr, i, sep="");
				first=0;
			end
                }
        }
	return(orderStr);
}
