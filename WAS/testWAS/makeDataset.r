
set.seed(1234)
n=1000

## snp score data

id = 1:n
score <- rnorm(n, 0, 1);
datax  = cbind.data.frame(id, score)
colnames(datax)[1] <- "userId"
colnames(datax)[2] <- "exposure"

write.table(datax, file='data/exposure.csv', sep=',', col.names=TRUE, row.names=FALSE);


##### phenotype data

## age
age <- rnorm(n, 60, 10);
sex = round(runif(n, 0, 1));
genoBatch = round(runif(n, 0, 1));


data  = cbind.data.frame(id, age, sex, genoBatch);

colnames(data)[1] <- "userId"
colnames(data)[2] <- "x21022_0_0"
colnames(data)[3] <- "x31_0_0"
colnames(data)[4] <- "x22000_0_0"

######
###### continuous data fields

## x1 - continuous main path through inverse rank normal transformation, N=1000
cont1 <- rnorm(n, 0.0, 1.0)

## x2 - continuous main path but removed because < 500 examples SKIPPED
cont2 = cont1;
cont2[0:800] = NA;

## x3 - continuous - a value has > 20% of the examples that are not NA, so treated as categorical ordinal, N=1000
cont3 = c(rep(0, 400), round(5*runif(n-400, 0, 1)))

## x4 - continuous - a value has > 20% of the examples that are not NA, so treated as categorical ordinal, but < 500 examples SKIPPED
cont4 = c(rep(NA,800), rep(0, 100), round(5*runif(100, 0, 1)))

## x5 - continuous - only two numbers so we treat as binary, N=500
cont5 = c(rep(NA,500), rep(0, 100), rep(1, 400))

## x6 - continuous - only two numbers so we treat as binary but one has < 10 examples SKIPPED
cont6 = c(rep(NA,800), rep(0, 5), rep(1, 195));


data  = cbind.data.frame(data, cont1, cont2, cont3, cont4, cont5, cont6);

colnames(data)[5] <- "x1_0_0"
colnames(data)[6] <- "x2_0_0"
colnames(data)[7] <- "x3_0_0"
colnames(data)[8] <- "x4_0_0"
colnames(data)[9] <- "x5_0_0"
colnames(data)[10] <- "x6_0_0"

######
###### integer data fields

## integer x21 - >20 values, treat as continuous, tested with N=900
int1 = c(rep(NA,100),round(19*runif(900, 0, 1)));
if(length(unique(na.omit(int1)))!=20) stop("Not 20");

## integer x22 - 2 distinct values with one having less than 10 examples = only one value
int2 = c(rep(NA,100),rep(0,891), rep(0,9));

## integer x23 - 2 distinct values = binary, N=800/100(900)
int3 = c(rep(NA,100),rep(0,800), rep(1,100));

## integer x24 - 3 distinct values but one <10 examples = binary, N=800/91(891) 
int4 = c(rep(NA,100),rep(0,800), rep(1,9), rep(2,91));

## integer x25 - 3 distinct values = ordered cat, N=900
int5 = c(rep(NA,100),rep(0,600), rep(1,100), rep(2,200));

## integer x26 - 3 distinct values = ordered cat with one having less than 10 examples, N=891
int6 = c(rep(NA,100),rep(0,600), rep(1,100), rep(2,9), rep(3,191));

## integer x27 - 19 distinct values = ordered cat, N=900
int7 = c(rep(NA,100),round(18*runif(900, 0, 1)));
if(length(unique(na.omit(int7)))!=19) stop("Not 19");

data  = cbind.data.frame(data, int1, int2, int3, int4, int5, int6, int7);

colnames(data)[11] <- "x21_0_0"
colnames(data)[12] <- "x22_0_0"
colnames(data)[13] <- "x23_0_0"
colnames(data)[14] <- "x24_0_0"
colnames(data)[15] <- "x25_0_0"
colnames(data)[16] <- "x26_0_0"
colnames(data)[17] <- "x27_0_0"


######
###### categorical single data fields

## x32 - binary but one value < 10 = only one value SKIPPED
cats1 = c(rep(NA,100),rep(0,891),rep(1,9));

## x33 - binary but 499 < 500 examples SKIPPED
cats2 = c(rep(NA,501),rep(0,300),rep(1,199));

## x34 - binary success, N=300/600(900)
cats3 = c(rep(NA,100),rep(0,300),rep(1,600));

## x35 - cat ord but 499 < 500 examples SKIPPED 
cats4 = c(rep(NA,501),rep(0,300),rep(1,100),rep(2,99));

## x36 - cat ord success, N=900
cats5 = c(rep(NA,100),round(5*runif(900, 0, 1)));

## x37 - cat not-ord but 499 < 500 examples SKIPPED
cats6 = c(rep(NA,501),rep(0,300),rep(1,100),rep(2,99));

## x38 - cat not-ord success, reference=4, N=750
cats7 = c(rep(NA,250),rep(0,50), rep(1,200), rep(4,300), rep(9,200));

data  = cbind.data.frame(data, cats1, cats2, cats3, cats4, cats5, cats6, cats7);

# 31 is the variable number for sex so we don't use it in this dataset
colnames(data)[18] <- "x32_0_0"
colnames(data)[19] <- "x33_0_0"
colnames(data)[20] <- "x34_0_0"
colnames(data)[21] <- "x35_0_0"
colnames(data)[22] <- "x36_0_0"
colnames(data)[23] <- "x37_0_0"
colnames(data)[24] <- "x38_0_0"


######
###### categorical multiple data fields

## 9 people with A1, 480 people NA, 516 people with some value not A1
## 30 people with A2, 475 people NA, 495 people with some value not A2
## 500 people with A3, 675 people NA, 25 people with some value not A3

## cat multiple with 3 arrays
catm1_0_0 = c(rep("A1", 5), rep("A2", 25), rep("A3", 495), rep("",370), rep(NA,105));
catm1_0_1 = c(rep("A2", 5), rep("A1", 4), rep(NA,991));
catm1_0_2 = c(rep("A3",5), rep(NA,100),rep(NaN,895));



## var 99 determines who is in sample for var 43 (N=510)
var99 = c(rep(1,5), rep("ZZ",5), rep(NA,490),rep(2,500));
## for those 510 people with a value for variable 99:
#### 9 people with A1, 501 not with A1
#### 10 people with A2, 500 not with A2
#### 30 people with A3, 480 not with A3


## 3 different versions of catm1 field to test 3 different ways of treating categorical multipl fields
data  = cbind.data.frame(data, catm1_0_0, catm1_0_1, catm1_0_2, catm1_0_0, catm1_0_1, catm1_0_2, catm1_0_0, catm1_0_1, catm1_0_2, catm1_0_0, catm1_0_1, catm1_0_2, var99)

colnames(data)[25] <- "x41_0_0"
colnames(data)[26] <- "x41_0_1"
colnames(data)[27] <- "x41_0_2"
colnames(data)[28] <- "x42_0_0"
colnames(data)[29] <- "x42_0_1"
colnames(data)[30] <- "x42_0_2"
colnames(data)[31] <- "x43_0_0"
colnames(data)[32] <- "x43_0_1"
colnames(data)[33] <- "x43_0_2"
colnames(data)[34] <- "x44_0_0"
colnames(data)[35] <- "x44_1_0"
colnames(data)[36] <- "x44_2_0"
colnames(data)[37] <- "x99_0_0"




write.table(data, file='data/phenotypes.csv', sep='\t', col.names=TRUE, row.names=FALSE);



















