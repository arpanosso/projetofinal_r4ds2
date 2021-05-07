
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Projeto Final - R4DS2

### Aluno: Alan R. Panosso

### Data: 01/05/2021

<!-- badges: start -->
<!-- badges: end -->

# CO2 Virtual Science Data Environment

O objetivo desse material é apresentar os procedimentos básicos para
aquisição de dados do satélite OCO-2 e processamento inicial em R.

## Aquisição de dados

**1)** Acesse o endereço <https://co2.jpl.nasa.gov/>

<img src="https://raw.githubusercontent.com/arpanosso/projetofinal_r4ds2/master/inst/jpl_01.png" width="600px" style="display: block; margin: auto;" />
**2)** Acesse o Browse *OCO-2 Data* em *Level 2 Data Set OCO-2*.

<img src="https://raw.githubusercontent.com/arpanosso/projetofinal_r4ds2/master/inst/jpl_02.png" width="600px" style="display: block; margin: auto;" />

**3)** Role a página para baixo e acesse *CUSTOMIZE PRODUCT ON BUILD
PAGE*.

<img src="https://raw.githubusercontent.com/arpanosso/projetofinal_r4ds2/master/inst/jpl_03.png" width="600px" style="display: block; margin: auto;" />

**4)** No menu à esquerda estarão as 9 categorias para personalizar o
banco de dados.

<img src="https://raw.githubusercontent.com/arpanosso/projetofinal_r4ds2/master/inst/jpl_04.png" width="600px" style="display: block; margin: auto;" />

**5)** Em *DATA TYPE* selecione **OCO-2 Satellite**.

<img src="https://raw.githubusercontent.com/arpanosso/projetofinal_r4ds2/master/inst/jpl_05.png" width="600px" style="display: block; margin: auto;" />

**6)** Em *PRODUCTS* selecione **OCO-2 Full**.

<img src="https://raw.githubusercontent.com/arpanosso/projetofinal_r4ds2/master/inst/jpl_06.png" width="600px" style="display: block; margin: auto;" />

**7)** Em *DATA VERSION* selecione **10**.

<img src="https://raw.githubusercontent.com/arpanosso/projetofinal_r4ds2/master/inst/jpl_07.png" width="600px" style="display: block; margin: auto;" />

**8)** Em *SPATIAL + TEMPORAL* selecione **Customize Your Spatial +
Temporal Coverage**.

<img src="https://raw.githubusercontent.com/arpanosso/projetofinal_r4ds2/master/inst/jpl_08.png" width="600px" style="display: block; margin: auto;" />

**OPTION 01** Utilize para selecionar a área para aquisição dos dados.

<img src="https://raw.githubusercontent.com/arpanosso/projetofinal_r4ds2/master/inst/jpl_09.png" width="600px" style="display: block; margin: auto;" />

**OPTION 02** Utilize para selecionar o período para aquisição dos
dados.

<img src="https://raw.githubusercontent.com/arpanosso/projetofinal_r4ds2/master/inst/jpl_09_1.png" width="600px" style="display: block; margin: auto;" />

**9)** Em *DOWN SAMPLE PRODUCT* selecione **Yes, I want a Level 3 data
product**. Altere os valores das células e o passo temporal desejado.

<img src="https://raw.githubusercontent.com/arpanosso/projetofinal_r4ds2/master/inst/jpl_10.png" width="600px" style="display: block; margin: auto;" />

**10)** Em *DATA VARIABLES* selecione as variáveis desejadas.

<img src="https://raw.githubusercontent.com/arpanosso/projetofinal_r4ds2/master/inst/jpl_11.png" width="600px" style="display: block; margin: auto;" />

**11)** Abaixo são apresentadas as opções para os filtros e o tipo de
arquivo, selecione **CSV FILE**.

<img src="https://raw.githubusercontent.com/arpanosso/projetofinal_r4ds2/master/inst/jpl_11_1.png" width="600px" style="display: block; margin: auto;" />

**12)** Forneça um endereço de e-mail para onde os links serão
direcionados.

<img src="https://raw.githubusercontent.com/arpanosso/projetofinal_r4ds2/master/inst/jpl_12.png" width="600px" style="display: block; margin: auto;" />
**13)** Acesse o seu e-mail, será enviado uma mensagem com o endereço
dos arquivos onde você poderá acompanhar o progresso do processamento de
seus dados. Ao final dessa etapa um novo e-mail é enviado informando que
os dados estão disponíveis.

<img src="https://raw.githubusercontent.com/arpanosso/projetofinal_r4ds2/master/inst/jpl_13.png" width="600px" style="display: block; margin: auto;" />

**14)** Acesse o link enviado em seu e-mail e você será direcionado a
página.

<img src="https://raw.githubusercontent.com/arpanosso/projetofinal_r4ds2/master/inst/jpl_14.png" width="600px" style="display: block; margin: auto;" />

**15)** Role a página para baixo e selecione a opção **WGET File List**.

<img src="https://raw.githubusercontent.com/arpanosso/projetofinal_r4ds2/master/inst/jpl_15.png" width="800px" style="display: block; margin: auto;" />

**16)** Salve o arquivo `.txt` na pasta `data-raw`.

<img src="https://raw.githubusercontent.com/arpanosso/projetofinal_r4ds2/master/inst/jpl_16.png" width="400px" style="display: block; margin: auto;" />

**17)** O arquivo contém os endereços de cada arquivo para download.

<img src="https://raw.githubusercontent.com/arpanosso/projetofinal_r4ds2/master/inst/caminhos.png" width="500px" style="display: block; margin: auto;" />

## Download dos arquivos

O código abaixo será utilizado para fazer o download dos arquivos CSV
com os dados do satélite OCO2.

``` r
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
```

Imagem dos arquivos baixados.

<img src="https://raw.githubusercontent.com/arpanosso/projetofinal_r4ds2/master/inst/dow_csv.png" width="700px" style="display: block; margin: auto;" />

O volume dos dados á alto, ao redor de *11 GB*, então para garantir a
reprodutibilidade desse material, vamos realizar uma faxina nos dados,
retirando, os valores perdidos, ou falhas do sensor, que são registrados
como **-999999.0**, como apresentado abaixo.

<img src="https://raw.githubusercontent.com/arpanosso/projetofinal_r4ds2/master/inst/dados_perdidos.png" width="700px" style="display: block; margin: auto;" />
