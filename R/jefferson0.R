#' Return apportioned vector according to Thomas Jefferson's Method - allowing for zeros
#'
#' @param x A named vector.
#' @param n Number of apportioned units to sum to
#' @param k The incrementing interval used to search for divisors
#' @return A named vector of length \code{x} containing apportioned integers summing to \code{n}.
#' @examples
#' z <- c(1,4,5,14,16,3)
#' names(z) <- letters[1:6]
#' jefferson0(z, 10, k=0.1)
#' @section References:
#'    http://www.maa.org/publications/periodicals/convergence/apportioning-representatives-in-the-united-states-congress-jeffersons-method-of-apportionment
#' @section Further details:
#'    Method suggested in 1792 by Thomas Jefferson 
#' @export


jefferson0 <- function(x, n=100, k=1){
  
  divisor <- sum(x)/n
  mydivisors <-  seq(0,divisor, by=k)
  
  obj<-(sapply(rev(mydivisors), function(y) sum(floor(x/y))==n))
  i <- which.max(obj) 
  
  jeff <- rev(mydivisors)[i]  #use index to find the actual value of the divisor that works.
  res <- floor(x/jeff)

  if (sum(floor(x/jeff))!=n) { stop("have not found an appropriate divisor - try reducing 'k'") } #check k was sufficient

  return(res)
  
}
