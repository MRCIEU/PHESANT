


# Perform binary logistic regression
#
# Performs binary logistic regression on the phenotype stored in thisdata 
# and stores result in 'results-logistic-binary' results file.
binaryLogisticRegression <- function(varName, varType, thisdata, isExposure) {

        phenoFactor = thisdata[,phenoStartIdx];

        facLevels = levels(phenoFactor)

	# assert variable has exactly two distinct values
	if (length(facLevels)!=2) {
		#stop(paste("Not 2 levels: ", length(facLevels), " || ", sep=""))
		cat("BINARY-NOT2LEVELS- (", length(facLevels), ") || ",sep="");
                incrementCounter("binary.nottwolevels")
	}

	idxTrue = length(which(phenoFactor==facLevels[1]))
	idxFalse = length(which(phenoFactor==facLevels[2]))
	numNotNA = length(which(!is.na(phenoFactor)))
  
        if (idxTrue<10 || idxFalse<10) {
		cat("BINARY-LOGISTIC-SKIP-10 (", idxTrue, "/", idxFalse, ") || ", sep="")
		incrementCounter("binary.10")
	}
	else if (numNotNA<500) {	
		cat("BINARY-LOGISTIC-SKIP-500 (", numNotNA, ") || ",sep="");
		incrementCounter("binary.500")
       	}
	else {

              	cat("sample ", idxTrue, "/", idxFalse, "(", numNotNA, ") || ", sep="");

		# use standardised geno values
                geno = scale(thisdata[,"geno"])
                confounders=thisdata[,2:numPreceedingCols];
		invisible(mylogit <- glm(phenoFactor ~ geno + ., data=confounders, family="binomial"));

                cis = confint(mylogit, level=0.95)
                sumx = summary(mylogit)

                pvalue = sumx$coefficients['geno','Pr(>|z|)']
                beta = sumx$coefficients["geno","Estimate"]
                lower = cis["geno", "2.5 %"]
                upper = cis["geno", "97.5 %"]

                numNotNA = length(na.omit(phenoFactor))

                ## save result to file
                write(paste(varName,varType,paste(idxTrue,"/",idxFalse,"(",numNotNA,")",sep=""), beta,lower,upper,pvalue, sep=","), file=paste(opt$resDir,"results-logistic-binary-",opt$varTypeArg,".txt",sep=""), append="TRUE");
                cat("SUCCESS results-logistic-binary ");
                
		incrementCounter("success.binary")

		if (isExposure==TRUE) {
	            	incrementCounter("success.exposure.binary")
	        }		
        }
}

