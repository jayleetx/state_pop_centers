library(rvest)
library(raster)
library(jsonlite)
library(dplyr)

# state population centers since 1880 census
download.file("http://www2.census.gov/geo/docs/reference/cenpop2010/nat_cop_1880_2010.txt", 'data/state_pop_centers.csv')

state_capital_url <- 'https://gist.githubusercontent.com/jpriebe/d62a45e29f24e843c974/raw/b1d3066d245e742018bce56e41788ac7afa60e29/us_state_capitals.json'
caps <- fromJSON(state_capital_url)
state_capitals <- data.frame(do.call(rbind, caps), stringsAsFactors = FALSE, row.names = NULL)
state_capitals <- c("United States", "Washington, D.C.", "38.89511", "-77.03637") %>%
  rbind(apply(state_capitals, 2, unlist)) %>%
  data.frame(stringsAsFactors = FALSE)
write.csv(state_capitals, file = "data/state_capitals.csv", row.names = FALSE)

temp <- tempfile()
download.file("http://www2.census.gov/geo/tiger/GENZ2016/shp/cb_2016_us_state_20m.zip",temp)
unzip(temp, exdir = "data/state_bounds")
unlink(temp)

temp <- tempfile()
download.file("http://www2.census.gov/geo/tiger/GENZ2016/shp/cb_2016_us_county_500k.zip",temp)
unzip(temp, exdir = "data/county_bounds")
unlink(temp)

