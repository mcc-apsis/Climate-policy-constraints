
rm(list = ls())
library(tidyverse)
library(xlsx)

##### import data from Matlab

file.copy('C:/Users/lamw/Documents/SpiderOak Hive/Work/Code/MATLAB/Data shop/Aggregation/Transition challenges/pe.xls','Data/',overwrite=TRUE)
pe<-read.xlsx('Data/pe.xls','data')
save(pe,file='Data/pe.RData')

#load('Data/pe.RData')

############### join IMF fossil subsidies ###############

subsidy_a <- read.xlsx('Data/IMF_Fuel_Subsidies_short.xlsx',sheetName='Pre-tax',startRow=2,encoding="UTF-8",check.names=FALSE)
ISOs <- read.xlsx('C:/Users/lamw/Documents/SpiderOak Hive/Work/Code/R/.Place names and codes/output/ISOcodes.xlsx',sheetName='alternative_names')

subsidy_a <- left_join(subsidy_a %>% mutate(Country=tolower(Country)),ISOs
                       ,by=c("Country"="alternative.name")) %>% 
  select(alpha.3,everything()) %>% 
  filter(!is.na(alpha.3))

subsidy_a <- gather(subsidy_a,Year,subsidy_pretax_IMF,-Country,-alpha.3)

subsidy_b <- read.xlsx('Data/IMF_Fuel_Subsidies_short.xlsx',sheetName='Post-tax',startRow=2,encoding="UTF-8",check.names=FALSE)
ISOs <- read.xlsx('C:/Users/lamw/Documents/SpiderOak Hive/Work/Code/R/.Place names and codes/output/ISOcodes.xlsx',sheetName='alternative_names')

subsidy_b <- left_join(subsidy_b %>% mutate(Country=tolower(Country)),ISOs
                       ,by=c("Country"="alternative.name")) %>% 
  select(alpha.3,everything()) %>% 
  filter(!is.na(alpha.3))

subsidy_b <- gather(subsidy_b,Year,subsidy_posttax_IMF,-Country,-alpha.3)

subsidy <- left_join(subsidy_a,subsidy_b,by=c("alpha.3"="alpha.3","Year"="Year")) %>% mutate(Year=as.numeric(Year))

pe <- left_join(pe,subsidy,by=c("ISO"="alpha.3","Year"="Year"))

############### join SWIID ###############

#load('C:\\Users\\lamw\\Documents\\SpiderOak Hive\\Work\\Code\\R\\Database\\SWIID\\SWIID.RData')
#pe <- left_join(pe,swiid_summary %>% select(ISO,year,gini_disp),by=c("ISO"="ISO","Year"="year"))
#rm(swiid_summary)

############### join regional values surveys ###############

load('Data/WVS.RData')

pe <- left_join(pe,WVS %>% select(ISO,trust_first,trust_last),by=c("ISO"="ISO"))
rm(WVS)

############### join vdem ############### 

load('Data/vdem.RData')
pe <- left_join(pe,vdem %>% select(-Country),by=c("ISO"="ISO","Year"="year"))
rm(vdem)

############### join laws ############### 

load('Data/laws.RData')
pe <- left_join(pe,laws %>% ungroup %>% select(-Country),by=c("ISO"="ISO"))
rm(laws)

############### join Gallup ############### 

gallup <- read.xlsx('Data/GallupData3.xlsx',sheetName = 'CombinedData')
gallup <- left_join(gallup %>% mutate(Country=tolower(Country)),ISOs,by=c("Country"="alternative.name")) %>% 
  select(alpha.3,climate_aware = AWARE_C,climate_human = HUMAN_C) %>% 
  filter(climate_aware!=0,climate_human!=0) %>% 
  mutate(Year=2008)

pe <- left_join(pe,gallup,by=c("ISO"="alpha.3","Year"="Year"))


save(pe,file='Data/pe.RData')


