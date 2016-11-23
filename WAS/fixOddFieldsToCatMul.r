
# Changes variable name from instances to arrays
# 
# This function changes the format of variable names from instance format to array format (i.e. we treat
# the instances as arrays), for a small subset of Biobank variables.
#
# Some variables are stored in Biobank as categorical (single) fields with the data stored as set of instances,
# but we want to treat these instead as categorical (multiple) with a set of arrays.
# These are indicated by the value "YES-INSTANCES" in the CAT_SINGLE_TO_CAT_MULT column of the variable info file.
# This function changes the format of these variable names from VARID_0_0, VARID_1_0, VARID_2_0 etc (which
# is instance format), to VARID_0_0, VARID_0_1, VARID_0_2 etc. (array format) so they can be treated as categorical (multiple) fields. 
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
