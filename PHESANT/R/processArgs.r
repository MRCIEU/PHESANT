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


# Parse the arguments input by the user
# if argument 'test' is used then run test phenome scan
processArgs <- function() {

if (opt$test==TRUE) {

	# set up the test phenome scan settings
	datadir='../testWAS/data/';
	opt$resDir <<- '../testWAS/results/';
        opt$userId <<- 'userId';
	opt$phenofile <<-  paste(datadir,'phenotypes.csv', sep="");
        opt$variablelistfile <<- '../testWAS/variable-lists/outcome-info.tsv';
        opt$datacodingfile <<- '../testWAS/variable-lists/data-coding-ordinal-info.txt';
	opt$confidenceintervals <<- TRUE	

	if(opt$save == FALSE) {
		opt$traitofinterestfile <<- paste(datadir,'exposure.csv', sep="");
		opt$traitofinterest <<- 'exposure';
		opt$sensitivity <<- FALSE;
		opt$genetic <<- TRUE;
	}

	processParts(opt$partIdx, opt$numParts);	
}
else {

	## check arguments are supplied correctly

	if (is.null(opt$phenofile)){
	  print_help(opt_parser)
	  stop("phenofile argument must be supplied", call.=FALSE)
	}
	else if (!file.exists(opt$phenofile)) {
                stop(paste("phenotype data file phenofile=", opt$phenofile, " does not exist", sep=""), call.=FALSE)
        }

#	if (is.null(opt$traitofinterestfile)){
#	  print_help(opt_parser)
#	  stop("traitofinterestfile argument must be supplied", call.=FALSE)
#	}
	if (opt$save==FALSE && !is.null(opt$traitofinterestfile) && !file.exists(opt$traitofinterestfile)) {
               stop(paste("trait of interest data file traitofinterestfile=", opt$traitofinterestfile, " does not exist", sep=""), call.=FALSE)
        }

	if (opt$save==FALSE && !is.null(opt$confounderfile) && !file.exists(opt$confounderfile)) {
               stop(paste("confounder data file confounderfile=", opt$confounderfile, " does not exist", sep=""), call.=FALSE)
        }

	if (is.null(opt$variablelistfile)){
	  print_help(opt_parser)
	  stop("variablelistfile argument must be supplied", call.=FALSE)
	}
	else if (!file.exists(opt$variablelistfile)) {
                stop(paste("variable listing file variablelistfile=", opt$variablelistfile, " does not exist", sep=""), call.=FALSE)
        }

	if (is.null(opt$datacodingfile)){
	  print_help(opt_parser)
	  stop("datacodingfile argument must be supplied", call.=FALSE)
	}
	else if (!file.exists(opt$datacodingfile)) {
                stop(paste("data coding file datacodingfile=", opt$datacodingfile, " does not exist", sep=""), call.=FALSE)
        }

	if (opt$save==FALSE && is.null(opt$traitofinterest)){
	  print_help(opt_parser)
	  stop("traitofinterest argument must be supplied", call.=FALSE)
	}

	if (is.null(opt$resDir)){
	  print_help(opt_parser)
	  stop("resDir argument must be supplied", call.=FALSE)
	}
	else if (!file.exists(opt$resDir)) {
		stop(paste("results directory resDir=", opt$resDir, " does not exist", sep=""), call.=FALSE)
	}


	processParts(opt$partIdx, opt$numParts);
}
	

if (opt$save==TRUE) {
	print("Saving phenotypes to file. Tests of association will not run!")
}

}

# Parse the 'part' arguments and check they are valid
processParts <- function(pIdx, nParts) {

	if (is.null(pIdx) && is.null(nParts)) {
                opt$varTypeArg <<- "all";
		print(paste("Running with all traits in phenotype file:", opt$phenofile));
        }
	else if (is.null(pIdx)) {
                print_help(opt_parser)
                stop("pIdx argument must be supplied when nParts argument is supplied", call.=FALSE)
        }
	else if (is.null(nParts)) {
                print_help(opt_parser)
                stop("nParts argument must be supplied when pIdx argument is supplied", call.=FALSE)
        }
	else if (pIdx<1 || pIdx>nParts) {
		print_help(opt_parser)
                stop("pIdx arguments must be between 1 and nParts inclusive", call.=FALSE)
	}
	else {
                opt$varTypeArg <<- paste(pIdx, "-", nParts, sep="");
        	print(paste("Running with part",pIdx,"of",nParts," in phenotype file:", opt$phenofile));
	}

}
