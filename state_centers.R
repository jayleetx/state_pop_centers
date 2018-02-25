library(dplyr)
library(tidyr)
library(stringr)
library(leaflet)
library(rvest)

temp <- tempfile()
download.file("http://www2.census.gov/geo/docs/reference/cenpop2010/nat_cop_1880_2010.txt",temp)
state_pop_centers <- read.csv(temp, na.strings = '', stringsAsFactors = FALSE) %>%
  slice(1:51) %>%
  dplyr::select(-X)
unlink(temp)

change_coord <- function(x) {
  x <- trimws(x)
  parts <- strsplit(x, " ")
  sapply(parts, function(y)   sum(as.numeric(y) / c(1, 60, 3600)))
}

long_pop_centers <- state_pop_centers %>%
  gather(key = coord_year, value = coord, -State) %>%
  mutate(Year = str_extract(coord_year, '\\d\\d\\d\\d'),
         coord_type = str_extract(coord_year, 'Lat|Long')) %>%
  dplyr::select(State, Year, coord_type, coord) %>%
  filter(!is.na(coord)) %>%
  spread(key = coord_type, value = coord) %>%
  mutate(Lat = change_coord(Lat),
         Long = change_coord(Long)) %>%
  mutate(Year = as.numeric(Year),
         Lat = as.numeric(Lat),
         Long = -as.numeric(Long))

or <- leaflet(data = filter(long_pop_centers, State == 'Oregon')) %>%
  addTiles() %>%
  addMarkers(~Long, ~Lat, popup = ~as.character(Year))

or
