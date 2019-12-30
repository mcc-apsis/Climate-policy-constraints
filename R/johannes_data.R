
rm(list=ls())

library(tidyverse)


load('Data/pe.RData')

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

# remove frameworks (nope don't do this)
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


save(jd,laws,file='Data for Johannes/data.Rdata')

openxlsx::write.xlsx(jd,file="Data for Johannes/all_data.xlsx",sheetName="data",row.names=FALSE)
openxlsx::write.xlsx(laws,file="Data for Johannes/laws.xlsx",sheetName="data",row.names=FALSE)


############### join carbon pricing gap (OECD) ###############

# carbon_pricing <- read.xlsx('Data/OECD Carbon-pricing-gap-by-country-ecr2018.xlsx',sheetName='Carbon Pricing Gap - EUR 60',startRow=4,endRow = 46) %>%
#   select(ISO=NA.,carbon_price_gap=X2015)
# pe <- left_join(pe,carbon_pricing,by=c("ISO"="ISO"))
# rm(carbon_pricing)
