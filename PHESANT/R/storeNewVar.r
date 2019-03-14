

storeNewVar <- function(userIDData, phenoData, varName, type) {

        # add pheno to dataframe
	newdata = data.frame(userID=userIDData, newvar=phenoData)
        names(newdata)[names(newdata)=="newvar"] = varName

	if (type == "bin") {
	        derivedBinary <<- merge(derivedBinary, newdata, by="userID", all=TRUE);
	} else if (type == "cont") {
		derivedCont <<- merge(derivedCont, newdata, by="userID", all=TRUE);
	} else if (type == "catOrd") {
		derivedCatOrd <<- merge(derivedCatOrd, newdata, by="userID", all=TRUE);
	} else if (type == "catUnord") {
		derivedCatUnord <<- merge(derivedCatUnord, newdata, by="userID", all=TRUE);
	}

	#write.table(phenoFactor, file=paste(opt$resDir, "data-binary-", varName, ".csv", sep=""), row.names=FALSE, col.names=FALSE, na="", quote=FALSE);

}
