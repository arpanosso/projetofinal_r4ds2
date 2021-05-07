# Definindo o Pipe
`%>%` <- magrittr::`%>%`

# Links de download gerados pela NASA
links <- list.files(path = "data-raw/",
             pattern = ".txt",
             full.names = TRUE) %>%
    read.table() %>%
    dplyr::pull(V1)

# Definindo os caminhos e nomes dos arquivos
n_split <- lengths(stringr::str_split(links[1],"/"))
files.csv <- stringr::str_split(links,"/",simplify = TRUE)[,n_split]
files.csv <- paste0("data-raw/csv/",files.csv)

# Download dos arquivos .csv
# purrr::map2(links,
#             files.csv,
#             .f=download.file,mode="wb")


# Faxina dos dados, retirando as falhas no sensor para a concentração de CO2
faxina_co2 <- function(arquivo, col, valor_perdido){
   da <- readr::read_csv(arquivo) %>%
     dplyr::filter({{col}} != valor_perdido)
   readr::write_csv(da,arquivo)
}

purrr::map(files.csv, faxina_co2,
           col=`xco2 (Moles Mole^{-1})`,
           valor_perdido= -999999)

# Compilando os arquivos e salvando a base em data
oco2 <- purrr::map_dfr(files.csv, ~readr::read_csv(.x))
readr::write_rds(oco2,"data/oco2.rds")
