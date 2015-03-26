#' Return apportioned vector according to Alexander Hamilton's Method - allowing for zeros
#'
#' @param x A named vector.
#' @param n Number of apportioned units to sum to
#' @return A named vector of length \code{x} containing apportioned integers summing to \code{n}.
#' @examples
#' hamilton0(usa1880, 300)
#' @section References:
#'    http://www.maa.org/publications/periodicals/convergence/apportioning-representatives-in-the-united-states-congress-hamiltons-method-of-apportionment
#' @section Further details:
#'    Method suggested in 1792 by Alexander Hamilton 
#' @export

hamilton0 <- function(x, n=100){
  
  x1 <-  n*x / sum(x)
  x2 <- floor(x1)
  Tot<-sum(x2)
  N <- n-Tot
  frac <- rev(sort(x1%%1))
  toadd  <- names(frac[1:N])
  x3 <- ifelse(names(x2) %in% toadd == T, x2 + 1, x2)
  names(x3) <- names(x)
  return(x3)
}
