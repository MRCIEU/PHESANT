\name{testCategoricalMultiple}
\alias{testCategoricalMultiple}
\title{
Association Test dispacther for "Categorical multiple" value type
}
\description{
The function takes the declared "Categorical multiple" value type of a field and validates/decides on the actual type of association test and perform the test accordingly.
}
\usage{
testCategoricalMultiple(opt, vl, varName, varType, thisdata, phenoStartIdx)
}
\arguments{
  \item{opt}{The list of input options provided by user.}
  \item{vl}{The list that holds input phenotype variable list and input data coding list.}
  \item{varName}{The phenotype/variable to be tested, in the form of FIELDID. For example 21022.}
  \item{varType}{The value type of the variable. Should always be "Categorical multiple" here and used for logging purpose only.}
  \item{thisdata}{The data frame object holds all variables including phenotypes, confounders, depeinding variables and trait of interest.}
  \item{phenoStartIdx}{The column index of the first phenotype.}
}
\details{
Performs variable processing for categorical (multiple) fields, namely
  \enumerate{
      \item Reassign values as specified in data coding file
      \item Generate binary variable for each category in field, restricting to correct set of participants as specified
      \item Replace missing codes - we assume values < 0 are missing for categorical (single) variables
      \item Check derived variable has at least 10 cases in each group
      \item Call binaryLogisticRegression function for this derived binary variable
  }
}

\value{
Return nothing and all output and lof information are written to output directory specified by user.
}

