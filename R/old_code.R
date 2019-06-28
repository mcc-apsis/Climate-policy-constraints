#Old code

```{r maps,echo=FALSE,warning=FALSE,fig.width=10,fig.path="Results/Plots/",dev=c('png','pdf')}
# 
# 
# mapdata <- left_join(world,ch,by=c("iso"="ISO"))
# # reverse direction of WGI indicators, for interpretability
# plmaps <- list()
# 
# for(i in 1:length(risk$vars)) {
#   
#   z <-  paste0("paste(", paste0('', c("region", "group"), collapse = ", "), ")")
#   
#   plmaps[[i]] <- mapdata %>% 
#     ggplot(.,aes_string("long","lat",group=z,fill=risk$vars[[i]])) +
#     geom_polygon(color="white") +
#     theme_minimal() +
#     theme(axis.title = element_blank(),axis.text = element_blank(),panel.border = element_rect(color='grey',fill='NA')) +
#     xlim(-180,180) +
#     coord_fixed(1) +
#     scale_fill_gradient(na.value = 'grey',high = "#132B43", low = "#56B1F7") +
#     theme(legend.position="bottom")
#   
#   rm(z)
#   
#   plot(plmaps[[i]])
# }
# 
# 
# summary_vars <- gather(ch,key,value,risk$vars) %>% 
#   group_by(key) %>% 
#   summarise_at("value",funs(n=sum(!is.na(.)),mean=mean(.),min=min(.),max=max(.)),na.rm=TRUE)
# 
# kable(summary_vars, format = "html", caption="Summary statistics",digits=1) %>%
#   kable_styling()
# 
# rm(plmaps,summary_vars)
```


#```{r jitters,echo=FALSE,warning=FALSE,fig.width=10,fig.height= 10,fig.path="Results/Plots/",dev=c('png','pdf')}

# cc <- pe %>% 
#   select(c("Country","ISO","Year",risk$vars,"committed_coal_planned")) %>%
#   mutate(committed_coal_planned=ifelse(committed_coal_planned>0,1,0)) %>% 
#   group_by(Country) %>% 
#   mutate_all(funs(na.locf(.,na.rm=FALSE))) %>% 
#   ungroup() %>% 
#   filter(Year==2015) %>% 
#   select(-Year) %>% 
#   filter(Country!="World")
# 
# 
# pl_jitt <- list()
# 
# for(i in 1:length(risk$vars)) {
#   
#   pl_jitt[[i]] <- cc %>%
#     mutate(committed_coal_planned=jitter(committed_coal_planned)) %>% 
#     ggplot(.,aes_string(x="committed_coal_planned",y=risk$vars[[i]],label="ISO")) +
#     geom_boxplot(aes(group = cut_width(committed_coal_planned,0.5)),width=0.25,outlier.shape = NA) +
#     geom_point()
#   
# }
# 
# do.call(grid.arrange,c(pl_jitt,ncol=2))
# 
# rm(cc,pl_jitt)
#```


#```{r ipcc_regions,echo=FALSE,warning=FALSE,fig.width=10,fig.height=8,fig.path="Results/Plots/",dev=c('png','pdf')}


### heterogeneity by exogenous region
# region="region_RCP5"
# 
# countries <- ch %>%
#   group_by_(region) %>%
#   summarise(countries=paste(Country, collapse=", "))
# 
# summary_regions <- ch %>% 
#   group_by_(region) %>% 
#   summarise_at(risk$vars,mean,na.rm=TRUE) %>% 
#   cbind(.,countries=countries$countries) %>% 
#   filter_at(region,any_vars(!is.na(.)))
# 
# gather(ch,key,value,risk$vars) %>% 
#   filter_at(region,any_vars(!is.na(.))) %>% 
#   ggplot(.,aes_string(x=region,y="value",fill=region)) +
#   geom_boxplot() +
#   facet_wrap(key ~., scales="free",switch="y",ncol=3) +
#   theme(axis.text.x=element_blank(),axis.title.x = element_blank(),axis.ticks.x = element_blank()) +
#   theme(axis.title.y = element_blank(),strip.text.y = element_text(size = 10)) +
#   theme(legend.position = "bottom",legend.title = element_blank()) +
#   guides(fill = guide_legend(nrow = 1,label.position = "bottom",keywidth = unit(1.25,"cm")))
# 
# 
# ##### transition bottlenecks
# load('Data\\remind.RData')
# 
# vars = c("Emissions|CO2","Policy Cost|Consumption Loss","Policy Cost|GDP Loss","Primary Energy|Coal","Primary Energy|Gas","Primary Energy|Oil","Primary Energy|Fossil","Subsidies|Energy|Fossil","Trade|Primary Energy|Coal|Volume","Trade|Primary Energy|Gas|Volume","Trade|Primary Energy|Oil|Volume","Population");
# 
# remind <- remind %>% 
#   filter(SCENARIO=="2C_Def") %>% 
#   mutate(REGION=replace(REGION,REGION=="R5ASIA","ASIA")) %>% 
#   mutate(REGION=replace(REGION,REGION=="R5LAM","LAM")) %>% 
#   mutate(REGION=replace(REGION,REGION=="R5MAF","MAF")) %>% 
#   mutate(REGION=replace(REGION,REGION=="R5OECD90+EU","OECD90")) %>% 
#   mutate(REGION=replace(REGION,REGION=="R5REF","REF")) %>% 
#   filter(VARIABLE %in% vars) %>% 
#   select(-MODEL,-SCENARIO,-UNIT) %>% 
#   filter(REGION!="World")
# 
# blarg <- gather(remind,year,value,'2015':'2100')
# blarg <- spread(blarg,VARIABLE,value)
# zz <- blarg %>% 
#   filter(year==2020 | year==2050) %>% 
#   group_by(REGION) %>% 
#   mutate(CO2_reduction_rate = nth(`Emissions|CO2`,1)/nth(`Emissions|CO2`,2))
#   
# blarg <- blarg %>% 
#   group_by(REGION) %>% 
#   summarise(consumption_loss=sum(`Policy Cost|Consumption Loss`)/sum(`Population`),
#             GDP_cost = sum(`Policy Cost|GDP Loss`)/sum(`Population`))
#   
# rm(countries,summary_regions,vars)
```




##########




##### import remind data

#library(openxlsx)
#remind <- read.xlsx('Data\\ERL_13_064038_SD_Scenario_data.xlsx','Scenario_data_R5')
#save(remind,file='Data/remind.RData')


######## V-Dem data


# vdem <-read.csv('Data/V-Dem/V-Dem-CY+Others-v8.csv')
# 
# vdem <- vdem %>% 
#   select(Country=country_name,ISO=country_text_id,year,democracy_electoral_vdem=v2x_polyarchy,corruption_public_vdem=v2excrptps) %>% 
#   filter(year>1950)
# 
# save(vdem,file='Data/vdem.RData')
# 

######### CC Laws

# laws <- read.csv('Data/CCLaws.csv',sep=',') %>% 
#   mutate(Country=tolower(Country))
# ISOs <- read.xlsx('C:/Users/lamw/Documents/SpiderOak Hive/Work/Code/R/.Place names and codes/output/ISOcodes.xlsx','alternative_names',encoding = 'UTF-8') %>% 
#   mutate(alternative.name=tolower(alternative.name))
# 
# laws <- left_join(laws,ISOs %>% select(alternative.name,alpha.3),by=c("Country"="alternative.name")) %>% 
#   select(Country,ISO=alpha.3,everything())

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
# laws <- laws[grep("^Adaptation*$",laws$Framework,invert=TRUE),]
# laws <- laws[grep("^(Adaptation)*$",laws$Categories,invert=TRUE),]
# laws <- laws[grep("^(Adaptation; Institutions / Administrative arrangements)*$",laws$Categories,invert=TRUE),]
# 
# 
# 
# ## aggregate
# laws <- laws %>% 
#   group_by(Country,ISO) %>% 
#   summarise(laws=n())
# 
# save(laws,file='Data/laws.RData')

############### join carbon pricing gap (OECD) ###############

# carbon_pricing <- read.xlsx('Data/OECD Carbon-pricing-gap-by-country-ecr2018.xlsx',sheetName='Carbon Pricing Gap - EUR 60',startRow=4,endRow = 46) %>% 
#   select(ISO=NA.,carbon_price_gap=X2015)
# pe <- left_join(pe,carbon_pricing,by=c("ISO"="ISO"))
# rm(carbon_pricing)

