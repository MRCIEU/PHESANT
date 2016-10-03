fixOddFieldsToCatMul <- function(data) {

	# examples are variables: 40006, 40011, 40012, 40013

	# get all variables that need their instances changing to arrays
	dataPheno = vl$phenoInfo[which(vl$phenoInfo$CAT_SINGLE_TO_CAT_MULT=="YES-INSTANCES"),];

	for (i in 1:nrow(dataPheno)) {
		varID = dataPheno[i,]$FieldID;		
		varidString = paste("x",varID,"_", sep="");			
			
		# get all columns in data dataframe for this variable	
		colIdxs = which(grepl(varidString,names(data)));
		
		# change format from xvarid_0_0, xvarid_1_0, xvarid_2_0, to xvarid_0_0, xvarid_0_1, xvarid_0_2
		count = 0;
		for (j in colIdxs) {	
			colnames(data)[j] <- paste(varidString, "0_", count, sep="")
			count = count + 1;
		}				
	}

	return(data)

}
