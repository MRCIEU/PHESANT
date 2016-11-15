testCategoricalOrdered <- function(varName, varType, thisdata, orderStr="") {

	
	pheno = thisdata[,phenoStartIdx:ncol(thisdata)]
	geno = thisdata[,"geno"]

	cat("CAT-ORD || ");
	count$ordCat <<- count$ordCat + 1;

	doCatOrdAssertions(pheno)

	uniqVar = unique(na.omit(pheno));

	# log the ordering of categories used
	orderStr = setOrderString(orderStr, uniqVar);
	cat("order: ", orderStr, " || ",  sep="");

	numNotNA = length(which(!is.na(pheno)))
	if (numNotNA<500) {
		cat("SKIP (" ,numNotNA, "< 500 examples) || ",sep="");
		count$ordCat.500 <<- count$ordCat.500 + 1;		
	}
	else {

	        phenoFactor = factor(pheno)
		cat("num categories: ", length(levels(phenoFactor)), " || ", sep="");

		# ordinal logistic regression
		sink()
		sink("/dev/null")
		require(MASS)
		require(lmtest)
		# install.packages('lmtest')

		tryCatch({
			confounders=thisdata[,2:numPreceedingCols];
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
		count$ordCat.success <<- count$ordCat.success + 1;
		
	}
}

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


	
setOrderString <- function(orderStr, uniqVar) {

	if (is.na(orderStr) || nchar(orderStr)==0) {

		orderStr="";

                uniqVarSorted = sort(uniqVar);
                first=1;
                for (i in uniqVarSorted) {
                        if (first==0) {
                                orderStr = paste(orderStr, "|",	sep="");
                        }
                        orderStr = paste(orderStr, i, sep="");
			first=0;
                }
        }
	return(orderStr);
}
