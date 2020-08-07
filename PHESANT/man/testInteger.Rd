\name{testInteger}
\alias{testInteger}
\title{
Association Test dispacther for Integer value type
}
\description{
The function takes the declared "Integer" value type of a field and validates/decides on the actual type of association test and perform the test accordingly. 
}
\usage{
testInteger(opt, vl, varName, varType, thisdata, phenoStartIdx)
}
\arguments{
  \item{opt}{The list of input options provided by user.}
  \item{vl}{The list that holds input phenotype variable list and input data coding list.}
  \item{varName}{The phenotype/variable to be tested, in the form of FIELDID. For example 21022.}
  \item{varType}{The value type of the variable. Should always be "INTEGER" here and used for logging purpose only.}
  \item{thisdata}{The data frame object holds all variables including phenotypes, confounders, depeinding variables and trait of interest.}
  \item{phenoStartIdx}{The column index of the first phenotype.}
}
\details{
Processing integer fields, namely:
  \enumerate{
      \item Reassigning values as specified in the data code information file
      \item Generate a single value if there are several values (arrays) by taking the mean
      \item Treating this field as continuous if at least 20 distinct values
      \item Otherwise treat as binary or ordered categorical if 2 or more than two values
  }
}
\value{
Return nothing and all output and lof information are written to output directory specified by user.
}

