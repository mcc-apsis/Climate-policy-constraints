
rm(list = ls())
library(tidyverse)
library(xlsx)

##### import data from Matlab

file.copy('C:/Users/lamw/Documents/SpiderOak Hive/Work/Code/MATLAB/Data shop/Aggregation/Transition challenges/pe.xls','Data/',overwrite=TRUE)
pe<-read.xlsx('Data/pe.xls','data')

save(pe,file='Data/pe.RData')


##### import remind data

library(openxlsx)
remind <- read.xlsx('Data\\ERL_13_064038_SD_Scenario_data.xlsx','Scenario_data_R5')

save(remind,file='Data/remind.RData')


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

# merge, check consistency
RVS <- pe %>% 
  select(Country,ISO,Year,values_trust_sta) %>% 
  mutate_all(funs(na.locf(.,na.rm=FALSE)))
RVS <- left_join(RVS,EVS,by=c("Country"="S003"))
RVS <- left_join(RVS,LAVS,by=c("Country"="idenpa"))
RVS <- left_join(RVS,AVS,by=c("Country"="COUNTRY")) %>% 
  filter(Year==2015)

RVS <- RVS %>% 
  mutate(regional=ifelse(is.na(EVS_trust)==FALSE,EVS_trust,LAVS_trust)) %>% 
  mutate(regional=ifelse(is.na(AVS_trust)==FALSE,AVS_trust,regional)) %>% 
  mutate(trust=ifelse(is.na(regional)==FALSE,regional,values_trust_sta))

RVS %>% 
  ggplot(.,aes(x=regional,y=values_trust_sta)) +
  geom_point() +
  geom_abline(intercept=0,slope=1)
         
RVS %>%
  filter(!is.na(trust)) %>%
  arrange(desc(trust)) %>% 
  ggplot(.,aes(x=reorder(Country, trust),y=trust))+
  geom_bar(stat='identity') + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1,vjust=0.35))
  
save(RVS,file='Data/RVS.RData')
