
# Tests the association of a field, determined by its field type
testAssociations <- function(currentVar, currentVarShort, thisdata) {

	## call file for variable type

	tryCatch({

		# retrieve whether phenotype is excluded etc
		idx=which(vl$phenoInfo$FieldID==currentVarShort);

		if (length(idx)==0) {
			cat(paste(currentVar, " || Variable could not be found in pheno info file. \n", sep=""))			
			incrementCounter("notinphenofile")
		}
		else {

		excluded = vl$phenoInfo$EXCLUDED[idx]
		catSinToMult = vl$phenoInfo$CAT_SINGLE_TO_CAT_MULT[idx]
		fieldType = vl$phenoInfo$ValueType[idx]
		isExposure = getIsExposure(currentVarShort) #vl$phenoInfo$EXPOSURE_PHENOTYPE[idx]

		if (fieldType=="Integer") {		
			cat(currentVar, "|| ", sep="")
			
			if (excluded!="") {
				cat(paste("Excluded integer: ", excluded, " || ", sep=""))
				incrementCounter("excluded.int")
			}
			else {
				incrementCounter("start.int")
				if (isExposure==TRUE) {
					incrementCounter("start.exposure.int")
				}

			    	testInteger(currentVarShort, "INTEGER", thisdata);
			}
			cat("\n");
	    	}
		else if (fieldType=="Continuous") {

			cat(currentVar, "|| ", sep="")

		    	if (excluded!="") {
				cat(paste("Excluded continuous: ", excluded, " || ", sep=""))
				incrementCounter("excluded.cont")
		    	}
			else {
				incrementCounter("start.cont")
				if (isExposure==TRUE) {
                                        incrementCounter("start.exposure.cont")
                                }
				testContinuous(currentVarShort, "CONTINUOUS", thisdata);
	        	}
	        	cat("\n");
		}
	    	else if (fieldType=="Categorical single" && catSinToMult=="") {

			cat(currentVar, "|| ", sep="")
	
	    		if (excluded!="") {
				cat(paste("Excluded cat-single: ", excluded, " || ", sep=""))
				incrementCounter("excluded.catSin")
			}
			else {
				incrementCounter("start.catSin")
				if (isExposure==TRUE) {
                                        incrementCounter("start.exposure.catSin")
                                }
			    	testCategoricalSingle(currentVarShort, "CAT-SIN", thisdata);
			}
			cat("\n");
	  	}
		else if (fieldType=="Categorical multiple" || catSinToMult!="") {
		
			cat(currentVar, "|| ", sep="")

			if (excluded!="") {
				cat(paste("Excluded cat-multiple: ", excluded, " || ", sep=""))
				incrementCounter("excluded.catMul")
			}
			else {

				if (catSinToMult!="") {
					cat("cat-single to cat-multiple || ", sep="")
					incrementCounter("catSinToCatMul")
				}

				incrementCounter("start.catMul")	
				if (isExposure==TRUE) {
                                        incrementCounter("start.exposure.catMul")
                                }
		        	testCategoricalMultiple(currentVarShort, "CAT-MUL", thisdata);
			}
			cat("\n");
		}
		else {
	        	#cat("VAR MISSING ", currentVarShort, "\n", sep="");
	    	}
		}

	}, error = function(e) {
		print(paste("ERROR:", currentVar,e))
	})

}



