\name{validateTraitInputHeader}
\alias{validateTraitInputHeader}
\title{
Validate the contents of the trait of interest file
}
\description{
Validate the contents of the trait of interest file.
}
\usage{
validateTraitInputHeader(opt)
}
\arguments{
  \item{opt}{The list of input options provided by user.}
}
\details{
This function validates the contents of the trait of interest file based on user options. A trait of interest ca nbe either from phrenotype file or trait of interest file.
\enumerate{
    \item check if user id field exists in pheno file or traint of interest file if the trait of interest file is provided.
    \item check if phenotype file or trait of interest file contains the required trait of interest variable column.
  }
}
\value{
No return values and reports error and stops the program if the validation fails.
}

\examples{
#validateTraitInputHeader(opt)
}
