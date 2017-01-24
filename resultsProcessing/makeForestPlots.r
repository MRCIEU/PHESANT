
makeForestPlots <- function(resDir, resultsAll) {

	library(forestplot)

	#### remove the fields excluded as stated in variable information file
	idx = which(is.na(resultsAll[,"isExposure"]) | resultsAll[,"isExposure"]=="")
	resultsIncluded = resultsAll[idx,];

	# keep only those reaching Bonferroni significance
	numRes = nrow(resultsIncluded)
	bonf= 0.05/numRes
	resultsIncluded = resultsIncluded[which(resultsIncluded[,"pvalue"]<bonf), ]

	numBelowBonf = nrow(resultsIncluded)
	print(paste('Number below Bonferroni threshold:', numBelowBonf))

	if (numBelowBonf==0) {
		print("Forest plot not made because no results below Bonferroni threshold")
		return(NULL)
	}

	# make sure results are numeric not character
	resultsIncluded$beta = as.numeric(resultsIncluded$beta)
	resultsIncluded$lower = as.numeric(resultsIncluded$lower)
	resultsIncluded$upper = as.numeric(resultsIncluded$upper)

	### three separate forest plots

	## forest plot for binary (logistic regression)
	# get binary results
	idxBinary = which(resultsIncluded[,"resType"]=="LOGISTIC-BINARY")
	resBinary = resultsIncluded[idxBinary,]
	# convert to odds ratio
	resBinary[,"beta"] = exp(resBinary[,"beta"])
	resBinary[,"lower"] = exp(resBinary[,"lower"])
	resBinary[,"upper"] = exp(resBinary[,"upper"])
	# make forest
	doMakeForest(resBinary, "binary", resDir, "Odds ratio", 1)

	## forest plot for continuous (linear regression)
	# get continuous results
	idxCont = which(resultsIncluded[,"resType"]=="LINEAR")
        resCont = resultsIncluded[idxCont,]
	# make forest
	doMakeForest(resCont, "continuous", resDir, "Standard deviation change", 0)

	## forest plot for ordered categorical (ordered logistic regression)
	# get ordered categorical results
	idxOrd = which(resultsIncluded[,"resType"]=="ORDERED-LOGISTIC")
        resOrd = resultsIncluded[idxOrd,]
	# convert to odds ratio
        resOrd[,"beta"] = exp(resOrd[,"beta"])
        resOrd[,"lower"] = exp(resOrd[,"lower"])
        resOrd[,"upper"] = exp(resOrd[,"upper"])
	# make forest
        doMakeForest(resOrd, "ordered-logistic", resDir, "Odds ratio", 1)

	## output number of MULTINOMIAL-LOGISTIC
	idxMul = which(resultsIncluded[,"resType"]=="MULTINOMIAL-LOGISTIC")
	print(paste("Number of MULTINOMIAL-LOGISTIC results (that we do not make a forest plot for): ", length(idxMul), sep=""))

}


doMakeForest <- function(results, label, resDir, thisXLabel, nullValue) {

	print(paste("Making forest plot for: ", label, sep=""));

	numRes = nrow(results)
	print(paste('Num results:', numRes))

	# sort data frame on P value
	results = results[with(results, order(pvalue)),]	

	v = cbind.data.frame(as.double(results[,"beta"]), as.double(results[,"lower"]), as.double(results[,"upper"]))

	# cat multiple fields have a hash to denote a particular value so we change this to ' value'
	
	results[,"varName"] = sub("#", " value=", results[,"varName"], perl=TRUE)

	# put upper limit of display width for variable descriptions so graph doesn't display funny
	results[,"description2"] = strtrim(results[,"description"], 30)

	idxTooLong = which(results[,"description2"]!=results[,"description"])
	results[idxTooLong,"description2"] = paste(results[idxTooLong,"description2"], "...", sep="");

	rownames(v) = paste(results[,"description2"], " (id=", results[,"varName"], ")", sep="")
	tabletext <- list(rownames(v))

	## plot forest
	pdf(paste(resDir,"forest-",label,".pdf",sep=""), height=2+nrow(v)*0.4) #height in inches, 0.4 inches = 1cm
	forestplot(tabletext, v, 
		xlab=thisXLabel, 
		new_page=FALSE, 
		txt_gp=fpTxtGp(label=gpar(cex=0.8)), 
		col=fpColors(box="royalblue",line="#990099", summary="royalblue"), 
		lineheight=unit(1, "cm"), 
		zero=nullValue, 
		boxsize=0.15, 
		ci.vertices=TRUE)
	dev.off()

	print("Finished forest plot")
}

