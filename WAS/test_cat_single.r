testCategoricalSingle <- function(varName, varType, thisdata) {
	cat("CAT-SINGLE || ");

	pheno = thisdata[,phenoStartIdx:ncol(thisdata)]

	# assert variable has only one column
	if (!is.null(dim(pheno))) stop("More than one column for categorical single")


	# get data code info - whether this data code is ordinal or not and any reordering and resassignments
        dataPheno = vl$phenoInfo[which(vl$phenoInfo$FieldID==varName),];
        dataCode = dataPheno$CAT_SINGLE_DATA_CODING;
	
       	dataCodeRow = which(vl$dataCodeInfo$dataCode==dataCode);
	if (length(dataCodeRow)==0) {
                cat("ERROR: No row in data coding info file || ");
		return(NULL);
        }
	dataDataCode = vl$dataCodeInfo[dataCodeRow,];
        ordered = dataDataCode$ordinal;
        order = as.character(dataDataCode$ordering);
        reassignments = as.character(dataDataCode$reassignments);

	## do reasssignments as specified in data coding info file
	pheno = reassignValue(pheno,reassignments);

	## reorder variable values into increasing order (we do this now as this may convert variable to binary rather than ordered)
        pheno = reorderOrderedCategory(pheno,order);

        ## all categories coded as <0 we assume are `missing' values
        pheno = replaceMissingCodes(pheno);

	## remove categories if < 10 examples
	pheno = testNumExamples(pheno)

	uniqVar = unique(na.omit(pheno))
	uniqVar = sort(uniqVar)

	if (length(uniqVar)<=1) {
		cat("SKIP (only one value) || ");
		count$catSin.onevalue <<- count$catSin.onevalue + 1;
	}
	else if (length(uniqVar)==2) {		
		cat("CAT-SINGLE-BINARY || ");
		count$catSin.case3 <<- count$catSin.case3 + 1;
		# binary so logistic regression

		phenoFactor = factor(pheno)
		# binary - so logistic regression
		thisdatanew = cbind.data.frame(thisdata[,1:numPreceedingCols], phenoFactor);
	        binaryLogisticRegression(varName, varType, thisdatanew)	
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
			count$catSin.case2 <<- count$catSin.case2 + 1;

			thisdatanew = cbind.data.frame(thisdata[,1:numPreceedingCols], pheno);
			testCategoricalUnordered(varName, varType, thisdatanew);
			
		}
		else if (ordered == 1) {
		
			## ordered
			cat("ordered || ");
			count$catSin.case1 <<- count$catSin.case1 + 1;

			## reorder variable values into increasing order
			thisdatanew = cbind.data.frame(thisdata[,1:numPreceedingCols], pheno);
			testCategoricalOrdered(varName, varType, thisdatanew, order)
		
		}
		else if (ordered == -2) {
			cat(" EXCLUDED or BINARY variable: Should not get here in code. ")
			count$catSin.binaryorexcluded <<- count$catSin.binaryorexcluded + 1;
		}
		else {
			print(paste("ERROR", varName, varType, dataCode));
		}
		}
	}

}


reassignValue <- function(pheno,reassignments) {

	# can be NA if row not included in data coding info file

		if (!is.na(reassignments) && nchar(reassignments)>0) {
			reassignParts = unlist(strsplit(reassignments,"\\|"));
	
			cat(paste("reassignments: ", reassignments, " || ", sep=""));
			for(i in reassignParts) {
				reassignParts = unlist(strsplit(i,"="));
				idx = which(pheno==reassignParts[1]);
	#			cat(paste(reassignParts[1], " ", reassignParts[2], " || "), sep="")
				pheno[idx]=strtoi(reassignParts[2]);
			}
		}
	

	return(pheno)
}

reorderOrderedCategory <- function(pheno,order) {

	## new pheno of NAs (all values not in order are assumed to be NA)

	if (!is.na(order) && nchar(order)>0) {
		
		pheno2 = rep(NA,length(pheno));
			
		## get ordering
		orderParts = unlist(strsplit(order,"\\|"));
		
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

