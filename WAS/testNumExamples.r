# remove variable values if less than 10 examples have this value
testNumExamples <- function(pheno) {
	
	## loop through values and remove if has < 10 examples
        uniqVar = unique(na.omit(pheno));
        for (u in uniqVar) {
                withValIdx = which(pheno==u)
                numWithVal = length(withValIdx);
                if (numWithVal<10) {
                        pheno[withValIdx]=NA
                }
        }
	return(pheno);
}