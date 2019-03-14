library("optparse")

option_list = list(
  make_option(c("-f", "--phenofile"), type="character", default=NULL, help="Phenotype dataset file name", metavar="character"),
  make_option(c("-g", "--traitofinterestfile"), type="character", default=NULL, help="Trait of interest dataset file name", metavar="character"),
  make_option(c("-v", "--variablelistfile"), type="character", default=NULL, help="variablelistfile file name (should be tab separated)", metavar="character"),
  make_option(c("-d", "--datacodingfile"), type="character", default=NULL, help="datacodingfile file name (should be comma separated)", metavar="character"),
  make_option(c("-e", "--traitofinterest"), type="character", default=NULL, help="traitofinterest option should specify trait of interest variable name", metavar="character"),
  make_option(c("-r", "--resDir"), type="character", default=NULL, help="resDir option should specify directory where results files should be stored", metavar="character"),
  make_option(c("-u", "--userId"), type="character", default="userId", help="userId option should specify user ID column in trait of interest and phenotype files [default= %default]", metavar="character"),
  make_option(c("-t", "--test"), action="store_true", default=FALSE, help="Run test phenome scan on test data (see test subfolder) [default= %default]"),
  make_option(c("-s", "--sensitivity"), action="store_true", default=FALSE, help="Run sensitivity phenome scan [default= %default]"),
  make_option(c("-a", "--partIdx"), type="integer", default=NULL, help="Part index of phenotype (used to parellise)"),
  make_option(c("-b", "--numParts"), type="integer", default=NULL, help="Number of phenotype parts (used to parellise)"),
  make_option(c("-j", "--genetic"), action="store", default=TRUE, help="Trait of interest is genetic, e.g. a SNP or genetic risk score [default= %default]"),
  make_option(c("-z", "--save"), action="store_true", default=FALSE, help="Save generated phenotypes to a file rather than testing associations [default= %default]"),
  make_option(c("-c", "--confounderfile"), type="character", default=NULL, help="Confounder file name", metavar="character"),
  make_option(c("-i", "--confidenceintervals"), type="logical", default=TRUE, help="Whether confidence intervals should be calculated [default= %default]"),
  make_option(c("-k", "--standardise"), action="store", default=TRUE, help="Trait of interest is standardised to have mean=0 and std=1 [default= %default]")
)