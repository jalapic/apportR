#' Return apportioned vector according to Dean's Method
#'
#' @param x A named vector.
#' @param n Number of apportioned units to sum to
#' @param k The incrementing interval used to search for divisors
#' @return A named vector of length \code{x} containing apportioned integers summing to \code{n}.
#' @examples
#' dean(usa1832, 240)
#' dean(usa1832, 240, 20)
#' @section References:
#'  http://www.maa.org/publications/periodicals/convergence/apportioning-representatives-in-the-united-states-congress-deans-method-of-apportionment
#' @section Further details:
#'   Method suggested in 1920s by James Dean, professsor of astronomy and mathematics at Dartmouth and University of Vermont. 
#' @export




dean <- function(x, n=100, k=1){
  
  divisor <- (sum(x)/n)
  
  seats <- dean3(x, divisor)  
  
  
  if(sum(seats)==n) {return(seats)} 
  
  if(sum(seats) != n) { 
    
    #set up vector of possible divisors
    myd1 <- rev(seq(0,divisor, by=k))  
    myd2 <- seq(divisor, divisor+(length(myd1)*k), by=k)
    
    #account for potential of unequal vector sizes prior to rbind
    shortest <- min(length(myd1), length(myd2))
    myd2 <- head(myd2, shortest)
    myd1 <- head(myd1, shortest)
    
    mydivisors <- c(rbind(myd1, myd2))
    
    #find divisor
    j<-1
    
    while(TRUE) {
      
      if(j == length(mydivisors))
        stop("have not found an appropriate divisor - try adjusting 'k'")  
      
      tmp <- dean3(x, mydivisors[j])
      
      if(sum(tmp)  == n)
        
        break
      j = j + 1
    }
    
    
    res <- dean3(x, mydivisors[j])
    
    return(res)
    
  }
}


harmon1 = function(x){2 / ( (1/x[1]) + (1/x[2]) )}

dean3<-function(x,divi){
  quotas <- x / divi
  lwqt <- floor(quotas)
  upqt <- ceiling(quotas)
  harmons <- apply(cbind(lwqt, upqt), 1, harmon1)
  seats <- ifelse(quotas > harmons, upqt, ifelse(quotas==0, 1, lwqt)) 
  return(seats)
}
