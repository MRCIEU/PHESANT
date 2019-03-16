\name{testAssociations}
\alias{testAssociations}

\title{
Association Test Dispacher 
}
\description{
The main function to identify the right kind of association test to perfrom based on phenotype variable information.
}
\usage{
testAssociations(opt, vl, currentVar, currentVarShort, thisdata, phenoStartIdx)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{opt}{The list of input options provided by user.}
  \item{vl}{The list that holds input phenotype variable list and input data coding list.}
  \item{currentVar}{The phenotype/variable to be tested, in the form of FIELDID_INSTANCE. For example 21022_0.}
  \item{currentVarShort}{The phenotype/variable to be tested, in the form of FIELDID. For example 21022.}
  \item{thisdata}{The data frame object holds all variables including phenotypes, confounders, depeinding variables and trait of interest.}
  \item{phenoStartIdx}{The column index of the first phenotype.}
}
\details{
For a given variable identified by its FIELDID, it reads from variable list to decide if to run association test and chooses the approriate assocition test based on variable value type. Currently, recognized variable types are "Integer", "Continuous", "Categorical single", and "Categorical multiple" and all other types are ignored.
}
\value{
Return nothing and all output and lof information are written to output directory specified by user.
}
