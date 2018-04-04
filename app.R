library(shiny)
library(rgeos)
library(rgdal)
library(leaflet)
library(dplyr)
library(raster)
#data_files <- c("pop_centers.RData", "lines.RData")
#lapply(data_files,load,.GlobalEnv)
load("data/pop_centers.RData")
source("R/make_lines.R")

states <- shapefile('data/state_bounds/cb_2016_us_state_20m.shp')
caps <- read.csv("data/state_capitals.csv", stringsAsFactors = FALSE)
cities <- read.csv("data/pop_cities.csv", stringsAsFactors = FALSE)

ui <- fluidPage(
   
   titlePanel("Mean Population Centers, by State"),
   
   sidebarLayout(
      sidebarPanel(
         selectInput(inputId = "state",
                     label = "State:",
                     choices = c("United States", state.name),
                     selected = "United States"),
         selectInput(inputId = "zoom",
                     label = "Zoom to:",
                     choices = c("Local", "State"),
                     selected = "Local",
                     selectize = FALSE),
         checkboxInput(inputId = "capital",
                       label = "Show state capital (2018)"),
         checkboxInput(inputId = "big_city",
                       label = "Show most populous city (2013)")
      ),
      
      mainPanel(
         leafletOutput("map")
      )
   )
)

server <- function(input, output, session) {
  # make reactive points, lines for plotting
  points <- eventReactive(input$state, {
    filter(pop_centers, State == input$state)
  })
  lines <- eventReactive(input$state, {
    filter(pop_centers, State == input$state) %>%
      points_to_line("Long", "Lat")
  })
  # make data for choice of state-sized view
  bounds <- eventReactive(input$state, {
    if (input$state == "United States") subset(states, !(NAME %in% c("Alaska", "Hawaii")))
    else subset(states, NAME == input$state)
  })
  # clear capital every time the state changes
  observe({
    q <- input$state
    updateCheckboxInput(session, "capital", value = FALSE)
    updateCheckboxInput(session, "big_city", value = FALSE)
  })
  cap <- eventReactive(input$capital, {
    filter(caps, name == input$state)
  })
  city <- eventReactive(input$big_city, {
    filter(cities, state == input$state)
  })
  
  # things to change plot
  cols <- colorNumeric("YlGnBu", pop_centers$Year)
  star <- awesomeIcons(
    icon = 'star',
    iconColor = 'white',
    library = 'fa'
  )
  building <- awesomeIcons(
    icon = 'building',
    iconColor = 'white',
    library = 'fa'
  )
  
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      {if(input$zoom == "State") {
        addPolygons(map = ., data = bounds(), weight = 1, fill = FALSE)
      } else .} %>%
      addCircleMarkers(data = points(), group = "mean_centers",
                       ~Long, ~Lat,
                       radius = 6,
                       color = ~cols(Year),
                       stroke = FALSE, fillOpacity = 1,
                       popup = ~as.character(Year)) %>%
      {if(input$capital) {
        addAwesomeMarkers(map = ., data = cap(), lng = ~long, lat = ~lat, icon = star, popup = ~capital)
      } else .} %>%
      {if(input$big_city) {
        addMarkers(map = ., data = city(), lng = ~longitude, lat = ~latitude,
                          icon = building, popup = ~city)
      } else .} %>%
      addPolylines(data = lines(), group = "lines", weight = 3, color = "black")
   })
}

shinyApp(ui = ui, server = server)
