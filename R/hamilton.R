#' Return apportioned vector according to Alexander Hamilton's Method
#'
#' @param x A named vector.
#' @param n Number of apportioned units to sum to
#' @return A named vector of length \code{x} containing apportioned integers summing to \code{n}.
#' @examples
#' hamilton(usa1990, 435)
#' @section References:
#'    http://www.maa.org/publications/periodicals/convergence/apportioning-representatives-in-the-united-states-congress-hamiltons-method-of-apportionment
#' @section Further details:
#'    Method suggested in 1792 by Alexander Hamilton 
#' @export




hamilton <- function(x, n=100){
  
  x1 <-  n*x / sum(x)
  x2 <- floor(x1)
  
  myzeros <- names(which(x2 == 0)) #Keep names of elements whose floor/lower quota == 0
  
  x2[x2 == 0] <- 1  #assign states with 0 lower quota (x2) to be 1.
  Tot<-sum(x2)
  N <- n-Tot   
  
  if(N==0){ return(x2) }
  
  else
    
    if(N<0) { stop("not possible to apportion") }
  
  else
    
    if(N>0)
      
      frac <- rev(sort(x1%%1))
  frac1 <- frac[!names(frac) %in% myzeros]   # ensures that those states whose lower quota == 0 are excluded from the assigning of fractional parts
  
  toadd  <- names(frac1[1:N])
  
  x3 <- ifelse(names(x2) %in% toadd == T, x2 + 1, x2)
  names(x3) <- names(x)
  return(x3)
}
