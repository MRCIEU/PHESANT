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
## load phenotypes from phenotype file

loadPhenotypes <- function() {

	sepx=','
	if (opt$tab == TRUE) {
		sepx='\t'
	}

        ## is not running 'all' then we determine the start and end idxs of phenotypes that we test, so that we can parallelise into multiple jobs
        if (opt$varTypeArg!="all") {

		# read pheno file column names
	        phenoVars = read.table(opt$phenofile, header=0, nrows=1, sep=sepx)
	        phenoVars = phenoVars[which(phenoVars!=opt$userId)]


		#####
		##### calculate part start and end

                partSize = ceiling(length(phenoVars)/opt$numParts);
                partStart = (opt$partIdx-1)*partSize + 1;

                if (opt$partIdx == opt$numParts) {
                        partEnd = length(phenoVars);
                } else {
                        partEnd = partStart + partSize - 1;
                }

                print(paste(partStart, '-', partEnd));


                #####
                ##### find range of columns to read in

		## This is more complicated than just reading in a column range, because we need to determine cut points
		## such that all columns of a particular field are loaded.
		## A field is included in a 'part' if its last column is within the part range.
		## e.g. for part 2 of 5 parts and for 100 columns, then fields having their last column at position 21 - 40 (i.e. its column index) are included in this part.

                ## user ID always included
                phenosToTest = c(opt$userId)

		currentVar=""
		currentVarLong=""
		currentVarShort=""
		first=TRUE
		phenoIdx=0

		# all columns for a particular field
		thisPhenoToTest = c()

                for (var in phenoVars) {

                        varx = gsub("^x", "", var);
                        varx = gsub("_[0-9]+$", "", varx);
                        varxShort = gsub("^x", "", var);
                        varxShort = gsub("_[0-9]+_[0-9]+$", "", varxShort);
			currentVarLong = var

			if (currentVar == varx) { # same variable same timepoint
				# add current var to pheno list
				thisPhenoToTest = append(thisPhenoToTest, as.character(currentVarLong))
			}
                        else if (currentVarShort == varxShort) { # save var, diff timepoint
                                ## different time point of this var so skip in testing but add here because some are fixed to cat mult
                                thisPhenoToTest = append(thisPhenoToTest, as.character(currentVarLong))
                        } else {
                              	## new variable so run test for previous (we have collected all the columns now)

                                if (first==FALSE) {
                                        if (phenoIdx>=partStart && phenoIdx<=partEnd) { # only start new variable processing if last column of it is within the idx range for this part
                                       		phenosToTest = append(phenosToTest, thisPhenoToTest)
					}
                                }

                                first=FALSE;

                                ## new variable so set values
                                currentVar = varx
                                currentVarShort = varxShort
				thisPhenoToTest = c(as.character(currentVarLong))
                        }


                        phenoIdx = phenoIdx + 1
                }

                # last variable so test association
                if (phenoIdx>=partStart && phenoIdx<=partEnd) {
                        #phenosToTest = append(phenosToTest, as.character(currentVarLong))
			phenosToTest = append(phenosToTest, as.character(thisPhenoToTest))
                }

                ## read in the right table columns - a subset of the data file
                data = fread(opt$phenofile, select=phenosToTest, sep=sepx, header=TRUE, data.table=FALSE, na.strings=c("", "NA"))

        } else {
                # reading all data at once
                data = fread(opt$phenofile, sep=sepx, header=TRUE, data.table=FALSE, na.strings=c("", "NA"))
        }

	## this is type conversion as used in the read.table function (that we used to use ((this was changed because read.table cannot read column subsets))
	data = data.frame(lapply(data,function(x) type.convert(as.character(x), as.is=TRUE)))

	colnames(data)[1] <- "userID"

	return(data)

}


