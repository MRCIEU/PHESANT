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


# looks up categorical multiple field in the variable info file, return
# number of values denoted as trait of interest.
# returns zero if whole field is denoted trait of interest, not particular values.
getNumValuesCatMultExposure <- function(varName) {
	
	# get row index of field in variable information file
	idx=which(vl$phenoInfo$FieldID==varName)

	# may be empty of may contain VALUE1|VALUE2 etc .. to denote those
	# cat mult values denoting exposure variable
	isExposure = vl$phenoInfo$TRAIT_OF_INTEREST[idx]
        
        if (!is.na(isExposure) & isExposure!="") {
		
		isExposure = as.character(isExposure)
		
		## first check if value is YES, then no partic values are traits of interest
		if (isExposure == "YES") {
			return(0)
		}

		## try to split by |, to set particular values as exposure

		# split into variable Values
		exposureValues = unlist(strsplit(isExposure,"\\|"))

		return(length(exposureValues))

	}

	# varValue is not in list of exposure values
	return(0)

}
