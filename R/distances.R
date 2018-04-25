library(geosphere)
library(dplyr)

load("data/pop_centers.RData")
pop <- pop_centers %>%
  filter(Year == 2010) %>%
  dplyr::select(4,2,3)
colnames(pop) <- c("state", "pop_lat", "pop_long")
caps <- read.csv("data/state_capitals.csv", stringsAsFactors = FALSE)[-2]
colnames(caps) = c("state", "cap_lat", "cap_long")
cities <- read.csv("data/pop_cities.csv", stringsAsFactors = FALSE)[ ,c(-2, -5)]
colnames(cities) = c("state", "big_lat", "big_long")
geo <- read.csv("data/geo_centers.csv", stringsAsFactors = FALSE)
colnames(geo) <- c("state", "geo_lat", "geo_long")

distances <- list(pop, caps, cities, geo) %>%
  Reduce(function(dtf1,dtf2) left_join(dtf1,dtf2,by="state"), .) %>%
  transmute(state = state,
            cap_dist_met = distCosine(.[ ,c('pop_long', 'pop_lat')], .[ ,c('cap_long', 'cap_lat')])/1000,
            cap_dist_imp = conv_unit(cap_dist_met, "km", "mi"),
            city_dist_met = distCosine(.[ ,c('pop_long', 'pop_lat')], .[ ,c('big_long', 'big_lat')])/1000,
            city_dist_imp = conv_unit(city_dist_met, "km", "mi"),
            geo_dist_met = distCosine(.[ ,c('pop_long', 'pop_lat')], .[ ,c('geo_long', 'geo_lat')])/1000,
            geo_dist_imp = conv_unit(geo_dist_met, "km", "mi"))

write.csv(distances, file = "data/distances.csv", row.names = FALSE)
