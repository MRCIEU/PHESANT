\name{initData}
\alias{initData}
\title{
Validates, loads input data  and inilizes working environment to run PHESANT 
}
\description{
Validates, loads input data  and inilizes working environment to run PHESANT. 
}
\usage{
initData(opt)
}
\arguments{
  \item{opt}{The list of input options provided by user.}
}

\value{
Return a list objerct containing all the data used to run PHESANT.
  \enumerate{
      \item data: data frame for all phenotypes
      \item vl: variable list for all phenotypes
      \item confounders: data frame for all confounders
      \item phenoStartIdx: the column index for first phenotype column in data data frame
      \item phenoVars: a list of all phenotypes, excluding user ID
  }
}

\examples{
# input <- initData(opt)
}
