library(rvest)
library(raster)
library(jsonlite)
library(dplyr)
library(tidyr)
library(stringr)
library(maps)
data(us.cities)

abbs <- c(state.abb, "US", "DC")
names <- c(state.name, "United States", "District of Columbia")
# this is a pretty bad function tbh but it works here
swap_abb_name <- function(x) {
  abbs[names == x]
}
  

##### state population centers since 1880 census #####
download.file("http://www2.census.gov/geo/docs/reference/cenpop2010/nat_cop_1880_2010.txt", 'data/state_pop_centers.csv')

##### state capitals #####
state_capital_url <- "https://gist.githubusercontent.com/jpriebe/d62a45e29f24e843c974/raw/b1d3066d245e742018bce56e41788ac7afa60e29/us_state_capitals.json"
caps <- fromJSON(state_capital_url)
state_capitals <- data.frame(do.call(rbind, caps), stringsAsFactors = FALSE, row.names = NULL) %>%
  rbind(c("United States", "Washington, D.C.", "38.89511", "-77.03637"),
        c("District of Columbia", "Washington", "38.89511", "-77.03637")) %>%
  data.frame(stringsAsFactors = FALSE) %>%
  mutate(name = as.character(name),
         capital = as.character(capital),
         lat = as.numeric(lat),
         long = as.numeric(long),
         abb = swap_abb_name(name)) %>%
  unite(capital, 2,5, sep = ", ")
state_capitals[26, 2] <- "Helena, MT" #typo fom "Helana"
state_capitals[34, 3] <- state_capitals[34, 3] - 2
state_capitals[51:52, 2] <- "Washington, D.C."
write.csv(state_capitals, file = "data/state_capitals.csv", row.names = FALSE)

##### biggest cities #####

big_city_url <- 'https://gist.githubusercontent.com/Miserlou/c5cd8364bf9b2420bb29/raw/2bf258763cdddd704f8ffd3ea9a3e81d25e2c6f6/cities.json'
large <- fromJSON(big_city_url)
pop_cities <- data.frame(large, stringsAsFactors = FALSE, row.names = NULL) %>%
  dplyr::select(7, 1, 3:5) %>%
  mutate(population = as.numeric(population)) %>%
  group_by(state) %>%
  top_n(1, population) %>%
  rbind(.[1, ]) %>%
  data.frame(stringsAsFactors = FALSE) %>%
  mutate(population = format(population, big.mark=",", scientific=FALSE, trim = TRUE))
pop_cities[52, 1] <- "United States"
pop_cities[52, 2] <- "New York, NY"
write.csv(pop_cities, file = "data/pop_cities.csv", row.names = FALSE)


##### county/state boundaries #####
temp <- tempfile()
download.file("http://www2.census.gov/geo/tiger/GENZ2016/shp/cb_2016_us_state_20m.zip",temp)
unzip(temp, exdir = "data/state_bounds")
unlink(temp)

temp <- tempfile()
download.file("http://www2.census.gov/geo/tiger/GENZ2016/shp/cb_2016_us_county_500k.zip",temp)
unzip(temp, exdir = "data/county_bounds")
unlink(temp)

