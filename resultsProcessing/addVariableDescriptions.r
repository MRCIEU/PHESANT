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


# add descriptions from the variable information field
# this is slightly more involved than just merging because each
# cat multiple field creates multiple binary results and we need to mark specific 
# results as exposure results for this (specified in the TRAIT_OF_INTEREST field of the variable information file
addVariableDescriptions <- function() {

	## add descriptions to rows
	varList=read.table(opt$variablelistfile, header=1, sep="\t", comment.char="",quote="");

	# create separate varID column, extracted from varName column
	resultsAll$varID <<- sapply(strsplit(resultsAll$varName,"[-#]", perl=TRUE), "[", 1)

	resultsAllx = merge(resultsAll, varList, by.x="varID", by.y="FieldID", all=FALSE, sort=FALSE);
	resultsAll <<- resultsAllx[, c("varID","varName","varType","n","beta","lower","upper","pvalue","resType","Field","TRAIT_OF_INTEREST","Cat1_ID","Cat1_Title","Cat2_ID","Cat2_Title","Cat3_ID","Cat3_Title")]
	names(resultsAll)[names(resultsAll)=="Field"] <<- "description"
	names(resultsAll)[names(resultsAll)=="TRAIT_OF_INTEREST"] <<- "isTraitOfInterest"

	# binary results from cat multiple need processing to set 'isExposure' using the list supplied in TRAIT_OF_INTEREST column in variable info file
	# (basically this is because 1 cat mult field generates multiple binary variables of which a subset may be denoting the exposure (e.g. a particular type of cancer))

	# get all cat mult fields with a value in TRAIT_OF_INTEREST
	catMultIdxs = which(varList$ValueType=="Categorical multiple" & !is.na(varList$TRAIT_OF_INTEREST) & varList$TRAIT_OF_INTEREST!="")
	resultsCatMult = resultsAll[catMultIdxs,]
	
	for (i in nrow(resultsCatMult)) {

		thisVarID = resultsCatMult[i,"FieldID"]

		# first set all values of isExposure for this cat multiple to "" in resultsAll
		idx = which(resultsAll$varID==thisVarID)
		resultsAll[idx,"isTraitOfInterest"] <<- ""

		# then mark all the stated values as exposure values
		exposureValuesAll = as.character(resultsCatMult[i,"TRAIT_OF_INTEREST"])

		exposureValues = unlist(strsplit(exposureValuesAll,"\\|"))

		for (j in nrow(exposureValues)) {
			thisVal = exposureValues[j]
			varNameStr = paste(thisVarID, "#", thisVal)

			# result row for this particular value of this cat multiple field			
			idxInRes = which(resultsAll$varName == varNameStr)
			resultsAll$isTraitOfInterest[idxInRes] <<- "YES"
		}
	}

	# remove varId column - we don't need it anymore
	resultsAll <<- resultsAll[, c("varName","varType","n","beta","lower","upper","pvalue","resType","description","isTraitOfInterest","Cat1_ID","Cat1_Title","Cat2_ID","Cat2_Title","Cat3_ID","Cat3_Title")]
        

}


