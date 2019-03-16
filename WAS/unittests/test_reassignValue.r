
library("testthat");
#install.packages("testthat")

source("../reassignValue.r");

# reassigning a value in a categorical variable
x1 = reassignValue2(c(1,1,6,6,7,3,5,7,3), "7=6");
expect_equal(x1, c(1,1,6,6,6,3,5,6,3));

# reassign a value in a categorical multple value, with several columns (arrays)
c1=c(1,2,3)
c2=c(3,4,5)
m=cbind.data.frame(c1,c2)
x1 = reassignValue2(m,"3=10|5=NA")

c1=c(1,2,10)
c2=c(10,4,NA)
exp=cbind.data.frame(c1,c2)
expect_equal(x1, exp)


## test equivalent to data code 216 - X converted to -1 so now the data is numeric and should be converted.

x1 = reassignValue2(c(1,1,6,6,"X",3,5,7,3), "X=-1");
expect_equal(x1, c(1,1,6,6,-1,3,5,7,3));
expect_equal(is.numeric(x1), TRUE)










