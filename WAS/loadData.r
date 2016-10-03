
loadData <- function() {

## load phenotype
#phenoFile=paste(dataDir,'phenotypes/ukb6564-150-ALL.csv',sep="");
phenotype=read.table(opt$outcomefile, header=1,sep="\t");

## load snps
#snpFile=paste(dataDir,'snps/snp-score96-withPhenIds-subset.csv',sep="");
snpScores=read.table(opt$exposurefile,sep=",", header=1);

# keep only the userID and exposure variable
idx1 = which(names(snpScores) == opt$userId);
idx2 = which(names(snpScores) == opt$exposurevariable);
snpScores=cbind.data.frame(snpScores[,idx1], snpScores[,idx2]);
colnames(snpScores)[1] <- opt$userId;
#colnames(snpScores)[2] <- opt$exposurevariable;
colnames(snpScores)[2] <- "geno";

## merge to one matrix
datax = merge(snpScores, phenotype, by=opt$userId);
datax = fixOddFieldsToCatMul(datax)

## vars we adjust for
age = datax[,"x21022_0_0"];
sex = datax[,"x31_0_0"];
genoBatch = datax[,"x22000_0_0"];

# chip comes from batch field 22000
genoChip = rep.int(NA,nrow(datax));
idxForVar = which(genoBatch<0);
genoChip[idxForVar] = 0;
idxForVar = which(genoBatch>=0 & genoBatch<2000);
genoChip[idxForVar] = 1;

confounders = cbind.data.frame(age,sex,genoChip);
if (opt$sensitivity==TRUE) {
	genoPCs = cbind(datax[,"x22009_0_1"], datax[,"x22009_0_2"], datax[,"x22009_0_3"], datax[,"x22009_0_4"], datax[,"x22009_0_5"], datax[,"x22009_0_6"], datax[,"x22009_0_7"], datax[,"x22009_0_8"], datax[,"x22009_0_9"], datax[,"x22009_0_10"]);
	assessCenter = datax[,"x54_0_0"];
	confounders = cbind.data.frame(confounders, genoBatch, genoPCs, assessCenter);
}

d = list(datax=datax, confounders=confounders);

return(d);

}
