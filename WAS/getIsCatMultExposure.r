getIsCatMultExposure <- function(varName, varValue) {
	
	idx=which(vl$phenoInfo$FieldID==varName)

	# may be empty of may contain VALUE1|VALUE2 etc .. to denote those
	# cat mult values denoting exposure variable
	isExposure = vl$phenoInfo$EXPOSURE_PHENOTYPE[idx]
        
        if (!is.na(isExposure) & isExposure!="") {

		isExposure = as.character(isExposure)
		# split into variable Values
		exposureValues = unlist(strsplit(isExposure,"\\|"))

		for (thisVal in exposureValues) {

			#thisVal = exposureValues[i];

			if (thisVal == varValue) {
				cat("IS_CM_EXPOSURE || ")
				return(TRUE)
			}
		}
	}

	# varValue is not in list of exposure values
	return(FALSE)

}
