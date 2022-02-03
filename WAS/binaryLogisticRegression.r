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


# Perform binary logistic regression
#
# Performs binary logistic regression on the phenotype stored in thisdata 
# and stores result in 'results-logistic-binary' results file.
binaryLogisticRegression <- function(varName, varType, thisdata, isExposure) {

        phenoFactor = factor(thisdata[,phenoStartIdx])

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
  
        if (idxTrue<opt$mincase || idxFalse<opt$mincase) {
		cat("BINARY-LOGISTIC-SKIP-10 (", idxTrue, "/", idxFalse, ") || ", sep="")
		incrementCounter("binary.10")
	}
	else if (numNotNA<500) {	
		cat("BINARY-LOGISTIC-SKIP-500 (", numNotNA, ") || ",sep="");
		incrementCounter("binary.500")
       	}
	else {

              	cat("sample ", idxTrue, "/", idxFalse, "(", numNotNA, ") || ", sep="");

		if (opt$save == TRUE) {
			# add pheno to dataframe
			storeNewVar(thisdata[,"userID"], phenoFactor, varName, 'bin')
			cat("SUCCESS results-logistic-binary ");			
			incrementCounter("success.binary")
		}
		else {

		# use standardised geno values
		if (opt$standardise==TRUE) {
                	geno = scale(thisdata[,"geno"])
		}
		else {
			geno = thisdata[,"geno"]
		}
                confounders=thisdata[,3:numPreceedingCols, drop = FALSE]
		
		sink()
		sink(modelFitLogFile, append=TRUE)
		print("--------------")
		print(varName)

		###### BEGIN TRYCATCH
                tryCatch({

		mylogit <- glm(phenoFactor ~ geno + ., data=confounders, family="binomial")

		sink()
             	sink(resLogFile, append=TRUE)

		if (mylogit$converged == TRUE) {
		
                sumx = summary(mylogit)

                pvalue = sumx$coefficients['geno','Pr(>|z|)']
                beta = sumx$coefficients["geno","Estimate"]


		if (opt$confidenceintervals == TRUE) {
			cis = confint(mylogit, "geno", level=0.95)
	                lower = cis["2.5 %"]
	                upper = cis["97.5 %"]
		}
		else {
			lower = NA
			upper = NA
		}

                numNotNA = length(na.omit(phenoFactor))

                ## save result to file
                write(paste(paste0("\"", varName, "\""),varType,paste(idxTrue,"/",idxFalse,"(",numNotNA,")",sep=""), beta,lower,upper,pvalue, sep=","), file=paste(opt$resDir,"results-logistic-binary-",opt$varTypeArg,".txt",sep=""), append="TRUE");
                cat("SUCCESS results-logistic-binary ");
                
		incrementCounter("success.binary")

		}
		else {
			cat("MODEL DID NOT CONVERGE")
			incrementCounter("binary.noconverge")
		}
		

		if (isExposure==TRUE) {
	            	incrementCounter("success.exposure.binary")
	        }	

		## END TRYCATCH
                }, error = function(e) {
                        sink()
                        sink(resLogFile, append=TRUE)
                        cat(paste("ERROR:", varName,gsub("[\r\n]", "", e), sep=" "))
                        incrementCounter("binary.error")
                })
		}	
        }
}

