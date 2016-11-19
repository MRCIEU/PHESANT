# remove variable values if less than 10 examples have this value
testNumExamples <- function(pheno) {
	
	## loop through values and remove if has < 10 examples
        uniqVar = unique(na.omit(pheno));
        for (u in uniqVar) {
                withValIdx = which(pheno==u)
                numWithVal = length(withValIdx);
                if (numWithVal<10) {
                        pheno[withValIdx]=NA
#			cat(paste("Removed ",u ,": <10 examples || ", sep=""));
                }
		else {
			cat(paste("Inc(>=10): ", u, "(", numWithVal, ") || ", sep=""));
		}
        }
	return(pheno);
}
