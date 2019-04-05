
rm(list = ls())
library(tidyverse)
library(xlsx)

##### import data from Matlab

file.copy('C:/Users/lamw/Documents/SpiderOak Hive/Work/Code/MATLAB/Data shop/Aggregation/Transition challenges/pe.xls','Data/',overwrite=TRUE)
pe<-read.xlsx('Data/pe.xls','data')
save(pe,file='Data/pe.RData')


##### import remind data

#library(openxlsx)
#remind <- read.xlsx('Data\\ERL_13_064038_SD_Scenario_data.xlsx','Scenario_data_R5')
#save(remind,file='Data/remind.RData')


##### Values Surveys
# European
library(foreign)
EVS <- foreign::read.dta("Data/European Values Survey.dta") %>% 
  select(S003,A165)
EVS$trust[grepl("Most people can be trusted",EVS$A165)] <- 1
EVS$trust[grepl("Can´t be too careful",EVS$A165)] <- 0
EVS <- EVS %>% 
  group_by(S003) %>% 
  summarise(EVS_trust=mean(trust,na.rm=T))

#Latin American
LAVS <- foreign::read.dta("Data/Latinobarometro2017Eng_v20180117.dta") %>% 
  select(idenpa,P13STGBS)
LAVS$trust[grepl("One can never be too careful when dealing with others",LAVS$P13STGBS)] <- 0
LAVS$trust[grepl("Most people can be trusted",LAVS$P13STGBS)] <- 1
LAVS <- LAVS %>% 
  group_by(idenpa) %>% 
  summarise(LAVS_trust=mean(trust,na.rm=T))

#African
AVS <- foreign::read.spss("Data/Afrobarometer.sav")
AVS <- data.frame(AVS) %>% 
  select(COUNTRY,Q87)
AVS$trust[grepl("Must be very careful",AVS$Q87)] <- 0
AVS$trust[grepl("Most people can be trusted",AVS$Q87)] <- 1
AVS <- AVS %>% 
  group_by(COUNTRY) %>% 
  summarise(AVS_trust=mean(trust,na.rm=T))

save(AVS,EVS,LAVS,file='Data/RVS.RData')


######## V-Dem data


vdem <-read.csv('Data/V-Dem/V-Dem-CY+Others-v8.csv')

vdem <- vdem %>% 
  select(Country=country_name,ISO=country_text_id,year,democracy_electoral_vdem=v2x_polyarchy,corruption_public_vdem=v2excrptps) %>% 
  filter(year>1950)

save(vdem,file='Data/vdem.RData')
