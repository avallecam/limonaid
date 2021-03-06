% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/export_with_languages.R
\name{export_with_languages}
\alias{export_with_languages}
\title{Export a survey with a specific primary and additional languages}
\usage{
export_with_languages(
  x,
  language,
  path,
  additional_languages = NULL,
  new_sid = x$sid,
  backupLanguage = x$language,
  prefix = "limesurvey--",
  suffix = "",
  parallel = TRUE
)
}
\arguments{
\item{x}{The Survey object.}

\item{language}{The desired primary language.}

\item{path}{The path where to save the .TSV file.}

\item{additional_languages}{If specified, the selection of additional
languages. If not specified, the survey's primary language will just be
switched to \code{language}, and all original languages will be retained.}

\item{new_sid}{If specified, a new sid to use.}

\item{backupLanguage}{The language to use if an element is not specified
in one of the languages.}

\item{prefix}{The prefix to use in the filename.}

\item{suffix}{The suffix to use in the filename.}

\item{parallel}{Whether to use multiple cores when exporting the survey.}
}
\value{
Invisibly, the cloned and altered survey object.
}
\description{
Sometimes it is useful to export a version of a survey with a
different primary language, and/or less additional languages. This
function allows that.
}
\examples{
### Add later
}
