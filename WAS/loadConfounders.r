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
## loads confounder variables from phenotype file

loadConfounders <- function(phenotypes) {

if (opt$save==TRUE) { 

	# saving not running tests so we add a fake confounder
	numRows = nrow(phenotypes)
        data = cbind.data.frame(phenotypes$userID, rep(-1, numRows))
        colnames(data)[1] <- "userID"
        colnames(data)[2] <- "conf1"
        return(data)

} else {

	if (!is.null(opt$confounderfile)) {
		print("Loading confounders from confounder file ...")
	
		confs = fread(opt$confounderfile, sep=',', header=TRUE, data.table=FALSE)
	        confs = lapply(confs,function(x) type.convert(as.character(x), as.is=TRUE))
	        confs = as.data.frame(confs)

		## find userID column and change name to userID
		idx = which(colnames(confs) == opt$userId)
		confs = confs[,c(opt$userID,setdiff(colnames(confs),opt$userID))]
		colnames(confs)[1] <- "userID"

		# remove any rows with no values
	        print(paste("Number of rows in confounder data: ", nrow(confs),sep=""))
	        confsComp = complete.cases(confs)
	        print(paste("Number of INCOMPLETE rows removed from confounder data: ", length(which(confsComp==FALSE)),sep=""))
	        confs = confs[confsComp==TRUE,]
		print(paste("Number of rows in confounder data: ", nrow(confs),sep=""))

	} else {
	print("Loading confounders from phenotypes file ...")
        confNames = getConfounderNames()

	sepx=','
	if (opt$tab == TRUE) {
	        sepx='\t'
	}



        #####
	##### extract confounders from data file
        confs = fread(opt$phenofile, select=confNames, sep=sepx, header=TRUE, data.table=FALSE)
	confs = lapply(confs,function(x) type.convert(as.character(x), as.is=TRUE))
	confs = as.data.frame(confs)

	#####
	##### remove any rows with no values
        print(paste("Number of rows in confounder data: ", nrow(confs),sep=""))
        confsComp = complete.cases(confs)
        print(paste("Number of INCOMPLETE rows removed from confounder data: ", length(which(confsComp==FALSE)),sep=""))
        confs = confs[confsComp==TRUE,]
	print(paste("Number of rows in confounder data: ", nrow(confs),sep=""))

        #####
	##### process genetic batch to create genetic chip variable
        if (opt$genetic == TRUE) {
                genoBatch = confs[,"x22000_0_0"]

                # chip comes from batch field 22000
                genoChip = rep.int(NA,nrow(confs));
                idxForVar = which(genoBatch<0);
                genoChip[idxForVar] = 0;
                idxForVar = which(genoBatch>=0 & genoBatch<2000);
                genoChip[idxForVar] = 1;

		# remove geno batch from and add geno chip to confounders
                confs = confs[,-which(names(confs) == "x22000_0_0")]
                confs = cbind.data.frame(confs, genoChip)
        }


	#####
	##### Convert assessment centre to an indicator variable
	if (opt$sensitivity==TRUE) {
		confs$x54_0_0 = as.factor(confs$x54_0_0)
		assCentre = model.matrix(~confs$x54_0_0)
		assCentre = assCentre[,2:ncol(assCentre)]
		confs = cbind(confs, assCentre)
		confs$x54_0_0 = NULL
	}

	colnames(confs)[1] <- "userID"

	}


	print("Confounder columns:")
	print(names(confs))

	return(confs)
}
}

getConfounderNames <- function() {

        #####
	##### first get vector of confounder names

        # age and sex
        confNames = c(opt$userId, "x21022_0_0", "x31_0_0")

        # if genetic trait of interest then adjust for genotype chip
        # and also let user choose sensitivity analysis that also adjusts for top 10 genetic principal components and assessment centre
        if (opt$genetic == TRUE) {

                confNames = append(confNames, "x22000_0_0")

                if (opt$sensitivity==TRUE) {
                        confNames = append(confNames, c("x22009_0_1", "x22009_0_2", "x22009_0_3", "x22009_0_4", "x22009_0_5", "x22009_0_6", "x22009_0_7", "x22009_0_8", "x22009_0_9", "x22009_0_10", "x54_0_0"))
                        print("Adjusting for age, sex, genotype chip, top 10 genetic principal components and assessment centre")
                } else {
                        print("Adjusting for age, sex and genotype chip")
                }
        } else {
                # non genetic trait of interest, then sensitivity adjusts for assessment center
                if (opt$sensitivity==TRUE) {
                        confNames = append(confNames, "x54_0_0")
                        print("Adjusting for age, sex and assessment centre")
                } else {
                        print("Adjusting for age and sex")
                }
        }

	return(confNames)
}


