\name{testContinuous}
\alias{testContinuous}
\title{
Association Test dispacther for Continuous value type
}
\description{
The function takes the declared "Continuous" value type of a field and validates/decides on the actual type of association test and perform the test accordingly. 
}
\usage{
testContinuous(opt, vl, varName, varType, thisdata, phenoStartIdx)
}
\arguments{
  \item{opt}{The list of input options provided by user.}
  \item{vl}{The list that holds input phenotype variable list and input data coding list.}
  \item{varName}{The phenotype/variable to be tested, in the form of FIELDID. For example 21022.}
  \item{varType}{The value type of the variable. Should always be "Continuous" here and used for logging purpose only.}
  \item{thisdata}{The data frame object holds all variables including phenotypes, confounders, depeinding variables and trait of interest.}
  \item{phenoStartIdx}{The column index of the first phenotype.}
}
\details{
  Processing integer fields, namely:
  \enumerate{
      \item Reassigning values as specified in the data code information file
      \item Generate a single value if there are several values (arrays) by taking the mean
      \item Treating this field as ordinal categorical if >20\% examples with same value
      \item Otherwise Treat as continuous (with Rank-based Inverse Normal Transformation) if 500 or more samples have values
      \item In the case of 3), treat it as binary if only two types of values, or ordinal categorical if its values can be binned approximately into three equl bins.
      \item In the case of 5), if more than 3 type of values and can not be binned reasonably into 3 euqal bins, merge them into two bins ans treat it as binary, or give up.
  }
}
\value{
Return nothing and all output and lof information are written to output directory specified by user.
}

