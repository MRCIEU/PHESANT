combineFlowCounts <- function() {

        ## only needed when the pheWAS was run in multiple parts
        if (!is.null(opt$numParts)) {

                source("../WAS/initFunctions.r");
                c = initCounters();

                for (i in 1:opt$numParts) {
                        filex=paste(opt$resDir,"variable-flow-counts-",i,"-",opt$numParts,".txt",sep="");
                        cx = read.table(filex, header=0, sep=":");

			for (j in 1:nrow(cx)) {
				counterName = cx[j,1]
				counterValue = cx[j,2]

				idx = which(c$name==counterName)
        			if (length(idx)==0) {
        			        c <<- rbind(c, data.frame(name=counterName, countValue=counterValue))
       			 	}
				else {
              				c$countValue[idx] <<- c$countValue[idx]+counterValue
        			}
			}
						
#			c$int = c$int + cx[which(cx[,1]=="integer starting"),2];
#                       c$cont = c$cont + cx[which(cx[,1]=="continuous starting"),2];
#			c$catSin = c$catSin + cx[which(cx[,1]=="categorical single starting"),2];
#			c$catMul = c$catMul + cx[which(cx[,1]=="categorical multiple starting"),2];
#			c$cont.main = c$cont.main + cx[which(cx[,1]=="continuous main, <=20% examples with same value"),2];
#			c$cont.main.500 = c$cont.main.500 + cx[which(cx[,1]=="continuous main, <500 examples"),2];
#			c$cont.onevalue = c$cont.onevalue + cx[which(cx[,1]=="continuous other, one value"),2];
#			c$cont.case2 = c$cont.case2 + cx[which(cx[,1]=="continuous other, 2 distinct values"),2];
#			c$cont.case3 = c$cont.case3 + cx[which(cx[,1]=="continuous other, >2 distinct values"),2];
#			c$int.case1 = c$int.case1 + cx[which(cx[,1]=="integer, >= 20 distinct values (treated as continuous)"),2];
#			c$int.case2 = c$int.case2 + cx[which(cx[,1]=="integer, 2 distinct values"),2];
#			c$int.case3 = c$int.case3 + cx[which(cx[,1]=="integer, 3-19 distinct values"),2];
#			c$int.onevalue = c$int.onevalue + cx[which(cx[,1]=="integer, one value"),2];	
#			c$catSin.case1 = c$catSin.case1 + cx[which(cx[,1]=="categorical single, ordered"),2];
#			c$catSin.case2 = c$catSin.case2 + cx[which(cx[,1]=="categorical single, not ordered"),2];
#			c$catSin.case3 = c$catSin.case3 + cx[which(cx[,1]=="categorical single, binary"),2];
#			c$catSin.ace = c$catSin.ace + cx[which(cx[,1]=="categorical single, ACE"),2];
#			c$catSin.onevalue = c$catSin.onevalue + cx[which(cx[,1]=="categorical single, one value"),2];
#			c$ordCat = c$ordCat + cx[which(cx[,1]=="ordered categorical"),2];
#			c$ordCat.500 = c$ordCat.500 + cx[which(cx[,1]=="ordered categorical, <500 examples"),2];
#			c$unordCat.500 = c$unordCat.500 + cx[which(cx[,1]=="not-ordered categorical, <500 examples"),2];
#			c$catMul.binary = c$catMul.binary + cx[which(cx[,1]=="categorical multiple, binary variables"),2];
#			c$catMul.10 = c$catMul.10 + cx[which(cx[,1]=="categorical multiple, <10 in each category"),2];
#			c$catMul.over10 = c$catMul.over10 + cx[which(cx[,1]=="categorical multiple, >=10 in each category"),2];
#			c$binary.500 = c$binary.500 + cx[which(cx[,1]=="binary, <500 examples"),2];
#			c$continuous.success = c$continuous.success + cx[which(cx[,1]=="success continuous"),2];
#			c$ordCat.success = c$ordCat.success + cx[which(cx[,1]=="success ordered categorical"),2];
#			c$unordCat.success = c$unordCat.success + cx[which(cx[,1]=="success not-ordered categorical"),2];
#			c$binary.success = c$binary.success + cx[which(cx[,1]=="success binary"),2];		
#			c$excluded.int = c$excluded.int + cx[which(cx[,1]=="excluded integer"),2];
#			c$excluded.cont = c$excluded.cont + cx[which(cx[,1]=="excluded continuous"),2];
#			c$excluded.catSin = c$excluded.catSin + cx[which(cx[,1]=="excluded categorical single"),2];
#			c$excluded.catMul = c$excluded.catMul + cx[which(cx[,1]=="excluded categorical multiple"),2];

			opt$varTypeArg <<- "combined"
			count <<- c;
			source("../WAS/saveCounts.r")
			saveCounts();

                }
	}

}
