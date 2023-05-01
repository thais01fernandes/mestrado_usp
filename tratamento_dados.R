## pacotes 

library("tidyverse")
library("readxl")
library('googlesheets4')
library("janitor")

## Baixando os dados


pib <- read_excel("PIB dos Municípios - base de dados 2010-2020.xls")

pib_2020 <-pib %>% 
  clean_names() %>% 
  filter(ano == 2020) 

write.csv(pib_2020, "pib_2020")
 