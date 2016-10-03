binaryLogisticRegression <- function(varName, varType, thisdata) {

#        cat("ncol ", ncol(thisdata)," || ");

        phenoFactor = thisdata[,phenoStartIdx];

        facLevels = levels(phenoFactor);
        # assert variable has only one column
		if (length(facLevels)!=2) stop(paste("Not 2 levels: ", length(facLevels), " || ", sep=""))

		idxTrue = length(which(phenoFactor==facLevels[1]))
       	idxFalse = length(which(phenoFactor==facLevels[2]))
  
        if (idxTrue<10 || idxFalse<10) stop("Less than 10 examples");

		numNotNA = length(which(!is.na(phenoFactor)))
	
		if (numNotNA<500) {
            cat("BINARY-LOGISTIC-SKIP-500 (", numNotNA, ") || ",sep="");
			count$binary.500 <<- count$binary.500 + 1;
        }
		else {

              	cat("sample ", idxTrue, "/", idxFalse, "(", numNotNA, ") || ", sep="");

                geno = thisdata[,"geno"]

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
                
                count$binary.success <<- count$binary.success + 1;
				
        }
}

