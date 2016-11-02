# UKBiobank-pheWAS
Run a phenome scan (pheWAS, Mendelian randomisation (MR)-pheWAS etc.) in UK Biobank

There are three components in this project:
1) Running a pheWAS in UK Biobank
2) Post-processing of results
3) Visualise the results


## 1) Running the phewas

A pheWAS is run using WAS/tests_phase1.r script, with the following arguments:

Arg | Description
-------|--------
outcomefile 		| Tab separated file containing phenotypes, and a user id column. Where there are multiple columns for a phenotype these must be adjacent in the file. Specifically for a given field in Biobank the instances should be adjacents and withing each instance the arrays should be adjacent.
exposurefile 		| Comma separated file containing the exposure variable (e.g. a snp or genetic risk score)
variablelistfile 	| Tab separated file containing information about each phenotype, that is used to process them.
datacodingfile 		| Comma separated file containing the data coding ids and whether each data coding is ordinal or not
exposurevariable 	| Variable name as in exposurefile
resDir 			| Directory where you want the results to be stored
userId 			| User id column as in the exposurefile and the outcomefile
partIdx			| Subset of phenotypes you want to run (for parallelising)
partNum			| Number of subsets you are using (for parallelising)

The partNum and partIdx are both used for parallelise your pheWAS. E.g. setting partNum to 5 will divide the set of phenotypes
into 5 (rough) parts and then partIdx can be used to call the pheWAS on a specific part (1-5).

See WAS/testWAS/readme.txt for an example with test data.


## 2) Post-pheWAS results processing

The resultsProcessing folder provides code to post process the results, specifically:
1) Combine the results where they were generated in parallel.
2) Combine the flow counts
3) Add the description information for each variable to the results file 

This takes three arguments:

Arg | Description
-------|--------
resDir			| Directory where the pheWAS results are stored
numParts		| Number of subsets you are have used (for parallelising)
variablelistfile	| Tab separated file containing information about each phenotype, that is used to process them.

See WAS/testWAS/README.md for an example with test data.


## 3) Results visualisation

A pheWAS generates a large number of results, and the aim of this visualisation is to help with interpretation, by allowing the researcher to view each result in the context of the
results of related traits.

See the resultsVisualisation folder and README for more info.




