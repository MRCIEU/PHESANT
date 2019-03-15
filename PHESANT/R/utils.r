
.storeNewVar <- function(userIDData, phenoData, varName, type) {
  # add pheno to dataframe
  newdata = data.frame(userID=userIDData, newvar=phenoData)
  names(newdata)[names(newdata)=="newvar"] = varName
  if (type == "bin") {
    pkg.env$derivedBinary <- merge(pkg.env$derivedBinary, newdata, by="userID", all=TRUE);
  } else if (type == "cont") {
    pkg.env$derivedCont <- merge(pkg.env$derivedCont, newdata, by="userID", all=TRUE);
  } else if (type == "catOrd") {
    pkg.env$derivedCatOrd <- merge(pkg.env$derivedCatOrd, newdata, by="userID", all=TRUE);
  } else if (type == "catUnord") {
    pkg.env$derivedCatUnord <- merge(pkg.env$derivedCatUnord, newdata, by="userID", all=TRUE);
  }
}

## makes a smaller data frame containing the data for a particular test
.makeTestDataFrame <- function(datax, confounders, currentVarValues) {
			thisdata <- datax[,c("geno", "userID")]
			thisdata <- merge(thisdata, confounders, by="userID", all.x=TRUE, all.y=FALSE, sort=FALSE)
			currentVarValues <- cbind.data.frame(datax$userID, currentVarValues)
      colnames(currentVarValues)[1] <- "userID"
			thisdata <- merge(thisdata, currentVarValues, by="userID", all.x=TRUE, all.y=FALSE, sort=FALSE)
			return(thisdata)
}

# Parse the arguments input by the user
# if argument 'test' is used then run test phenome scan
processArgs <- function(opt, opt_parser) {
    if (opt$test==TRUE) {
      	# set up the test phenome scan settings
      	datadir='../testWAS/data/';
      	opt$resDir <- '../testWAS/results/';
              opt$userId <- 'userId';
      	opt$phenofile <-  paste(datadir,'phenotypes.csv', sep="");
              opt$variablelistfile <- '../testWAS/variable-lists/outcome-info.tsv';
              opt$datacodingfile <- '../testWAS/variable-lists/data-coding-ordinal-info.txt';
      	opt$confidenceintervals <- TRUE	
      
      	if(opt$save == FALSE) {
      		opt$traitofinterestfile <- paste(datadir,'exposure.csv', sep="");
      		opt$traitofinterest <- 'exposure';
      		opt$sensitivity <- FALSE;
      		opt$genetic <- TRUE;
      	}
    	  opt <- .processParts(opt, opt_parser,opt$partIdx, opt$numParts)
    }
    else {
    	## check arguments are supplied correctly
    	if (is.null(opt$phenofile)){
      	  print_help(opt_parser)
      	  stop("phenofile argument must be supplied", call.=FALSE)
    	} else if (!file.exists(opt$phenofile)) {
          stop(paste("phenotype data file phenofile=", opt$phenofile, " does not exist", sep=""), call.=FALSE)
      }
    
    	if (opt$save==FALSE && !is.null(opt$traitofinterestfile) && !file.exists(opt$traitofinterestfile)) {
          stop(paste("trait of interest data file traitofinterestfile=", opt$traitofinterestfile, " does not exist", sep=""), call.=FALSE)
      }
    
    	if (opt$save==FALSE && !is.null(opt$confounderfile) && !file.exists(opt$confounderfile)) {
          stop(paste("confounder data file confounderfile=", opt$confounderfile, " does not exist", sep=""), call.=FALSE)
      }
    
    	if (is.null(opt$variablelistfile)){
      	  print_help(opt_parser)
      	  stop("variablelistfile argument must be supplied", call.=FALSE)
    	} else if (!file.exists(opt$variablelistfile)) {
          stop(paste("variable listing file variablelistfile=", opt$variablelistfile, " does not exist", sep=""), call.=FALSE)
      }
    
    	if (is.null(opt$datacodingfile)){
      	  print_help(opt_parser)
      	  stop("datacodingfile argument must be supplied", call.=FALSE)
    	} else if (!file.exists(opt$datacodingfile)) {
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
    	opt <-.processParts(opt, opt_parser,opt$partIdx, opt$numParts);
    }
    if (opt$save==TRUE) {
    	  print("Saving phenotypes to file. Tests of association will not run!")
    }
    return(opt)
}

# Parse the 'part' arguments and check they are valid
.processParts <- function(opt, opt_parser, pIdx, nParts) {
  	if (is.null(pIdx) && is.null(nParts)) {
        opt$varTypeArg <- "all";
  		  print(paste("Running with all traits in phenotype file:", opt$phenofile));
    } else if (is.null(pIdx)) {
        print_help(opt_parser)
        stop("pIdx argument must be supplied when nParts argument is supplied", call.=FALSE)
    } else if (is.null(nParts)) {
        print_help(opt_parser)
        stop("nParts argument must be supplied when pIdx argument is supplied", call.=FALSE)
    } else if (pIdx<1 || pIdx>nParts) {
  		  print_help(opt_parser)
        stop("pIdx arguments must be between 1 and nParts inclusive", call.=FALSE)
  	} else {
        opt$varTypeArg <- paste(pIdx, "-", nParts, sep="");
        print(paste("Running with part",pIdx,"of",nParts," in phenotype file:", opt$phenofile));
  	}
    return(opt)
}
