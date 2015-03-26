##### Script for Extracting Census Population of Voting States

#http://en.wikipedia.org/wiki/List_of_U.S._states_by_historical_population

library(XML)
doc<-readHTMLTable("http://en.wikipedia.org/wiki/List_of_U.S._states_by_historical_population")
doc[[1]]
temp <- cbind(doc[[1]], doc[[2]], doc[[3]])
temp


temp1 <- as.character(temp[,1])
temp$state <- ifelse(grepl("\\[", temp1), substr(temp1, 1, nchar(temp1)-3), temp1)
temp$Name<-NULL; temp$Name<-NULL; temp$Name<-NULL #have to do it 3 times as there are 3 of them
temp2 <- temp[-52,]
temp2 <- temp2[-9,]
temp3 <- sapply(temp2, function(x) gsub(",","", x))

#remove non voting counts...
temp3[1,3:4] <- ""
temp3[4,4:6] <- ""
temp3[6,9:10] <- ""
temp3[9,6:7] <- ""
temp3[11,13:18] <- ""
temp3[12,10:11] <- ""
temp3[13,3:4] <- ""
temp3[14,3:4] <- ""
temp3[15,7] <- ""
temp3[16,9] <- ""
temp3[17,2] <- ""
temp3[18,4] <- ""
temp3[19,2:4] <- ""
temp3[22,3:6] <- ""
temp3[23,8] <- ""
temp3[24,3:4] <- ""
temp3[25,4:5] <- ""
temp3[26,10:11] <- ""
temp3[27,9] <- ""
temp3[28,9] <- ""
temp3[31,8:14] <- ""
temp3[34,10:11] <- ""
temp3[35,3] <- ""
temp3[36,12:13] <- ""
temp3[37,8] <- ""
temp3[41,9:11] <- ""
temp3[42,2] <- ""
temp3[44,8:12] <- ""
temp3[45,2] <- ""
temp3[47,8:11] <- ""
temp3[48,2:9] <- ""
temp3[49,5:7] <- ""
temp3[50,10:11] <- ""


temp4 <- as.data.frame(temp3)
temp5 <- cbind(temp4$state, temp4[,1:24])
temp5[temp5==""]  <- NA #blanks to NAs
colnames(temp5)[1]<-"state"

temp5[,3:25] <- apply(temp5[,3:25], 2, function(x) as.numeric(as.character(x)))
colnames(temp5)[2]<-"admitted"

temp5$admitted <- as.numeric(as.character(temp5$admitted))
temp5$state <- as.character(temp5$state)

str(temp5)

usa_census<-temp5

save(usa_census, file="usa_census.RData")
