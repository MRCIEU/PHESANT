# The MIT License (MIT)
# Copyright (c) 2017 Louise AC Millard, MRC Integrative Epidemiology Unit, University of Bristol
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the "Software"), to deal in the Software without restriction, including without
# limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions
# of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
# TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.


# Reassigns values as specified in data coding info file
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
                cat("WARNING: >1 ROWS IN DATA CODE INFO FILE || ")
		return(pheno);
        }

	dataDataCode = vl$dataCodeInfo[dataCodeRow,];
        reassignments = as.character(dataDataCode$reassignments);
	
	return(reassignValue2(pheno, reassignments))
	
}

# Reassigns values in pheno, as specified in resassignments argument
reassignValue2 <- function(pheno, reassignments) {

	# can be NA if row not included in data coding info file
	if (!is.na(reassignments) && nchar(reassignments)>0) {

		reassignParts = unlist(strsplit(reassignments,"\\|"));
		cat(paste("reassignments: ", reassignments, " || ", sep=""));

		# do each reassignment
		for(i in reassignParts) {
			reassignParts = unlist(strsplit(i,"="));

			# matrix version
			idx = which(pheno==reassignParts[1],arr.ind=TRUE)
			pheno[idx]=strtoi(reassignParts[2]);
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
