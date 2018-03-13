library(shiny)
library(leaflet)
library(dplyr)
#data_files <- c("pop_centers.RData", "lines.RData")
#lapply(data_files,load,.GlobalEnv)
load("pop_centers.RData")
source("R/make_lines.R")

ui <- fluidPage(
   
   titlePanel("Mean Population Centers, by State"),
   
   sidebarLayout(
      sidebarPanel(
         selectInput(inputId = "state",
                     label = "State:",
                     choices = c("United States", state.name),
                     selected = "United States")
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
  
  cols <- colorNumeric("YlGnBu", pop_centers$Year)
  output$map <- renderLeaflet({
    leaflet(data = points()) %>%
      addTiles() %>%
      addCircleMarkers(~Long, ~Lat,
                       radius = 6,
                       color = ~cols(Year),
                       stroke = FALSE, fillOpacity = 1,
                       popup = ~as.character(Year)) %>%
      addPolylines(data = lines(), weight = 3, color = "black")
   })
}

shinyApp(ui = ui, server = server)
