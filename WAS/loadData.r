

# loads phenotype and trait of interest data files
# creates phenotype / trait of interest data frame
# creates confounder data frame
# returns an object holding these two data frames
loadData <- function() {

## load phenotype
#phenoFile=paste(dataDir,'phenotypes/ukb6564-150-ALL.csv',sep="");
print("Loading phenotypes...")
phenotype=read.table(opt$outcomefile, header=1,sep=","); #\t

## load snps
print("Loading trait of interest...")
#snpFile=paste(dataDir,'snps/snp-score96-withPhenIds-subset.csv',sep="");
snpScores=read.table(opt$traitofinterestfile,sep=",", header=1);

validateInput(phenotype, snpScores);
print("Phenotype and trait of interest files validated");

# keep only the userID and exposure variable
idx1 = which(names(snpScores) == opt$userId);
idx2 = which(names(snpScores) == opt$traitofinterest);
snpScores=cbind.data.frame(snpScores[,idx1], snpScores[,idx2]);
colnames(snpScores)[1] <- opt$userId;
#colnames(snpScores)[2] <- opt$traitofinterest;
colnames(snpScores)[2] <- "geno";

## merge to one matrix
datax = merge(snpScores, phenotype, by=opt$userId, all=FALSE);

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
