
addVariableDescriptions <- function() {

	## add descriptions to rows
	varList=read.table(opt$variablelistfile, header=1, sep="\t", comment.char="",quote="");

	# create separate varID column, extracted from varName column
	resultsAll$varID <<- sapply(strsplit(resultsAll$varName,"[-#]", perl=TRUE), "[", 1)

	resultsAllx = merge(resultsAll, varList, by.x="varID", by.y="FieldID", all=FALSE, sort=FALSE);
	resultsAll <<- resultsAllx[, c("varName","varType","n","beta","lower","upper","pvalue","resType","Field","EXPOSURE_PHENOTYPE","Cat1_ID","Cat1_Title","Cat2_ID","Cat2_Title","Cat3_ID","Cat3_Title")]
	names(resultsAll)[names(resultsAll)=="Field"] <<- "description"
	names(resultsAll)[names(resultsAll)=="EXPOSURE_PHENOTYPE"] <<- "isExposure"

}
