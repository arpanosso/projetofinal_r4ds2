library(magrittr)
library(dplyr)
library(tidyr)
library(lubridate)
library(stringr)
library(ggplot2)
source("r/graficos.R")
source("r/funcoes.R")

# Lendo o banco de dados
oco2 <- readr::read_rds("data/oco2.rds")
glimpse(oco2)



# Inicialmente vamos modificar a concentração de CO2 para ppm
# A partir da coluna `time (YYYYMMDDHHMMSS)`
 oco2<-oco2 %>%
         mutate(
           xco2 = `xco2 (Moles Mole^{-1})`*1e06,
           data = ymd_hms(`time (YYYYMMDDHHMMSS)`),
           ano = year(data),
           mes = month(data),
           dia = day(data),
           dia_semana = wday(data))


# Vamos plotar a concentração de CO2 no ano de 2014
# mapeamos o dia da semana e observamos que o satélite passa
# de 15 a 16 dias.
oco2 %>%
  filter(ano == 2014) %>%
  ggplot(aes(x=longitude, y=latitude, color=dia_semana)) +
  geom_point()

# Agora precisamos filtrar apenas os dados que estão dentro do território
# nacional, utilizamos então o pacote geobr

regiao <- geobr::read_region(showProgress = FALSE)
br <- geobr::read_country(showProgress = FALSE)

pol_br <- br$geom %>%
  purrr::pluck(1) %>%
  as.matrix()

### Vamos criar os polígonos das regiões
pol_norte <- regiao$geom %>% purrr::pluck(1) %>% as.matrix()
pol_nordeste <- regiao$geom %>% purrr::pluck(2) %>% as.matrix()
pol_sudeste <- regiao$geom %>% purrr::pluck(3) %>% as.matrix()
pol_sul <- regiao$geom %>% purrr::pluck(4) %>% as.matrix()
pol_centroeste<- regiao$geom %>% purrr::pluck(5) %>% as.matrix()


br %>%
  ggplot() +
  geom_sf(fill="#2D3E50", color="#FEBF57",
          size=.15, show.legend = FALSE)+
  tema_mapa() +
  geom_point(data=oco2 %>% filter(ano == 2014) ,
             aes(x=longitude,y=latitude),
             shape=3,
             col="red",
             alpha=0.2)

# Deve-se corrigir os polígono do Brasil e da Regição Nordeste
pol_nordeste <- pol_nordeste[pol_nordeste[,1]<=-34,]# CORREÇÃO do polígono
pol_nordeste <- pol_nordeste[!((pol_nordeste[,1]>=-38.7 & pol_nordeste[,1]<=-38.6) &
                                 pol_nordeste[,2]<= -15),]# CORREÇÃO do polígono

pol_br <- pol_br[pol_br[,1]<=-34,] # CORREÇÃO do polígono
pol_br <- pol_br[!((pol_br[,1]>=-38.8 & pol_br[,1]<=-38.6) &
                     (pol_br[,2]>= -19 & pol_br[,2]<= -16)),]

# Vamos criar o filtro para os pontos pertencentes ao polígono do Brasil.
# e do nordeste
oco2 <- oco2 %>%
  dplyr::mutate(
    flag_br = def_pol(longitude, latitude, pol_br),
    flag_norte = def_pol(longitude, latitude, pol_norte),
    flag_nordeste = def_pol(longitude, latitude, pol_nordeste),
    flag_sul = def_pol(longitude, latitude, pol_sul),
    flag_sudeste = def_pol(longitude, latitude, pol_sudeste),
    flag_centroeste = def_pol(longitude, latitude, pol_centroeste)
  )
glimpse(oco2)

br %>%
  ggplot() +
  geom_sf(fill="#2D3E50", color="#FEBF57",
          size=.15, show.legend = FALSE)+
  tema_mapa() +
  geom_point(data=oco2 %>% filter(flag_br|flag_nordeste, ano == 2014),
             aes(x=longitude,y=latitude),
             shape=3,
             col="red",
             alpha=0.2)

## Agora podemos filtrar os pontos, para os dados do Brasil
oco2_br <- oco2 %>%
  filter( flag_br | flag_nordeste ) %>%
  select(-flag_br)
readr::write_rds(oco2_br,"data/oco2_br.rds")

### Análise






