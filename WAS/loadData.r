# The MIT License (MIT)
# Copyright (c) 2017 Louise AC Millard
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
phenotype=read.table(opt$outcomefile, header=1,sep=","); #\t
validatePhenotypeInput(phenotype)


## load snps
if (is.null(opt$traitofinterestfile)) {
	print("Extracting trait of interest from pheno file")
	if (opt$traitofinterest %in% colnames(phenotype)) {

		print("Trait of interest found in pheno file.")

		# set name of trait of interest to geno in phenotype file
		idxTOI = which(colnames(phenotype)==opt$traitofinterest)
		colnames(phenotype)[idxTOI] <- "geno"		

		datax = phenotype;
	
		# remove all rows with no trait of interest
		idxNotEmpty = which(!is.na(phenotype[,idxTOI]))
	        print(paste("Phenotype file has ", nrow(phenotype), " rows with ", length(idxNotEmpty), " not NA for trait of interest (",opt$traitofinterest,").", sep=""))
	        phenotype = phenotype[idxNotEmpty,]
	}
	else {
		stop(paste("Trait of interest (",opt$traitofinterest,") not found in phenotype file ",opt$outcomefile, ". Trait of interest should either be in phenotype file or seperate trait of interest file specified in traitofinterestfile arg.", sep=""), call.=FALSE)
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
	colnames(snpScores)[1] <- opt$userId;
	colnames(snpScores)[2] <- "geno";

	print("Merging trait of interest and phenotype data")
	## merge to one matrix
	datax = merge(snpScores, phenotype, by=opt$userId, all=FALSE);
}

if (nrow(datax)==0) {
	stop("No examples with row in both trait of interest and phenotype files", call.=FALSE)
}
else {
	print(paste("Phenotype and trait of interest data files merged, with", nrow(datax),"examples"))
}

datax = fixOddFieldsToCatMul(datax)

## vars we adjust for
age = datax[,"x21022_0_0"];
sex = datax[,"x31_0_0"];

confounders = cbind.data.frame(age,sex);

# if genetic trait of interest then adjust for genotype chip
# and also let user choose sensitivity analysis that also adjusts for top 10 genetic principal components and assessment centre
if (opt$genetic == TRUE) {

	genoBatch = datax[,"x22000_0_0"];

	# chip comes from batch field 22000
	genoChip = rep.int(NA,nrow(datax));
	idxForVar = which(genoBatch<0);
	genoChip[idxForVar] = 0;
	idxForVar = which(genoBatch>=0 & genoBatch<2000);
	genoChip[idxForVar] = 1;

	confounders = cbind.data.frame(confounders, genoChip);

	if (opt$sensitivity==TRUE) {
		genoPCs = cbind(datax[,"x22009_0_1"], datax[,"x22009_0_2"], datax[,"x22009_0_3"], datax[,"x22009_0_4"], datax[,"x22009_0_5"], datax[,"x22009_0_6"], datax[,"x22009_0_7"], datax[,"x22009_0_8"], datax[,"x22009_0_9"], datax[,"x22009_0_10"]);
		assessCenter = datax[,"x54_0_0"];
		confounders = cbind.data.frame(confounders, genoBatch, genoPCs, assessCenter);
		print("Adjusting for age, sex, genetic batch, top 10 genetic principal components and assessment centre")
	}
	else {
		print("Adjusting for age, sex and genetic batch")
	}
}
else {
	# non genetic trait of interest, then sensitivity adjusts for assessment center
	if (opt$sensitivity==TRUE) {
		assessCenter = datax[,"x54_0_0"];
		confounders = cbind.data.frame(confounders, assessCenter)
		print("Adjusting for age, sex and assessment centre")
	} else {
		print("Adjusting for age and sex")
	}
}

d = list(datax=datax, confounders=confounders);

return(d);

}
