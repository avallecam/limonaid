% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/append_lsdf_rows.R
\name{emptyDf}
\alias{emptyDf}
\title{Create an empty dataframe}
\usage{
emptyDf(colnames, nrow, fillWith = "")
}
\arguments{
\item{colnames}{The column names for the dataframe.}

\item{nrow}{The number of rows.}

\item{fillWith}{What to fill the dataframe with.}
}
\value{
The data.frame.
}
\description{
This function is used by \code{\link[=append_lsdf_rows]{append_lsdf_rows()}}, and you normally
should not use it directly.
}
\examples{
limonaid::emptyDf(c("x", "y"), 3);
}
