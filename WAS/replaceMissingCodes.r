
# Replace negative values with NA as these are assumed to be missing
replaceMissingCodes <- function(pheno) {

	phenoReplaced = pheno;

	uniqVar = unique(na.omit(phenoReplaced))
	# variable values <0 are `missing' codes
        for (u in uniqVar) {
#                if (!is.na(u) && u<0) {
		if (u<0) {
		    	idxU = which(phenoReplaced==u)
                       	phenoReplaced[idxU]=NA
                }
        }

	return(phenoReplaced)

}
