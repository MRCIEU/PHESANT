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


# Remove variable values if less than 10 examples have this value
testNumExamples <- function(pheno) {
	
	## loop through values and remove if has < 10 examples
        uniqVar = unique(na.omit(pheno));
        for (u in uniqVar) {
                withValIdx = which(pheno==u)
                numWithVal = length(withValIdx);
                if (numWithVal<opt$mincase) {
                        pheno[withValIdx]=NA
			cat(paste("Removed ",u ,": ", numWithVal, "<",opt$mincase," examples || ", sep=""));
                }
		else {
			cat(paste("Inc(>=",opt$mincase,"): ", u, "(", numWithVal, ") || ", sep=""));
		}
        }
	return(pheno);
}
