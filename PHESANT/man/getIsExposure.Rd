\name{getIsExposure}
\alias{getIsExposure}
\title{
Check field exposure 
}
\description{
Check whether a field denotes the trait of interest, as specified.
}
\usage{
getIsExposure(vl, varName)
}
\arguments{
  \item{vl}{variable list object
}
  \item{varName}{ the field ID to be checked
}
}

\value{
Return true if the field has a "YES" value in TRAIT_OF_INTEST column.
}
