\name{loadData}
\alias{loadData}
\title{
Loads phenotype, trait of interest data files
}
\description{
Validates and loads phenotype, trait of interest, and relted fields from data files. 
}
\usage{
loadData(opt, vl)
}
\arguments{
  \item{opt}{The list of input options provided by user.}
  \item{vl}{The list that holds input phenotype variable list and input data coding list}
}
\details{
Taking user options as input, this function validates and loads phenotype, trait of interest, and relted fields from data files. 
  \enumerate{
      \item loads phenotype and trait of interest data files
      \item creates phenotype / trait of interest data frame
      \item creates confounder data frame
      \item parses and creates indicator data frame
      \item returns an object holding these three data frames
  }
}
\value{
  Returns a list of dataframes:
  \enumerate{
      \item phenotype: data frame for all phenotypes
      \item confounders: data frame for all confounders
      \item inds: data frame for all related indicators
  }
}

\examples{
#d <- loadData(opt, vl)
}
