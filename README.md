# UKBiobank-pheWAS
Run a phenome scan (pheWAS, Mendelian randomisation (MR)-pheWAS etc.) in UK Biobank



A pheWAS is run using WAS/tests_phase1.r script, with the following arguments:

outcomefile 		| tab separated file containing phenotypes, and a user id column
exposurefile 		| comma separated file containing the exposure variable (e.g. a snp or genetic risk score)
variablelistfile 	| tab separated file containing information about each phenotype, that is used to process them.
datacodingfile 		| comma separated file containing the data code ids and whether each data coding is ordinal or not
exposurevariable 	| variable name as in exposurefile
resDir 			| directory where you want the results to be stored
userId 			| user id column as in the exposurefile and the outcomefile


See WAS/testWAS/readme.txt for an example with test data.
