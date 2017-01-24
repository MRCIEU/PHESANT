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
		cat("num categories: ", length(levels(phenoFactor)), " || ", sep="");

		# ordinal logistic regression
		sink()
		sink("/dev/null")
		require(MASS)
		require(lmtest)

		tryCatch({
			confounders=thisdata[,2:numPreceedingCols];
			geno = scale(geno)
			fit <- polr(phenoFactor ~ geno + ., data=confounders, Hess=TRUE)
		}, error = function(e) {
			sink()
			sink(resLogFile, append=TRUE)
        		print(paste("ERROR:", varName,e))
		})

		ctable <- coef(summary(fit))
		sink()
		sink(resLogFile, append=TRUE)

		ct = coeftest(fit)
		pvalue = ct["geno","Pr(>|t|)"]
		beta = ctable["geno", "Value"];
		se = ctable["geno", "Std. Error"];
		lower = beta - 1.96*se;
		upper = beta + 1.96*se;
		
		write(paste(varName, varType, numNotNA, beta, lower, upper, pvalue, sep=","), file=paste(opt$resDir,"results-ordered-logistic-",opt$varTypeArg,".txt",sep=""), append="TRUE");
		cat("SUCCESS results-ordered-logistic");
		incrementCounter("success.ordCat")

		isExposure = getIsExposure(varName)
                if (isExposure == TRUE) {
                        incrementCounter("success.exposure.ordCat")
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
		
			if (numWithVal<10) stop("value with <10 examples")
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
