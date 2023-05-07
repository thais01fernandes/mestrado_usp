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

file1 <- "https://raw.githubusercontent.com/thais01fernandes/mestrado_usp/main/dados/pib_2020"
munic_pib <- read_delim(file1, delim = ",", 
                        locale = locale(encoding='latin1'))


# Informações básicas municipais - População Municipal, estimativa de 2021 pelo IBGE 
# endereço: https://www.ibge.gov.br/estatisticas/sociais/populacao/9103-estimativas-de-populacao.html?=&t=downloads


file2 <- "https://raw.githubusercontent.com/thais01fernandes/mestrado_usp/main/dados/pop_munic"
munic_pop <- read_delim(file2, delim = ",", 
                        locale = locale(encoding='latin1'))

# Cidades com tarifa zero - levantamento produzido por pesquisadores do tema

ffpt_cities <- read_sheet(ss = "https://docs.google.com/spreadsheets/d/1UnKXflAf5RVRMhCL-FuroTsPZBy7am3qAmD5j_hXc3g/edit#gid=0", sheet = 1) 


# Base de dados sobre transporte público - IBGE, 2020
# endereço: https://www.ibge.gov.br/estatisticas/sociais/saude/10586-pesquisa-de-informacoes-basicas-municipais.html?=&t=downloads

file3 <- "https://raw.githubusercontent.com/thais01fernandes/mestrado_usp/main/dados/munic_transporte"
munic_transporte <- read_delim(file3, delim = ",", 
                               locale = locale(encoding='latin1')) 

                               
                               

# Área Territorial dos municípios, IBGE, 2022
# endereço: https://www.ibge.gov.br/geociencias/organizacao-do-territorio/estrutura-territorial/15761-areas-dos-municipios.html?=&t=downloads

file4 <- "https://raw.githubusercontent.com/thais01fernandes/mestrado_usp/main/dados/area_territorial"
area_territorial <- read_delim(file4, delim = ",",
                               locale = locale(encoding='latin1')) 

# Plano de mobilidade urbana - Levantamento conduzido pela SEMOB - última atualização 22/jan/2020
# endereço: https://antigo.mdr.gov.br/index.php?option=com_content&view=article&id=4398:levantamen

file5 <- "https://raw.githubusercontent.com/thais01fernandes/mestrado_usp/main/dados/plano_mob"
plano_mob <- read_delim(file5, delim = ",",
                        locale = locale(encoding='latin1'))

# Base do índice de vulnerabilidade econômica Produzido pelo IPEA
# Endereço: http://ivs.ipea.gov.br/index.php/pt/planilha 


file6 <- "https://raw.githubusercontent.com/thais01fernandes/mestrado_usp/main/dados/indice_ipea"
  indice_ipea <- read_delim(file6, delim = ",",
                          locale = locale(encoding='latin1'))

# Todos os seguintes dados foram baixados do pacote R "abjData": Índice de Desenvolvimento Humano Municipal (IDHM), índice de Gini e índice de Theil, IVS municipal, Índice de prosperidade social, População Urbana e Rural, Renda per Capta, % de pobres
# Os dados do índice de vulnerabilidade econômica foram retirados do site do ipea: http://ivs.ipea.gov.br/index.php/pt/planilha 
# Todos esses dados são referentes ao censo IBGE 2010
# Endereço: https://abjur.github.io/abjData/

# Tratamento na base de população que tem o código do município sem iniciar com o código da UF

munic_pop_2 <-
area_territorial %>% 
  select(CD_UF, NM_UF_SIGLA) %>% 
  rename(uf = NM_UF_SIGLA) %>% 
  left_join(munic_pop, by = "uf") %>% 
  select(CD_UF, cod_munic, nome_do_municipio, uf, populacao_estimada) %>% 
  unite("cod_munic", c(CD_UF,cod_munic), sep="") %>% 
  distinct(cod_munic, .keep_all = TRUE)  %>% 
  mutate(cod_munic = as.double(cod_munic))
  
  
# Juntando as bases, criando algumas variáveis novas e tratando a base final
  
banco_completo <- 
  munic_transporte %>% 
  select(-1, -2, -4, -5, -7) %>% 
  rename_with(.data = ., .cols = 1:80, 
              .fn = str_replace, pattern = ".*",
              replacement = str_c(c("cod_munic", "nome_muni", "regiao", "Caracterização do órgão gestor", "Sexo do(a) titular do órgão gestor", "Idade do(a) titular do órgão gestor", 
                                    "Cor/raça do(a) titular do órgão gestor", "Foi respondido pelo próprio titular do órgão gestor", "Escolaridade do(a) titular do órgão gestor", 
                                    "Plano Municipal de Transporte - existência", "A política de circulação viária e de transportes do município", 
                                    "A estrutura e a forma de organização do sistema de transporte de passageiros, bem como suas regras básicas de funcionamento", 
                                    "A política tarifária", "A estrutura, a forma de organização e as normas de utilização do espaço viário de uso público", 
                                    "O uso pelo pedestre e pelo ciclista do espaço viário de uso público", 	"A inclusão de pessoas com deficiência na rede viária e no sistema de transporte", 
                                    "Outros_1","O município realizou alguma Conferência Municipal de Transporte nos últimos 4 anos", 
                                    "Foram consideradas como elementos de referência para a elaboração e desenvolvimento do Plano Municipal de Transporte as deliberações das conferências realizadas", 
                                    "Conselho Municipal de Transporte - existência", "Ano de criação", "Formação do conselho", "Consultivo", "Deliberativo",  "Normativo","Fiscalizador", 
                                    "Quantidade de reuniões realizadas nos últimos 12 meses","Numero de conselheiros (titulares e suplentes)", "Periodicamente", "Ocasionalmente"	, "Não realiza", 
                                    "Município disponibiliza infraestrutura", "Sala", "Computador", "Impressora", "Acesso à internet", "Veiculo", "Telefone", "Diarias", "Dotação orçamentária própria", 
                                    "Fundo Municipal de Transporte - existência", "O conselho gestor do Fundo é o Conselho Municipal de Transporte", "O fundo tem financiado ações e projetos para questões do transporte nos últimos 12 meses", 
                                    "Barco", "Metro", "Mototaxi", "Taxi", "Trem", "Van", "Aviao", "Serviço por aplicativo", "Nenhum dos relacionados", "Transporte coletivo por ônibus intramunicipal", 
                                    "Concessão","Concedida através de licitação_1", "Permissão", "Concedida através de licitação_2", "Autorização","Serviço prestado diretamente pela prefeitura", 
                                    "Não regulamentado", "Maiores de 60/65 anos", "Estudantes da rede pública", "Estudantes da rede privada", "Carteiros", "Pessoas com deficiência", "Policiais", "Professores", 
                                    "Crianças menores de 5 anos", "Outros_2", "Toda a população", "Nenhum passageiro", "Frota de ônibus municipais adaptada para pessoas com deficiência ou mobilidade reduzida", "Piso baixo", 
                                    "Piso alto com acesso realizado por plataforma de embarque/desembarque", "Piso alto equipado com plataforma elevatória veicular", "Não sabe", "Transporte coletivo por ônibus intermunicipal", 
                                    "Este transporte coletivo atende também ao deslocamento entre bairros, distritos, localidades dentro do município", "Ciclovia no município","Bicicletário no município"))) %>% 
    left_join(ffpt_cities, by = c("cod_munic" = "Cod_IBGE")) %>% 
    mutate(tarifa_zero = case_when(tarifa_zero == "sim" ~ "sim", 
                                 TRUE ~ "não")) %>% 
    left_join(pnud_muni, by = c("cod_munic" =  "codmun7")) %>% 
    filter(ano == 2010) %>% 
    select(cod_munic, uf, tarifa_zero, ano_implementacao, regiao, `Caracterização do órgão gestor`, `Escolaridade do(a) titular do órgão gestor`, `Plano Municipal de Transporte - existência`, 
           `O município realizou alguma Conferência Municipal de Transporte nos últimos 4 anos`, `Conselho Municipal de Transporte - existência`,
           `Fundo Municipal de Transporte - existência`, `Transporte coletivo por ônibus intramunicipal`, `Transporte coletivo por ônibus intermunicipal`, 
           `Este transporte coletivo atende também ao deslocamento entre bairros, distritos, localidades dentro do município`, `Serviço prestado diretamente pela prefeitura`, 
           `Maiores de 60/65 anos`, `Estudantes da rede pública`, `Estudantes da rede privada`, Carteiros, `Pessoas com deficiência`, Policiais, Professores, 
           `Crianças menores de 5 anos`, `Toda a população`, `Nenhum passageiro`, `Ciclovia no município`,  rdpc, pesourb, pesorur, pesotot, theil, gini, idhm_r, idhm_l, idhm_e, idhm,	
           pmpob) %>% 
    left_join(munic_pop_2, by = "cod_munic") %>% 
    mutate(populacao_estimada = as.double(populacao_estimada)) %>% 
    mutate(classe_pop = case_when(populacao_estimada <= 5000 ~ "Up to 5.000", 
                                  populacao_estimada >= 5001 & populacao_estimada <= 10000 ~ "5.000 up to 10.000",
                                  populacao_estimada >= 10001 & populacao_estimada <= 20000 ~ "10.000 up to 20.000", 
                                  populacao_estimada >= 20001 & populacao_estimada <= 50000 ~ "20.000 up to 50.000", 
                                  populacao_estimada >= 50001 & populacao_estimada <= 100000 ~ "50.000 up to 100.000", 
                                  populacao_estimada >= 100001 & populacao_estimada <= 500000 ~ "100.000 up to 500.000",
                                  populacao_estimada >= 500001 ~ "Greater than 500.000", TRUE ~ "NA")) %>% 
    left_join(indice_ipea, by = c("cod_munic" = "Município")) %>% 
    left_join(area_territorial, by = c("cod_munic" = "CD_MUN")) %>% 
    left_join(munic_pib, by = c("cod_munic" = "codigo_do_municipio")) %>% 
    left_join(plano_mob, by = c("cod_munic" = "código do município - IBGE")) %>% 
    mutate(regiao = gsub(pattern = "1 -|2 -|3 -|4 -|5 -",replacement = "", regiao)) %>% clean_names() %>% 
    select(-38, -42:-43, -46:-47, -58:-63, -65:-102, -108:-111, -118) %>% 
    mutate(idhm_class = case_when(idhm > 0 & idhm <= 0.499 ~ "Very Low", 
                                idhm  >= 0.500 & idhm <= 0.599 ~ "Low", 
                                idhm  >= 0.600 & idhm <= 0.699 ~ "Medium", 
                                idhm  >= 0.700 & idhm <= 0.799 ~"High", 
                                idhm  >= 0.800 ~ "Very High", TRUE ~ "idhm")) %>% 
    mutate(idhm_r_class = case_when(idhm_r > 0 & idhm_r <= 0.499 ~ "Very Low", 
                                    idhm_r  >= 0.500 & idhm_r <= 0.599 ~ "Low", 
                                    idhm_r  >= 0.600 & idhm_r <= 0.699 ~ "Medium", 
                                    idhm_r  >= 0.700 & idhm_r <= 0.799 ~"High", 
                                    idhm_r  >= 0.800 ~ "Very High", TRUE ~ "idhm")) %>% 
    mutate(idhm_e_class = case_when(idhm_e > 0 & idhm_e <= 0.499 ~ "Very Low", 
                                    idhm_e  >= 0.500 & idhm_e <= 0.599 ~ "Low", 
                                    idhm_e  >= 0.600 & idhm_e <= 0.699 ~ "Medium", 
                                    idhm_e  >= 0.700 & idhm_e <= 0.799 ~"High", 
                                    idhm_e  >= 0.800 ~ "Very High", TRUE ~ "idhm")) %>% 
    mutate(idhm_l_class = case_when(idhm_l > 0 & idhm_l <= 0.499 ~ "Very Low", 
                                    idhm_l  >= 0.500 & idhm_l <= 0.599 ~ "Low", 
                                    idhm_l  >= 0.600 & idhm_l <= 0.699 ~ "Medium", 
                                    idhm_l  >= 0.700 & idhm_l <= 0.799 ~"High", 
                                    idhm_l  >= 0.800 ~ "Very High", TRUE ~ "idhm")) %>% 
    mutate(ivs_class = case_when(ivs >= 0 & ivs <= 0.200 ~ "Very Low", 
                                 ivs  >= 0.201 & ivs <= 0.300 ~ "Low", 
                                 ivs  >= 0.301 & ivs <= 0.400 ~ "Medium", 
                                 ivs  >= 0.401 ~"High", TRUE ~ "indice_ivs")) %>% 
    mutate(ivs_infra_urbana_class = case_when(ivs_infraestrutura_urbana >= 0 & ivs_infraestrutura_urbana <= 0.200 ~ "Very Low", 
                                              ivs_infraestrutura_urbana  >= 0.201 & ivs_infraestrutura_urbana <= 0.300 ~ "Low", 
                                              ivs_infraestrutura_urbana  >= 0.301 & ivs_infraestrutura_urbana <= 0.400 ~ "Medium", 
                                              ivs_infraestrutura_urbana  >= 0.401 ~"High",  TRUE ~ "indice_ivs")) %>% 
    mutate(ivs_renda_trab_class = case_when(ivs_renda_e_trabalho >= 0 & ivs_renda_e_trabalho <= 0.200 ~ "Very Low", 
                                            ivs_renda_e_trabalho  >= 0.201 & ivs_renda_e_trabalho <= 0.300 ~ "Low", 
                                            ivs_renda_e_trabalho  >= 0.301 & ivs_renda_e_trabalho <= 0.400 ~ "Medium", 
                                            ivs_renda_e_trabalho  >= 0.401 ~"High",  TRUE ~ "indice_ivs")) %>% 
    mutate(ivs_cap_class = case_when(ivs_capital_humano >= 0 & ivs_capital_humano <= 0.200 ~ "Very Low", 
                                     ivs_capital_humano  >= 0.201 & ivs_capital_humano <= 0.300 ~ "Low", 
                                     ivs_capital_humano  >= 0.301 & ivs_capital_humano <= 0.400 ~ "Medium", 
                                     ivs_capital_humano  >= 0.401 ~"High", TRUE ~ "indice_ivs")) %>% 
  mutate(taxa_urbanizacao = pesourb/pesotot) %>% 
  mutate(densidade_demografica = populacao_estimada/ar_mun_2022)
  

# Salvando o banco completo no Github pra ser usado no arquivo Rmarckdown que será usado para o relatório:

write.csv(banco_completo, "banco_completo")


