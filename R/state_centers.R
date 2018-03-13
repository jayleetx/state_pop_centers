library(dplyr)
library(tidyr)
library(stringr)
library(leaflet)
library(rvest)

# get state data
state_pop_centers <- read.csv("data/state_pop_centers.csv", na.strings = '', stringsAsFactors = FALSE) %>%
  slice(1:51) %>%
  dplyr::select(-X)
state_pop_centers[25,4] <- "32 59 52" # believed by the census to be an error

# get US data
url <- "https://www.census.gov/geo/reference/centersofpop/natcentersofpop.html"
population <- url %>%
  read_html() %>%
  html_nodes("table") %>%
  html_table()

pop_df <- population[[1]][c(-1,-8), -4]
colnames(pop_df) <- c("Year", "Lat", "Long")

nat_pop <- pop_df %>%
  mutate_all(as.numeric) %>%
  mutate(State = "United States",
         Long = -Long) %>%
  arrange(Year)
  

# custom function to change into decimal coordinates
change_coord <- function(x) {
  x <- trimws(x)
  parts <- strsplit(x, " ")
  sapply(parts, function(y)   sum(as.numeric(y) / c(1, 60, 3600)))
}

pop_centers <- state_pop_centers %>%
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
         Long = -as.numeric(Long)) %>%
  bind_rows(nat_pop)

save(pop_centers, file = "pop_centers.RData")
