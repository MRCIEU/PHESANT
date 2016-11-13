testAssociations <- function(currentVar, currentVarShort, thisdata) {

	## call file for variable type

	tryCatch({

		# retrieve whether phenotype is excluded etc
		idx=which(vl$phenoInfo$FieldID==currentVarShort);

		if (length(idx)==0) {
			cat(paste(currentVar, " || Variable could not be found in pheno info file. \n", sep=""))			
			count$notinphenofile <<- count$notinphenofile+1;
		}
		else {

		excluded = vl$phenoInfo$EXCLUDED[idx]
		catSinToMult = vl$phenoInfo$CAT_SINGLE_TO_CAT_MULT[idx]
		fieldType = vl$phenoInfo$ValueType[idx]

		if (fieldType=="Integer") {		
			cat(currentVar, "|| ", sep="")
			
			if (excluded!="") {
				cat(paste("Excluded integer: ", excluded, " || ", sep=""))
				count$excluded.int <<- count$excluded.int+1;
			}
			else {
				count$int <<- count$int + 1;
		    	testInteger(currentVarShort, "INTEGER", thisdata);			
			}
			cat("\n");
	    	}
		else if (fieldType=="Continuous") {

			cat(currentVar, "|| ", sep="")

		    	if (excluded!="") {
				cat(paste("Excluded continuous: ", excluded, " || ", sep=""))
				count$excluded.cont <<- count$excluded.cont+1;
		    	}
			else {
	        		count$cont <<- count$cont	+ 1;
				testContinuous(currentVarShort, "CONTINUOUS", thisdata);
	        	}
	        	cat("\n");
		}
	    	else if (fieldType=="Categorical single" && catSinToMult=="") {

			cat(currentVar, "|| ", sep="")
	
	    		if (excluded!="") {
				cat(paste("Excluded cat-single: ", excluded, " || ", sep=""))
				count$excluded.catSin <<- count$excluded.catSin+1;
			}
			else {
				count$catSin <<- count$catSin + 1;
		    	testCategoricalSingle(currentVarShort, "CAT-SIN", thisdata);
			}
			cat("\n");
	  	}
		else if (fieldType=="Categorical multiple" || catSinToMult!="") {
		
			cat(currentVar, "|| ", sep="")

			if (excluded!="") {
				cat(paste("Excluded cat-multiple: ", excluded, " || ", sep=""))
				count$excluded.catMul <<- count$excluded.catMul+1;
			}
			else {
				count$catMul <<- count$catMul + 1;
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



