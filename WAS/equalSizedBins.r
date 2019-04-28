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

# splits the pheno into 3 bins with the cut points between values rather at the exact value for the quantile
equalSizedBins <- function(phenoAvg) {

	## equal sized bins 
        q = quantile(phenoAvg, probs=c(1/3,2/3), na.rm=TRUE)

	minX = min(phenoAvg, na.rm=TRUE)
	maxX = max(phenoAvg, na.rm=TRUE)

	phenoBinned = phenoAvg;
	if (q[1]==minX) {
		# edge case - quantile value is lowest value

		# assign min value as cat1
		idx1 = which(phenoAvg==q[1]);
		phenoBinned[idx1] = 0;

		# divide remaining values into cat2 and cat3
		phenoAvgRemaining = phenoAvg[which(phenoAvg!=q[1])];
		qx = quantile(phenoAvgRemaining, probs=c(0.5), na.rm=TRUE)
		minXX = min(phenoAvgRemaining, na.rm=TRUE)
		maxXX =	max(phenoAvgRemaining, na.rm=TRUE)

		if (qx[1]==minXX) {
			# edge case again - quantile value is lowest value
			idx2 = which(phenoAvg==qx[1]);
			idx3 = which(phenoAvg>qx[1]);
			cat("Bin 1: ==", q[1],", bin 2: ==",qx[1], "bin 3: >", qx[1], " || ", sep="")
		}
		else if (qx[1]==maxXX) {
			# edge case again - quantile value is max value
			idx2 = which(phenoAvg<qx[1] & phenoAvg>q[1]);
			idx3 = which(phenoAvg==qx[1]);
			cat("Bin 1: ==", q[1],", bin 2: > ",q[1], " AND <", qx[1] , "bin 3: ==", qx[1], " || ", sep="")
		}
		else {
			idx2 = which(phenoAvg<qx[1] & phenoAvg>q[1]);
			idx3 = which(phenoAvg>=qx[1]);
			cat("Bin 1: ==", q[1],", bin 2: > ",q[1], " AND <", qx[1] , "bin 3: >=", qx[1], " || ", sep="")
		}
		phenoBinned[idx2] = 1;
                phenoBinned[idx3] = 2;
	}
	else if (q[2]==maxX) {
		# edge case - quantile value is highest value

		# assign max value as cat3
		idx3 = which(phenoAvg==q[2]);
		phenoBinned[idx3] = 2;

		# divide remaining values into cat1 and cat2
		phenoAvgRemaining = phenoAvg[which(phenoAvg!=q[2])];
                qx = quantile(phenoAvgRemaining, probs=c(0.5), na.rm=TRUE)
		minXX = min(phenoAvgRemaining, na.rm=TRUE)
                maxXX = max(phenoAvgRemaining, na.rm=TRUE)

		if (qx[1]==minXX) {
			# edge case again - quantile value is lowest value
                        idx1 = which(phenoAvg==qx[1]);
                        idx2 = which(phenoAvg>qx[1] & phenoAvg<q[2]);
			cat("Bin 1: ==", qx[1], ", bin 2: >", qx[1], " AND < ", q[2], ", bin 3: ==", q[2], " || ", sep="")
                }
                else if	(qx[1]==maxXX) {
			# edge case again - quantile value is max value
                        idx1 = which(phenoAvg<qx[1]);
                        idx2 = which(phenoAvg==qx[1]);
			cat("Bin 1: <", qx[1], ", bin 2: ==", qx[1], ", bin 3: ==", q[2], " || ", sep="")
                }
                else {
	                idx1 = which(phenoAvg<qx[1]);  
			idx2 = which(phenoAvg>=qx[1] & phenoAvg<q[2]);
			cat("Bin 1: <", qx[1], ", bin 2: >=", qx[1], " AND < ", q[2], ", bin 3: ==", q[2], " || ", sep="")
		}

                phenoBinned[idx1] = 0;
                phenoBinned[idx2] = 1;
	}
       else if (q[1] == q[2]) {
		# both quantiles correspond to the same value so set 
		# cat1 as < this value, cat2 as exactly this value and
		# cat3 as > this value
              	phenoBinned = phenoAvg;
        	idx1 = which(phenoAvg<q[1]);
                idx2 = which(phenoAvg==q[2]);
                idx3 = which(phenoAvg>q[2]);
                phenoBinned[idx1] = 0;
                phenoBinned[idx2] = 1;
                phenoBinned[idx3] = 2;

		cat("Bin 1: <", q[1], ", bin 2: ==", q[2], ", bin 3: >", q[2], " || ", sep="")
       	}
        else {
		# standard case - split the data into three roughly equal parts where
		# cat1<q1, cat2 between q1 and q2, and cat3>=q2
         	phenoBinned = phenoAvg;
                idx1 = which(phenoAvg<q[1]);
                idx2 = which(phenoAvg>=q[1] & phenoAvg<q[2]);
               	idx3 = which(phenoAvg>=q[2]);
                phenoBinned[idx1] = 0;
                phenoBinned[idx2] = 1;
                phenoBinned[idx3] = 2;

		cat("Bin 1: <", q[1], ", bin 2: >=", q[1], "AND < ", q[2] ,", bin 3: >=", q[2], " || ", sep="")
	}

	cat("cat N: ", length(idx1),", ",length(idx2),", ",length(idx3), " || ", sep="");
	
	return(phenoBinned);
}

