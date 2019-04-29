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


# Validate the contents of the phenotype file
validatePhenotypeInput <- function() {

	print("Validating phenotype data ...")

	sepx=','
        if (opt$tab == TRUE) {
                sepx='\t'
        }

	## get just first row so we can check the column names
	phenoIn = read.table(opt$phenofile, header=1, nrows=1, sep=sepx)
	
	###
	### pheno file validation

	print(paste("Number of columns in phenotype file: ", ncol(phenoIn),sep=""))

	## check user id exists in pheno file
	idx1 = which(names(phenoIn) == opt$userId);
	if (length(idx1)==0) {
                stop(paste("phenotype file doesn't contain userID colunn:", opt$userId), call.=FALSE)
        }

	# we only need the confounders if we are actually running the tests
	if (opt$save==FALSE & is.null(opt$confounderfile)) {

	## confounder variables exist in pheno file
	idx = which(names(phenoIn) == "x21022_0_0");
	if (length(idx)==0) {
                stop("phenotype file doesn't contain required age colunn: x21022_0_0", call.=FALSE)
        }

	idx = which(names(phenoIn) == "x31_0_0");
        if (length(idx)==0) {
                stop("phenotype file doesn't contain required sex colunn: x31_0_0", call.=FALSE)
        }

	
	if (opt$genetic ==TRUE) {
		idx = which(names(phenoIn) == "x22000_0_0");
        	if (length(idx)==0) {
        	        stop("phenotype file doesn't contain required genetic batch colunn: x22000_0_0", call.=FALSE)
        	}	
	}

	## if running with sensitivity option then check extra columns exist in pheno file (genetic PCs and assessment centre)
	if (opt$sensitivity==TRUE) {

		if (opt$genetic ==TRUE) {
			## check first 10 genetic PCs exist
			for (i in 1:10) {
				idx = which(names(phenoIn) == paste("x22009_0_", i, sep=""));
				if (length(idx)==0) {
         			       stop(paste("phenotype file doesn't contain required genetic principal component colunn: x22009_0_", i, sep=""), call.=FALSE)
        			}
			}
		}

		## assessment centre field
		idx = which(names(phenoIn) == "x54_0_0");
        	if (length(idx)==0) {
        	        stop("phenotype file doesn't contain required assessment centre colunn: x54_0_0", call.=FALSE)
        	}
	}

	}

	print("Phenotype file validated")

}
