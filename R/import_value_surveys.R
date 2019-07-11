##### Values Surveys
rm(list=ls())

library(tidyverse)
library(foreign)
library(xlsx)
library(reshape2)

# World

WVS <- read_rds('Data/WVS/WVS_Longitudinal_1981_2016_r_v20180912.rds')
WVS <- WVS %>% 
  select(S003,trust=A165,wave=S002)
WVS$trust[WVS$trust == 2] <- 0     #"Can't be too careful"
WVS$trust[WVS$trust == -2] <- NA   

ISOs <- read.xlsx('C:/Users/lamw/Documents/SpiderOak Hive/Work/Code/R/.Place names and codes/output/ISOcodes.xlsx','ISO_master',encoding = 'UTF-8')
WVS <- left_join(WVS,ISOs <- ISOs %>% select(Country,Code,numeric.code),by=c("S003"="numeric.code"))

WVS <- WVS %>% 
  select(-S003,trust) %>% 
  filter(trust>=0)

WVS <- WVS %>% 
  group_by(Country,ISO=Code,wave) %>% 
  summarise(WVS_trust=mean(trust,na.rm=T))

WVS$wave[WVS$wave==1] <- '1981-1984'
WVS$wave[WVS$wave==2] <- '1990-1994'
WVS$wave[WVS$wave==3] <- '1995-1998'
WVS$wave[WVS$wave==4] <- '1999-2004'
WVS$wave[WVS$wave==5] <- '2005-2008'
WVS$wave[WVS$wave==6] <- '2010-2012'

WVS <- dcast(WVS,Country + ISO~wave,value.var='WVS_trust')


# European

EVS <- foreign::read.dta("Data/WVS/European Values Survey.dta")
EVS <- EVS %>% 
  select(name=S003,wave=S002EVS,A165)
EVS$trust[grepl("Most people can be trusted",EVS$A165)] <- 1
EVS$trust[grepl("Can´t be too careful",EVS$A165)] <- 0

EVS <- EVS %>% 
  filter(trust>=0) %>% 
  group_by(name,wave) %>% 
  summarise(EVS_trust=mean(trust,na.rm=T))

EVS <- dcast(EVS,name~wave,value.var='EVS_trust')

ISOs <- read.xlsx('C:/Users/lamw/Documents/SpiderOak Hive/Work/Code/R/.Place names and codes/output/ISOcodes.xlsx','alternative_names',encoding = 'UTF-8') %>% 
  select(ISO=alpha.3,alternative.name) %>%
  mutate(alternative.name=tolower(alternative.name))

EVS <- EVS %>% 
  mutate(name=tolower(name))
EVS <- left_join(EVS,ISOs,by=c("name"="alternative.name"))


#Latin American
LAVS <- foreign::read.dta("Data/WVS/Latinobarometro2017Eng_v20180117.dta") %>% 
  select(name=idenpa,P13STGBS)
LAVS$trust[grepl("One can never be too careful when dealing with others",LAVS$P13STGBS)] <- 0
LAVS$trust[grepl("Most people can be trusted",LAVS$P13STGBS)] <- 1

LAVS <- LAVS %>% 
  filter(trust>=0) %>% 
  group_by(name) %>% 
  summarise('2017'=mean(trust,na.rm=T))
LAVS <- LAVS %>% 
  mutate(name=tolower(name))
LAVS <- left_join(LAVS,ISOs,by=c("name"="alternative.name"))

# Latinobarometer trust question goes back to 1996, but coded differently each year ugh


#African
AVS <- foreign::read.spss("Data/WVS/Afrobarometer_r6.sav")
AVS <- data.frame(AVS) %>% 
  select(name=COUNTRY,Q87)
AVS$trust[grepl("Must be very careful",AVS$Q87)] <- 0
AVS$trust[grepl("Most people can be trusted",AVS$Q87)] <- 1
AVS <- AVS %>% 
  filter(trust>=0) %>% 
  group_by(name) %>% 
  summarise('2016'=mean(trust,na.rm=T))

##
AVS_2 <- foreign::read.spss("Data/WVS/Afrobarometer_r1.sav")
AVS_2 <- data.frame(AVS_2) %>% 
  select(country,sctrust)
AVS_2$trust[grepl("You must be very careful",AVS_2$sctrust)] <- 0
AVS_2$trust[grepl("Most people can be trusted",AVS_2$sctrust)] <- 1
AVS_2 <- AVS_2 %>% 
  filter(trust>=0) %>% 
  group_by(country) %>% 
  summarise('1999-2001'=mean(trust,na.rm=T))

AVS <- left_join(AVS,AVS_2,by=c("name"="country"))
rm(AVS_2)

AVS <- AVS %>% 
  mutate(name=tolower(name))
AVS <- left_join(AVS,ISOs,by=c("name"="alternative.name"))


##########
blarg <- full_join(WVS %>% select(-Country),EVS %>% select(-name),by=c('ISO'='ISO'))
blarg <- full_join(blarg,AVS %>% select(-name),b=c('ISO'='ISO'))
blarg <- full_join(blarg,LAVS %>% select(-name),by=c('ISO'='ISO'))

#blarg <- blarg %>% 
#  select(ISO,`1981-1984.x`,`1981-1984.y`)

blarg <- blarg %>% 
  mutate(`1981-1984`=ifelse(is.na(`1981-1984.y`),`1981-1984.x`,`1981-1984.y`)) %>% 
  select(-`1981-1984.x`,-`1981-1984.y`)

#blarg <- blarg %>% 
 # select(ISO,`1999-2001.x`,`1999-2001.y`)

blarg <- blarg %>% 
  mutate(`1999-2001`=ifelse(is.na(`1999-2001.y`),`1999-2001.x`,`1999-2001.y`)) %>% 
  select(-`1999-2001.x`,-`1999-2001.y`)

blarg <- gather(blarg,key="wave",value="value",-one_of('ISO'))
blarg <- blarg %>% 
  filter(!is.na(ISO))

WVS <- blarg

WVS <- WVS %>%
  arrange(ISO,wave) %>% 
  filter(!is.na(value))

WVS <- WVS %>%
  group_by(ISO) %>% 
  summarise(trust_first=first(value),trust_last=last(value),first_year=first(wave),last_year=last(wave))


save(WVS,file='Data/WVS.RData')
