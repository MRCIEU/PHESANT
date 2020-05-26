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


# Main function called for continuous fields
testContinuous <- function(varName, varType, thisdata) {

	cat("CONTINUOUS MAIN || ");	

	pheno = thisdata[,phenoStartIdx:ncol(thisdata)]

	# reassign values
        pheno = reassignValue(pheno, varName)

	thisdata[,phenoStartIdx:ncol(thisdata)] = pheno

	testContinuous2(varName, varType, thisdata)
	
}

# Main code used to process continuous fields, or integer fields that have been reassigned as continuous because they have >20 distinct values.
# This is needed because we have already reassigned values for integer fields, so do this in the function above for continuous fields.
testContinuous2 <- function(varName, varType, thisdata) {
	cat("CONTINUOUS || ");

	pheno = thisdata[,phenoStartIdx:ncol(thisdata)]
	isExposure = getIsExposure(varName)

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
		
		# if >2 unique values then treat as ordered categorical
		numUniqueValues = length(uniqVar)

		# straight forward case that there are two (or one) values		
		if (numUniqueValues<=2) {
			## treat as binary or skip (binary requires>=10 per category)

			## remove categories if < 10 examples to see if this should be binary or not, but if ordered categorical
			## then we include all values when generating this
	    		phenoAvgMoreThan10 = testNumExamples(phenoAvg)

			## binary if 2 distinct values, else ordered categorical
        		phenoFactor = factor(phenoAvgMoreThan10)
        		numLevels = length(unique(na.omit(phenoAvgMoreThan10))) #length(levels(phenoFactor))

        		if (numLevels<=1) {
       				cat("SKIP (number of levels: ",numLevels,")",sep="")
				incrementCounter("cont.onevalue")
        		}
        		else if (numLevels==2) {
	        		# binary
				incrementCounter("cont.binary")
        			thisdatanew = cbind.data.frame(thisdata[,1:numPreceedingCols], phenoFactor);			
        			binaryLogisticRegression(varName, varType, thisdatanew, isExposure);
        		}
        	}
		else {
			## try to treat as ordered categorical

			incrementCounter("cont.ordcattry")
			## equal sized bins
			phenoBinned = equalSizedBins(phenoAvg);

			# check number of people in each bin
			bin0Num = length(which(phenoBinned==0))
			bin1Num = length(which(phenoBinned==1))
			bin2Num = length(which(phenoBinned==2))

			if (bin0Num>=opt$mincase & bin1Num>=opt$mincase & bin2Num>=opt$mincase) {

				# successful binning. >=10 examples in each of the 3 bins

				incrementCounter("cont.ordcattry.ordcat")
			        thisdatanew = cbind.data.frame(thisdata[,1:numPreceedingCols], phenoBinned);
				testCategoricalOrdered(varName, varType, thisdatanew);
			}
			else {
				# try to treat as binary because not enough examples in each bin
								
				if (bin0Num<opt$mincase & bin2Num<opt$mincase) {
					## skip - not possible to create binary variable because first and third bins are too small
					## ie. could merge bin1 with bin 2 but then bin3 still too small etc
					cat("SKIP 2 bins are too small || ")
	                                incrementCounter("cont.ordcattry.smallbins")
				} 
				else if ((bin0Num<opt$mincase | bin1Num<opt$mincase) & (bin0Num+bin1Num)>=opt$mincase) {

					# combine first and second bin to create binary variable
					incrementCounter("cont.ordcattry.binsbinary")
					cat("Combine first two bins and treat as binary || ")
					phenoBinned[which(phenoBinned==0)] = 1	

					# test binary
					thisdatanew = cbind.data.frame(thisdata[,1:numPreceedingCols], phenoBinned)
	                                binaryLogisticRegression(varName, varType, thisdatanew, isExposure);
				}
				else if ((bin2Num<opt$mincase | bin1Num<opt$mincase) & (bin2Num+bin1Num)>=opt$mincase) {

					# combine second and last bin to create binary variable
					incrementCounter("cont.ordcattry.binsbinary")
					cat("Combine last two bins and treat as binary || ")
                                        phenoBinned[which(phenoBinned==2)] = 1
					
                                        # test binary
                                        thisdatanew = cbind.data.frame(thisdata[,1:numPreceedingCols], phenoBinned)
                                        binaryLogisticRegression(varName, varType, thisdatanew, isExposure)
                                }
				

				else {
					## skip - not possible to create binary variable because combining bins would still be too small
					cat("SKIP 2 bins are too small(2) || ")
                                        incrementCounter("cont.ordcattry.smallbins2")
				}

			}
	
		}
	}
	else {		
		cat("IRNT || ");
		incrementCounter("cont.main")

		# check there are at least 500 examples
		numNotNA = length(which(!is.na(phenoAvg)))
		if (numNotNA<500) {
			cat("CONTINUOUS-SKIP-500 (", numNotNA, ") || ",sep="");
			incrementCounter("cont.main.500")
		}
		else {
			## inverse rank normal transformation
			phenoIRNT = irnt(phenoAvg)

			if (opt$save == TRUE) {
				# add pheno to dataframe
				storeNewVar(thisdata[,"userID"], phenoIRNT, varName, 'cont')
				cat("SUCCESS results-linear");
	                        incrementCounter("success.continuous")
                        }
                        else {
		
			## do regression (use standardised geno values)
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

			fit <- lm(phenoIRNT ~ geno + ., data=confounders)
			
			sink()
			sink(resLogFile, append=TRUE)
			
			sumx = summary(fit)

			pvalue = sumx$coefficients['geno','Pr(>|t|)']
			beta = sumx$coefficients["geno","Estimate"]

			if (opt$confidenceintervals == TRUE) {
				cis = confint(fit, level=0.95)
				lower = cis["geno", "2.5 %"]
	                        upper = cis["geno", "97.5 %"]
                        }
                        else {
                                lower = NA
                                upper = NA
                        }

			numNotNA = length(which(!is.na(phenoIRNT)))

			## save result to file
			write(paste(paste0("\"", varName, "\""), varType, numNotNA, beta, lower, upper, pvalue, sep=","), file=paste(opt$resDir,"results-linear-",opt$varTypeArg,".txt", sep=""), append="TRUE");
			cat("SUCCESS results-linear");

			incrementCounter("success.continuous")
                	if (isExposure == TRUE) {
                	        incrementCounter("success.exposure.continuous")
                	}

			## END TRYCATCH
                	}, error = function(e) {
                	        sink()
                	        sink(resLogFile, append=TRUE)
                	        cat(paste("ERROR:", varName,gsub("[\r\n]", "", e), sep=" "))
                	        incrementCounter("continuous.error")
                	})
			}			
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

