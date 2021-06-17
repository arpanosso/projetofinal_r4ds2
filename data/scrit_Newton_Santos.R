library(tidyverse)

santos <- read.table("data/Santos_ok.txt",h=TRUE)
glimpse(santos)


santos  |>
  filter(year == 2016) |>
  ggplot(aes(x=longitude, y=latitude, color=xco2)) +
  geom_point() +
  theme_bw()

regiao <- geobr::read_region(showProgress = FALSE)
br <- geobr::read_country(showProgress = FALSE)

pol_br <- br$geom %>% purrr::pluck(1) %>% as.matrix()

### Polígonos das Regiões
pol_norte <- regiao$geom %>% purrr::pluck(1) %>% as.matrix()
pol_nordeste <- regiao$geom %>% purrr::pluck(2) %>% as.matrix()
pol_sudeste <- regiao$geom %>% purrr::pluck(3) %>% as.matrix()
pol_sul <- regiao$geom %>% purrr::pluck(4) %>% as.matrix()
pol_centroeste<- regiao$geom %>% purrr::pluck(5) %>% as.matrix()


br %>%
  ggplot2::ggplot() +
  ggplot2::geom_sf(fill="#2D3E50", color="#FEBF57",
                   size=.15, show.legend = FALSE)+
  ggplot2::geom_point(data=santos %>% dplyr::filter(year == 2014) ,
                      ggplot2::aes(x=longitude,y=latitude),
                      shape=3,
                      col="red",
                      alpha=0.2)


santos <- santos %>%
  dplyr::mutate(
    flag_br = def_pol(longitude, latitude, pol_br),
    flag_norte = def_pol(longitude, latitude, pol_norte),
    flag_nordeste = def_pol(longitude, latitude, pol_nordeste),
    flag_sul = def_pol(longitude, latitude, pol_sul),
    flag_sudeste = def_pol(longitude, latitude, pol_sudeste),
    flag_centroeste = def_pol(longitude, latitude, pol_centroeste)
  )
dplyr::glimpse(santos)





santos_litoral <- santos %>%
  dplyr::filter(year==2020) %>%
  dplyr::mutate(coordxy = paste0(latitude,longitude)) %>%
  dplyr::group_by(longitude,latitude) %>%
  dplyr::summarise(xco2_media = mean(xco2, na.rm=TRUE) )

santos_litoral %>%
  ggplot2::ggplot(ggplot2::aes(x=longitude, y=latitude) ) +
  ggplot2::geom_point()



sp::coordinates(santos_litoral)=~ longitude+latitude
form<-xco2_media~1


vari_co2_litoral<-gstat::variogram(form, data=santos_litoral)
vari_co2_litoral %>%
  ggplot2::ggplot(ggplot2::aes(x=dist, y=gamma)) +
  ggplot2::geom_point()


m_xco2 <- gstat::fit.variogram(vari_co2_litoral,gstat::vgm(1,"Sph",1,0))
plot(vari_co2_litoral,model=m_xco2, col=1,pl=F,pch=16)


x<-santos_litoral$longitude
y<-santos_litoral$latitude
dis <- 0.05 #Distância entre pontos
grid <- expand.grid(X=seq(min(x),max(x),dis), Y=seq(min(y),max(y),dis))
sp::gridded(grid) = ~ X + Y

ko_fco2<-gstat::krige(formula=form, santos_litoral, grid, model=m_xco2,
                      block=c(0,0),
                      nsim=0,
                      na.action=na.pass,
                      debug.level=-1,
)


tibble::as.tibble(ko_fco2) %>%
  ggplot2::ggplot(ggplot2::aes(x=X, y=Y)) +
  ggplot2::geom_tile(ggplot2::aes(fill = var1.pred)) +
  ggplot2::scale_fill_gradient(low = "yellow", high = "blue") +
  ggplot2::coord_equal()










