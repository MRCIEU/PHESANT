
library("testthat");
#install.packages("testthat")

source("../testCatMultiple.r");
source("../replaceNaN.r")

# categorical multiple phenotype with two arrays
pheno_0_0 <- c(1,2,-1,NA,1,2,-1,NA);
pheno_0_1 <- c(NA,-1,NA,NA,NA,-1,NA,NA)

other_0_0 <- c(1,1,1,1,NA,NA,-1,-1)

data = cbind.data.frame(pheno_0_0,pheno_0_1,other_0_0)
colnames(data)[1] <- "pheno_0_0"
colnames(data)[2] <- "pheno_0_1"
colnames(data)[3] <- "xother_0_0"

####
# include ALL - pheno with NK values aren't included as -ve examples
idxNA = restrictSample2('test1',data[,1:2], "ALL", 1)
expect_equal(sort(idxNA), c(2,3,6,7))

# here examples 2 and 6 aren't included because they correspond to the -ve class
idxNA = restrictSample2('test1',data[,1:2], "ALL", 2) 
expect_equal(sort(idxNA), c(3,7))

####
# include NO_NAN
idxNA = restrictSample2('test1',data[,1:2], "NO_NAN", 1)
cat("\n")
expect_equal(sort(idxNA), c(2,3,4,6,7,8))

# here examples 2 and 6	aren't included	because	they correspond	to the -ve class
idxNA = restrictSample2('test1',data[,1:2], "NO_NAN", 2)
cat("\n")
expect_equal(sort(idxNA), c(3,4,7,8))

####
# include only those with (non missing) value for other field
idxNA = restrictSample2('test1',data[,1:2], "other", 1)
cat("\n")
expect_equal(sort(idxNA), c(2,3,5,6,7,8))

# 
idxNA = restrictSample2('test1',data[,1:2], "other", 2)
cat("\n")
expect_equal(sort(idxNA), c(3,5,6,7,8))


## if cat mult is not numeric then can't have missing values
pheno_0_0 <- c("A","B","C",NA,"A","B","C",NA);
pheno_0_1 <- c(NA,"C",NA,NA,NA,"C",NA,NA)
other_0_0 <- c("A","A","A","A",NA,NA,"C","C")
data = cbind.data.frame(pheno_0_0,pheno_0_1,other_0_0)
colnames(data)[1] <- "pheno_0_0"
colnames(data)[2] <- "pheno_0_1"
colnames(data)[3] <- "xother_0_0"


idxNA = restrictSample2('test1',data[,1:2], "ALL", "A")
expect_equal(idxNA, NULL)

idxNA = restrictSample2('test1',data[,1:2], "NO_NAN", "A")
expect_equal(sort(idxNA), c(4,8))

idxNA = restrictSample2('test1',data[,1:2], "other", "A")
expect_equal(sort(idxNA), c(5,6))


