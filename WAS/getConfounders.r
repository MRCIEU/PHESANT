

getConfounders <- function(datax) {

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
                confounders = cbind.data.frame(confounders, genoPCs, assessCenter);
                print("Adjusting for age, sex, genotype chip, top 10 genetic principal components and assessment centre")
        } else {
                print("Adjusting for age, sex and genotype chip")
        }
} else {
        # non genetic trait of interest, then sensitivity adjusts for assessment center
        if (opt$sensitivity==TRUE) {
                assessCenter = datax[,"x54_0_0"];
                confounders = cbind.data.frame(confounders, assessCenter)
                print("Adjusting for age, sex and assessment centre")
        } else {
                print("Adjusting for age and sex")
        }
}


return(confounders)

}
