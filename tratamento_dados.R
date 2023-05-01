## O objetivo desse arquivo é produzir uma base de dados com informações coletadas a partir de dados públicos sobre todas cidades com política de tarifa zero

## pacotes 

library("tidyverse")
library("readxl")
library('googlesheets4')
library("janitor")
library ("abjData")

## Baixando os dados

# PIB - Os dados do PIB municipal foram baixandos do site do IBGE e são referentes a 2020
# endereço: https://www.ibge.gov.br/estatisticas/economicas/contas-nacionais/9088-produto-interno-bruto-dos-municipios.html?=&t=resultados

file1 <- "https://raw.githubusercontent.com/thais01fernandes/mestrado_usp/main/data/pib_2020"
munic_pib <- read_delim(file1, delim = ",", 
                        locale = locale(encoding='latin1'))


# Informações básicas municipais - População Municipal, estimativa de 2021 pelo IBGE 
# endereço: https://www.ibge.gov.br/estatisticas/sociais/populacao/9103-estimativas-de-populacao.html?=&t=downloads


file2 <- "https://raw.githubusercontent.com/thais01fernandes/mestrado_usp/main/data/pop_munic"
munic_pop <- read_delim(file2, delim = ",", 
                        locale = locale(encoding='latin1'))

# Cidades com tarifa zero - levantamento produzido por pesquisadores do tema

ffpt_cities <- read_sheet(ss = "https://docs.google.com/spreadsheets/d/1UnKXflAf5RVRMhCL-FuroTsPZBy7am3qAmD5j_hXc3g/edit#gid=0", sheet = 1)


# Base de dados sobre transporte público - IBGE, 2020
# endereço: https://www.ibge.gov.br/estatisticas/sociais/saude/10586-pesquisa-de-informacoes-basicas-municipais.html?=&t=downloads

file3 <- "https://raw.githubusercontent.com/thais01fernandes/mestrado_usp/main/data/munic_transporte"
munic_transporte <- read_delim(file3, delim = ",", 
                               locale = locale(encoding='latin1'))

# Área Territorial dos municípios 

file7 <- "https://raw.githubusercontent.com/thais01fernandes/Analises-Mestrado/main/area_territorial.csv"
area_territorial <- read_delim(file7, delim = ",") 


# Índice de Desenvolvimento Humano Municipal (IDHM) 
# índice de Gini
# IVS municipal

pnud_muni 

















