\name{loadConfounders}
\alias{loadConfounders}
\title{
Loads confounder variables
}
\description{
Loads confounder variables from phenotype file or confounder file based on user options. If user provides a confunder file, all confounder variables will be extracted from it. Otherwise, confounder variables will be read from phenotype file and a set of predefined confounders will be extracted.
}
\usage{
loadConfounders(opt, phenotypes)
}
\arguments{
  \item{opt}{The list of input options provided by user.}
  \item{phenotypes}{The phenotype data from loadPhenotypes function.}
}
\details{
If user provides a confunder file, all confounder variables will be extracted from it. Otherwise, confounder variables will be read from phenotype file and a set of predefined confounders will be extracted. When reading from phenotype file for confounders, the following variables will be extracted:
  \enumerate{
      \item age: x21022_0_0
      \item sex: x31_0_0
      \item genetic: x22000_0_0, with genetic batch used to create genetic chip variable, optional, present only if opt$genetic is set.
      \item genetic principal components and assessment centre, optional, present only if opt$genetic and opt$sensitivity are set: x22009_0_1 through x22009_0_10, and x54_0_0.
      \item assessment centre only if opt$genetic is false and opt$sensitivity is true: x54_0_0.
  }
}

\value{
Returns a dataframe for all confounder variables, with first column being UserID.}

\examples{
#conf <- loadConfounders(opt, phenotype)
}
