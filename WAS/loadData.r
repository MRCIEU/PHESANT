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

## load phenotype
#phenoFile=paste(dataDir,'phenotypes/ukb6564-150-ALL.csv',sep="");
print("Loading phenotypes...")
phenotype=read.table(opt$phenofile, header=1,sep=","); #\t
validatePhenotypeInput(phenotype)


if (opt$save==TRUE) { # saving not running tests so we don't need the confounders or trait of interest

	datax = phenotype;
	datax = fixOddFieldsToCatMul(datax)

	# add pretend trait of interest so other code doesn't break
	numRows = nrow(datax)
	datax$geno = rep(-1, numRows)

	idxUserId = which(names(datax) == opt$userId);
        colnames(datax)[idxUserId] = "userID"
	
	confounders = data.frame(rep(-1, numRows))
	colnames(confounders)[1] = "conf"
        d = list(datax=datax, confounders=confounders);
        return(d);

} else {

## load snps
if (is.null(opt$traitofinterestfile)) {
	print("Extracting trait of interest from pheno file")
	if (opt$traitofinterest %in% colnames(phenotype)) {

		print("Trait of interest found in pheno file.")

		# set name of trait of interest to geno in phenotype file
		idxTOI = which(colnames(phenotype)==opt$traitofinterest)
		colnames(phenotype)[idxTOI] <- "geno"		

		datax = phenotype;
	
		# reorder columns so user id and trait of interest are first and second columns
		idxUserId = which(names(phenotype) == opt$userId);
		colnames(phenotype)[idxUserId] = "userID"
		datax = cbind( datax[,c(idxUserId,idxTOI)], datax[,-c(idxUserId,idxTOI)])

		# remove all rows with no trait of interest
		idxNotEmpty = which(!is.na(phenotype[,idxTOI]))
	        print(paste("Phenotype file has ", nrow(phenotype), " rows with ", length(idxNotEmpty), " not NA for trait of interest (",opt$traitofinterest,").", sep=""))
	        phenotype = phenotype[idxNotEmpty,]
	} else {
		stop(paste("Trait of interest (",opt$traitofinterest,") not found in phenotype file ",opt$phenofile, ". Trait of interest should either be in phenotype file or seperate trait of interest file specified in traitofinterestfile arg.", sep=""), call.=FALSE)
	}

} else {
	print("Loading trait of interest file...")
	snpScores=read.table(opt$traitofinterestfile,sep=",", header=1);
	validateTraitInput(snpScores)

	# keep only the userID and exposure variable
	idx1 = which(names(snpScores) == opt$userId);
	idx2 = which(names(snpScores) == opt$traitofinterest);

	# remove all rows with no trait of interest
	idxNotEmpty = which(!is.na(snpScores[,idx2]))
	print(paste("Trait of interest has ", nrow(snpScores), " rows with ", length(idxNotEmpty), " not NA", sep=""))
	snpScores = snpScores[idxNotEmpty,]

	snpScores=cbind.data.frame(snpScores[,idx1], snpScores[,idx2]);
	colnames(snpScores)[1] <- "userID";
	colnames(snpScores)[2] <- "geno";

	# rename user id column in pheno dataframe
	idxUserId = which(names(phenotype) == opt$userId);
        colnames(phenotype)[idxUserId] = "userID"

	print("Merging trait of interest and phenotype data")
	## merge to one matrix
	datax = merge(snpScores, phenotype, by="userID", all=FALSE);
}

if (nrow(datax)==0) {
	stop("No examples with row in both trait of interest and phenotype files", call.=FALSE)
} else {
	print(paste("Phenotype and trait of interest data files merged, with", nrow(datax),"examples"))
}

# some fields are fixed that have a field type as cat single but we want to treat them like cat mult
datax = fixOddFieldsToCatMul(datax)

confounders = getConfounders(datax)

d = list(datax=datax, confounders=confounders);

return(d);
}

}
