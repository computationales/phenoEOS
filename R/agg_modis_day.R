
library(tidyverse)
library(dplyr)
library(lubridate)

setwd("/cluster/work/climate/bestocke/data/pep_pmodel_output/modis")

mod <- list.files(pattern = "*.rds") %>%
  map(readRDS) %>% 
  bind_rows() %>% 
  as_tibble() %>% 
  dplyr::select(-sitename)

# read phenology dates from MODIS
modis_pheno_sites <- readRDS("/cluster/home/lmarques/modis_pheno_sites.rds")
modis_pheno_sites <- modis_pheno_sites %>%
  select(sitename,year,lon,lat,SOS_2_doy) %>%
  rename(on=SOS_2_doy)

# join both datasets
df_modis <- modis_pheno_sites %>% 
  left_join(mod)

# Option cutoff
#daylength_cutoff <- 11.2
daylength_cutoff <- 10

df_out <- df_modis %>%
  mutate(Anet_pmodel = ifelse(!is.na(gpp) & (doy < on | daylength <= daylength_cutoff), 0, gpp)) %>%
  mutate(rd_pmodel = ifelse(!is.na(gpp) & (doy < on | daylength <= daylength_cutoff), 0, rd)) 

modis_check <- df_out[1:365,]
saveRDS(modis_check, "/cluster/home/lmarques/outputs_phenoEOS/modis_check_10h.rds")

df_modis_pmodel_Anet <- df_out %>% 
  group_by(sitename, lat, lon, year) %>% 
  summarise(
    Anet_pmodel = sum(Anet_pmodel),
    rd_pmodel = sum(rd_pmodel)
  ) 

saveRDS(df_modis_pmodel_Anet, "/cluster/home/lmarques/outputs_phenoEOS/modis_pmodel_Anet_10h.rds")
