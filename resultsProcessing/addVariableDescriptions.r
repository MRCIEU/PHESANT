
# add descriptions from the variable information field
# this is slightly more involved than just merging because each
# cat multiple field creates multiple binary results and we need to mark specific 
# results as exposure results for this (specified in the EXPOSURE_PHENOTYPE field of the variable information file
addVariableDescriptions <- function() {

	## add descriptions to rows
	varList=read.table(opt$variablelistfile, header=1, sep="\t", comment.char="",quote="");

	# create separate varID column, extracted from varName column
	resultsAll$varID <<- sapply(strsplit(resultsAll$varName,"[-#]", perl=TRUE), "[", 1)

	resultsAllx = merge(resultsAll, varList, by.x="varID", by.y="FieldID", all=FALSE, sort=FALSE);
	resultsAll <<- resultsAllx[, c("varID","varName","varType","n","beta","lower","upper","pvalue","resType","Field","EXPOSURE_PHENOTYPE","Cat1_ID","Cat1_Title","Cat2_ID","Cat2_Title","Cat3_ID","Cat3_Title")]
	names(resultsAll)[names(resultsAll)=="Field"] <<- "description"
	names(resultsAll)[names(resultsAll)=="EXPOSURE_PHENOTYPE"] <<- "isExposure"

	# binary results from cat multiple need processing to set 'isExposure' using the list supplied in EXPOSURE_PHENOTYPE column in variable info file
	# (basically this is because 1 cat mult field generates multiple binary variables of which a subset may be denoting the exposure (e.g. a particular type of cancer))

	# get all cat mult fields with a value in EXPOSURE_PHENOTYPE
	catMultIdxs = which(varList$ValueType=="Categorical multiple" & !is.na(varList$EXPOSURE_PHENOTYPE) & varList$EXPOSURE_PHENOTYPE!="")
	resultsCatMult = resultsAll[catMultIdxs,]
	
	for (i in nrow(resultsCatMult)) {

		thisVarID = resultsCatMult[i,"FieldID"]

		# first set all values of isExposure for this cat multiple to "" in resultsAll
		idx = which(resultsAll$varID==thisVarID)
		resultsAll[idx,"isExposure"] <<- ""

		# then mark all the stated values as exposure values
		exposureValuesAll = as.character(resultsCatMult[i,"EXPOSURE_PHENOTYPE"])

		exposureValues = unlist(strsplit(exposureValuesAll,"\\|"))

		for (j in nrow(exposureValues)) {
			thisVal = exposureValues[j]
			varNameStr = paste(thisVarID, "#", thisVal)

			# result row for this particular value of this cat multiple field			
			idxInRes = which(resultsAll$varName == varNameStr)
			resultsAll$isExposure[idxInRes] <<- "YES"
		}
	}

	# remove varId column - we don't need it anymore
	resultsAll <<- resultsAll[, c("varName","varType","n","beta","lower","upper","pvalue","resType","description","isExposure","Cat1_ID","Cat1_Title","Cat2_ID","Cat2_Title","Cat3_ID","Cat3_Title")]
        

}


