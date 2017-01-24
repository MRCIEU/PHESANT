combineFlowCounts <- function() {

        ## only needed when the pheWAS was run in multiple parts
        if (!is.null(opt$numParts)) {

                source("../WAS/initFunctions.r");
                c = initCounters();

                for (i in 1:opt$numParts) {
                        filex=paste(opt$resDir,"variable-flow-counts-",i,"-",opt$numParts,".txt",sep="");

                        cx = read.table(filex, header=1, sep=",");
	
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

		opt$varTypeArg <<- "combined"
		counters <<- c;
		source("../WAS/saveCounts.r")
		saveCounts()
		
	}

}
