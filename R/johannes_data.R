
rm(list=ls())

library(tidyverse)
library(xlsx)


load('Data/pe.RData')

# iea <- pe %>% 
#   group_by(Country,Year) %>% 
#   select(Country,Year,ene_coal_tpes_IEA,ene_crude_tpes_IEA,ene_elec_tpes_IEA,ene_gas_tpes_IEA,ene_geo_tpes_IEA,
#          ene_hydro_tpes_IEA,ene_nuclear_tpes_IEA,ene_oil_tpes_IEA,ene_solar_wind_other_tpes_IEA,ene_tot_tpes_IEA)


bp <- openxlsx::read.xlsx('Data for Johannes/bp-stats-review-2019-consolidated-dataset-narrow-format.xlsx','Sheet1')
bp <- spread(bp,Var,Value)
bp <- bp %>% 
  filter(Country=="United Kingdom")

  jd <- pe %>% 
  select(country=Country,ISO,year=Year,region_UN6,pop_UN,gdp_ppp_WB,co2_terr_GCB,ene_coal_tpes_IEA,
         ene_tot_tpes_IEA,ene_tot_tfec_IEA,subsidy_pretax_IMF,subsidy_posttax_IMF,climate_laws_total=laws) %>% 
  filter(year>1989)


##########

laws <- read.csv('Data/CCLaws.csv',sep=',') %>%
  mutate(Country=tolower(Country))
ISOs <- read.xlsx('C:/Users/lamw/Documents/SpiderOak Hive/Work/Code/R/.Place names and codes/output/ISOcodes.xlsx','alternative_names',encoding = 'UTF-8') %>%
  mutate(alternative.name=tolower(alternative.name))

laws <- left_join(laws,ISOs %>% select(alternative.name,alpha.3),by=c("Country"="alternative.name")) %>%
  select(Country,ISO=alpha.3,everything())

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


############### join carbon pricing gap (OECD) ###############

carbon_pricing <- read.xlsx('Data/OECD Carbon-pricing-gap-by-country-ecr2018.xlsx',sheetName='Carbon Pricing Gap - EUR 60',startRow=4,endRow = 46) %>%
  select(ISO=NA.,carbon_price_gap=X2015)
jd <- left_join(jd,carbon_pricing,by=c("ISO"="ISO"))
rm(carbon_pricing)





save(jd,laws,file='Data for Johannes/data.Rdata')

openxlsx::write.xlsx(jd,file="Data for Johannes/all_data.xlsx",sheetName="data",row.names=FALSE)
openxlsx::write.xlsx(laws,file="Data for Johannes/laws.xlsx",sheetName="data",row.names=FALSE)


