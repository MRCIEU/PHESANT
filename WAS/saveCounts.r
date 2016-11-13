saveCounts <- function() {

	countFile = paste(opt$resDir,"variable-flow-counts-",opt$varTypeArg,".txt",sep="")

	# not in pheno file
	write(paste("Field not listed in phenotype information file:", count$notinphenofile), file=countFile, append="FALSE");

	# start counts for each field type
	write(paste("excluded integer:", count$excluded.int), file=countFile, append="TRUE");
	write(paste("excluded continuous:", count$excluded.cont), file=countFile, append="TRUE");
	write(paste("excluded categorical single:", count$excluded.catSin), file=countFile, append="TRUE");
	write(paste("excluded categorical multiple:", count$excluded.catMul), file=countFile, append="TRUE");
    
	write(paste("continuous starting:", count$cont), file=countFile, append="TRUE");
    	write(paste("integer starting:", count$int), file=countFile, append="TRUE");
    	write(paste("categorical single starting:", count$catSin), file=countFile, append="TRUE");
    	write(paste("categorical multiple starting:", count$catMul), file=countFile, append="TRUE");
    
	write(paste("continuous main, <=20% examples with same value:", count$cont.main), file=countFile, append="TRUE");
    	write(paste("continuous main, <500 examples:", count$cont.main.500), file=countFile, append="TRUE");

	write(paste("continuous other, one value:", count$cont.onevalue), file=countFile, append="TRUE");
    	write(paste("continuous other, 2 distinct values:", count$cont.case2), file=countFile, append="TRUE");
    	write(paste("continuous other, >2 distinct values:", count$cont.case3), file=countFile, append="TRUE");
	
	write(paste("integer, >= 20 distinct values (treated as continuous):", count$int.case1), file=countFile, append="TRUE");
    	write(paste("integer, one value:", count$int.onevalue), file=countFile, append="TRUE");
    	write(paste("integer, 2 distinct values:", count$int.case2), file=countFile, append="TRUE");
    	write(paste("integer, 3-19 distinct values:", count$int.case3), file=countFile, append="TRUE");
	
	write(paste("categorical single, one value:", count$catSin.onevalue), file=countFile, append="TRUE");
    	write(paste("categorical single, ACE:", count$catSin.ace), file=countFile, append="TRUE");
    	write(paste("categorical single, ordered:", count$catSin.case1), file=countFile, append="TRUE");
    	write(paste("categorical single, not ordered:", count$catSin.case2), file=countFile, append="TRUE");
    	write(paste("categorical single, binary:", count$catSin.case3), file=countFile, append="TRUE");
	
	write(paste("ordered categorical:", count$ordCat), file=countFile, append="TRUE");
	write(paste("ordered categorical, <500 examples:", count$ordCat.500), file=countFile, append="TRUE");
	
	write(paste("not-ordered categorical, <500 examples:", count$unordCat.500), file=countFile, append="TRUE");
	
	write(paste("categorical multiple, binary variables:", count$catMul.binary), file=countFile, append="TRUE");
	write(paste("categorical multiple, <10 in each category:", count$catMul.10), file=countFile, append="TRUE");
	write(paste("categorical multiple, >=10 in each category:", count$catMul.over10), file=countFile, append="TRUE");

	write(paste("binary, <500 examples:", count$binary.500), file=countFile, append="TRUE");

	write(paste("success continuous:", count$continuous.success), file=countFile, append="TRUE");
	write(paste("success ordered categorical:", count$ordCat.success), file=countFile, append="TRUE");
	write(paste("success not-ordered categorical:", count$unordCat.success), file=countFile, append="TRUE");
	write(paste("success binary:", count$binary.success), file=countFile, append="TRUE");

}
