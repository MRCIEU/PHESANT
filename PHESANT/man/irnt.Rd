\name{irnt}
\alias{irnt}
\title{
 Inverse Rank Normal Transformation
}
\description{
  Perform an inverse rank normal transformation for input phenotypes
}
\usage{
irnt(pheno,seed)
}
\arguments{
  \item{pheno}{
  A vector of numeric vlues with NA allowed.
}
\item{seed}{
  Random seed for tie breakers, default to 1234.
}
}

\value{
  A vector of the transformed values.
}

