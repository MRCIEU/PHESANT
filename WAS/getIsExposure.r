
# returns boolean var - whether this field denotes the trait of interest, as specified
# in the variable information file
# this should not be used for cat mult fields - use getIsCatMultExposure function instead.
getIsExposure <- function(varName) {

	idx=which(vl$phenoInfo$FieldID==varName)
        isExposure = vl$phenoInfo$TRAIT_OF_INTEREST[idx]
        if (!is.na(isExposure) & isExposure!="") {
		return(TRUE)
    	}
	return(FALSE)
}
