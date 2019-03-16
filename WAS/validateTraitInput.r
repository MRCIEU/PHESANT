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


# Validate the contents of the trait of interest file
validateTraitInput <- function(snpIn) {

if (opt$save!=TRUE) {

	print("Validating trait of interest data ...")

	###
	### get header of trait of interest file or pheno file (if no trait of interest file is specified

	if (is.null(opt$traitofinterestfile)) {
		snpIn = read.table(opt$phenofile, header=1, nrows=1, sep=',')
	}
	else {
		snpIn = read.table(opt$traitofinterestfile, header=1, nrows=1, sep=',')	
	}

	###
	### trait of interest file validation

	print(paste("Number of columns in trait of interest file:", ncol(snpIn),sep=""))

	## check user id exists in snp file
	idx1 = which(names(snpIn) == opt$userId);
	if (length(idx1)==0) {
		if (is.null(opt$traitofinterestfile)) {
			stop(paste("Phenotype file doesn't contain userID colunn:", opt$userId), call.=FALSE)
		} else {
			stop(paste("Trait of interest file doesn't contain userID colunn:", opt$userId), call.=FALSE)
		}

	}
	
	## check trait of interest exists in trait of interest file
	idx2 = which(names(snpIn) == opt$traitofinterest);
	if (length(idx2)==0) {

		if (is.null(opt$traitofinterestfile)) {
			stop(paste("No trait of interest file specified, and phenotypes file doesn't contain trait of interest variable column:", opt$traitofinterest), call.=FALSE)
		}
		else {
			stop(paste("Trait of interest file doesn't contain trait of interest variable column:", opt$traitofinterest), call.=FALSE)
		}
	}

	print("Trait of interest file validated")

}

}
