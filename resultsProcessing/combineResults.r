combineResults <- function() {

if (is.null(opt$numParts)) {

	resBin = loadResult(paste(opt$resDir,"results-logistic-binary-all.txt",sep=""), "LOGISTIC-BINARY");
	resMulL = loadResult(paste(opt$resDir,"results-multinomial-logistic-all.txt",sep=""), "MULTINOMIAL-LOGISTIC");
	
        # we store all the results in the multinomial model (for all categories) but here we only display the overall result (i.e. the model p value)
        resMulL = resMulL[which(resMulL$beta==-999),];

	resOrdL = loadResult(paste(opt$resDir,"results-ordered-logistic-all.txt",sep=""), "ORDERED-LOGISTIC");
	resLin = loadResult(paste(opt$resDir,"results-linear-all.txt",sep=""), "LINEAR");

	resultsAll <<- rbind.data.frame(resBin, resMulL, resOrdL, resLin);	

} else {

for (i in 1:opt$numParts) {

	resBin = loadResult(paste(opt$resDir,"results-logistic-binary-",i,"-",opt$numParts,".txt",sep=""), "LOGISTIC-BINARY");
        resMulL	= loadResult(paste(opt$resDir,"results-multinomial-logistic-",i,"-",opt$numParts,".txt",sep=""), "MULTINOMIAL-LOGISTIC");

        # we store all the results in the multinomial model (for all categories) but here we only display the overall result (i.e. the model p value)
        resMulL = resMulL[which(resMulL$beta==-999),];

        resOrdL	= loadResult(paste(opt$resDir,"results-ordered-logistic-",i,"-",opt$numParts,".txt",sep=""), "ORDERED-LOGISTIC");
        resLin = loadResult(paste(opt$resDir,"results-linear-",i,"-",opt$numParts,".txt",sep=""), "LINEAR");

	# new data frame if first file
        if (i==1) {
                resultsAll <<- rbind.data.frame(resBin, resMulL, resOrdL, resLin);
        }
	else {
              	resultsAll <<- rbind.data.frame(resultsAll, resBin, resMulL, resOrdL, resLin);
        }
}
}

}



loadResult <- function(filename, resultType) {
        resBin = read.table(filename, header=1, sep=",", comment.char="", colClasses=c("character","character","character","character","character","character","numeric"));
        resBin$resType = rep(resultType, nrow(resBin));
	return(resBin);
}
