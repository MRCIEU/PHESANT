
addVariableDescriptions <- function() {

## add descriptions to rows
varList=read.table(opt$variablelistfile, header=1, sep="\t", comment.char="",quote="");

for (i in 1:nrow(resultsAll)) {
        varName = resultsAll$varName[i];
        varNameParts = strsplit(varName,"[-#]", perl=TRUE);
        varID=unlist(varNameParts)[1]

	idx=which(varList$FieldID==varID)

        description  = varList$Field[idx]
        resultsAll$description[i] <<- as.character(description)

	exposurePheno = varList$EXPOSURE_PHENOTYPE[idx];
	resultsAll$isExposure[i] <<- as.character(exposurePheno);

	resultsAll$Cat1_ID[i] <<- varList$Cat1_ID[idx]
	cat1Title = varList$Cat1_Title[idx]
	resultsAll$Cat1_Title[i] <<- as.character(cat1Title);

	resultsAll$Cat2_ID[i] <<- varList$Cat2_ID[idx]
        cat2Title = varList$Cat2_Title[idx]
        resultsAll$Cat2_Title[i] <<- as.character(cat2Title);

	resultsAll$Cat3_ID[i] <<- varList$Cat3_ID[idx]
        cat3Title = varList$Cat3_Title[idx]
        resultsAll$Cat3_Title[i] <<- as.character(cat3Title);

}


}
