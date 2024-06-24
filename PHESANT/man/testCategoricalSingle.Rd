\name{testCategoricalSingle}
\alias{testCategoricalSingle}
\title{
Association Test dispacther for "Categorical single" value type
}
\description{
The function takes the declared "Categorical single" value type of a field and validates/decides on the actual type of association test and perform the test accordingly. 
}
\usage{
testCategoricalSingle(opt, vl, varName, varType, thisdata, phenoStartIdx)
}
\arguments{
  \item{opt}{The list of input options provided by user.}
  \item{vl}{The list that holds input phenotype variable list and input data coding list.}
  \item{varName}{The phenotype/variable to be tested, in the form of FIELDID. For example 21022.}
  \item{varType}{The value type of the variable. Should always be "Categorical single" here and used for logging purpose only.}
  \item{thisdata}{The data frame object holds all variables including phenotypes, confounders, depeinding variables and trait of interest.}
  \item{phenoStartIdx}{The column index of the first phenotype.}
}
\details{
Performs variable processing for categorical (single) fields, namely
  \enumerate{
      \item Reassign values as specified in data coding information file
      \item Reorder categories for ordered fields
      \item Replace missing codes - we assume values < 0 are missing for categorical (single) variables
      \item Remove values with <10 cases
      \item Deterimine correct test to perform, either binary, ordered or unordered
  }
}
\value{
Return nothing and all output and lof information are written to output directory specified by user.
}