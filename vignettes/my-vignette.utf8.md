---
title: "apportR introduction"
author: "Prof James P Curley, Columbia University"
date: "2015-03-26"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{apportR introduction}
  %\VignetteEngine{knitr::rmarkdown}
  \usepackage[utf8]{inputenc}
---




## Introduction

The `apportR` package contains several functions for performing apportionment procedures.  The inspiration behind me writing this package can be found [here]().  This package is in development and is very much a work in progress.  This vignette details some sample problems that can be solved using the functions in this package, information regarding the example datasets contained in `apportR` as well as some background and worked examples of each function.  At this stage of development I would welcome hearing from anyone who thinks that they could help improve the package.



------


### Installation

The `apportR` package can be downloaded from [github](https://github.com/jalapic/apportR).


```r
library(devtools)
devtools::install_github("jalapic/apportR")

```

\  

#### Loading the package

```r
library(apportR)
```

\  


------


### Examples

To illustrate the general problem at hand, here are three examples.

\  

#### Fair Division Example 1.

> Mom has 50 identical pieces of candy that cannot be broken into bits.  She tells her five children that she will divide the candy fairly at the end of the week according to the proportion of housework that each performs.

\  

The following tables shows the minutes spent in housework by each child and how many of the 50 candies each child should expect to get:



```r
housework
#>  Anna Betty  Carl Derek  Ella 
#>   150    78   173   204   295


candies <- (50*housework) / sum(housework)
candies
#>      Anna     Betty      Carl     Derek      Ella 
#>  8.333333  4.333333  9.611111 11.333333 16.388889

floor(candies)
#>  Anna Betty  Carl Derek  Ella 
#>     8     4     9    11    16


sum(floor(candies))
#> [1] 48
```

\  

Anna expects 8.33%, Betty 4.33%, Carl 9.6%, Derek 11.33% and Ella 16.39% of the candies, but they cannot be broken up.
Assuming each gets the number of candies equal to their rounded down proportion at least, then Who should get the extra 2 candies that are not yet allocated?


\  


#### Fair Division Example 2.

> There are 12 scholarships to be given out to each of 3 subjects at a university. They are to be awarded based upon the proportion of majors that each subject has.

\  

Here are the majors in each subject as well as the expected number of scholarships each would get out of the 12 available:


```r
majors
#>    English    History Psychology 
#>        231        502        355


scholarships <- (12*majors) / sum(majors)
scholarships
#>    English    History Psychology 
#>   2.547794   5.536765   3.915441

floor(scholarships)
#>    English    History Psychology 
#>          2          5          3


sum(floor(scholarships))
#> [1] 10
```

\  

If each gets the rounded down value that they would expect, where do the remaining 2 scholarships go ?  Presumably Psychology should get an extra one as its fractional is .9, but which of English and History should get the other one?

\  



#### Fair Division Example 3.

> At the 1792 US House of Representatives elections, a total of 105 seats were to be awarded that would be shared between the 15 states of the union proportional to each state's population size at the 1790 US census.

\  

[More reading can be found here](http://en.wikipedia.org/wiki/United_States_House_of_Representatives_elections,_1792)

\  

Here are the states and their population sizes in 1790, followed by the expected number of seats for each state based on there being 105 available:



```r
usa1790
#>     VA     MA     PA     NC     NY     MD     CT     SC     NJ     NH 
#> 630560 475327 432879 353523 331589 278514 236841 206236 179570 141822 
#>     VT     GA     KY     RI     DE 
#>  85533  70835  68705  68446  55540


seats <- (105*usa1790) / sum(usa1790)
seats
#>        VA        MA        PA        NC        NY        MD        CT 
#> 18.310361 13.802666 12.570050 10.265690  9.628765  8.087560  6.877449 
#>        SC        NJ        NH        VT        GA        KY        RI 
#>  5.988733  5.214399  4.118263  2.483729  2.056925  1.995073  1.987552 
#>        DE 
#>  1.612785

floor(seats)
#> VA MA PA NC NY MD CT SC NJ NH VT GA KY RI DE 
#> 18 13 12 10  9  8  6  5  5  4  2  2  1  1  1


sum(floor(seats))
#> [1] 97
```

\  

Who should get those 8 extra seats ???  This is a slightly more important question to get right than the fair division of candies (depending upon your perspective)!

I will describe some methods for working this out as well as the functions contained in `apportR` to represent these methods a bit later in this vignette.

\  


------


### Datasets

The `apportR` package contains a number of small datasets useful for testing functions and/or illustrating methods.  These are:


```r
data(package='apportR')

#Data sets in package ‘apportR’:
#
#housework                            Housework example
#majors                               Majors example
#parador                              Parador example
#pop1                                 Population example 1
#usa1790                              USA population by state in 1790.
#usa1820                              USA population by state in 1820.
#usa1832                              USA population by state in 1832.
#usa1880                              USA population by state in 1880.
#usa1900                              USA population by state in 1900.
#usa1907                              USA population by state in 1907.
#usa1990                              USA population by state in 1990.
#usa_census                           USA population by state in every census.
```

\  

All are named vectors except for the last `usa_census` which is a dataframe that contains the year that each state was admitted to the union as well as the population of every state at every official US census.  It should be noted that these population figures do not include Native American or slave populations.


\  


------


### Methods / Functions Overview

The methods for solving these sorts of questions essentially fall into two broad groups.  There are the standard (or non-divisor) methods and the divisor methods.  Many (if not all) of them have been discovered independently in various disciplines and so each may have several different names.   I will mainly focus on the methods from the historical perspective of the US House of Representatives apportionment problem, as it is the most interesting.  

Currently I include discussion of the standard (non-divisor) methods.  I will add information about the divisor methods shortly.  


\  


------


## Standard Non-Divisor Methods

- Hamilton's Method, aka Largest Remainder Method, [Vinton's Method](http://en.wikipedia.org/wiki/Samuel_Finley_Vinton), Hare-Niemeyer Method.
- Lowndes' Method

\  


------


### **Hamilton Method**

The most simple method was first suggested by [Alexander Hamilton](http://www.maa.org/publications/periodicals/convergence/apportioning-representatives-in-the-united-states-congress-hamiltons-method-of-apportionment) in 1792.

Quite straightforwardly, the logic of this method is as follows:

- choose the number of seats available
- calculate the standard divisor (this is equal to the total population / number of seats)
- calculate the standard quota (this is equal to each state population / standard divisor)
- assign each state initally its lower quota (this is the rounded down value of each standard quota)
- calculate how many seats are still to be assigned
- assign extra seats to those states with the highest fractionals from their standad quota in descending order.

\ 

**Example**

There were 120 seats to be allocated in the House in 1790.  The population of each state and the total US population at the 1790 census was as follows:


```r
usa1790
#>     VA     MA     PA     NC     NY     MD     CT     SC     NJ     NH 
#> 630560 475327 432879 353523 331589 278514 236841 206236 179570 141822 
#>     VT     GA     KY     RI     DE 
#>  85533  70835  68705  68446  55540

sum(usa1790)
#> [1] 3615920
```

\  

The standard divisor (which is equivalent to the average number of people that each representative is representing) and standard quotas of each state are therefore:


```r
#standard divisor
std <- sum(usa1790) / 120
std
#> [1] 30132.67


stq <- usa1790 / std
stq
#>        VA        MA        PA        NC        NY        MD        CT 
#> 20.926127 15.774475 14.365771 11.732218 11.004303  9.242926  7.859942 
#>        SC        NJ        NH        VT        GA        KY        RI 
#>  6.844266  5.959313  4.706586  2.838547  2.350771  2.280084  2.271488 
#>        DE 
#>  1.843182
```


\  

The first allocation of seats is the rounded down value of these standard quotas.  When summing these values, it is clear that they only sum to 111 seats which is 9 short of the required total of 120.



```r

lowq <- floor(stq)
lowq
#> VA MA PA NC NY MD CT SC NJ NH VT GA KY RI DE 
#> 20 15 14 11 11  9  7  6  5  4  2  2  2  2  1

sum(lowq)
#> [1] 111
```


\  

The states are then arranged in order of their fractional parts and the states with the 9 largest fractionals are awarded an extra seat. That would be NJ to NC.


```r
rev(sort(stq%%1))
#>          NJ          VA          CT          SC          DE          VT 
#> 0.959313259 0.926126684 0.859941592 0.844266466 0.843182371 0.838547313 
#>          MA          NC          NH          PA          GA          KY 
#> 0.774475099 0.732217527 0.706586429 0.365771367 0.350771035 0.280083630 
#>          RI          MD          NY 
#> 0.271488307 0.242925728 0.004303193
```

\  

This can be done using the `hamilton` function.  The first argument is the named vector of population sizes and the second argument is the number of seats to allocate.


```r
hamilton(usa1790, 120)
#> VA MA PA NC NY MD CT SC NJ NH VT GA KY RI DE 
#> 21 16 14 12 11  9  8  7  6  5  3  2  2  2  2
```


\  

Despite the 1792 bill proposing this method be used was passed but yet it was not brought into use at this time. Instead, this bill was the very first usage of a Presidential veto by George Washingon and a divsor method proposed by [Thomas Jefferson](http://www.maa.org/publications/periodicals/convergence/apportioning-representatives-in-the-united-states-congress-jeffersons-method-of-apportionment) was used.  I will discuss this method in the divisor methods section.  Washington vetoed the bill as Hamilton's method would have meant that some representatives would be representing fewer than 30,000 individuals which was against the constitution.  It was first of only two times that Washington used his Presidential veto. 


We can see this here - several states have too many representatives according to the Constitution:


```r

usa1790 / hamilton(usa1790, 120)
#>       VA       MA       PA       NC       NY       MD       CT       SC 
#> 30026.67 29707.94 30919.93 29460.25 30144.45 30946.00 29605.12 29462.29 
#>       NJ       NH       VT       GA       KY       RI       DE 
#> 29928.33 28364.40 28511.00 35417.50 34352.50 34223.00 27770.00
```


\  


Despite this initial lack of support, Hamilton's method (also known as Vinton's method by the mid nineteenth century) was passed into law and adopted by 1850 and continued to be used until the turn of the 20th century.  It stopped being used at this time because some strange anomalies or paradoxes were discovered.  These are as follows:


\  

**Alabama Paradox**

In 1880 a goverment clerk named C. W. Seaton computed apportionments for all potential House sizes between 275 and 350 members. He then wrote to Congress describing that if the House of Representatives had 299 seats, Alabama would get 8 members but it would only receive 7 members if the House had 300 seats.  This seemed to be a failure of common sense and became known as the [Alabama Paradox](http://en.wikipedia.org/wiki/Apportionment_paradox#Alabama_paradox).


Here are the state populations for 1880 and the number of seats that would be given under the Hamilton method if the House had 299 or 300 members:


```r

usa1880
#>        Alabama       Arkansas     California       Colorado    Connecticut 
#>        1262505         802525         864694         194327         622700 
#>       Delaware        Florida        Georgia       Illinois        Indiana 
#>         146608         269493        1542180        3077871        1978301 
#>           Iowa         Kansas       Kentucky      Louisiana          Maine 
#>        1624615         996096        1648690         939946         648936 
#>       Maryland  Massachusetts       Michigan      Minnesota    Mississippi 
#>         934943        1783085        1636937         780773        1131597 
#>       Missouri       Nebraska         Nevada  New Hampshire     New Jersey 
#>        2168380         452402          62266         346991        1131116 
#>       New York North Carolina           Ohio         Oregon   Pennsylvania 
#>        5082871        1399750        3198062         174768        4282891 
#>   Rhode Island South Carolina      Tennessee          Texas        Vermont 
#>         276531         995577        1542359        1591749         332286 
#>       Virginia  West Virginia      Wisconsin 
#>        1512565         618457        1315497


hamilton(usa1880, 299)
#>        Alabama       Arkansas     California       Colorado    Connecticut 
#>              8              5              5              1              4 
#>       Delaware        Florida        Georgia       Illinois        Indiana 
#>              1              1              9             18             12 
#>           Iowa         Kansas       Kentucky      Louisiana          Maine 
#>             10              6             10              6              4 
#>       Maryland  Massachusetts       Michigan      Minnesota    Mississippi 
#>              6             11             10              5              7 
#>       Missouri       Nebraska         Nevada  New Hampshire     New Jersey 
#>             13              3              1              2              7 
#>       New York North Carolina           Ohio         Oregon   Pennsylvania 
#>             31              8             19              1             26 
#>   Rhode Island South Carolina      Tennessee          Texas        Vermont 
#>              2              6              9              9              2 
#>       Virginia  West Virginia      Wisconsin 
#>              9              4              8


hamilton(usa1880, 300)
#>        Alabama       Arkansas     California       Colorado    Connecticut 
#>              7              5              5              1              4 
#>       Delaware        Florida        Georgia       Illinois        Indiana 
#>              1              1              9             19             12 
#>           Iowa         Kansas       Kentucky      Louisiana          Maine 
#>             10              6             10              6              4 
#>       Maryland  Massachusetts       Michigan      Minnesota    Mississippi 
#>              6             11             10              5              7 
#>       Missouri       Nebraska         Nevada  New Hampshire     New Jersey 
#>             13              3              1              2              7 
#>       New York North Carolina           Ohio         Oregon   Pennsylvania 
#>             31              8             19              1             26 
#>   Rhode Island South Carolina      Tennessee          Texas        Vermont 
#>              2              6              9             10              2 
#>       Virginia  West Virginia      Wisconsin 
#>              9              4              8
```

\  

Texas and Illinois would each gain a member whilst Alabama lost one !

\  


**New States Paradox**

A second paradox of this method also came to light. This is probably best illustrated using the example of Oklahoma which was admitted to the union in 1907.   In 1900 the house had 386 seats.  According to OK's population, they should have got 5 seats.   

The US population in 1900 and seat allocation according to Hamilton's method was as follows:


```r

usa1900
#>      NY      PA      IL      OH      MO      TX      MA      IN      MI 
#> 7264183 6302115 4821550 4157545 3106665 3048710 2805346 2516462 2420982 
#>      IA      GA      KY      WI      TN      NC      NJ      VA      AL 
#> 2231853 2216331 2147174 2067385 2020616 1893810 1883669 1854184 1828697 
#>      MN      MS      CA      KS      LA      SC      AR      MD      NE 
#> 1749626 1551270 1483504 1470495 1381625 1340316 1311564 1188044 1066300 
#>      WV      CT      ME      CO      FL      WA      RI      OR      NH 
#>  958800  908420  694466  539103  528542  515572  428556  413536  411588 
#>      SD      VT      ND      UT      MT      DE      ID      WY      NV 
#>  390638  343641  314454  275277  232583  184735  159475   92531   40670


hamilton(usa1900, 386)
#> NY PA IL OH MO TX MA IN MI IA GA KY WI TN NC NJ VA AL MN MS CA KS LA SC AR 
#> 38 33 25 21 16 16 14 13 12 11 11 11 11 10 10 10 10  9  9  8  8  8  7  7  7 
#> MD NE WV CT ME CO FL WA RI OR NH SD VT ND UT MT DE ID WY NV 
#>  6  5  5  5  3  3  3  3  2  2  2  2  2  2  1  1  1  1  1  1
```

\ 

but the following happens when adding in Oklahoma and allowing for an extra 5 seats:


```r
usa1907
#>      NY      PA      IL      OH      MO      TX      MA      IN      MI 
#> 7264183 6302115 4821550 4157545 3106665 3048710 2805346 2516462 2420982 
#>      IA      GA      KY      WI      TN      NC      NJ      VA      AL 
#> 2231853 2216331 2147174 2067385 2020616 1893810 1883669 1854184 1828697 
#>      MN      MS      CA      KS      LA      SC      AR      MD      NE 
#> 1749626 1551270 1483504 1470495 1381625 1340316 1311564 1188044 1066300 
#>      OK      WV      CT      ME      CO      FL      WA      RI      OR 
#> 1000000  958800  908420  694466  539103  528542  515572  428556  413536 
#>      NH      SD      VT      ND      UT      MT      DE      ID      WY 
#>  411588  390638  343641  314454  275277  232583  184735  159475   92531 
#>      NV 
#>   40670


hamilton(usa1907, 391)
#> NY PA IL OH MO TX MA IN MI IA GA KY WI TN NC NJ VA AL MN MS CA KS LA SC AR 
#> 37 33 25 21 16 16 14 13 12 11 11 11 11 10 10 10 10  9  9  8  8  8  7  7  7 
#> MD NE OK WV CT ME CO FL WA RI OR NH SD VT ND UT MT DE ID WY NV 
#>  6  5  5  5  5  4  3  3  3  2  2  2  2  2  2  1  1  1  1  1  1
```

\  

As you can see, after OK is added in 1907, New York would lose a seat and gives it to Maine!  Again, this seems to fail a common sense test.


\  


**Population Paradox**

A final paradox that has been found is that states that increase in population more relative to other states over a period of time can even lose seats.

Here is a fictious example. Say there are five states (A-E) and this is their population in hundreds of thousands at time 1 (states1) and time 2 (states2):


```r
states1 <- c(150, 78, 173, 204, 295)
states2 <- c(150, 78, 181, 204, 296) #C increases by 8, E by 1
names(states1)<-names(states2)<-LETTERS[1:5]

states1
#>   A   B   C   D   E 
#> 150  78 173 204 295

states2
#>   A   B   C   D   E 
#> 150  78 181 204 296
```

\  

A, B and D have remained the same whilst E and C have increased in population.  Now say there are 50 seats to allocate - let's see what happens:



```r
hamilton(states1, 50)
#>  A  B  C  D  E 
#>  8  4 10 11 17


hamilton(states2, 50)
#>  A  B  C  D  E 
#>  8  5 10 11 16
```

\  

Even though E's population went up by 100,000 it actually lost a representative seat! whilst B whose population stayed the same increased its seat number and C whose population increased by 800,000 remained the same.


\  



**Strengths & Weaknesses**

The biggest advantage of this method is that it is very easy to calculate and to explain.  This method also never violates the quota rule which states that the number of seats ought to be between the lower and upper quota of the standard quota (effectively the floor and ceiling value).  The biggest weaknesses are that it throws up these strange paradoxes or common sense failures, and also that it does systematically favor larger states over smaller ones.


\  


**Notes about the function**

There are a few things to note about this function.

__*1. Named vector*__ - the input vector **must** be named.

\  


__*2. Zero seats problem*__ - for calculating seats in the House, there must always be at least one seat allocated to every state.  The `hamilton` function does this automatically, so if for instance the standard quota of any state would be e.g. 0.333 and its fraction was not large enough to receive an extra surplus seat, then it will override this and allocate the seat.  This happens several times in US census history for Delaware and Nevada.

Other users of this function may want to have the option of allocating 0 to a group. Therefore the sister function to `hamilton` is `hamilton0` which allows for this.

For example, take the US census in 1880 and 300 available seats in the House:


```r
usa1880
#>        Alabama       Arkansas     California       Colorado    Connecticut 
#>        1262505         802525         864694         194327         622700 
#>       Delaware        Florida        Georgia       Illinois        Indiana 
#>         146608         269493        1542180        3077871        1978301 
#>           Iowa         Kansas       Kentucky      Louisiana          Maine 
#>        1624615         996096        1648690         939946         648936 
#>       Maryland  Massachusetts       Michigan      Minnesota    Mississippi 
#>         934943        1783085        1636937         780773        1131597 
#>       Missouri       Nebraska         Nevada  New Hampshire     New Jersey 
#>        2168380         452402          62266         346991        1131116 
#>       New York North Carolina           Ohio         Oregon   Pennsylvania 
#>        5082871        1399750        3198062         174768        4282891 
#>   Rhode Island South Carolina      Tennessee          Texas        Vermont 
#>         276531         995577        1542359        1591749         332286 
#>       Virginia  West Virginia      Wisconsin 
#>        1512565         618457        1315497


hamilton(usa1880, 300)
#>        Alabama       Arkansas     California       Colorado    Connecticut 
#>              7              5              5              1              4 
#>       Delaware        Florida        Georgia       Illinois        Indiana 
#>              1              1              9             19             12 
#>           Iowa         Kansas       Kentucky      Louisiana          Maine 
#>             10              6             10              6              4 
#>       Maryland  Massachusetts       Michigan      Minnesota    Mississippi 
#>              6             11             10              5              7 
#>       Missouri       Nebraska         Nevada  New Hampshire     New Jersey 
#>             13              3              1              2              7 
#>       New York North Carolina           Ohio         Oregon   Pennsylvania 
#>             31              8             19              1             26 
#>   Rhode Island South Carolina      Tennessee          Texas        Vermont 
#>              2              6              9             10              2 
#>       Virginia  West Virginia      Wisconsin 
#>              9              4              8


hamilton0(usa1880, 300)
#>        Alabama       Arkansas     California       Colorado    Connecticut 
#>              8              5              5              1              4 
#>       Delaware        Florida        Georgia       Illinois        Indiana 
#>              1              1              9             19             12 
#>           Iowa         Kansas       Kentucky      Louisiana          Maine 
#>             10              6             10              6              4 
#>       Maryland  Massachusetts       Michigan      Minnesota    Mississippi 
#>              6             11             10              5              7 
#>       Missouri       Nebraska         Nevada  New Hampshire     New Jersey 
#>             13              3              0              2              7 
#>       New York North Carolina           Ohio         Oregon   Pennsylvania 
#>             31              8             19              1             26 
#>   Rhode Island South Carolina      Tennessee          Texas        Vermont 
#>              2              6              9             10              2 
#>       Virginia  West Virginia      Wisconsin 
#>              9              4              8
```


\  

Clearly, Nevada would not get a seat unless allowances were made to ensure all states received at least one seat. Alabama would have lost out again in this instance !

\  


This zero issue can also be illustrated with a couple of fair division problems.  Say we had five candies to divide to each of 3 children dependent upon how many hours of work they completed.


```r
hours <- c(1,3,11)
names(hours) <- c("Xavier", "Yasmin", "Zach")
hours
#> Xavier Yasmin   Zach 
#>      1      3     11


#standard quotas
(5*hours)/ sum(hours)
#>    Xavier    Yasmin      Zach 
#> 0.3333333 1.0000000 3.6666667
```

\  

If we look at the standard quotas then we should initially give 0 to Xavier, 1 to Yasmin and 3 to Zach.  The question then is what to do with the fifth candy.  If we allow zeros then that extra one would be given to Zach.  If we don't allow zeros, then that extra one will be given to Xavier.


```r
hamilton(hours,5)
#> Xavier Yasmin   Zach 
#>      1      1      3


hamilton0(hours,5)
#> Xavier Yasmin   Zach 
#>      0      1      4
```


\  

This also leads us to an issue with the `hamilton` function when we automatically assign 1 to every group.  If there are many individuals with small standard quotas, then it may become impossible to apportion.  

For instance, if we had ten gold watches to give out proportionally to sales reps who sold the most cars in a car dealership and the data looked like this:


```r
cars.sold <- c(1, 2, 15, 3, 1, 12, 4)
names(cars.sold) <- c(paste0("rep", 1:7))
cars.sold
#> rep1 rep2 rep3 rep4 rep5 rep6 rep7 
#>    1    2   15    3    1   12    4


#standard quotas
(cars.sold*10) / sum(cars.sold)
#>      rep1      rep2      rep3      rep4      rep5      rep6      rep7 
#> 0.2631579 0.5263158 3.9473684 0.7894737 0.2631579 3.1578947 1.0526316
```

\ 

Using Hamilton's method everyone would get at least 1 watch accounting for 7 of the watches, but rep3 and rep6 should each get 3 watches, making 11 to be allocated when there are only 10.  Clearly this does not work.  If it is possible to allocate zero watches to individuals, then we can apportion.  Notice that the standard `hamilton` function reports the error.


```r
hamilton(cars.sold, 10)
#> Error in hamilton(cars.sold, 10): not possible to apportion


hamilton0(cars.sold, 10)
#> rep1 rep2 rep3 rep4 rep5 rep6 rep7 
#>    0    1    4    1    0    3    1
```


\  


__*3. Population and seat size*__ - the procedure works by calculating the standard quota of each state i.e. each element of the initial inputted vector.  Therefore it won't work in situations where 1) the values in the input vector are too small, 2) the number of seats to be allocated are either too small.

For example, let's say we had the following vector and wanted to allocate 3 seats:


```r
z <- c(1,3,11)
names(z) <- LETTERS[1:3]
z
#>  A  B  C 
#>  1  3 11


z1 <- sum(z) / 3 #standard divisor
z1
#> [1] 5

z2 <- z/z1 #standard quota
z2
#>   A   B   C 
#> 0.2 0.6 2.2
```

\  

The above cannot work as the function will try to allocate 1 seat to each of A and B and then 2 to C.  The minimum number of seats that can be allocated are 4.



\  


**Future adaptations**

There are [several slight variations](http://en.wikipedia.org/wiki/Largest_remainder_method) to the Hamilton Method, which change slightly how the standard quotas are calculated.  I will add these in time. These include:

- Droop Quota method
- Hagenbach-Bischoff quota 
- Imperiali quota


\  

------

### **Lowndes' Method**

In 1822, Rep. Lowndes of South Carolina proposed an [alternative method](http://www.maa.org/publications/periodicals/convergence/apportioning-representatives-in-the-united-states-congress-lowndes-method-of-apportionment) to Hamilton's. The main tenet of this approach was to give a greater emphasis to the smaller states.  Consequently, this approach never received much support and did not become law.

The general logic is as follows:

- choose the number of seats available
- calculate the standard divisor (this is equal to the total population / number of seats)
- calculate the standard quota (this is equal to each state population / standard divisor)
- assign each state initally its lower quota (this is the rounded down value of each standard quota)
- list the number of persons per already assigned representative
- assign extra seats to those states with the highest number of persons per assigned representative untial all seats are filled

This function also accounts for the zero seats issue by automatically assigning at least one representative per state.


Here is an example of Lowndes' approach from the 1820 census with 213 seats to assign:


```r
usa1820
#>       New York   Pennsylvania       Virginia           Ohio North Carolina 
#>        1368775        1049313         895303         581434         556821 
#>  Massachusetts       Kentucky South Carolina       Tennesse       Maryland 
#>         523287         513623         399351         390769         364389 
#>          Maine        Georgia    Connecticut     New Jersey  New Hampshire 
#>         298335         281126         275208         274551         244161 
#>        Vermont        Indiana      Louisiana        Alabama   Rhode Island 
#>         235764         147102         125779         111147          83038 
#>       Delaware       Missouri    Mississippi       Illinois 
#>          70943          62496          62320          54843


lowndes(usa1820, 213)
#>       New York   Pennsylvania       Virginia           Ohio North Carolina 
#>             32             24             21             13             13 
#>  Massachusetts       Kentucky South Carolina       Tennesse       Maryland 
#>             12             12              9              9              8 
#>          Maine        Georgia    Connecticut     New Jersey  New Hampshire 
#>              7              7              7              7              6 
#>        Vermont        Indiana      Louisiana        Alabama   Rhode Island 
#>              6              4              3              3              2 
#>       Delaware       Missouri    Mississippi       Illinois 
#>              2              2              2              2
```

\  

For comparison, here is how Lowndes' approach differs from Hamilton's for the 120 seats to be assigned in 1790.


```r
hamilton(usa1790, 120)
#> VA MA PA NC NY MD CT SC NJ NH VT GA KY RI DE 
#> 21 16 14 12 11  9  8  7  6  5  3  2  2  2  2


lowndes(usa1790, 120)
#> VA MA PA NC NY MD CT SC NJ NH VT GA KY RI DE 
#> 20 15 14 11 11  9  8  7  6  5  3  3  3  3  2
```

\  

As is clearly evident, Lowndes' method disporportionately favors the smaller states.

\  


------


## Divisor Methods

There are a large number of divisor methods. The general logic is as follows:

- choose the house size (number of seats)

- find a number (the divisor) such that when all the population sizes of every state are divided by this divisor and these numbers are rounded, that they sum to the number of seats.

The different divisor methods differ in how they round numbers. Further, there is rarely one unique value of the divisor that satisfies this equation, but all values that do for each method will lead to the same apportionment.


Although divisor methods are free from paradoxes that the Hamilton Method suffers, they can violate another rule of apportionment the quota rule - that the number of seats allocated should be no higher than rounded up value of the standard quota and no lower than the rounded down value of this number.


\  

Eventually the package will include the following divisor apportionment methods:

- **Jefferson's Method**, aka Greatest Divisor Method, [de Hondt's Method](http://en.wikipedia.org/wiki/Victor_D%27Hondt) - (used in House from 1791-1830)
- **[Webster's Method](http://en.wikipedia.org/wiki/Daniel_Webster)**, aka Major Fractions Method, Sainte-Lague Method, - (used in House in 1840, 1910 and 1930)
- **Huntington-Hill Method**, aka Geometric Mean Method, Equal Proportions Method, - (used in House from 1940 to present)
- **Adams' Method**, aka Smallest Divisors Method, - (considered by Congress but not used)
- **Dean's Method**, aka Harmonic Mean Method

\  

The package currently contains functions called `jefferson`, `jefferson0` and `adams` that can perform those methods.

\  

### **Jefferson's Method**

In 1792, ten days after George Washington vetoed the bill to use the Hamilton Method, Congress passed the method of apportionment sugested by Thomas Jefferson.  They also decided to reduce the number of seats available from 120 to 105 to avoid the issue of having representatives representing too few people (i.e. fewer than 30,000).

Jefferson's Method works as follows:

1. Find the initial divisor - this is equal to the sum of state populations divided by the number of seats available.

2. Determine if the sum of the rounded down standard quotas produced by dividing state populations by the divisor are equal to the number of seats available.

3. If they are not, then through trial and error, find a divisor such that the sum of the rounded down standard quotas produced by dividing state populations by the divisor are equal to the number of seats available.

4. If a state's lower quota is equal to zero, assign them one representative seat regardless (the `jefferson` function automatically does this at present).

For example, here is the 1790 US state populations:


```r
usa1790
#>     VA     MA     PA     NC     NY     MD     CT     SC     NJ     NH 
#> 630560 475327 432879 353523 331589 278514 236841 206236 179570 141822 
#>     VT     GA     KY     RI     DE 
#>  85533  70835  68705  68446  55540


divisor <- sum(usa1790) / 105
initial.divisor <- floor(divisor)
initial.divisor
#> [1] 34437


first.sum <- sum(floor(usa1790/initial.divisor))
first.sum
#> [1] 97


first.sum == 105
#> [1] FALSE
```


\  

The best strategy here as we have too few seats is to decrease the value of the divisor to try and find a solution.   This is possible and is what the `jefferson` function does:



```r
jefferson(usa1790, 105)
#> CT DE GA KY MA MD NC NH NJ NY PA RI SC VA VT 
#>  7  1  2  2 14  8 10  4  5 10 13  2  6 19  2

rev(sort(jefferson(usa1790, 105)))
#> VA MA PA NY NC MD CT SC NJ NH VT RI KY GA DE 
#> 19 14 13 10 10  8  7  6  5  4  2  2  2  2  1
```

\  

... and to compare this with what Hamilton's Method would have produced:


```r
hamilton(usa1790, 105)
#> VA MA PA NC NY MD CT SC NJ NH VT GA KY RI DE 
#> 18 14 13 10 10  8  7  6  5  4  2  2  2  2  2
```

\  

If Hamilton's had been used instead then 13 of the 15 states would have received the same number of Representatives.  Unsurprisingly, Virginia were the beneficiaries under Jefferson's method with poor Delaware losing a seat.

This method was used by the House from 1792-1842 when it was considered that it was too favorable towards the larger States and a different method was needed.

\  

Here is how the Jefferson Method determined the allocation of seats for the 1832 elections to the House of Representatives with 240 seats being available.  I have sorted the allocations in descending order.



```r
usa1832
#>      NY      PA      VA      OH      NC      TN      KY      MA      SC 
#> 1918578 1348072 1023503  937901  639747  625263  621832  610408  455025 
#>      GA      MD      ME      IN      NJ      CT      VT      NH      AL 
#>  429811  405843  399454  343031  319922  297665  280657  269326  262508 
#>      LA      IL      MO      MS      RI      DE 
#>  171904  157147  130419  110358   97194   75432


rev(sort(jefferson(usa1832, 240)))
#> NY PA VA OH TN NC KY MA SC GA ME MD IN NJ CT VT NH AL LA IL RI MS MO DE 
#> 40 28 21 19 13 13 13 12  9  9  8  8  7  6  6  5  5  5  3  3  2  2  2  1
```

\  

**Quota Rule Violations**

Although divisor methods do not have paradoxes associated with them, they can violate the quota rule which states that the number of seats given to each state should be at most the ceiling value of their standard quota and at least the floor value of their standard quota.   The 1832 election above is interesting from this point of view because it actually breaks the quota rule.  New York is allocated 40 seats, yet this is the standard quota for each state:



```r
(240*usa1832)/sum(usa1832)
#>        NY        PA        VA        OH        NC        TN        KY 
#> 38.593472 27.117365 20.588444 18.866502 12.868936 12.577581 12.508564 
#>        MA        SC        GA        MD        ME        IN        NJ 
#> 12.278763  9.153131  8.645934  8.163802  8.035283  6.900297  6.435444 
#>        CT        VT        NH        AL        LA        IL        MO 
#>  5.987729  5.645602  5.417672  5.280523  3.457963  3.161116  2.623465 
#>        MS        RI        DE 
#>  2.219925  1.955122  1.517365
```

\  

NY should have received only 38 or 39 seats to satisfy the quota rule, but instead it received 40.   

Interestingly, according to [Balinski and Young’s Impossibility Theorem](http://en.wikipedia.org/wiki/Apportionment_paradox#Impossibility_result), it is not possible to come up with a perfect apporitonment system - there will always be quota rule violations or paradoxes but not both with any system.


\  

The quota rule violation can also be understood with this example of a fictitious country called Parador which has 5 states and needs to allocate 250 seats to its House.  Below I will show the populations of each state, the standard, lower and upper quotas and the results of Jefferson's Method using the built-in dataset `parador`.



```r

state = names(parador)
popn = parador
st.q = (250*parador)/sum(parador)
low.q = floor(st.q)
upp.q = ceiling(st.q)
seats = jefferson(parador, 250)

data.frame(state, popn, st.q, low.q, upp.q, seats)
#>   state    popn   st.q low.q upp.q seats
#> A     A 1646000  32.92    32    33    33
#> B     B 6936000 138.72   138   139   140
#> C     C  154000   3.08     3     4     3
#> D     D 2091000  41.82    41    42    42
#> E     E  685000  13.70    13    14    13
#> F     F  988000  19.76    19    20    19
```


\  

As can be seen, state B actually garners one extra seat that it should not do so according to the quota rule.  One of the major criticisms of the Jefferson Method is that it overly favors large states.

\  



**Notes about using the Jefferson Function**

There are two important issues to consider as regards the Jefferson Method function.

**1.** All the divisor methods utilize a 'trial-and-error' method to find a divisor that will correctly apportion the seats to the states based on relative population size.  For the `jefferson` function to work, there must therefore be a divisor that meets this criteria.     

The way I have programmed the `jefferson` function to search for this divisor is to begin with the initial divisor and then try smaller and smaller divisors (initial divisors are too large).   The user can adjust the increments by which the function searches for these divisors.  The default is set to `k=1` which means that the function will search for divisors by decreasing integer values one by one.   This works fine for examples such as those above when using large population sizes.  However, this might not be appropriate when using smaller initial values in groups.  In this case, it may be better to set `k` to a smaller value such that the function will search for divisors between integers.

\  

Here is an example:

> A teacher has 10 gold stars to divide between 6 students who are taking an exam.  The teachers says they will award the stars based on how many questions each student gets correct.



```r
answers <- c(1,4,5,14,16,3)
names(answers) <- paste0("Student ", LETTERS[1:6])
answers
#> Student A Student B Student C Student D Student E Student F 
#>         1         4         5        14        16         3


(10*answers)/sum(answers) #standard quotas
#> Student A Student B Student C Student D Student E Student F 
#> 0.2325581 0.9302326 1.1627907 3.2558140 3.7209302 0.6976744
```

\  

Let's try and apply the `jefferson` function with the default parameter setting for `k=1`:


```r

jefferson(answers,10)
#> Error in jefferson(answers, 10): have not found an appropriate divisor - try reducing 'k'
```


\   

This tells us that it was not able to find an appropriate divisor and that we should try reducing our value of `k`.



```r
jefferson(answers, 10, k=0.1)
#> Student A Student B Student C Student D Student E Student F 
#>         1         1         1         3         3         1
```


\   

Now, we are able to find a solution.  My suggestion for adjusting `k` is to gradually decrease it by one decimal place at a time.  

Here is another example. 

> In the country of Tecala, there are four states that wish to elect 160 seats to their house. The population of each state was 3.31, 2.67, 1.33 & 0.69 (in millions).

\  


```r
popn <- c(3.31, 2.67, 1.33, 0.69)
names(popn)<- c("Apure", "Barinas", "Carabobo", "Dolores")
popn
#>    Apure  Barinas Carabobo  Dolores 
#>     3.31     2.67     1.33     0.69


jefferson(popn, n=160) # 160 seats
#> Error in jefferson(popn, n = 160): have not found an appropriate divisor - try reducing 'k'
jefferson(popn, n=160, k=0.1) # 160 seats
#> Error in jefferson(popn, n = 160, k = 0.1): have not found an appropriate divisor - try reducing 'k'
jefferson(popn, n=160, k=0.01) # 160 seats
#> Error in jefferson(popn, n = 160, k = 0.01): have not found an appropriate divisor - try reducing 'k'
jefferson(popn, n=160, k=0.001) # 160 seats
#> Error in jefferson(popn, n = 160, k = 0.001): have not found an appropriate divisor - try reducing 'k'
jefferson(popn, n=160, k=0.0001) # 160 seats
#>    Apure  Barinas Carabobo  Dolores 
#>       67       54       26       13
```

\  

**2.** Allowing zero apportions.  It is possible to allow for zero apportions using `jefferson`'s sister function `jefferson0`. 

For instance, if the teacher in the example above did not feel that all students should get gold stars but only those who were deserving should get them, then we could allocate using `jefferson0`:


```r
jefferson0(answers, 10, k=0.1)
#> Student A Student B Student C Student D Student E Student F 
#>         0         1         1         4         4         0


jefferson(answers, 10, k=0.1)
#> Student A Student B Student C Student D Student E Student F 
#>         1         1         1         3         3         1
```


\  




### **Adams' Method** 

In 1832, former president John Quincy Adams essentially suggested an inverse method to Jefferson's Method.  This method was considered but never passed into law.  Essentially, this method operates identically to Jefferson's except that the rounding method used to determine representatives from the standard quota is a ceiling rounding (i.e. round the standard quota up).  This has the result of overly benefitting the smaller states and hence why it didn't receive much support.

Here is an example for the `adams` function for the 1832 House with a size of 240 seats.  The function is compared to the Hamilton and Jefferson Methods.



```r
usa1832
#>      NY      PA      VA      OH      NC      TN      KY      MA      SC 
#> 1918578 1348072 1023503  937901  639747  625263  621832  610408  455025 
#>      GA      MD      ME      IN      NJ      CT      VT      NH      AL 
#>  429811  405843  399454  343031  319922  297665  280657  269326  262508 
#>      LA      IL      MO      MS      RI      DE 
#>  171904  157147  130419  110358   97194   75432


adams(usa1832, 240)
#> NY PA VA OH NC TN KY MA SC GA MD ME IN NJ CT VT NH AL LA IL MO MS RI DE 
#> 37 26 20 18 13 12 12 12  9  9  8  8  7  7  6  6  6  6  4  4  3  3  2  2


rev(sort(jefferson(usa1832, 240))) #function doesn't automatically sort currently
#> NY PA VA OH TN NC KY MA SC GA ME MD IN NJ CT VT NH AL LA IL RI MS MO DE 
#> 40 28 21 19 13 13 13 12  9  9  8  8  7  6  6  5  5  5  3  3  2  2  2  1


hamilton(usa1832, 240)
#> NY PA VA OH NC TN KY MA SC GA MD ME IN NJ CT VT NH AL LA IL MO MS RI DE 
#> 39 27 21 19 13 13 12 12  9  9  8  8  7  6  6  6  5  5  3  3  3  2  2  2
```


\  



**Notes about using the Adams Function**

1. As with the `jefferson` and `jefferson0` functions, the `adams` function will automatically stop and return an error message if it cannot find an appropriate divisor.  It will encourage the user to use a smaller incremental for the 'trial-and-error' process of finding a divisor.

For example, say we had collected data on how many workers attended an office on each day of the week and we wanted to create a chart such as a [waffle chart](https://github.com/hrbrmstr/waffle) to visually represent this.  However, we wanted a nice rectangular chart that requires 100 percentage points to be allocated.  We could use the `adams` function.



```r

set.seed(111)
workers <- round(runif(7, 1, 1000))
names(workers) <- c("Mon", "Tues", "Weds", "Thurs", "Fri", "Sat", "Sun")
workers
#>   Mon  Tues  Weds Thurs   Fri   Sat   Sun 
#>   593   727   371   515   378   419    12

adams(workers)  #defaults are n=100, k=1
#> Error in adams(workers): have not found an appropriate divisor - try reducing 'k'


adams(workers, k=.1)
#>   Mon  Tues  Weds Thurs   Fri   Sat   Sun 
#>    19    24    12    17    13    14     1



waffle::waffle(adams(workers, k=.1), rows=5)
```

![](C:\Users\curley1\AppData\Local\Temp\RtmpmQWHes\preview-21b05dab213d.dir\my-vignette_files/figure-html/unnamed-chunk-39-1.png) 


\  


2. Like the Lowndes Method above, the Adams Method uses a rounding up method, so it is not possible to apportion zeros to groups.

\ 

------


### Note of Caution

This package is very much a work in progress. I am looking to improve functions to make them more generalizable as well as adding new functions. Please reach out if you have suggestions or are interested in this project.

\  

------



### Ideas for future

I'm keen to hear from anyone who has ideas for this project.  One vision I have is to generate map plots that visualize how different states have gained and lost representative seats over time.  I'd also like to map forecasts of how seats in the House may change given current population projections.


\  


------


### References and Further Reading

There are many online resources that describe the apportionment problem, here are some that are worthwhile:

- [Mathematical Association of America](http://www.maa.org/publications/periodicals/convergence/apportioning-representatives-in-the-united-states-congress-paradoxes-of-apportionment)
- [American Mathematical Association](http://www.ams.org/samplings/feature-column/fcarc-apportionii1)
- [The Mathematics of Apportionment](http://faculty.tcu.edu/epark/papers/Apportionment.pdf)

