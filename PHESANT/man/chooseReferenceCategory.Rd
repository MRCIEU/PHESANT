\name{chooseReferenceCategory}
\alias{chooseReferenceCategory}
\title{
Choose Reference Category 
}
\description{
Convert an integer vector with possible NA's to a factor and use the category/factor with most number of examples as reference.
}
\usage{
chooseReferenceCategory(pheno)
}
\arguments{
  \item{pheno}{ An integer vector with possible NA's. }
}

\value{
  A factor with the most number of examples as reference.
}
