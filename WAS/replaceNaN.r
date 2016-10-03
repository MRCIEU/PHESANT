replaceNaN <- function(pheno) {

	if (is.factor(pheno)) {
		
		phenoReplaced = pheno

		nanStr  = which(phenoReplaced=="NaN")
        phenoReplaced[nanStr]=NA 
		
		emptyx  = which(phenoReplaced=="")
       	phenoReplaced[emptyx]=NA

	}
	else {

		phenoReplaced = pheno
		nanx  = which(is.nan(phenoReplaced))
	    phenoReplaced[nanx] = NA;

		emptyStr  = which(phenoReplaced=="")
	    phenoReplaced[emptyStr] = NA;
	    
	}

	return(phenoReplaced)

}
