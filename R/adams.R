#' Return apportioned vector according to John Quincy Adams' Method
#'
#' @param x A named vector.
#' @param n Number of apportioned units to sum to
#' @return A named vector of length \code{x} containing apportioned integers summing to \code{n}.
#' @examples
#' adams(usa1832, 240)
#' @section References:
#'  http://www.maa.org/publications/periodicals/convergence/apportioning-representatives-in-the-united-states-congress-adams-method-of-apportionment
#' @section Further details:
#'   Method suggested in 1832 by Former President John Quincy Adams 
#' @export


adams <- function(x, n=100, k=1){
    
    divisor <- sum(x)/n
    
    #initialize j
    j = divisor
    
    while(TRUE) {
      # test for the condition of interest
      
      if( sum(ceiling(x/j))  == n  )
        # break if the condition is met
        break
      
      if( sum(ceiling(x/j)) < n  )
        stop("have not found an appropriate divisor - try reducing 'k'")  
      
      # incremenet j
      j = j + k
    }
    
    res <- ceiling(x/j)
    return(res)
    
  }
  