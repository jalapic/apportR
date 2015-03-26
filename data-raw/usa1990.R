library(XML)
doc <- readHTMLTable("http://www.ctl.ua.edu/math103/apportionment/appo1990.htm#Apportionment of the U.S. House of Representatives using various apportionment methods and the 1990 census data.")
temp <- doc[[1]][1:50,]
usa1990 <- as.numeric(as.character(temp[,2]))
names(usa1990) <- as.character(temp[,1])
usa1990
