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

##
## load data used for data code default value related field, and categorical multiple indicator field
loadIndicatorFields <- function() {

        ## is not running 'all' then we determine the start and end idxs of phenotypes that we test, so that we can parallelise into multiple jobs

	# read pheno file column names
        phenoVars = read.table(opt$phenofile, header=0, nrows=1, sep=',')
        phenoVars = phenoVars[which(phenoVars!=opt$userId)]

	phenosToTest = c(opt$userId)

	## add indicator variables to pheno data
	phenosToTest = addIndicatorVariables(phenosToTest)

        ## read in the right table columns
        data = fread(opt$phenofile, select=phenosToTest, sep=',', header=TRUE, data.table=FALSE)
	data = data.frame(lapply(data,function(x) type.convert(as.character(x))))

	colnames(data)[1] <- "userID"
	return(data)

}


addIndicatorVariables <- function(phenosToTest) {

	#####
	##### default value related fields for data codes
	# get list of all indicator variables from outcome info file
	defaultFields = unique(na.omit(vl$dataCodeInfo$default_related_field))
	defaultFields = paste("x", defaultFields, "_0_0", sep="")
	## remove those that already exist in phenotypes 'part'
	defaultFields = defaultFields[-which(defaultFields %in% phenosToTest)]
	phenosToTest = append(phenosToTest, defaultFields)

	#####
	##### categorical multiple indicator fields
	defaultFields = unique(na.omit(vl$phenoInfo$CAT_MULT_INDICATOR_FIELDS))
	defaultFields = as.character(defaultFields)
        defaultFields = defaultFields[-which(defaultFields == "NO_NAN")]
        defaultFields = defaultFields[-which(defaultFields == "ALL")]
	defaultFields = defaultFields[-which(defaultFields == "")]
	defaultFields = paste("x", defaultFields, "_0_0", sep="")

        #####
	##### remove those that already exist in phenotypes 'part'
	idxExists = which(defaultFields %in% phenosToTest)
	if (length(idxExists>0)) {
	        defaultFields = defaultFields[-idxExists]
	}

        phenosToTest = append(phenosToTest, defaultFields)
	return(phenosToTest)

}

