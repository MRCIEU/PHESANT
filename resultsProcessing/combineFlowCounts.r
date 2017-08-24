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


combineFlowCounts <- function() {

        ## only needed when the pheWAS was run in multiple parts
        if (!is.null(opt$numParts)) {

                source("../WAS/initFunctions.r");
                c = initCounters();

                for (i in 1:opt$numParts) {
                        filex=paste(opt$resDir,"variable-flow-counts-",i,"-",opt$numParts,".txt",sep="");

			if (file.exists(filex)) {
                        cx = read.table(filex, header=1, sep=",");
			if (nrow(cx)>0) {	
			for (j in 1:nrow(cx)) {
				counterName = cx[j,1]
				counterValue = cx[j,2]
				
				idx = which(as.character(c$name)==as.character(counterName))
				if (length(idx)==0) {

					if (nrow(c)==0) {
						c = data.frame(name=counterName, countValue=counterValue)
					}
					else {
	        			        c = rbind(c, data.frame(name=counterName, countValue=counterValue))
					}
       			 	}
				else {
              				c$countValue[idx] = c$countValue[idx]+counterValue
				}
			}
			}
			}
		}

		opt$varTypeArg <<- "combined"
		counters <<- c;
		source("../WAS/saveCounts.r")
		saveCounts()
		
	}

}
