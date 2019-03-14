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

# adds given value to counter, that are used to count how many variables go down each route in the data flow
addToCounts <- function(counters, countName, num) {
    idx = which(counters$name==countName)
    if (length(idx)==0) {
        # counter does not exist so add with countValue 1
        counters <- rbind(counters, data.frame(name=countName, countValue=num))
    } else {
        # add to counter that already exists
        counters$countValue[idx] <- counters$countValue[idx]+num
    }
    return(counters)
}

# increments counters used to count how many variables go down each route in the data flow
incrementCounter <- function(counters, countName) {
    idx = which(counters$name==countName)
    if (length(idx)==0) {
        # counter does not exist so add with countValue 1
        counters <- rbind(counters, data.frame(name=countName, countValue=1))
    } else {
        # increment counter that already exists
        counters$countValue[idx] <- counters$countValue[idx]+1
    }
    return(counters)
}

# Saves the counters stored in count variables, to a file in results directory
saveCounts <- function(counters) {
    countFile = paste(opt$resDir,"variable-flow-counts-",opt$varTypeArg,".txt",sep="")
    # sort on counter name
    sortIdx = order(as.character(counters[,"name"]))
    counters <<- counters[sortIdx,]
    write.table(counters, file=countFile, sep=",", quote=FALSE, row.names=FALSE)
}

# init the counters used to determine how many variables took each path in the variable processing flow.
initCounters <- function() {
    counters = data.frame(name=character(),countValue=integer(), stringsAsFactors=FALSE)
    return(counters)
}