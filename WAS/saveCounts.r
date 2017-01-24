
# Saves the counters stored in count variables, to a file in results directory
saveCounts <- function() {

	countFile = paste(opt$resDir,"variable-flow-counts-",opt$varTypeArg,".txt",sep="")

	# sort on counter name
	sortIdx = order(as.character(counters[,"name"]))
	counters <<- counters[sortIdx,]

	write.table(counters, file=countFile, sep=",", quote=FALSE, row.names=FALSE)
}

