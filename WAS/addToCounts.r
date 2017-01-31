
# adds given value to counter, that are used to count how many variables go down each route in the data flow
addToCounts <- function(countName, num) {
		
	idx = which(counters$name==countName)

	if (length(idx)==0) {
		# counter does not exist so add with countValue 1
		counters <<- rbind(counters, data.frame(name=countName, countValue=num))
	}
	else {
		# add to counter that already exists
		counters$countValue[idx] <<- counters$countValue[idx]+num
	}

}
