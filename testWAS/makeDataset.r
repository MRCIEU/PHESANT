
set.seed(1234)
n=1000

## snp score data

id = 1:n
score <- rnorm(n, 0, 1);
score = score[order(score)]
datax  = cbind.data.frame(id, score)
colnames(datax)[1] <- "userId"
colnames(datax)[2] <- "exposure"

write.table(datax, file='data/exposure.csv', sep=',', col.names=TRUE, row.names=FALSE);


##### phenotype data

## age
age <- 2*score + rnorm(n, 60, 10);
sex = round(runif(n, 0, 1));
genoBatch = round(rnorm(n, 0, 1))


data  = cbind.data.frame(id, age, sex, genoBatch);

colnames(data)[1] <- "userId"
colnames(data)[2] <- "x21022_0_0"
colnames(data)[3] <- "x31_0_0"
colnames(data)[4] <- "x22000_0_0"

######
###### continuous data fields

## x1 - continuous main path through inverse rank normal transformation, N=1000
## Expected result: association ~ 2
cont1 <- 2*score + 20 + rnorm(n, 0.0, 0.2)

## x2 - continuous main path but removed because < 500 examples SKIPPED
cont2 = cont1
cont2[0:800] = NA

## x3 - continuous - a value has > 20% of the examples that are not NA, so treated as categorical ordinal, N=1000
cont3 = c(rep(0, 400), score[401:1000]+round(rnorm(600, 0, 1)))

## x4 - continuous - a value has > 20% of the examples that are not NA, so treated as categorical ordinal, but < 500 examples SKIPPED
cont4 = c(rep(NA,800), rep(0, 100), round(5+5*rnorm(100, 0, 1)))

## x5 - continuous - only two numbers so we treat as binary, N=(120/380)500
cont5 = c(rep(NA,500), rep(0, 100), rep(1, 400))
randidx = sample(501:600, 10)
cont5[randidx] = 1
randidx = sample(601:1000, 30)
cont5[randidx] = 0

## x6 - continuous - only two numbers so we treat as binary but one has < 10 examples SKIPPED
cont6 = c(rep(NA,800), rep(0, 5), rep(1, 195))

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
int1 = c(rep(NA,100),cut(score[101:1000]*10 + rnorm(900, 0, 1), 20))
if(length(unique(na.omit(int1)))!=20) stop("Not 20");

## integer x22 - 2 distinct values with one having less than 10 examples = only one value SKIPPED
int2 = c(rep(NA,100),rep(0,891), rep(1,9));

## integer x23 - 2 distinct values = binary, N=800/100(900)
int3 = c(rep(NA,100),rep(0,800), rep(1,100));
int3[sample(101:900, 30)] = 1
int3[sample(901:1000, 30)] = 0

## integer x24 - 3 distinct values but one <10 examples = binary, N=760/131(891) 
int4 = c(rep(NA,100),rep(0,800), rep(1,9), rep(2,91));
int4[sample(101:900, 50)] = 2
int4[sample(909:1000, 10)] = 0

## integer x25 - 3 distinct values = ordered cat, N=900
int5 = c(rep(NA,100), rep(0, 500), rep(1, 200), rep(2, 200))
int5[sample(101:600, 10)] = 1
int5[sample(101:600, 10)] = 2
int5[sample(601:800, 10)] = 0
int5[sample(601:800, 10)] = 2
int5[sample(801:1000, 10)] = 0
int5[sample(801:1000, 10)] = 1

## integer x26 - 3 distinct values = ordered cat with one having less than 10 examples, N=(600/291)891 = binary
int6 = c(rep(NA,100),rep(0,600), rep(1,291), rep(2,9))
int6[sample(101:700, 50)] = 1
int6[sample(701:991, 50)] = 0

## integer x27 - 19 distinct values = ordered cat, N=891 (9 are removed because <10 in some categories)
int7 = c(rep(NA,100),cut(score[101:1000], 19))
int7[sample(101:1000, 50)] = 1
int7[sample(101:1000, 50)] = 2
int7[101:1000] = int7[101:1000]+10

if(length(unique(na.omit(int7)))!=19) stop("Not 19");

data  = cbind.data.frame(data, int1, int2, int3, int4, int5, int6, int7);
#data  = cbind.data.frame(data, int1, int2, int3, int4, int5)

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
cats3[sample(101:400, 50)] = 1
cats3[sample(401:1000, 50)] = 0

## x35 - cat ord but 499 < 500 examples SKIPPED 
cats4 = c(rep(NA,501),rep(0,300),rep(1,100),rep(2,99));

## x36 - cat ord success, N=889 (11 removed because <10 examples)
cats5 = c(rep(NA,100), 10+5*round(score[101:1000]) + round(runif(900, 0, 5)))

## x37 - cat not-ord but 499 < 500 examples SKIPPED
cats6 = c(rep(NA,501),rep(0,300),rep(1,100),rep(2,99));

## x38 - cat not-ord success, reference=4, N=750
cats7 = c(rep(NA,250),rep(0,50), rep(1,200), rep(4,300), rep(9,200));
cats7[sample(301:500, 50)] = 4
cats7[sample(501:800, 50)] = 1
cats7[sample(251:300, 10)] = 9
cats7[sample(801:1000, 10)] = 0

## x39 - same as 38 but default value set in variable information file
## the first 250 of field cats8 are NA and have a value in field 99 so these are set to the default value 100
cats8 = cats7

data  = cbind.data.frame(data, cats1, cats2, cats3, cats4, cats5, cats6, cats7, cats8);

# 31 is the variable number for sex so we don't use it in this dataset
colnames(data)[18] <- "x32_0_0"
colnames(data)[19] <- "x33_0_0"
colnames(data)[20] <- "x34_0_0"
colnames(data)[21] <- "x35_0_0"
colnames(data)[22] <- "x36_0_0"
colnames(data)[23] <- "x37_0_0"
colnames(data)[24] <- "x38_0_0"
colnames(data)[25] <- "x39_0_0"

######
###### categorical multiple data fields

## 14 people with A1, 470 people NA, 516 people with some value not A1
## 35 people with A2, 470 people NA, 495 people with some value not A2
## 505 people with A3, 670 people NA, 25 people with some value not A3

## cat multiple with 3 arrays
catm1_0_0 = c(rep("A1", 5), rep("A2", 25), rep("A3", 495), rep("",370), rep(NA,100), rep("A1", 5));
catm1_0_1 = c(rep("A2", 5), rep("A1", 4), rep(NA,986), rep("A2", 5));
catm1_0_2 = c(rep("A3",5), rep(NA,990), rep("A3",5));


## var 99 determines who is in sample for var 43 (N=510)
var99 = c(rep(1,30), rep("ZZ",495), rep(NA,465),rep(2,10));

#### 14 people with A1, 516 people with some value not A1 + 5 with no A1 value but having var99 value: binary variable TRUE=14,FALSE=521
#### 35 people with A2, 495 people with some value not A2 + 5 with no A2 value but having var99 value: binary variable TRUE=35,FALSE=500
#### 505 people with A3, 25 people with some value not A3 + 5 with no A3 value but having var99 value: binary variable TRUE=505,FALSE=30


## 3 different versions of catm1 field to test 3 different ways of treating categorical multiple fields
data  = cbind.data.frame(data, catm1_0_0, catm1_0_1, catm1_0_2, catm1_0_0, catm1_0_1, catm1_0_2, catm1_0_0, catm1_0_1, catm1_0_2, catm1_0_0, catm1_0_1, catm1_0_2, var99)

colnames(data)[26] <- "x41_0_0"
colnames(data)[27] <- "x41_0_1"
colnames(data)[28] <- "x41_0_2"
colnames(data)[29] <- "x42_0_0"
colnames(data)[30] <- "x42_0_1"
colnames(data)[31] <- "x42_0_2"
colnames(data)[32] <- "x43_0_0"
colnames(data)[33] <- "x43_0_1"
colnames(data)[34] <- "x43_0_2"
colnames(data)[35] <- "x44_0_0"
colnames(data)[36] <- "x44_1_0"
colnames(data)[37] <- "x44_2_0"
colnames(data)[38] <- "x99_0_0"


write.table(data, file='data/phenotypes.csv', sep=',', col.names=TRUE, row.names=FALSE, quote=TRUE, na="");





