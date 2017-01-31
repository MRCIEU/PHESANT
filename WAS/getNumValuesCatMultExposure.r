

# looks up categorical multiple field in the variable info file, return
# number of values denoted as trait of interest.
# returns zero if whole field is denoted trait of interest, not particular values.
getNumValuesCatMultExposure <- function(varName) {
	
	# get row index of field in variable information file
	idx=which(vl$phenoInfo$FieldID==varName)

	# may be empty of may contain VALUE1|VALUE2 etc .. to denote those
	# cat mult values denoting exposure variable
	isExposure = vl$phenoInfo$TRAIT_OF_INTEREST[idx]
        
        if (!is.na(isExposure) & isExposure!="") {
		
		isExposure = as.character(isExposure)
		
		## first check if value is YES, then no partic values are traits of interest
		if (isExposure == "YES") {
			return(0)
		}

		## try to split by |, to set particular values as exposure

		# split into variable Values
		exposureValues = unlist(strsplit(isExposure,"\\|"))

		return(length(exposureValues))

	}

	# varValue is not in list of exposure values
	return(0)

}
