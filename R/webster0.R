#' Return apportioned vector according to Webster's Method - allows for zeros
#'
#' @param x A named vector.
#' @param n Number of apportioned units to sum to
#' @param k The incrementing interval used to search for divisors
#' @return A named vector of length \code{x} containing apportioned integers summing to \code{n}.
#' @examples
#' majs <- c(100, 154, 0, 22, 5)
#' names(majs) <- c("English", "History", "Swahili", "French", "Aeronautics")
#' webster0(majs,10)
#' @section References:
#' http://www.maa.org/publications/periodicals/convergence/apportioning-representatives-in-the-united-states-congress-websters-method-of-apportionment
#' @section Further details:
#'  Method suggested by Sen Daniel Webster used in 1840, 1910 and 1930 apportionments 
#' @export

webster0 <- function(x, n=100, k=1){
  
  divisor <- (sum(x)/n)
  
  seats <- webster2(x, divisor)  
  
  
  if(sum(seats)==n) {return(seats)} 
  
  if(sum(seats) != n) { 
    
    #set up vector of possible divisors
    myd1 <- rev(seq(0,divisor, by=k))  
    myd2 <- seq(divisor, divisor+(length(myd1)-1), by=k)
    
    #account for potential of unequal vector sizes prior to rbind
    shortest <- min(length(myd1), length(myd2))
    myd2 <- head(myd2, shortest)
    myd1 <- head(myd1, shortest)
    
    mydivisors <- c(rbind(myd1, myd2))
    
    #find divisor
    j<-1
    
    while(TRUE) {
      tmp <- webster2(x, mydivisors[j])
      
      
      if(sum(tmp)  == n)
        
        break
      j = j + 1
    }
    
    res <- webster2(x, mydivisors[j])
    
    return(res)
    
  }
}



gmean1 = function(x){sqrt(x[1]*x[2])}

webster2<-function(x,divi){
  quotas <- x / divi
  lwqt <- floor(quotas)
  upqt <- ceiling(quotas)
  arithmeans <- apply(cbind(lwqt, upqt), 1, mean)
  seats <- ifelse(quotas > arithmeans, upqt, lwqt)
  return(seats)
}
