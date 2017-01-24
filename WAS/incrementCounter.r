
# increments counters used to count how many variables go down each route in the data flow
incrementCounter <- function(countName) {
		
	idx = which(counters$name==countName)

	if (length(idx)==0) {
		counters <<- rbind(counters, data.frame(name=countName, countValue=1))
	}
	else {
		counters$countValue[idx] <<- counters$countValue[idx]+1
	}

}
