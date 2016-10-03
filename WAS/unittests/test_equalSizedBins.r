
library("testthat");
source("../equalSizedBins.r");


# q1 == minX and q2 == minXX
x1Binned = equalSizedBins(rbind(1,1,1,1,1,2,2,2,3,3));
expect_equal(x1Binned, rbind(0,0,0,0,0,1,1,1,2,2));

# q1 == minX and q2 == maxXX
x1Binned = equalSizedBins(rbind(1,1,1,1,1,2,2,3,3,3));
expect_equal(x1Binned, rbind(0,0,0,0,0,1,1,2,2,2));

# q1 == minX and normal split
x1Binned = equalSizedBins(rbind(1,1,1,1,1,2,3,4,5,6));
expect_equal(x1Binned, rbind(0,0,0,0,0,1,1,2,2,2));

# q3 == maxX and q1 == minXX
x1Binned = equalSizedBins(rbind(1,1,1,2,2,3,3,3,3,3));
expect_equal(x1Binned, rbind(0,0,0,1,1,2,2,2,2,2));

# q3 == maxX and q1 == maxXX
x1Binned = equalSizedBins(rbind(1,1,2,2,2,3,3,3,3,3));
expect_equal(x1Binned, rbind(0,0,1,1,1,2,2,2,2,2));

# q3 == maxX and q1 == maxXX
x1Binned = equalSizedBins(rbind(1,2,3,4,5,6,6,6,6,6));
expect_equal(x1Binned, rbind(0,0,1,1,1,2,2,2,2,2));


# q1==q2
x1Binned = equalSizedBins(rbind(1,2,2,2,2,2,2,2,2,3));
expect_equal(x1Binned, rbind(0,1,1,1,1,1,1,1,1,2));


# main case - nicely separates into 3 bins
x1Binned = equalSizedBins(rbind(1,2,3,4,5,6,7,8,9,10));
expect_equal(x1Binned, rbind(0,0,0,1,1,1,2,2,2,2));





