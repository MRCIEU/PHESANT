
library("testthat");
#install.packages("testthat")

source("../testCatSingle.r");

# reordering values of a categorical variable
x1 = reorderOrderedCategory(c(7,3,5,1,8,10,1,5,3,7), "7|3|5|1");
expect_equal(x1, c(1,2,3,4,NA,NA,4,3,2,1));







