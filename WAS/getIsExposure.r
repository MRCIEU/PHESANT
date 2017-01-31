
# returns boolean var - whether this field denotes the trait of interest, as specified
# in the variable information file
# to determine if values of cat mult fields (not the whole field) are exposure values, use getIsCatMultExposure function instead.
getIsExposure <- function(varName) {

	idx=which(vl$phenoInfo$FieldID==varName)
        isExposure = vl$phenoInfo$TRAIT_OF_INTEREST[idx]
        if (!is.na(isExposure) & isExposure=="YES") {
		return(TRUE)
    	}
	return(FALSE)
}
