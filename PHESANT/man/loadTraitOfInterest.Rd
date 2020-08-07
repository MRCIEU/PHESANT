\name{loadTraitOfInterest}
\alias{loadTraitOfInterest}
\title{
Load trait of interest
}
\description{
Load trait of interest, either from separate trait of interest file, or from phenotype file.
}
\usage{
loadTraitOfInterest(opt, phenotypes)
}
\arguments{
  \item{opt}{The list of input options provided by user.}
  \item{phenotypes}{The phenotype data from loadPhenotypes function.}
}
\details{
Load trait of interest, either from separate trait of interest file, or from phenotype file.
}
\value{
Returns a data frame of two columns for User ID and trait of interest.
}

\examples{
#toi <- loadTraitOfInterest(opt, phenotype)
}
