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


makeQQPlot <- function(resDir, resultsAll) {

	## remove the fields excluded as stated in variable information file
        idx = which(is.na(resultsAll[,"isTraitOfInterest"]) | resultsAll[,"isTraitOfInterest"]=="")

	print(paste("Number not exposure variable:", length(idx)))

	resultsIncluded = resultsAll[idx,];
	pvalues = sort(resultsIncluded[,"pvalue"]);

	numRes = length(pvalues)
	pSort = sort(pvalues)
	rank = rank(pSort, ties.method="first")
	rankProportion = rank/numRes
	rankProportionLog10 = -log10(rankProportion)
	pLog10 = -log10(pSort)

	## do bonferroni correction and output this.
	bonf= 0.05/numRes
	print(paste('Bonferroni threshold:', bonf))
	threshold = -log10(bonf)
	belowBonf = length(which(pSort<bonf))
	print(paste('Number below Bonferroni threshold:', belowBonf));

	# check pvalues are valid (not zero)
        idxZero = which(pvalues==0)
        if (length(idxZero)>0) {
                print(paste("There are ", length(idxZero)," results with pvalues too small to be stored exactly, colored red on QQ plot.", sep=""))
        }

	# set indicator for pvalue ~zero (we don't have a precise p value for these results), these are coloured red on QQ plot
	zeroVal  = rep(0, length(rankProportionLog10))
	zeroVal[idxZero] = 1
	zeroVal = as.factor(zeroVal)
	pLog10[idxZero] = -log10(5e-324)

	## plot qqplot
	pdf(paste(resDir,"qqplot.pdf",sep=""))

	# qq
	par(pch='.')
	plot(rankProportionLog10, pLog10,col=c("#990099", "red")[zeroVal], xlab='expected -log10(p)', ylab='actual -log10(p)',cex=0.8, pch=c(16, 8)[zeroVal])

	# ascending diagonal, dotted blue
	minVal = min(max(rankProportionLog10), max(pLog10))
	segments(0, 0, minVal, minVal, col='#0066cc',lty=3)	

	# horizontal threshold line, dashed green
	segments(0, threshold, max(rankProportionLog10), threshold, col='#008000',lty=2)

	junk<- dev.off()

	print("Finished QQ plot")

}
