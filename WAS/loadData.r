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


# loads phenotype and trait of interest data files
# creates phenotype / trait of interest data frame
# creates confounder data frame
# returns an object holding these two data frames
loadData <- function() {

	library(data.table)

	#####
	##### validating data

	## check phenotype file headers
	validatePhenotypeInput()

	## check trait of interest file headers
	validateTraitInput()

	#####
	##### load data

	## load phenotype
	print("Loading phenotypes ...")
	phenotype = loadPhenotypes()

	## load trait of interest
        toi <- loadTraitOfInterest(phenotype)

        ## load confounders
        conf <- loadConfounders(phenotype)

	## add trait of interest to phenotype data frame and remove rows with no trait of interest
	## merge in toi with phenotype - keep id list from phenotypes file
	phenotype = merge(toi, phenotype, by="userID", all.y=TRUE, all.x=FALSE)
	
        ## remove any rows with no trait of interest
        idxNotEmpty = which(!is.na(phenotype[,"geno"]))

	if (opt$save == TRUE) {
	        print(paste("Phenotype file has ", nrow(phenotype), " rows.", sep=""))
	} else {
		print(paste("Phenotype file has ", nrow(phenotype), " rows with ", length(idxNotEmpty), " not NA for trait of interest (",opt$traitofinterest,").", sep=""))
	}

        phenotype = phenotype[idxNotEmpty,]

	# match ids from not empty phenotypes list
	confsIdx = which(conf$userID %in% phenotype$userID)
        conf = conf[confsIdx,]

	if (nrow(phenotype)==0) {
	        stop("No examples with row in both trait of interest and phenotype files", call.=FALSE)
	} else {
	        print(paste("Phenotype and trait of interest data files merged, with", nrow(phenotype),"examples"))
	}

	# some fields are fixed that have a field type as cat single but we want to treat them like cat mult
	phenotype = fixOddFieldsToCatMul(phenotype)

	indFields = loadIndicatorFields(colnames(phenotype))
	
	d = list(datax=phenotype, confounders=conf, inds=indFields)
	return(d)

}


