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


# Performs variable processing for categorical (single) fields, namely:
# 1) Reassigning values as specified in data coding information file
# 2) Reordering categories for ordered fields
# 3) Replacing missing codes - we assume values < 0 are missing for categorical (single) variables
# 4) Remove values with <10 cases
# 5) Deterimine correct test to perform, either binary, ordered or unordered.
testCategoricalSingle <- function(varName, varType, thisdata) {
	cat("CAT-SINGLE || ");

	pheno = thisdata[,phenoStartIdx:ncol(thisdata)]
	isExposure = getIsExposure(varName)

	# assert variable has only one column
	if (!is.null(dim(pheno))) stop("More than one column for categorical single")

	pheno = reassignValue(pheno, varName)

	# get data code info - whether this data code is ordinal or not and any reordering
        dataPheno = vl$phenoInfo[which(vl$phenoInfo$FieldID==varName),];
        dataCode = dataPheno$DATA_CODING;

	# get data coding information	
       	dataCodeRow = which(vl$dataCodeInfo$dataCode==dataCode);
	if (length(dataCodeRow)==0) {
                cat("ERROR: No row in data coding info file || ");
		return(NULL);
        }
	dataDataCode = vl$dataCodeInfo[dataCodeRow,];
        ordered = dataDataCode$ordinal;
        order = as.character(dataDataCode$ordering);

	## reorder variable values into increasing order (we do this now as this may convert variable to binary rather than ordered)
        pheno = reorderOrderedCategory(pheno,order);

	## if data code has a default_value then recode NA's to this value for participants with value in default_related_field
	## this is used where there is no zero option e.g. field 100200
	defaultValue = dataDataCode$default_value
	defaultRelatedID = dataDataCode$default_related_field
	pheno = setDefaultValue(pheno, defaultValue, defaultRelatedID, thisdata[,"userID", drop=FALSE])

        ## all categories coded as <0 we assume are `missing' values
        pheno = replaceMissingCodes(pheno)

	## remove categories if < 10 examples
	pheno = testNumExamples(pheno)

	uniqVar = unique(na.omit(pheno))
	uniqVar = sort(uniqVar)

	if (length(uniqVar)<=1) {
		cat("SKIP (only one value) || ");
		incrementCounter("catSin.onevalue")
	}
	else if (length(uniqVar)==2) {		
		cat("CAT-SINGLE-BINARY || ");
		incrementCounter("catSin.case3")
		# binary so logistic regression

		phenoFactor = factor(pheno)
		# binary - so logistic regression
		thisdatanew = cbind.data.frame(thisdata[,1:numPreceedingCols], phenoFactor);
	        binaryLogisticRegression(varName, varType, thisdatanew, isExposure)	
	}
	else {
		# > 2 categories
		if (is.na(ordered)) {
			cat(" ERROR: 'ordered' not found in data code info file")	
		}
		else {

		## unordered
		if (ordered == 0) {
			
			cat("CAT-SINGLE-UNORDERED || ")
			incrementCounter("catSin.case2")

			thisdatanew = cbind.data.frame(thisdata[,1:numPreceedingCols], pheno);
			testCategoricalUnordered(varName, varType, thisdatanew);
			
		}
		else if (ordered == 1) {
		
			## ordered
			cat("ordered || ");
			incrementCounter("catSin.case1")

			## reorder variable values into increasing order
			thisdatanew = cbind.data.frame(thisdata[,1:numPreceedingCols], pheno);
			testCategoricalOrdered(varName, varType, thisdatanew, order)
		
		}
		else if (ordered == -2) {
			cat(" EXCLUDED or BINARY variable: Should not get here in code. ")
			incrementCounter("catSin.binaryorexcluded")
		}
		else {
			print(paste("ERROR", varName, varType, dataCode));
		}
		}
	}

}

## values are reordered and assigned values 1:N for N categories
reorderOrderedCategory <- function(pheno,order) {

	## new pheno of NAs (all values not in order are assumed to be NA)

	if (!is.na(order) && nchar(order)>0) {

		# make empty pheno		
		pheno2 = rep(NA,length(pheno));
			
		## get ordering
		orderParts = unlist(strsplit(order,"\\|"));
		
		# go through values in correct order and set value
		# from 1 to the number of values
		count=1;
		for(i in orderParts) {
			idx = which(pheno==i);
			pheno2[idx] = count;
		
			count=count+1;
		}
		
		cat("reorder ",order," || ",sep="");
		
		return(pheno2)
	}	
	else {
		return(pheno);
	}
	
}

## sets default value for people with no value in pheno, but with a value in the
## field specified in the default_value_related_field column in the data coding info file.
## the default value is specified in the default_value column in the data coding info file.
setDefaultValue <- function(pheno, defaultValue, defaultRelatedID, userID) {


	if (!is.na(defaultValue) && nchar(defaultValue)>0) {

		# remove people who have no value for indicator variable
	       	indName = paste("x",defaultRelatedID,"_0_0",sep="");

	     	cat("Default related field: ", indName, " || ", sep="");
		indicatorVar = indicatorFields[,indName]
		indvarx = merge(userID, indicatorFields, by="userID", all.x=TRUE, all.y=FALSE, sort=FALSE)
                indicatorVar = indvarx[,indName]

	    	# remove participants with NA value in this related field
	    	indicatorVar = replaceNaN(indicatorVar)

		# check if there are already examples with default value and if so display warning
		numWithDefault = length(which(pheno==defaultValue))
		if (numWithDefault>0) {
			cat("(WARNING: already ", numWithDefault, " values with default value) ", sep="")
		}
		
		# set default value in people who have no value in the pheno but do have a value in the default_value_related_field
	    	defaultIdxs = which(!is.na(indicatorVar) & is.na(pheno))
		pheno[defaultIdxs] = defaultValue

	       	cat("default value ", defaultValue, " set, N= ", length(defaultIdxs), " || ", sep="");

	}

	return(pheno)

}


