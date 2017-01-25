

# looks up categorical multiple field in the variable info file, return
# whether field has YES in TRAIT_OF_INTEREST column (i.e. all values in 
# this field denote the exposure), or whether varName has varValue stated 
# as a trait of interest in the TRAIT_OF_INTEREST column (multiple values are
# separated by "|" in this field
getIsCatMultExposure <- function(varName, varValue) {
	
	# get row index of field in variable information file
	idx=which(vl$phenoInfo$FieldID==varName)

	# may be empty of may contain VALUE1|VALUE2 etc .. to denote those
	# cat mult values denoting exposure variable
	isExposure = vl$phenoInfo$TRAIT_OF_INTEREST[idx]
        
        if (!is.na(isExposure) & isExposure!="") {
		
		isExposure = as.character(isExposure)
		
		## first check if value is YES, then all values are exposure traits
		if (isExposure == "YES") {
			cat("IS_CM_ALL_EXPOSURE || ")
			return(TRUE)
		}

		## try to split by |, to set particular values as exposure

		# split into variable Values
		exposureValues = unlist(strsplit(isExposure,"\\|"))

		# for each value stated, check whether it is varValue
		for (thisVal in exposureValues) {
			if (thisVal == varValue) {
				cat("IS_CM_EXPOSURE || ")
				return(TRUE)
			}
		}
	}

	# varValue is not in list of exposure values
	return(FALSE)

}
