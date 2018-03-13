library(shiny)
library(leaflet)
library(dplyr)
#data_files <- c("pop_centers.RData", "lines.RData")
#lapply(data_files,load,.GlobalEnv)
load("pop_centers.RData")
source("R/make_lines.R")

states <- shapefile('data/state_bounds/cb_2016_us_state_20m.shp')

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
                     selectize = FALSE)
      ),
      
      mainPanel(
         leafletOutput("map")
      )
   )
)

server <- function(input, output) {
  # make reactive points, lines for plotting
  points <- eventReactive(input$state, {
    filter(pop_centers, State == input$state)
  })
  lines <- eventReactive(input$state, {
    filter(pop_centers, State == input$state) %>%
      points_to_line("Long", "Lat")
  })
  bounds <- eventReactive(input$state, {
    if (input$state == "United States") subset(states, !(NAME %in% c("Alaska", "Hawaii")))
    else subset(states, NAME == input$state)
  })
  
  cols <- colorNumeric("YlGnBu", pop_centers$Year)
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
      addPolylines(data = lines(), group = "lines", weight = 3, color = "black")
   })
}

shinyApp(ui = ui, server = server)
