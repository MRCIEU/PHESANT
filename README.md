# PHESANT - PHEnome Scan ANalysis Tool
Run a phenome scan (pheWAS, Mendelian randomisation (MR)-pheWAS etc.) in UK Biobank.

There are three components in this project:

1. Running a phenome scan in UK Biobank
2. Post-processing of results
3. PHESANT-viz: Visualising the results


## General requirements

R for parts 1 and 2 above. Tested with R-3.3.1-ATLAS. Phenome scan requires the R packages: optparse (V1.3.2), MASS (V7.3-45), lmtest (V0.9-34), nnet (V7.3-12), forestplot (V1.7) and data.table (V1.10.4).

Java for part 3 above. Tested with jdk-1.8.0-66.


## Citing this project

Please cite:

Millard LAC, et al. Software Application Profile: PHESANT: a tool for performing automated phenome scans in UK Biobank. *International Journal of Epidemiology* (2017).


## 1) Running a phenome scan

A phenome scan is run using `WAS/phenomeScan.r`. This is ready to go. One amendment you may wish to make before running PHESANT is the TRAIT_OF_INTEREST column in the variable information file (see below).

The PHESANT phenome scan processing pipeline is illustrated in the figure [here](biobank-PHESANT-figure.pdf), and described in detail in the paper above.

The phenome scan is run with the following command:

```bash
cd WAS/
Rscript phenomeScan.r \
--phenofile=<phenotypesFilePath> \
--traitofinterestfile=<traitOfInterestFilePath> \
--variablelistfile="../variable-info/outcome-info.tsv" \
--datacodingfile="../variable-info/data-coding-ordinal-info.csv" \
--traitofinterest=<traitOfInterestName> \
--resDir=<resultsDirectoryPath> \
--userId=<userIdFieldName>
```

The following example runs part 1 of 20, of a sensitivity analysis phenome scan (adjusting for age, sex, and assessment centre, see below), using a non genetic trait of interest:
```bash
cd WAS/
Rscript phenomeScan.r \
--phenofile=<phenotypesFilePath> \
--traitofinterestfile=<traitOfInterestFilePath> \
--variablelistfile="../variable-info/outcome-info.tsv" \
--datacodingfile="../variable-info/data-coding-ordinal-info.csv" \
--traitofinterest=<traitOfInterestName> \
--resDir=<resultsDirectoryPath> \
--userId=<userIdFieldName> \
--sensitivity \
--genetic=FALSE \
--partIdx=1 \
--numParts=20
```



### Required arguments

Arg | Description
-------|--------
phenofile 		| Comma separated file containing phenotypes. Each row is a participant, the first column contains the participant id and the remaining columns are phenotypes. Where there are multiple columns for a phenotype these must be adjacent in the file. Specifically for a given field in Biobank the instances should be adjacent and within each instance the arrays should be adjacent. Each variable name needs to be changed to the format 'x[varid]\_[instance]\_[array]' (we use the prefix 'x' so that the variable names are valid in R).
variablelistfile 	| Tab separated file containing information about each phenotype, that is used to process them (see below).
datacodingfile 		| Comma separated file containing information about data codings (see below).
traitofinterest 	| Variable name as in traitofinterestfile.
resDir 			| Directory where you want the results to be stored.

### Optional arguments
Arg | Description
-------|--------
traitofinterestfile	| Comma separated file containing the trait of interest (e.g. a snp, genetic risk score or observed phenotype). Each row is a participant and there should be two columns - the user ID and the trait of interest. Where this argument is not supplied, the trait of interest should be a column in the phenofile.
confounderfile		| Comma separated file containing the confounders, so that you can choose what confounders to use in the phenome scan.
userId                  | User id column as in the `traitofinterestfile` and the `phenofile` (default: userId).
partIdx			| Subset of phenotypes you want to run (for parallelising).
numParts		| Number of subsets you are using (for parallelising).
sensitivity		| By default analyses are adjusted for age (field [21022](http://biobank.ctsu.ox.ac.uk/showcase/field.cgi?id=21022)), sex (field [31](http://biobank.ctsu.ox.ac.uk/showcase/field.cgi?id=31)) and, if the `genetic` argument is set to `TRUE`, genotype chip (a binary variable derived from field [22000](http://biobank.ctsu.ox.ac.uk/showcase/field.cgi?id=22000)). If sensitivity argument is used (by including `--sensitivity` when running PHESANT) then analyses additionally adjust for the assessment centre (field [54](http://biobank.ctsu.ox.ac.uk/showcase/field.cgi?id=54)). If `sensitivity` argument is used (by including `--sensitivity` when running PHESANT) and the `genetic` argument is set to `TRUE`, the first 10 genetic principal components (fields [22009_0_1](http://biobank.ctsu.ox.ac.uk/showcase/field.cgi?id=22009) to [22009_0_10](http://biobank.ctsu.ox.ac.uk/showcase/field.cgi?id=22009)) are also included as confounders. If you wish to choose your own confounders to use in the phenome scan you can use the `confounderfile` option (described above).
genetic			| By default `genetic=TRUE`, and we assume the trait of interest is a genetic variable (e.g. a SNP or genetic risk score). If this is not the case (e.g you are running an environment-wide association study) then set this flag to FALSE. This option determines which variables are controlled for in analyses, see sensitivity arg above.
save			| Instead of running phenome scan, generated phenotypes are stored to file, in `resDir`. If this option is used then `traitofinterest` argument is not required.
confidenceintervals	| By default `confidenceintervals=TRUE`, but specifying `confidenceintervals=FALSE` means that PHESANT doesn't calculate the association confidence intervals (which may speed up PHESANT).
standardise		| By default `standardise=TRUE`, but specifying `standardise=FALSE` means that PHESANT will not standardise the exposure variable. E.g. use this option for binary exposure variables.
tab			| By default phenotype file (phenofile) is comma seperated, but `tab=TRUE` can be specified when your file is tab delimited (e.g. using the `r` option for UK Biobank's `ukbconv` utility).
mincase			| Minimum size of phenotype categories (default is 10).

The numParts and partIdx arguments are both used to parallelise the phenome scan. E.g. setting numParts to 5 will divide the set of phenotypes into 5 (rough) parts and then partIdx can be used to call the phenome scan on a specific part (1-5).

#### Data coding file

Data codes define a set of values that can be assigned to a given field. A data code can be assigned to more than one variable, which is why we use
a separate file describing the necessary information for each data code. For example, there are several fields about diet that have data code [100009](http://biobank.ctsu.ox.ac.uk/showcase/coding.cgi?id=100009).

The data coding file should have the following columns:

1. dataCode - The ID of the data code.
2. ordinal - Whether the field is ordinal (value 1) or not (value 0). This field is only used for fields of the categorical (single) field type. Value -1 denotes this is not needed because the field is binary. 
3. ordering - Any needed corrections for the numeric ordering of a data codes specified by Biobank. This field is only used for data codes specified as ordinal in the ordinal column. For example, data code [100001](http://biobank.ctsu.ox.ac.uk/showcase/coding.cgi?id=100001) has values half, 1 and 2+ coded as 555, 1 and 200, respectively. We need the 'half' value to be less than the '1' value, so we change the order to '555|1|200'. NB: if this column is used then and any value is not included then this value is set to NA (i.e. this field can be used to remove and reorder values at the same time).
4. reassignments - Any value changes that are needed. For example, in data code [100662](http://biobank.ctsu.ox.ac.uk/showcase/coding.cgi?id=100662), the values
7 and 6 may be deemed equal (both representing 'never visited by friends/family' so we can set '7=6' to assign the value 6 to all participants with the value 7.
5. default_value - A default value assigned to all participants with no value for the field, but with a value for field stated in `default_value_related_field` column below. This is used where a category is not explicitly stated in the field but 
instead needs to be determined by looking at whether another field has a value. Typically, this occurs where there is no category for 'none' in a questionnaire field, because participants were told they did not have to mark 'none' but could instead leave it blank 
(see for example section 5.3 in the [24 hour diet questionnaire manual](http://biobank.ctsu.ox.ac.uk/showcase/refer.cgi?id=118240)). Hence, we assume that if they completed the questionnaire and have not ticked a value, then the value is 'none'. See default value example below.
6. default_value_related_field - The field used to determine which participants are assigned the default value. All participants with a value in the field stated here, and with no value for a field with this data code, are assigned the default value stated in `default_value`.

##### Example of default value

In the data code information file we specify `default_value=0` and `default_value_related_field=20080` for data code 100006. 
Field [100200](http://biobank.ctsu.ox.ac.uk/showcase/field.cgi?id=100200), for example, has data code 100006. 
Therefore all participants with a value for field [20080](http://biobank.ctsu.ox.ac.uk/showcase/field.cgi?id=20080), but with no value in field 100200, are assigned value 0 for field 100200.
Intuitively, all participants who have answered the 24-hour recall diet questionnaire have a value in field 20080, and of these, we assume that those with no value for field 100200 have opted
for 'none' implicitly, by not ticking any option.

#### Variable information file

This file was initially the UK Biobank data dictionary, which can be downloaded from the UK Biobank website [here](http://biobank.ctsu.ox.ac.uk/~bbdatan/Data_Dictionary_Showcase.csv).
This data dictionary provides the following set of information about fields, used in this phenome scan tool:

1. ValueType column - the field type, either 'Integer', 'Continuous', 'Categorical single', 'Categorical multiple', or a few others we do not use.
2. Three Cat_ID and three Cat_Title columns - the three levels of the category hierarchy, that can be seen [here](http://biobank.ctsu.ox.ac.uk/showcase/label.cgi).
3. FieldID column - We use this to match the variable in our biobank data file to the correct row in this TSV file.
4. Field column -  The name of the field.

The variable information file also has the following columns that we have added, to provide additional information used in the phenome scan:

1. TRAIT_OF_INTEREST - Specifies any field that represents the trait of interest (set this column to 'YES'). This is a marker so that after the phenome scan is run we can use these
results as validation only (e.g. a pheWAS of the BMI FTO SNP would expect the BMI phenotypes to show high in the results ranking), i.e. they do not contribute to the multiple testing burden. We have set this up for BMI, so have marked BMI/weight fields as the trait of interest - you will need to change this for your particular trait of interest. 
For categorical multiple fields you may want to mark the whole field as denoting the trait of interest (e.g all [cancers](http://biobank.ctsu.ox.ac.uk/showcase/field.cgi?id=20001)), or just a specific value (e.g. a particular type of cancer). To do the former set this column to YES, and to do the latter specify each particular value in this field separated by a bar, i.e. 'VALUE1|VALUE2'.
2. EXCLUDED - Phenotypes we apriori decide to exclude from the phenome scan. Any field with a value in this field is excluded, and we state a code that describes the reason we exclude a variable (for future reference). Our codes and reasons are as follows (of course for your phenome scan you can add others as you would like): 
 - YES-ACE: "Assessment center environment" variables that do not directly describe the participant.
 - YES-AGE: Age variables.
 - YES-ASSESSMENT-CENTRE: The assessment centre the participant attended.
 - YES-BIOBANK-SUGGESTED-VARIABLE: Variables not initially included in our data request, but that biobank suggested we receive.
 - YES-CAT-SIN-MUL-VAL: Fields that were 'Categorical single' types but had multiple values (several arrays in an instance). We do not deal with these currently so remove from the phenome scan.
 - YES-GENETIC: Genetic description variables.
 - YES-SENSITIVE: Variables not received from Biobank because they are sensitive so have more restricted access.
 - YES-SEX: Sex fields.
 - YES-POLYMORPHIC: Fields denoted as [polymorphic](http://biobank.ctsu.ox.ac.uk/showcase/help.cgi?cd=polymorphic) by UK Biobank (e.g. [field 87](http://biobank.ctsu.ox.ac.uk/showcase/field.cgi?id=87)). 
 - YES-PROCESSING: Fields that describe some aspect of the data collection process rather than some aspect (phenotype) of the participants themselves (e.g. [field 23049](http://biobank.ctsu.ox.ac.uk/showcase/field.cgi?id=23049)).
 - YES-SUPERSEDED: Fields that have been superseded by another version. For example, all fields used to create the aggregated ['first occurence' disease variables](https://biobank.ctsu.ox.ac.uk/crystal/label.cgi?id=1712).
 - YES-DATE: Fields that are dates. Dates are not currently included in phenome scans. They are only used where they are converted to a binary variable (see DATE_CONVERT column below).
3. CAT_MULT_INDICATOR_FIELDS - every categorical multiple field must have a value in this column. 
The value describes which set of participants to include as the negative examples, when a binary variable is created from each value (see above cited paper for more information). 
The positive examples for a value `v` in this categorical multiple field are simply the people with this particular value. However the negative values can be determined in three ways:
 - ALL - Include all participants (any participant without value `v` is assigned `FALSE`, except those with a value denoting missingness (i.e. value is <0)). 
 - NO_NAN - Included only those who have at least one value for this field (assign `FALSE` to any participant with at least one value for this field, where these values do not include value `v`, and also do not include a value denoting missingness (i.e. value is <0).
 - fieldID - Include only those who have a value for another field, with ID `fieldID` (assign `FALSE` to any participant without value `v` and without a value denoting missingness (i.e. value is <0) and with a value in this other field with ID `fieldID`).
4. CAT_SINGLE_TO_CAT_MULT - Specifies fields that have the categorical single field type (as specified by UK Biobank) but that we actually want to treat as categorical multiple. State YES in this column to change this. To also convert the instances to arrays, state YES-INSTANCES. For example, field [20107](http://biobank.ctsu.ox.ac.uk/showcase/field.cgi?id=20107) has illnesses stored in 10 arrays (for each instance) so it makes sense to treat this as a categorical(multiple) field. Field [40011](http://biobank.ctsu.ox.ac.uk/showcase/field.cgi?id=40011) stores the histology of cancer tumours but is stored in 31 instances (rather than arrays) so we specify YES-INSTANCES so this field is treated as a categorical (multiple) field and the instances are treated as arrays.
5. DATE_CONVERT - Specifies that a date field should be included and converted to a binary variable indicating whether each participant has a date in this field or not. This is used for the ['first occurence' disease variables](https://biobank.ctsu.ox.ac.uk/crystal/label.cgi?id=1712) that are date fields.
5. DATA_CODING - The data coding IDs used to map a field to its data code in the data code information file described above. This is required for categorical (single) fields.

### Output
In the directory specified with the `resDir` argument, the following files will be created:

1. Results files for each test type:
 - Linear regression: results-linear-all.txt - One line for each linear regression result
 - Logistic regression: results-logistic-all.txt - One line for each logistic regression result
 - Multinomial regression: results-multinomial-all.txt - Each multinomial regression results in *n* lines in this results file, where *n* is the number of categories in the variable. One line corresponds to the results for a particular category compared to an assigned baseline category (the category with the highest sample size), and then there is also one line for the overall association of this variable (across all categories), using a likelihood ratio test comparing this model with the model with confounders only.
 - Ordered logistic regression: results-ordered-logistic-all.txt - One line for each ordinal logistic regression result.
2. A log file: results-log-all.txt - One line for each Biobank field, providing information about the processing flow for this field (see PHESANT-logging-information.md for examples).
3. A model fit log file: modelfit-log-all.txt - shows model fit output for categorical unordered models.
4. Flow counts file: variable-flow-counts-all.txt - A set of counts denoting the number of variables reaching each point in the processing flow. Each code with count value corresponds to a particular position in the processing flow (see figure [here](PHESANT-counter-codes.pdf)).

Where the phenome scan is run in parallel setup, then each parallel part will have one of each of the above files, with 'all' in each filename replaced with: [partIdx]-[numParts].

See testWAS/README.md for an example with test data.

If the save option is used, instead or producing results files, PHESANT will create the following files:

1. Data files for each trait type. e.g. `data-linear-all.txt`.
2. A log file e.g. `data-log-all.txt`.



## 2) Post phenome scan results processing

The resultsProcessing folder provides code to post-process the results, specifically:

1. Combine the results where they were generated in parallel.
2. Combine the flow counts.
3. Add the description information for each variable from the `variablelistfile` file, to the results file.
4. Rank the results by P value.
5. For the multinomial regression results, include only the main result (not the results for each particular category of a given variable as described above).
6. Generate basic figures: qqplot, and 3 forest plots for continous, ordered categorical and binary results separately (for results with P<0.05/numTests, i.e. the
Bonferroni corrected 0.05 threshold). 
We do not generate a forest plot for the categorical unordered results, because we have no overall estimate (and confidence interval) for the model overall, 
because we use a likelihood ratio test to generate a model P value. For these plots we use all results except for phenotypes marked as 'trait of interest'. 

The results processing is run with the following command:

```bash
cd resultsProcessing/

Rscript mainCombineResults.r \
--resDir=<resultsDirectoryPath> \
--variablelistfile="../variable-info/outcome-info.tsv"
```

### Required arguments

Arg | Description
-------|--------
resDir			| Directory where the phenome scan results are stored.
variablelistfile	| Tab separated file containing information about each phenotype, that is used to process them. Same as `variablelistfile` used in main phenome scan.

### Optional argument

Arg | Description
-------|--------
numParts                | Number of subsets (parts) you have used (for parallelising).


See `testWAS/README.md` for an example with test data.

### QQ plot description
The QQ plot contains the following elements:

1. A horizontal line (dashed, green) denoting the Bonferroni corrected P value threshold.
2. A line (dotted, blue) denoting the expected trajectory of points under the null (actual=expected).
3. A set of points each denoting the result for a phenotype. It is possible (as in the testWAS) that the P value is smaller than the smallest possible value that R can store (see [.Machine documentation](https://stat.ethz.ch/R-manual/R-devel/library/base/html/zMachine.html)).
When this occurs the P value is set to zero, and on the QQ plot we set these to 5e-324 (the smallest positive double on a typical R platform) and display these as red stars to indicate that an exact P value was not recorded.


## 3) PHESANT-viz: Results visualisation

A phenome scan generates a large number of results. The aim of this visualisation is to help with interpretation, by allowing the researcher to view each result in the context of the
results of related traits.

See the PHESANT-viz folder and README therein for more information.


