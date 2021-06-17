library(tidyverse)
library(lubridate)
library(purrr)
library(plotly)
library(shiny)
library(htmlwidgets)
library(leaflet)
library(reactable)
library(shiny)
library(shinydashboard)


ui <- dashboardPage(
  header = dashboardHeader(title = "XCO2-UNESP"),
  sidebar = dashboardSidebar(
    sidebarMenu(
      menuItem("Mapeamento", tabName = "mapeamento", icon = icon("map")),
      menuItem("Multivariada", tabName = "mult", icon = icon("square-root-alt"))
    )
  ),
  body = dashboardBody(
    tabItems(
      # Página 01 - Mapeamento
      tabItem(
        tabName = "mapeamento",
        h1("Série temporais Univariadas"),
        hr(style = "border-top: 1px solid black;"),
        br(),
        fluidRow(
          column(
            width = 4,
            fluidRow(
                column(
                  width = 12,
                  uiOutput("ui_variavel")
                )
              )
            )
          ),
        fluidRow(
          box(
            width = 10,
            title = "Série temporal",
            solidHeader = TRUE,
            status = "primary",
            # height = "200px",
            plotlyOutput("serie_mapa")
          )
        ),
        fluidRow(
          box(
            width = 10,
            title = "Série temporal",
            solidHeader = TRUE,
            status = "primary",
            leafletOutput("mapa_pos")
          ),
          column(
            width = 6,
            uiOutput("ui_mapeamento")
          )
        ),
        fluidRow(
          box(
            width = 6,
            title = "Variograma",
            plotOutput("variograma_mapa")
          ),
          box(
            width = 6,
            title = "Krigagem Ordinária",
            plotOutput("krig_mapa")
          )
        )
      ),
      #Página 2
      tabItem(
        tabName = "mult",
        h1("Em construção..."),
        hr(style = "border-top: 1px solid black;"),
        br(),
      )
    )
  ),
  title = "Xco2 Santos"
)

server <- function(input, output, session) {
  santos <- read.table("Santos_ok.txt",h=TRUE)
  santos <- santos |>
    mutate(
      data = lubridate::make_date(year=year, month=month, day=day)
    )
  anos <- santos$year |> unique()
  variaveis <- names(santos[6:8])

  # Página 01 - Mapeamento
  output$ui_variavel <- renderUI({
    selectInput(
      inputId = "variavel",
      label = "Selecione a Variavel",
      choices = variaveis,
      selected = variaveis[1]
    )
  })

  output$ui_mapeamento <- renderUI({
    selectInput(
      inputId = "data",
      label = "Selecione o ano para Mapeamento",
      choices = anos,
      selected = 2014
    )
  })

  output$serie_mapa <- renderPlotly({
    req(input$variavel)
    santos |>
      ggplot(aes_string(x="data", y=input$variavel))+
      geom_line(color="red") +
      theme_bw()
  })

  output$mapa_pos <- renderLeaflet({
    req(input$data)
    long<-santos |>
      filter(year == input$data) |>
      pull(longitude)

    lati<-santos |>
      filter(year == input$data) |>
      pull(latitude)

    leaflet(height = 300) |>
      addTiles() |>
      addCircleMarkers(
        lng = long,#-46.6623969,
        lat = lati, #-23.5581664,
        popup = "Pontos amostrados",
        radius = 2
      )
  })

  output$variograma_mapa <- renderPlot({
    req(input$variavel)
    req(input$data)
    spo<-santos |>
      filter(year == input$data) |>
      select(longitude,latitude,input$variavel) |>
      group_by(longitude,latitude) |>
      summarise(Y = mean(.data[[input$variavel]], na.rm=TRUE))


    sp::coordinates(spo)=~ longitude+latitude
    form<-Y~1
    variograma<-gstat::variogram(form, data=spo)
    variograma |>
      ggplot2::ggplot(ggplot2::aes(x=dist, y=gamma)) +
      ggplot2::geom_point()

    vari_mod <- gstat::fit.variogram(variograma,gstat::vgm(1,"Sph",1,0))
    plot(variograma,model=vari_mod, col=1,pl=F,pch=16)
  })

  output$krig_mapa <- renderPlot({
    req(input$variavel)
    req(input$data)
    spo<-santos |>
      filter(year == input$data) |>
      select(longitude,latitude,input$variavel) |>
      group_by(longitude,latitude) |>
      summarise(Y = mean(.data[[input$variavel]], na.rm=TRUE))


    sp::coordinates(spo)=~ longitude+latitude
    form<-Y~1
    variograma<-gstat::variogram(form, data=spo)
    variograma |>
      ggplot2::ggplot(ggplot2::aes(x=dist, y=gamma)) +
      ggplot2::geom_point()

    vari_mod <- gstat::fit.variogram(variograma,gstat::vgm(1,"Sph",1,0))
    x<-spo$longitude
    y<-spo$latitude
    dis <- 0.05 #Distância entre pontos
    grid <- expand.grid(X=seq(min(x),max(x),dis), Y=seq(min(y),max(y),dis))
    sp::gridded(grid) = ~ X + Y

    ko<-gstat::krige(formula=form, spo, grid, model=vari_mod,
                          block=c(0,0),
                          nsim=0,
                          na.action=na.pass,
                          debug.level=-1,
    )

    tibble::as.tibble(ko) %>%
      ggplot2::ggplot(ggplot2::aes(x=X, y=Y)) +
      ggplot2::geom_tile(ggplot2::aes(fill = var1.pred)) +
      ggplot2::scale_fill_gradient(low = "yellow", high = "blue") +
      ggplot2::coord_equal()

  })
}

shinyApp(ui, server)
