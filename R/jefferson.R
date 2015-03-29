#' Return apportioned vector according to Thomas Jefferson's Method
#'
#' @param x A named vector.
#' @param n Number of apportioned units to sum to
#' @param k The incrementing interval used to search for divisors
#' @return A named vector of length \code{x} containing apportioned integers summing to \code{n}.
#' @examples
#' jefferson(usa1990, 435)
#' @section References:
#' http://www.maa.org/publications/periodicals/convergence/apportioning-representatives-in-the-united-states-congress-jeffersons-method-of-apportionment
#' @section Further details:
#'   Method suggested in 1792 by Thomas Jefferson 
#' @export

jefferson <- function(x, n=100, k=1){
  
  # get initial divisor
  divisor <- sum(x)/n

  
  # assign floored zeros to get 1.
  x2 <- floor(x/divisor)
  myzeros <- names(which(x2 == 0)) #Keep names of elements whose floor/lower quota == 0
  n.new <- n - length(myzeros) #new target
  x.new <- x[!(names(x) %in% myzeros)]
  
  
  # find a divisor that works with new target

  divisor.new <- sum(x.new)/n.new
  mydivisors <-  seq(0,divisor.new, by=k)
  
  obj<-(sapply(rev(mydivisors), function(y) sum(floor(x.new/y))==n.new))
  i <- which.max(obj)
  jeff <- rev(mydivisors)[i]  #use index to find the actual value of the divisor that works.
  res <- floor(x.new/jeff)
  
  
  # recombine with those assigned a 1
  myzeros.1 <- rep(1, length(myzeros))
  names(myzeros.1) <- myzeros
  
  res1 <- c(res, myzeros.1)
  res1 <- res1[sort(names(x))] #put back into alphanumeric order
  
  if (sum(res1)!=n) { stop("have not found an appropriate divisor - try reducing 'k'") } #check k was sufficient
  
  return(res1)
  
}
