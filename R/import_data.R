
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


######## V-Dem data


vdem <-read.csv('Data/V-Dem/V-Dem-CY+Others-v8.csv')

vdem <- vdem %>% 
  select(Country=country_name,ISO=country_text_id,year,democracy_electoral_vdem=v2x_polyarchy,corruption_public_vdem=v2excrptps) %>% 
  filter(year>1950)

save(vdem,file='Data/vdem.RData')


######### CC Laws

laws <- read.csv('Data/CCLaws.csv',sep=',') %>% 
  mutate(Country=tolower(Country))
ISOs <- read.xlsx('C:/Users/lamw/Documents/SpiderOak Hive/Work/Code/R/.Place names and codes/output/ISOcodes.xlsx','alternative_names',encoding = 'UTF-8') %>% 
  mutate(alternative.name=tolower(alternative.name))

laws <- left_join(laws,ISOs %>% select(alternative.name,alpha.3),by=c("Country"="alternative.name")) %>% 
  select(Country,ISO=alpha.3,everything())

### plot ###
# ISOs2 <- read.xlsx('C:/Users/lamw/Documents/SpiderOak Hive/Work/Code/R/.Place names and codes/output/ISOcodes.xlsx','ISO_master',encoding = 'UTF-8') %>% 
#   select(alpha.3,region)
# library(gridExtra)
# laws <- left_join(laws,ISOs2,by=c("ISO"="alpha.3"))
# plots <- list()
# 
# plots[[1]] <- laws %>% 
#   filter(grepl("Law|Plan|Policy|Strategy",Document.Type)) %>% 
#   group_by(Year.Passed,Document.Type) %>%
#   summarise(no.laws=n()) %>% 
#   ggplot(.,aes(x=Year.Passed,y=no.laws,fill=Document.Type)) +
#   geom_bar(stat='identity')+
#   xlim(1990,2018)
# 
# plots[[2]] <- laws %>% 
#   filter(grepl("Law|Plan|Policy|Strategy",Document.Type)) %>% 
#   group_by(Year.Passed,region) %>%
#   summarise(no.laws=n()) %>% 
#   ggplot(.,aes(x=Year.Passed,y=no.laws,fill=region)) +
#   geom_bar(stat='identity')+
#   xlim(1990,2018)
# 
# do.call(grid.arrange,c(plots,ncol=1))

# remove frameworks
# laws <- laws %>% 
#   filter(!grepl("Mitigation and adaptation",Framework)) %>% 
#   filter(!grepl("mitigation and adaptation",Framework)) %>% 
#   filter(!grepl("Mitigation",Framework)) %>% 
#   filter(!grepl("Adaptation",Framework)) %>% 
#   filter(!grepl("mitigation",Framework))

# remove adaptation only laws
laws <- laws[grep("^Adaptation*$",laws$Framework,invert=TRUE),]
laws <- laws[grep("^(Adaptation)*$",laws$Categories,invert=TRUE),]
laws <- laws[grep("^(Adaptation; Institutions / Administrative arrangements)*$",laws$Categories,invert=TRUE),]



## aggregate
laws <- laws %>% 
  group_by(Country,ISO) %>% 
  summarise(laws=n())

save(laws,file='Data/laws.RData')
