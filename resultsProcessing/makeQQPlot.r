
makeQQPlot <- function(resDir, resultsAll) {

	## remove the fields excluded as stated in variable information file
	idx = which(is.na(resultsAll[,"isExposure"]) | resultsAll[,"isExposure"]=="")

	print(paste("Number not exposure variable:", length(idx)))

	resultsIncluded = resultsAll[idx,];
	pvalues = sort(resultsIncluded[,"pvalue"]);

	# check pvalues are valid (not zero)
	idxZero = which(pvalues==0)
	if (length(idxZero>0)) { 
		#stop("At least one P value is zero!", call.=FALSE)
		print("At least one P value is zero! Could not make QQ plot")
		return(NULL)
	}

	numRes = length(pvalues)
	pSort = sort(pvalues)
	rank = rank(pSort, ties.method="first")
	rankProportion = rank/numRes
	rankProportionLog10 = -log10(rankProportion)
	pLog10 = -log10(pSort)

	print(paste('Num results:', numRes))

	## do bonferroni correction and output this.
	bonf= 0.05/numRes
	print(paste('Bonferroni threshold:', bonf))
	threshold = -log10(bonf)
	belowBonf = length(which(pSort<bonf))
	print(paste('Number below Bonferroni threshold:', belowBonf));

	## plot qqplot

	pdf(paste(resDir,"qqplot.pdf",sep=""))

	# qq
	par(pch='.')
	plot(rankProportionLog10, pLog10,col='#990099', xlab='expected -log10(p)', ylab='actual -log10(p)',cex=4)

	# ascending diagonal
	lines(rankProportionLog10~pLog10,col='#0066cc',lty=3)
	
	# horizontal threshold line
	segments(0, threshold, 4.4, threshold, col='#008000',lty=2)

	junk<- dev.off()

	print("Finished QQ plot")

}
