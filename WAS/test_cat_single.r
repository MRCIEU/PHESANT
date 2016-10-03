testCategoricalSingle <- function(varName, varType, thisdata) {
	cat("CAT-SINGLE || ");

	pheno = thisdata[,phenoStartIdx:ncol(thisdata)]

	# assert variable has only one column
	if (!is.null(dim(pheno))) stop("More than one column for categorical single")

        ## all categories coded as <0 we assume are `missing' values
        pheno = replaceMissingCodes(pheno);

	## remove categories if < 10 examples
	pheno = testNumExamples(pheno)

	uniqVar = unique(na.omit(pheno))
	uniqVar = sort(uniqVar)

	#numNotNA = length(which(!is.na(pheno)))
	#if (numNotNA<500) {
	#	cat("SKIP (", numNotNA, "< 500 examples) || ",sep="");
	#} else 
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

		# get data code and whether this data code is ordinal or not
		dataPheno = vl$phenoInfo[which(vl$phenoInfo$FieldID==varName),];
		dataCode = dataPheno$CAT_SINGLE_DATA_CODING;
		dataDataCode = vl$dataCodeInfo[which(vl$dataCodeInfo$dataCode==dataCode),];
		ordered = dataDataCode$ordinal;
		order = dataDataCode$ordering;	
		reassignments = dataDataCode$reassignments;
		
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

			## reassign values and reorder variable values into increasing order
			## FIXME: potentially reassigning values could reduce the number of categories to 2 - i.e. should treat as binary
			pheno = reassignValue(pheno,reassignments);
			pheno = reorderOrderedCategory(pheno,order);
			thisdatanew = cbind.data.frame(thisdata[,1:numPreceedingCols], pheno);
			testCategoricalOrdered(varName, varType, thisdatanew);
		
		}
		else if (ordered == -2) {
			cat(" SKIP (ACE variable) ")
			count$catSin.ace <<- count$catSin.ace + 1;
		}
		else {
			print(paste("ERROR", varName, varType, dataCode));
		}
	}

}

reassignValue <- function(pheno,reassignments) {

#	cat(paste("aa ", class(reassignments), " ", reassignments, sep=""));
	reassignments = as.character(reassignments);

	if (!is.na(reassignments) && nchar(reassignments)>0) {
#		print("XXXX")
		reassignParts = unlist(strsplit(reassignments,"\\|"));

		for(i in reassignParts) {
			reassignParts = unlist(strsplit(i,"="));
			idx = which(pheno==reassignParts[1]);
			cat(paste(reassignParts[1], " ", reassignParts[2], " || "), sep="")
			pheno[idx]=strtoi(reassignParts[2]);
		}
	}

	return(pheno)
}

reorderOrderedCategory <- function(pheno,order) {
	## new pheno of NAs (all values not in order are assumed to be NA)


#	cat(paste("xx ", class(order), " ", order, sep=""));	
	order = as.character(order);

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







