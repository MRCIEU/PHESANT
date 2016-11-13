# UKBiobank-phenome scan
Run a phenome scan (pheWAS, Mendelian randomisation (MR)-pheWAS etc.) in UK Biobank

There are three components in this project:

1. Running a phenome scan in UK Biobank
2. Post-processing of results
3. Visualising the results


## General requirements

R for parts 1 and 2 above. Tested with R-3.2.4-ATLAS. Phenome scan requires the R packages: optparse, MASS, lmtest and nnet.

Java for part 3 above. Tested with jdk-1.8.0-66.


## Citing this project

Millard, L.A.C, et al. Software Application Profile: PHESANT: a tool for performing automated phenome scans in UK Biobank. bioRxiv (2016)


## 1) Running a phenome scan

A phenome scan is run using WAS/phewas.r script. This is basically ready to go - the only essential amendment you will need to make is the EXPOSURE column in the variable information file (see below).

The phenome scan process is illustrated in the figure below, and described in detail in the paper above.

![PHESANT processing pipeline][biobank-PHESANT-figure.pdf]


The phenome scan is run with the following arguments:

### Input

Arg | Description
-------|--------
outcomefile 		| Comma separated file containing phenotypes, and a user id column. Where there are multiple columns for a phenotype these must be adjacent in the file. Specifically for a given field in Biobank the instances should be adjacent and within each instance the arrays should be adjacent. Each variable name is in the format 'x[varid]\_[instance]\_[array]' (we use the prefix 'x' so that the variable names are valid in R).
exposurefile 		| Comma separated file containing the exposure variable (e.g. a snp or genetic risk score)
variablelistfile 	| Tab separated file containing information about each phenotype, that is used to process them.
datacodingfile 		| Comma separated file containing the data coding ids and whether each data coding is ordinal or not
exposurevariable 	| Variable name as in exposurefile
resDir 			| Directory where you want the results to be stored
userId 			| User id column as in the exposurefile and the outcomefile
partIdx			| Subset of phenotypes you want to run (for parallelising)
partNum			| Number of subsets you are using (for parallelising)
sensitivity		| By default analyses are adjusted for age (field 21022), sex (field 31) and genotype chip (a binary variable derived from field 22000). If sensitivity argument is set to TRUE then also analsyses additionally adjusts for the first 10 genetic principal components (fields x22009_0_1 to x22009_0_10) and assessment centre (field 54).

The partNum and partIdx are both used for parallelise your phenome scan. E.g. setting partNum to 5 will divide the set of phenotypes
into 5 (rough) parts and then partIdx can be used to call the phenome scan on a specific part (1-5).

#### Data coding file

Data codes define a set of values that can be assigned to a given field. A data code can be assigned to more than one variable, which is why it makes sense to have
a separate file describing the necessary information for each data code. For example, there are several fields about diet that have data code [100009](http://biobank.ctsu.ox.ac.uk/showcase/coding.cgi?id=100009).

The data coding file should have the following columns:

1. dataCode - The ID of the data code.
2. ordinal - Whether the field is ordinal (value 1) or not (value 0). Value -1 denotes this is not needed because the field is binary. 
3. ordering - Any needed corrections for the numeric ordering of a data codes specified by Biobank. For example, data code (10001)[http://biobank.ctsu.ox.ac.uk/showcase/coding.cgi?id=100001] has values half=555, 1=1, and 200=2+, but we want the 'half' value should be less that the '1' value, so we
set change the order to '555|1|200'
4. reassignments - Any value changes that are needed. For example, in data code (100662)[http://biobank.ctsu.ox.ac.uk/showcase/coding.cgi?id=100662], the values
7 and 6 may be deemed equal (both representing 'never visited by friends/family' so we can set '7=6' to reassign the value 7 to the value 6.


#### Variable information file

This file was initially the UK Biobank Data dictionary, which can be downloaded from their website [here](http://biobank.ctsu.ox.ac.uk/~bbdatan/Data_Dictionary_Showcase.csv).
This provides the following set of information used in our phenome tool:

1. ValueType column - the field type, either 'Integer', 'Continuous', 'Categorical single', 'Categorical multiple', or a few others we do not use.
2. 3 Cat_ID and 3 Cat_Title columns - the three levels of the category hierarchy, that can be seen [here](http://biobank.ctsu.ox.ac.uk/showcase/label.cgi)
3. FieldID column - We use this to match the variable in our biobank data file to the correct row in this TSV file.
4. Field column -  The name of the field.

The variable information file also has the following columns, to provide additional information used in the phenome scan:

1. EXPOSURE_PHENOTYPE - Specifies any field that represents the exposure phenotype. This is a marker so that after the phenome scan is run we can use these
results as validation only (e.g. a pheWAS of the BMI FTO SNP would expect the BMI phenotypes to show high in the results ranking), i.e. they do not contribute to the multiple testing burden. We have set this code up for BMI, so have marked BMI/weight fields as an exposure - you'll need to change this for you particualar 'exposure' trait. 
2. EXCLUDED - phenotypes we have apriori decided to exclude from the phenome scan. Any field with a value in this field is excluded, and we state a code that describes the reason we exclude a variable (for future reference). Our codes and reasons are as follows (of course for your phenome scan you can add other as you would like): 
* YES-ACE: "assessment center environment" variables that don't directly describe the participant;
* YES-AGE: age variables;
* YES-ASSESSMENT-CENTRE: which assessment centre the participant attended; 
* YES-BIOBANK-SUGGESTED-VARIABLE: Variables not initially included in our data request, but that biobank suggested we receive;
* YES-CAT-SIN-MUL-VAL: fields that were 'Categorical single' types but had multiple value. We do not deal with these currently so remove from the phenome scan.
* YES-GENETIC: genetic description variables;
* YES-SENSITIVE: variables not received from Biobank because they are sensitive so have more restricted access;
* YES-SEX: sex fields.
3. CAT_MULT_INDICATOR_FIELDS - every categorical multiple field must have a value in this column. The value describes which set of participants to include as the negative examples, when a binary variable is created from each value. The positive examples are simply the people with a particular value for this categorical multiple field. However the negative values can be determined in three ways:
* ALL -  Include all participants. 
* NO_NAN - Included only those who have at least one value for this field.
* field ID - Include only those who have a value for another field, with this field ID.
4. CAT_SINGLE_TO_CAT_MULT - Specifies fields that have the categorical single field type (as specified by UK Biobank) but that we actually want to treat as categorical multiple.
5. CAT_SINGLE_DATA_CODING - The data coding IDs for each categorical single file to map each of categorical single field to it's data code in the data code information file described above.

### Output
In the directory specified with the `resDir` argument, the following files will be created:

1. Results files for each test type:
* Linear regression: results-linear-all.txt - One line for each linear regression result
* Logistic regression: results-logistic-all.txt - One line for each logistic regression result
* Multinomial regression: results-multinomial-all.txt - Each multinomial regression results in n+1 lines in this results file, where n is the number of categories in the variables. One line corresponds to the results for a particular category, and then there is also one line for the overall assocation of this variable (across all categories).
* Ordered logistic regression: results-ordered-logistic-all.txt - One line for each ordinal logistic regression result.
2. A log file: results-log-all.txt - One line for each Biobank field, providing information about the processing flow for this field. 
3. Flow counts file: variable-flow-counts-all.txt - A set of counts denoting the number of variables reaching each point in the processing flow (see figure above).

Where the phenome scan is run in parallel setup then each parallel part will have one file for each of the above files, with 'all' in each filename replaced
with partNum: [filename]-[partIdx].txt


See testWAS/README.md for an example with test data.


## 2) Post phenome scan results processing

The resultsProcessing folder provides code to post process the results, specifically:

1. Combine the results where they were generated in parallel.
2. Combine the flow counts.
3. Add the description information for each variable to the results file.

This takes three arguments:

Arg | Description
-------|--------
resDir			| Directory where the phenome scan results are stored
numParts		| Number of subsets you are have used (for parallelising)
variablelistfile	| Tab separated file containing information about each phenotype, that is used to process them.

See testWAS/README.md for an example with test data.


## 3) Results visualisation

A phenome scan generates a large number of results, and the aim of this visualisation is to help with interpretation, by allowing the researcher to view each result in the context of the
results of related traits.

See the resultsVisualisation folder and README for more info.




