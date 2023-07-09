## O objetivo desse arquivo é produzir uma base de dados com informações coletadas a partir de dados públicos sobre todas cidades com política de tarifa zero

## pacotes 

library("tidyverse")
library("readxl")
library('googlesheets4')
library("janitor")
library ("abjData")
library("geobr")
library("dplyr")
library("tidyr")
library("purrr")

## Baixando os dados

# PIB - Os dados do PIB municipal foram baixandos do site do IBGE e são referentes a 2020
# endereço: https://www.ibge.gov.br/estatisticas/economicas/contas-nacionais/9088-produto-interno-bruto-dos-municipios.html?=&t=resultados

file1 <- "https://raw.githubusercontent.com/thais01fernandes/mestrado_usp/main/dados/pib_2020"
munic_pib <- read_delim(file1, delim = ",", 
                        locale = locale(encoding='latin1'))


# Resultados do Censo 2022, População coletada e população imputada, por município
# endereço: https://www.ibge.gov.br/estatisticas/sociais/populacao/22827-censo-demografico-2022.html?edicao=37225&t=resultados


file2 <- "https://raw.githubusercontent.com/thais01fernandes/mestrado_usp/main/dados/pop_munic.csv"
munic_pop <- read_delim(file2, delim = ";", 
                        locale = locale(encoding='UTF-8')) %>% filter(!is.na(uf))


# Cidades com tarifa zero - levantamento produzido por pesquisadores do tema

ffpt_cities <- read_sheet(ss = "https://docs.google.com/spreadsheets/d/1UnKXflAf5RVRMhCL-FuroTsPZBy7am3qAmD5j_hXc3g/edit#gid=0", sheet = "Codigo IBGE") 


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
  
# Base de Recursos Humanos da Base de Informações Municipais de 2021
# Endereço: https://www.ibge.gov.br/estatisticas/sociais/saude/10586-pesquisa-de-informacoes-basicas-municipais.html?=&t=downloads
  
  
file7 <- "https://raw.githubusercontent.com/thais01fernandes/mestrado_usp/main/dados/recursos_humanos"
  recursos_humanos <- read_delim(file7, delim = ",",
                                 locale = locale(encoding='latin1'))
  
## Base de dados de estatísticas eleitorais do TSE - Eleições Anteriores
# Endereço: https://www.tse.jus.br/eleicoes/eleicoes-anteriores 
  
  
  file8 <- "https://raw.githubusercontent.com/thais01fernandes/mestrado_usp/main/dados/votacao_1996"
  votacao_1996 <- read_delim(file8, delim = ",", 
                             locale = locale(encoding='latin1')) %>% select(-1)

  
  file9 <- "https://raw.githubusercontent.com/thais01fernandes/mestrado_usp/main/dados/votacao_2000"
  votacao_2000 <- read_delim(file9, delim = ",", 
                                locale = locale(encoding='latin1')) %>% select(-1) 
  
  file10 <- "https://raw.githubusercontent.com/thais01fernandes/mestrado_usp/main/dados/votacao_2004"
  votacao_2004 <- read_delim(file10, delim = ",", 
                                locale = locale(encoding='latin1')) %>% select(-1)
  
  file11 <- "https://raw.githubusercontent.com/thais01fernandes/mestrado_usp/main/dados/votacao_2008"
  votacao_2008 <- read_delim(file11, delim = ",", 
                                locale = locale(encoding='latin1')) %>% select(-1)
  
  file12 <- "https://raw.githubusercontent.com/thais01fernandes/mestrado_usp/main/dados/eleicoes_2012"
  votacao_2012 <- read_delim(file12, delim = ";", 
                                locale = locale(encoding='latin1')) %>% select(-1)  %>% mutate(SG_UE = as.character(SG_UE), 
                                                                                               CD_MUNICIPIO = as.character(CD_MUNICIPIO)) 
  
  file13 <- "https://raw.githubusercontent.com/thais01fernandes/mestrado_usp/main/dados/votacao_2016"
  votacao_2016 <- read_delim(file13, delim = ",", 
                                locale = locale(encoding='latin1')) %>% select(-1) 
  
  file14 <- "https://raw.githubusercontent.com/thais01fernandes/mestrado_usp/main/dados/votacao_2020"
  votacao_2020 <- read_delim(file14, delim = ",", 
                                locale = locale(encoding='latin1')) %>% select(-1)

  tarifa_zero_tse <- read_sheet(ss = "https://docs.google.com/spreadsheets/d/1UnKXflAf5RVRMhCL-FuroTsPZBy7am3qAmD5j_hXc3g/edit#gid=0", sheet = 2)   ## cidades com tarifa zero com o código TSE
  

# Todos os seguintes dados foram baixados do pacote R "abjData": Índice de Desenvolvimento Humano Municipal (IDHM), índice de Gini e índice de Theil, IVS municipal, Índice de prosperidade social, População Urbana e Rural, Renda per Capta, % de pobres
# Os dados do índice de vulnerabilidade econômica foram retirados do site do ipea: http://ivs.ipea.gov.br/index.php/pt/planilha 
# Todos esses dados são referentes ao censo IBGE 2010
# Endereço: https://abjur.github.io/abjData/


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
    left_join(munic_pop, by = "cod_munic") %>% 
    mutate(populacao = as.double(populacao)) %>% 
    mutate(classe_pop = case_when(populacao <= 5000 ~ "Up to 5.000", 
                                  populacao >= 5001 & populacao <= 10000 ~ "5.000 up to 10.000",
                                  populacao >= 10001 & populacao <= 20000 ~ "10.000 up to 20.000", 
                                  populacao >= 20001 & populacao <= 50000 ~ "20.000 up to 50.000", 
                                  populacao >= 50001 & populacao <= 100000 ~ "50.000 up to 100.000", 
                                  populacao >= 100001 & populacao <= 500000 ~ "100.000 up to 500.000",
                                  populacao >= 500001 ~ "Greater than 500.000", TRUE ~ "NA")) %>% 
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
  mutate(densidade_demografica = populacao/ar_mun_2022) %>% 
  left_join(recursos_humanos, by = c("cod_munic" = "CodMun")) %>% 
  select(-75:-81, -88:-94) %>% 
  rename(Estatutarios = Mreh0111, 
         Celetistas = Mreh0112, 
         Comissionados = Mreh0113, 
         Estagiarios = Mreh0114, 
         sem_vinculo_permanente = Mreh0115) %>% 
  mutate(ano_implementacao_classe = case_when(ano_implementacao <= 1998 ~ "Anos 90", 
                                              ano_implementacao >= 2001 & ano_implementacao  <= 2009 ~ "Entre 2001 e 2009",
                                              ano_implementacao >= 2010 & ano_implementacao <= 2015 ~  "Entre 2010 e 2015", 
                                              ano_implementacao >= 2016 & ano_implementacao <= 2020 ~  "Entre 2016 e 2020", 
                                              ano_implementacao >= 2021  ~ "Entre 2021 e 2022", 
                                              TRUE ~ "NA"))

  

# Salvando o banco completo no Github pra ser usado no arquivo Rmarckdown que será usado para o relatório:

write.csv(banco_completo, "banco_completo")


# ----------------------------------------------------------------------------

## Tratamento dos dados Eleitorais para a análise "Teoria do Eleitor Mediano":


dados_Votacao <- bind_rows(votacao_2000, votacao_2004, votacao_2008, votacao_2012, votacao_2016, votacao_2020) %>% 
  select(3,6, 11, 14, 15, 21, 30, 38) %>% 
  group_by(ANO_ELEICAO, NM_MUNICIPIO, CD_MUNICIPIO, SG_PARTIDO, NR_TURNO) %>% 
  summarize(votos_nominais = sum(QT_VOTOS_NOMINAIS)) %>% 
  ungroup()


munic_segundo_turno_usar <- dados_Votacao %>%  filter(NR_TURNO == 2) %>% 
  group_by(ANO_ELEICAO, CD_MUNICIPIO) %>% 
  mutate(pct = votos_nominais/sum(votos_nominais)*100) %>% 
  mutate(pct = round(pct, digits = 1)) %>% 
  ungroup()

# Tirar do banco completo o 1° turno dos municipios que tiveram 2° turno

munic_segundo_turni_nao_usar <- munic_segundo_turno_usar %>% select (1,3) %>% 
  group_by(ANO_ELEICAO, CD_MUNICIPIO) %>% 
  tally() %>% 
  select(-n)  

# Juntando os municípios com 2° turno

dados_votacao_completo <- dados_Votacao %>% 
  anti_join(munic_segundo_turni_nao_usar) %>% 
  group_by(ANO_ELEICAO, CD_MUNICIPIO) %>% 
  mutate(pct = votos_nominais/sum(votos_nominais)*100) %>% 
  mutate(pct = round(pct, digits = 1)) %>% 
  ungroup() %>% 
  bind_rows(munic_segundo_turno_usar)

# Selecionando os eleitos

candidatos_eleitos <- dados_votacao_completo %>%  
  group_by(ANO_ELEICAO, CD_MUNICIPIO) %>% 
  slice_max(votos_nominais) %>% 
  mutate(Situacao= "Eleito") %>% 
  ungroup()

# Selecionando o 2° colocado  

candidatos_segundo_lugar <- dados_votacao_completo %>% 
  anti_join(candidatos_eleitos, by = c("ANO_ELEICAO", "CD_MUNICIPIO", "pct")) %>% 
  group_by(ANO_ELEICAO, CD_MUNICIPIO) %>% 
  slice_max(votos_nominais) %>% 
  mutate(Situacao = "Segundo lugar") %>% 
  ungroup()

candidatos_eleitos_1 <- candidatos_eleitos %>% 
  pivot_wider(names_from = Situacao, values_from = pct)

candidatos_segundo_lugar_1 <- candidatos_segundo_lugar %>% 
  pivot_wider(names_from = Situacao, values_from = pct) 

# Juntando Candidatos Eleitos e 2° lugar e fazendo o cálculo da diferença entre a % de votos


eleicoes <- candidatos_eleitos_1 %>% 
  left_join(candidatos_segundo_lugar_1, by = c("ANO_ELEICAO", "CD_MUNICIPIO")) %>% 
  select(1, 2, 3, 4, 5, 7, 9, 12 ) %>% 
  rename(partido_candidato_eleito = SG_PARTIDO.x, partido_segundo_lugar = SG_PARTIDO.y) %>% 
  group_by(ANO_ELEICAO, CD_MUNICIPIO) %>% 
  mutate(diferenca_votos = last(Eleito) - first(`Segundo lugar`)) %>% 
  ungroup()

# Identificando as cidades com tarifa zero 

cidades_tarifa_zero <- tarifa_zero_tse %>% 
  select(CD_MUNICIPIO, tarifa_zero) %>% 
  mutate(CD_MUNICIPIO = as.character(CD_MUNICIPIO))  

eleicoes_quase <- eleicoes %>% 
  left_join(cidades_tarifa_zero, by = "CD_MUNICIPIO") %>% 
  filter(CD_MUNICIPIO !=  "79430" | 
           partido_candidato_eleito != "PMDB" |
           ANO_ELEICAO != 2008 | 
           partido_segundo_lugar != "PSDC") %>% 
  rename(nome_munic = NM_MUNICIPIO.x, turno_eleicao = NR_TURNO.x) %>% 
  select(CD_MUNICIPIO, nome_munic, ANO_ELEICAO, turno_eleicao, tarifa_zero, 
         partido_candidato_eleito, partido_segundo_lugar, Eleito, `Segundo lugar`, diferenca_votos) %>% 
  distinct(CD_MUNICIPIO, nome_munic, ANO_ELEICAO, turno_eleicao, partido_candidato_eleito, partido_segundo_lugar, .keep_all = TRUE)

# Tiramos  os municípios em que a votaçao deu empate no 1° turno e não há informação do 2° turno dessas cidades no banco de dados do TSE
# São 57 cidades: 3 das eleicoes de 2000, 39 de 2004, 2 de 2008, 8 de 2012, 2 de 2016 e 3 de 2020. 

cidades_empate <- eleicoes_quase %>% 
  group_by(CD_MUNICIPIO, ANO_ELEICAO) %>% 
  tally() %>% 
  filter(n == 2) %>% 
  select(-n)

eleicoes_1 <- eleicoes_quase %>% 
  anti_join(cidades_empate) 


# Salvando o banco de dados no Git hub: 

# write.csv(eleicoes_1, "eleicoes_1")


# ----------------------------------------------------------------------------------------

## Tratamento dos dados Eleitorais para a análise "Teoria dos Multiplos Fluxos": 

dados_votacao_completo_2 <- eleicoes_1 %>% 
  filter(tarifa_zero == "sim") %>% 
  select(CD_MUNICIPIO,ANO_ELEICAO, partido_candidato_eleito) %>% 
  rename(SG_PARTIDO = partido_candidato_eleito)

nome_cidades <- eleicoes_1 %>% 
  filter(tarifa_zero == "sim") %>% 
  distinct(CD_MUNICIPIO, .keep_all = TRUE) %>% 
  select(CD_MUNICIPIO, nome_munic)

filtrar_pivotar_anos <- function(ano) {
  dados_votacao_completo_2 %>%
    filter(ANO_ELEICAO == ano) %>%
    pivot_wider(names_from = ANO_ELEICAO, values_from = SG_PARTIDO)
}


anos_eleicao <- c(2000, 2004, 2008, 2012, 2016, 2020)

resultados <- map(anos_eleicao, filtrar_pivotar_anos)


eleicao_2000 <- resultados[[1]] 
eleicao_2004 <- resultados[[2]] 
eleicao_2008 <- resultados[[3]] 
eleicao_2012 <- resultados[[4]] 
eleicao_2016 <- resultados[[5]]
eleicao_2020 <- resultados[[6]]

# Juntando as bases 

eleicoes_quase_pronto <- eleicao_2000 %>% 
  left_join(eleicao_2004, by = c("CD_MUNICIPIO")) %>% 
  left_join(eleicao_2008, by = c("CD_MUNICIPIO")) %>% 
  left_join(eleicao_2012, by = c("CD_MUNICIPIO")) %>% 
  left_join(eleicao_2016, by = c("CD_MUNICIPIO")) %>% 
  left_join(eleicao_2020, by = c("CD_MUNICIPIO")) %>% 
  left_join(nome_cidades, by = c("CD_MUNICIPIO")) %>% 
  clean_names() %>% 
  mutate(nome_munic = str_to_title(nome_munic)) %>% 
  select(nome_munic, cd_municipio, x2000, x2004, x2008, x2012, x2016, x2020)

colunas <- c("x2000", "x2004", "x2008", "x2012", "x2016", "x2020")

eleicoes_quase_pronto_2 <- eleicoes_quase_pronto %>%
  mutate(across(all_of(colunas), ~case_when(
    . == "PMDB" ~ "Centro",
    . == "PDT" ~ "Centro Esquerda",
    . == "PPB" ~ "Direita",
    . == "PSB" ~ "Esquerda",
    . == "PTB" ~ "Centro Direita",
    . == "PFL" ~ "Direita",
    . == "PSDB" ~ "Centro",
    . == "PT" ~ "Esquerda",
    . == "PMN" ~ "Direita",
    . == "PV" ~ "Esquerda",
    . == "PL" ~ "Direita",
    . == "PPS" ~ "Centro Esquerda",
    . == "PST" ~ "Direita",
    . == "PSD" ~ "Centro Direita",
    . == "PSC" ~ "Extrema Direita",
    . == "PRP" ~ "Direita",
    . == "PRTB" ~ "Direita",
    . == "PSL" ~ "Extrema Direita",
    . == "PSDC" ~ "Extrema Direita",
    . == "PHS" ~ "Esquerda",
    . == "PC do B" ~ "Esquerda",
    . == "PT do B" ~ "Direita",
    . == "PAN" ~ "Centro",
    . == "PRN" ~ "Direita",
    . == "PTN" ~ "Direita",
    . == "PP" ~ "Centro",
    . == "PRONA" ~ "Direita",
    . == "PTC" ~ "Centro",
    . == "PR" ~ "Direita",
    . == "DEM" ~ "Extrema Direita",
    . == "PRB" ~ "Direita",
    . == "PPL" ~ "Centro",
    . == "PSOL" ~ "Extrema Esquerda",
    . == "SD" ~ "Centro Direita",
    . == "PROS" ~ "Centro",
    . == "MDB" ~ "Centro",
    . == "PMB" ~ "Centro Direita",
    . == "REDE" ~ "Centro Esquerda",
    . == "PEN" ~ "Centro",
    . == "PATRI" ~ "Centro",
    . == "PCB" ~ "Esquerda",
    . == "PATRIOTA" ~ "Centro",
    . == "PODE" ~ "Centro Direita",
    . == "AVANTE" ~ "Centro",
    . == "REPUBLICANOS" ~ "Centro Direita",
    . == "SOLIDARIEDADE" ~ "Centro",
    . == "CIDADANIA" ~ "Centro",
    . == "DC" ~ "Centro Direita",
    . == "NOVO" ~ "Direita"
  )))

eleicoes_2 <- eleicoes_quase_pronto_2 %>% left_join(eleicoes_quase_pronto, by = c("nome_munic", "cd_municipio"))
  

# Salvando o banco de dados no Git hub: 

# write.csv(eleicoes_2, "eleicoes_2")

# ---------------------------------------------------------------------------------------------------

# banco para a análise da teoria do sistema partidário 

eleicoes_3 <- eleicoes_1 %>% 
  select(CD_MUNICIPIO, nome_munic, tarifa_zero, ANO_ELEICAO, partido_candidato_eleito) %>% 
  mutate(tarifa_zero = case_when(tarifa_zero == "sim" ~ "sim", 
                                 TRUE ~ "não")) %>% 
  mutate(nome_munic = str_to_title(nome_munic)) %>% 
  mutate(ideologia_dos_partidos = case_when(partido_candidato_eleito == "PMDB" ~ "Centro",
                                            partido_candidato_eleito == "PDT" ~ "Centro Esquerda",
                                            partido_candidato_eleito == "PPB" ~ "Direita",
                                            partido_candidato_eleito == "PSB" ~ "Esquerda",
                                            partido_candidato_eleito == "PTB" ~ "Centro Direita",
                                            partido_candidato_eleito == "PFL" ~ "Direita",
                                            partido_candidato_eleito == "PSDB" ~ "Centro",
                                            partido_candidato_eleito == "PT" ~ "Esquerda",
                                            partido_candidato_eleito == "PMN" ~ "Direita",
                                            partido_candidato_eleito == "PV" ~ "Esquerda",
                                            partido_candidato_eleito == "PL" ~ "Direita",
                                            partido_candidato_eleito == "PPS" ~ "Centro Esquerda",
                                            partido_candidato_eleito == "PST" ~ "Direita",
                                            partido_candidato_eleito == "PSD" ~ "Centro Direita",
                                            partido_candidato_eleito == "PSC" ~ "Extrema Direita",
                                            partido_candidato_eleito == "PRP" ~ "Direita",
                                            partido_candidato_eleito == "PRTB" ~ "Direita",
                                            partido_candidato_eleito == "PSL" ~ "Extrema Direita",
                                            partido_candidato_eleito == "PSDC" ~ "Extrema Direita",
                                            partido_candidato_eleito == "PHS" ~ "Esquerda",
                                            partido_candidato_eleito == "PC do B" ~ "Esquerda",
                                            partido_candidato_eleito == "PT do B" ~ "Direita",
                                            partido_candidato_eleito == "PAN" ~ "Centro",
                                            partido_candidato_eleito == "PRN" ~ "Direita",
                                            partido_candidato_eleito == "PTN" ~ "Direita",
                                            partido_candidato_eleito == "PP" ~ "Centro",
                                            partido_candidato_eleito == "PRONA" ~ "Direita",
                                            partido_candidato_eleito == "PTC" ~ "Centro",
                                            partido_candidato_eleito == "PR" ~ "Direita",
                                            partido_candidato_eleito == "DEM" ~ "Extrema Direita",
                                            partido_candidato_eleito == "PRB" ~ "Direita",
                                            partido_candidato_eleito == "PPL" ~ "Centro",
                                            partido_candidato_eleito == "PSOL" ~ "Extrema Esquerda",
                                            partido_candidato_eleito == "SD" ~ "Centro Direita",
                                            partido_candidato_eleito == "PROS" ~ "Centro",
                                            partido_candidato_eleito == "MDB" ~ "Centro",
                                            partido_candidato_eleito == "PMB" ~ "Centro Direita",
                                            partido_candidato_eleito == "REDE" ~ "Centro Esquerda",
                                            partido_candidato_eleito == "PEN" ~ "Centro",
                                            partido_candidato_eleito == "PATRI" ~ "Centro",
                                            partido_candidato_eleito == "PCB" ~ "Esquerda",
                                            partido_candidato_eleito == "PATRIOTA" ~ "Centro",
                                            partido_candidato_eleito == "PODE" ~ "Centro Direita",
                                            partido_candidato_eleito == "AVANTE" ~ "Centro", 
                                            partido_candidato_eleito == "REPUBLICANOS" ~ "Centro Direita",
                                            partido_candidato_eleito == "SOLIDARIEDADE" ~ "Centro",
                                            partido_candidato_eleito == "CIDADANIA" ~ "Centro",
                                            partido_candidato_eleito == "DC" ~ "Centro Direita",
                                            partido_candidato_eleito == "NOVO" ~ "Direita")) 

# Salvando o banco de dados no Git hub: 

# write.csv(eleicoes_3, "eleicoes_3")

