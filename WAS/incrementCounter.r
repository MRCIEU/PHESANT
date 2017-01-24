
# increments counters used to count how many variables go down each route in the data flow
incrementCounter <- function(countName) {
		
	idx = which(counters$name==countName)

	if (length(idx)==0) {
		# counter does not exist so add with countValue 1
		counters <<- rbind(counters, data.frame(name=countName, countValue=1))
	}
	else {
		# increment counter that already exists
		counters$countValue[idx] <<- counters$countValue[idx]+1
	}

}
