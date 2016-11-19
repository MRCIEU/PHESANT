reassignValue <- function(pheno, varName) {

	# get data code info - whether this data code is ordinal or not and any reordering and resassignments
        dataPheno = vl$phenoInfo[which(vl$phenoInfo$FieldID==varName),];
        dataCode = dataPheno$DATA_CODING;

	# not all variables will have a data code info row
        dataCodeRow = which(vl$dataCodeInfo$dataCode==dataCode);

        if (length(dataCodeRow)==0) {
                return(pheno);
        }
	else if (length(dataCodeRow)>1) {
                cat(">1 ROWS IN DATA CODE INFO FILE || ")
		return(pheno);
        }

	dataDataCode = vl$dataCodeInfo[dataCodeRow,];
        reassignments = as.character(dataDataCode$reassignments);

	# can be NA if row not included in data coding info file
	if (!is.na(reassignments) && nchar(reassignments)>0) {
		reassignParts = unlist(strsplit(reassignments,"\\|"));
		cat(paste("reassignments: ", reassignments, " || ", sep=""));
		for(i in reassignParts) {
			reassignParts = unlist(strsplit(i,"="));

			# matrix version
			idx = which(pheno==reassignParts[1],arr.ind=TRUE)
			pheno[idx]=strtoi(reassignParts[2]);

			#idx = which(pheno==reassignParts[1]);
#			cat(paste(reassignParts[1], " ", reassignParts[2], " || "), sep="")
			#pheno[idx]=strtoi(reassignParts[2]);
		}
		
		## see if type has changed (this happens for field 216 (X changed to -1))
		## as.numeric will set non numeric to NA so we know if it's ok to do this by seeing if there are extra NA's after the conversion
		pNum = as.numeric(unlist(pheno))
		isNum = length(which(is.na(pheno), arr.ind=TRUE))==length(which(is.na(pNum), arr.ind=TRUE))
		if (isNum) {
			pheno = pNum
		}
	}

	return(pheno)
}
