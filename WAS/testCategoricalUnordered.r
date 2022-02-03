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


# Tests an unordered categorical phenotype with multinomial regression
# and saves this result in the multinomial logistic results file
testCategoricalUnordered <- function(varName, varType, thisdata) {

	pheno = thisdata[,phenoStartIdx:ncol(thisdata)]
	#geno = thisdata[,"geno"]

	numNotNA = length(which(!is.na(pheno)))
	if (numNotNA<500) {
		cat("CATUNORD-SKIP-500 (", numNotNA, ") || ",sep="");
		incrementCounter("unordCat.500")
	}
	else {

		# check there are not too many levels and skip if there are
		numUnique = length(unique(na.omit(pheno)))

		# num outcome values * (num confounders and trait of interest and bias term)
		numWeights=(numUnique-1)*((numPreceedingCols-2)+1+1)
		if (numWeights>1000) {
			cat("Too many weights in model: ", numWeights, " > 1000, (num outcomes values: ", numUnique, ") || SKIP ", sep="")
			incrementCounter("unordCat.cats")
			return(NULL)
		}

		phenoFactor = chooseReferenceCategory(pheno);

		if (opt$save == TRUE) {
			# add pheno to dataframe
			storeNewVar(thisdata[,"userID"], phenoFactor, varName, 'catUnord')
			cat("SUCCESS results-notordered-logistic ");
	                incrementCounter("success.unordCat")
		}
                else {
		

		reference = levels(phenoFactor)[1];

		sink()
		sink(modelFitLogFile, append=TRUE) # hide output of model fitting
		print("--------------")
                print(varName)

		require(nnet)
		if (opt$standardise==TRUE) {
                	geno = scale(thisdata[,"geno"])
                }
		else {
                        geno = thisdata[,"geno"] 
                }
		#cat("genoMean=", mean(geno), " genoSD=", sd(geno), " || ", sep="")
		
		confounders=thisdata[,3:numPreceedingCols, drop = FALSE]

		###### BEGIN TRYCATCH
		tryCatch({

		fit <- multinom(phenoFactor ~ geno + ., data=confounders, maxit=1000)

		## baseline model with only confounders, to which we compare the model above
		fitB <- multinom(phenoFactor ~ ., data=confounders, maxit=1000)

		# only store results if both models have converged
		if (fit$convergence == 0 & fitB$convergence == 0) {

		## compare model to baseline model
		lres = anova(fit, fitB)
		modelP = pchisq(lres[2,"LR stat."], df=lres[2,"   Df"], lower.tail=FALSE)
		
		## save result to file
		maxFreq = length(which(phenoFactor==reference));
		numNotNA = length(which(!is.na(pheno)))
	    	write(paste(paste0("\"",varName,"-",reference,"\""), varType, paste(maxFreq,"/",numNotNA,sep=""), -999, -999, -999, modelP, sep=","), file=paste(opt$resDir,"results-multinomial-logistic-",opt$varTypeArg,".txt",sep=""), append="TRUE")

		sink()
		sink(resLogFile, append=TRUE)	
		
		sumx <- summary(fit)
		
		z <- sumx$coefficients/sumx$standard.errors
		p = (1 - pnorm(abs(z), 0, 1))*2			

		ci <- confint(fit, "geno", level=0.95)
		ci = data.frame(ci)

		## get result for each variable category
		uniqVar = unique(na.omit(pheno))
		for (u in uniqVar) {
		
			## no coef for baseline value, and values <0 are assumed to be missing
			if (u == reference || u<0) {
				next
			}

			pvalue = p[paste(eval(u),sep=""),"geno"]				
			beta = sumx$coefficients[paste(eval(u),sep=""),"geno"]
							
			if (opt$confidenceintervals == TRUE) {
				lower = ci[1, paste("X2.5...", u, sep="")]
				upper =	ci[1, paste("X97.5...", u, sep="")]
                	}
                	else {
                	      	lower = NA
                	        upper = NA
                	}

			numThisValue = length(which(phenoFactor==u));

			## save result to file
			write(paste(paste("\"", varName,"-",reference,"#",u,"\"", sep=""), varType, paste(maxFreq,"#",numThisValue,sep=""), beta, lower, upper, pvalue, sep=","), file=paste(opt$resDir,"results-multinomial-logistic-",opt$varTypeArg,".txt",sep=""), append="TRUE")
			
		}

		cat("SUCCESS results-notordered-logistic ");
		incrementCounter("success.unordCat")

		isExposure = getIsExposure(varName)
                if (isExposure == TRUE) {
                        incrementCounter("success.exposure.unordCat")
                }

		}
		else {
			sink()
	                sink(resLogFile, append=TRUE)

			cat("MODEL DID NOT CONVERGE")
                        incrementCounter("unordCat.noconverge")
		}
		
		## END TRYCATCH
		}, error = function(e) {
                        sink()
                        sink(resLogFile, append=TRUE)
                        cat(paste("ERROR:", varName,gsub("[\r\n]", "", e), sep=" "))
                	incrementCounter("unordCat.error")
		})
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




