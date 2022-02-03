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
## load trait of interest, either from separate trait of interest file, or from phenotype file

loadTraitOfInterest <- function(phenotypes) {


if (opt$save==TRUE) { 
	# saving not running tests so we don't have a trait of interest

        # add pretend trait of interest so other code doesn't break
        numRows = nrow(phenotypes)
	data = cbind.data.frame(phenotypes$userID, rep(-1, numRows))

} else {

	# load the trait of interest specified by the user

        if (is.null(opt$traitofinterestfile)) {
                print("Extracting trait of interest from pheno file ...")
		data = fread(opt$phenofile, select=c(opt$userId, opt$traitofinterest), sep=',', header=TRUE, data.table=FALSE)

        } else {
                print("Loading trait of interest file ...")
                data = fread(opt$traitofinterestfile, select=c(opt$userId, opt$traitofinterest), sep=',', header=TRUE, data.table=FALSE)
        }

	data = data.frame(lapply(data,function(x) type.convert(as.character(x), as.is=TRUE)))
}

colnames(data)[1] <- "userID"
colnames(data)[2] <- "geno"

return(data)

}
