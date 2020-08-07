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


# Tests the association of a field, determined by its field type
testAssociations <- function(currentVar, currentVarShort, thisdata) {

	## call file for variable type

	tryCatch({

		# retrieve whether phenotype is excluded etc
		idx=which(vl$phenoInfo$FieldID==currentVarShort);

		# check if variable info is found for this field
		if (length(idx)==0) {
			cat(paste(currentVar, " || Variable could not be found in pheno info file. \n", sep=""))			
			incrementCounter("notinphenofile")
		}
		else {

		# get info from variable info file
		excluded = vl$phenoInfo$EXCLUDED[idx]
		catSinToMult = vl$phenoInfo$CAT_SINGLE_TO_CAT_MULT[idx]
		fieldType = vl$phenoInfo$ValueType[idx]
		isExposure = getIsExposure(currentVarShort) #vl$phenoInfo$EXPOSURE_PHENOTYPE[idx]
		dateConvert = vl$phenoInfo$DATE_CONVERT[idx]

		if (fieldType=="Integer") {		

			#### INTEGER
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

			#### CONTINUOUS
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

			#### CAT SINGLE
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
		
			#### CAT MULTIPLE
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
				else {
					# get number of cat mult values denoting trait of interest
	                                numVals = getNumValuesCatMultExposure(currentVarShort)
					if (numVals>0) {
		                                addToCounts("start.exposure.catMulvalues", numVals)
					}
				}
		        	testCategoricalMultiple(currentVarShort, "CAT-MUL", thisdata);
			}
			cat("\n");
		}
		else if (fieldType=="Date" && dateConvert!="") {

			#### DATE TO BE CONVERTED TO BINARY
			cat(currentVar, "|| ", sep="")

			testDate(currentVarShort, "DATE", thisdata)

			cat("\n")
		}
		else {
	        	#cat("VAR MISSING ", currentVarShort, "\n", sep="");
	    	}
		}

	}, error = function(e) {
		print(paste("ERROR:", currentVar,e))
	})

}



