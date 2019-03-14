storeNewVar <- function(userIDData, phenoData, varName, type) {
    # add pheno to dataframe
  	newdata = data.frame(userID=userIDData, newvar=phenoData)
    names(newdata)[names(newdata)=="newvar"] = varName
  	if (type == "bin") {
  	    pkg.env$derivedBinary <- merge(pkg.env$derivedBinary, newdata, by="userID", all=TRUE);
  	} else if (type == "cont") {
  	    pkg.env$derivedCont <- merge(pkg.env$derivedCont, newdata, by="userID", all=TRUE);
  	} else if (type == "catOrd") {
  	    pkg.env$derivedCatOrd <- merge(pkg.env$derivedCatOrd, newdata, by="userID", all=TRUE);
  	} else if (type == "catUnord") {
  	    pkg.env$derivedCatUnord <- merge(pkg.env$derivedCatUnord, newdata, by="userID", all=TRUE);
  	}
}
