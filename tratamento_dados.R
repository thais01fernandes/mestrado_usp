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

ffpt_cities <- read_sheet(ss = "https://docs.google.com/spreadsheets/d/1UnKXflAf5RVRMhCL-FuroTsPZBy7am3qAmD5j_hXc3g/edit#gid=0", sheet = 1) %>% 
  rename(CodMun = Cod_IBGE)


# Base de dados sobre transporte público - IBGE, 2020
# endereço: https://www.ibge.gov.br/estatisticas/sociais/saude/10586-pesquisa-de-informacoes-basicas-municipais.html?=&t=downloads

file3 <- "https://raw.githubusercontent.com/thais01fernandes/mestrado_usp/main/data/munic_transporte"
munic_transporte <- read_delim(file3, delim = ",", 
                               locale = locale(encoding='latin1')) %>% select(-1)

# Área Territorial dos municípios, IBGE, 2022
# endereço: https://www.ibge.gov.br/geociencias/organizacao-do-territorio/estrutura-territorial/15761-areas-dos-municipios.html?=&t=downloads

file4 <- "https://raw.githubusercontent.com/thais01fernandes/mestrado_usp/main/data/area_territorial"
area_territorial <- read_delim(file4, delim = ",",
                               locale = locale(encoding='latin1')) 

# Plano de mobilidade urbana - Levantamento conduzido pela SEMOB - última atualização 22/jan/2020
# endereço: https://antigo.mdr.gov.br/index.php?option=com_content&view=article&id=4398:levantamen

file5 <- "https://raw.githubusercontent.com/thais01fernandes/mestrado_usp/main/data/plano_mob"
plano_mob <- read_delim(file5, delim = ",",
                        locale = locale(encoding='latin1'))

# Base do índice de vulnerabilidade econômica Produzido pelo IPEA
# Endereço: http://ivs.ipea.gov.br/index.php/pt/planilha 


file6 <- "https://raw.githubusercontent.com/thais01fernandes/Analises-Mestrado/main/dados_ipea.csv"
indice_ipea <- read_delim(file6, delim = ",")


# Organização da Base Munic Transporte e juntando com a base de cidades com tarifa zero

munic_transporte <- munic_transporte %>%
  select(-1, -3, -4, -6)


names(munic_transporte) <- c("CodMun", "nome_muni", "regiao", "Caracterização do órgão gestor", "Sexo do(a) titular do órgão gestor", "Idade do(a) titular do órgão gestor", 
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
                             "Este transporte coletivo atende também ao deslocamento entre bairros, distritos, localidades dentro do município", "Ciclovia no município","Bicicletário no município")

munic_transporte_2 <- munic_transporte %>% View()
  select(CodMun, `Caracterização do órgão gestor`, `Escolaridade do(a) titular do órgão gestor`, `Plano Municipal de Transporte - existência`, 
         `O município realizou alguma Conferência Municipal de Transporte nos últimos 4 anos`, `Conselho Municipal de Transporte - existência`,
         `Fundo Municipal de Transporte - existência`, `Transporte coletivo por ônibus intramunicipal`, `Transporte coletivo por ônibus intermunicipal`, 
         `Este transporte coletivo atende também ao deslocamento entre bairros, distritos, localidades dentro do município`, `Serviço prestado diretamente pela prefeitura`, 
         `Maiores de 60/65 anos`, `Estudantes da rede pública`, `Estudantes da rede privada`, Carteiros, `Pessoas com deficiência`, Policiais, Professores, 
         `Crianças menores de 5 anos`, `Toda a população`, `Nenhum passageiro`, `Ciclovia no município`) %>% 
  left_join(ffpt_cities, by = "CodMun") %>% 
  mutate(tarifa_zero = case_when(tarifa_zero == "sim" ~ "sim", 
                                 TRUE ~ "não")) 


  
# Todos os seguintes dados foram baixados do pacote R "abjData": Índice de Desenvolvimento Humano Municipal (IDHM), índice de Gini e índice de Theil, IVS municipal, Índice de prosperidade social, População Urbana e Rural, Renda per Capta, % de pobres
# Os dados do índice de vulnerabilidade econômica foram retirados do site do ipea: http://ivs.ipea.gov.br/index.php/pt/planilha 
# Todos esses dados são referentes ao censo IBGE 2010
# Endereço: https://abjur.github.io/abjData/
  
  munic_transporte_3 <- pnud_muni %>% 
    filter(ano == 2010) %>% 
    select(uf, ufn, municipio, codmun6,codmun7, rdpc, pesourb, pesorur, pesotot, theil, gini, idhm_r, idhm_l, idhm_e, idhm,	
           pmpob) %>% 
    rename(CodMun = codmun7) %>% 
    left_join(munic_pop, by = "CodMun") %>% 
    select(-`COD UF`, -UF, -`NOME MUNIC`) %>% 
    mutate(`CLASSE POP` = gsub(pattern = "1 -|2 -|3 -|4 -|5 -|6 -|7 -",replacement = "",`CLASSE POP`)) %>% 
    mutate(REGIAO = gsub(pattern = "1 -|2 -|3 -|4 -|5 -",replacement = "", REGIAO)) %>% 
    mutate(`CLASSE POP` = gsub("Até 5000","Up to 5.000", `CLASSE POP`)) %>% 
    mutate(`CLASSE POP` = gsub("5001 até 10000","5.000 up to 10.000", `CLASSE POP`)) %>%  
    mutate(`CLASSE POP` = gsub("10001 até 20000","10.000 up to 20.000", `CLASSE POP`)) %>% 
    mutate(`CLASSE POP` = gsub("20001 até 50000","20.000 up to 50.000", `CLASSE POP`)) %>% 
    mutate(`CLASSE POP` = gsub("50001 até 100000","50.000 up to 100.000", `CLASSE POP`)) %>% 
    mutate(`CLASSE POP` = gsub("100001 até 500000","100.000 up to 500.000",`CLASSE POP`)) %>%
    mutate(`CLASSE POP` = gsub("Maior que 500000","Greater than 500.000", `CLASSE POP`)) %>% 
    left_join(indice_ipea, by = c("CodMun" = "Município")) %>% 
    left_join(area_territorial, by = c("CodMun")) %>% 
    left_join(munic_transporte_2, by = c("CodMun")) 
  












