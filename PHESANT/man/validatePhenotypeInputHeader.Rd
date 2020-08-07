\name{validatePhenotypeInputHeader}
\alias{validatePhenotypeInputHeader}
\title{
Validate the contents of the phenotype file
}
\description{
Validate the contents of the phenotype file
}
\usage{
validatePhenotypeInputHeader(opt)
}
\arguments{
  \item{opt}{
  The list of input options provided by user.
}
}
\details{
This function validates the input phenotype file based on user options. 
\enumerate{
    \item check if user id field exists in pheno file
    \item check if phenotype file contains the required age colunn: x21022_0_0
    \item check if phenotype file contains the required sex colunn: x31_0_0
    \item check if phenotype file contains the required genetic batch colunn: x22000_0_0, when genetic option is used
    \item check if phenotype file contains the required genetic principal component colunns(1 to 10): x22009_0_, when sensitivity and genetic options are used
    \item check if phenotype file contains the required assessment centre colunn: x54_0_0, when sensitivity option is used
    
  }
}
\value{
  No return values and reports error and stops the program if the validation fails.
}


\examples{
#validatePhenotypeInputHeader(opt)
}
