% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/adams.R
\name{adams}
\alias{adams}
\title{Return apportioned vector according to John Quincy Adams' Method}
\usage{
adams(x, n = 100, k = 1)
}
\arguments{
\item{x}{A named vector.}

\item{n}{Number of apportioned units to sum to}

\item{k}{The incrementing interval used to search for divisors}
}
\value{
A named vector of length \code{x} containing apportioned integers summing to \code{n}.
}
\description{
Return apportioned vector according to John Quincy Adams' Method
}
\section{References}{

 http://www.maa.org/publications/periodicals/convergence/apportioning-representatives-in-the-united-states-congress-adams-method-of-apportionment
}

\section{Further details}{

  Method suggested in 1832 by Former President John Quincy Adams
}
\examples{
adams(usa1832, 240)
}

