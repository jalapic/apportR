#' Return apportioned vector according to Dean's Method - allows for zeros
#'
#' @param x A named vector.
#' @param n Number of apportioned units to sum to
#' @param k The incrementing interval used to search for divisors
#' @return A named vector of length \code{x} containing apportioned integers summing to \code{n}.
#' @examples
#' majs <- c(100, 154, 0, 22, 5)
#' names(majs) <- c("English", "History", "Swahili", "French", "Aeronautics")
#' dean0(majs,10)
#' @section References:
#'  http://www.maa.org/publications/periodicals/convergence/apportioning-representatives-in-the-united-states-congress-deans-method-of-apportionment
#' @section Further details:
#'   Method suggested in 1920s by James Dean, professsor of astronomy and mathematics at Dartmouth and University of Vermont. 
#' @export




dean0 <- function(x, n=100, k=1){
  
  divisor <- (sum(x)/n)
  
  seats <- dean2(x, divisor)  
  
  
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
      
      tmp <- dean2(x, mydivisors[j])
      
      if(sum(tmp)  == n)
        
        break
      j = j + 1
    }
    
    
    res <- dean2(x, mydivisors[j])
    
    return(res)
    
  }
}


harmon1 = function(x){2 / ( (1/x[1]) + (1/x[2]) )}

dean2<-function(x,divi){
  quotas <- x / divi
  lwqt <- floor(quotas)
  upqt <- ceiling(quotas)
  harmons <- apply(cbind(lwqt, upqt), 1, harmon1)
  seats <- ifelse(quotas > harmons, upqt, lwqt) 
  return(seats)
}
