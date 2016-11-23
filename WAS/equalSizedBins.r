
# splits the pheno into 3 bins with the cut points between values rather at the exact value for the quantile
equalSizedBins <- function(phenoAvg) {

	## equal sized bins 
        q = quantile(phenoAvg, probs=c(1/3,2/3), na.rm=TRUE)

	minX = min(phenoAvg, na.rm=TRUE)
	maxX = max(phenoAvg, na.rm=TRUE)

	phenoBinned = phenoAvg;
	if (q[1]==minX) {
		# edge case - quantile value is lowest value
		idx1 = which(phenoAvg==q[1]);
		phenoBinned[idx1] = 0;

		phenoAvgRemaining = phenoAvg[which(phenoAvg!=q[1])];
		qx = quantile(phenoAvgRemaining, probs=c(0.5), na.rm=TRUE)
		minXX = min(phenoAvgRemaining, na.rm=TRUE)
		maxXX =	max(phenoAvgRemaining, na.rm=TRUE)

		if (qx[1]==minXX) {
			idx2 = which(phenoAvg==qx[1]);
			idx3 = which(phenoAvg>qx[1]);
		}
		else if (qx[1]==maxXX) {
			idx2 = which(phenoAvg<qx[1] & phenoAvg>q[1]);
			idx3 = which(phenoAvg==qx[1]);
		}
		else {
			idx2 = which(phenoAvg<qx[1] & phenoAvg>q[1]);
			idx3 = which(phenoAvg>=qx[1]);
		}
		phenoBinned[idx2] = 1;
                phenoBinned[idx3] = 2;
	}
	else if (q[2]==maxX) {
		# edge case - quantile value is highest value
		idx3 = which(phenoAvg==q[2]);
		phenoBinned[idx3] = 2;

		phenoAvgRemaining = phenoAvg[which(phenoAvg!=q[2])];
                qx = quantile(phenoAvgRemaining, probs=c(0.5), na.rm=TRUE)
		minXX = min(phenoAvgRemaining, na.rm=TRUE)
                maxXX = max(phenoAvgRemaining, na.rm=TRUE)

		if (qx[1]==minXX) {
                        idx1 = which(phenoAvg==qx[1]);
                        idx2 = which(phenoAvg>qx[1] & phenoAvg<q[2]);
                }
                else if	(qx[1]==maxXX) {
                        idx1 = which(phenoAvg<qx[1]);
                        idx2 = which(phenoAvg==qx[1]);
                }
                else {
	                idx1 = which(phenoAvg<qx[1]);  
			idx2 = which(phenoAvg>=qx[1] & phenoAvg<q[2]);
		}

                phenoBinned[idx1] = 0;
                phenoBinned[idx2] = 1;
	}
       else if (q[1] == q[2]) {
              	phenoBinned = phenoAvg;
        	idx1 = which(phenoAvg<q[1]);
                idx2 = which(phenoAvg==q[2]);
                idx3 = which(phenoAvg>q[2]);
                phenoBinned[idx1] = 0;
                phenoBinned[idx2] = 1;
                phenoBinned[idx3] = 2;
       	}
        else {
         	phenoBinned = phenoAvg;
                idx1 = which(phenoAvg<q[1]);
                idx2 = which(phenoAvg>=q[1] & phenoAvg<q[2]);
               	idx3 = which(phenoAvg>=q[2]);
                phenoBinned[idx1] = 0;
                phenoBinned[idx2] = 1;
                phenoBinned[idx3] = 2;
	}

	cat("cat N: ", length(idx1),", ",length(idx2),", ",length(idx3), " || ", sep="");
	

	return(phenoBinned);
}

