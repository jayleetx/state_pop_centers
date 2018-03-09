#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Mean Population Centers, by State"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
         selectInput(inputId = "state",
                     label = "State:",
                     choices = c("United States", state.name),
                     selected = "United States")
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         leafletOutput("map")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  cols <- colorNumeric("YlGnBu", pop_centers$Year)
   output$map <- renderLeaflet({
     leaflet(data = filter(pop_centers, State == input$state)) %>%
       addTiles() %>%
       addCircleMarkers(~Long, ~Lat,
         radius = 6,
         color = ~cols(Year),
         stroke = FALSE, fillOpacity = 1,
         popup = ~as.character(Year)
       ) %>%
       addPolylines(data = points_to_line(filter(pop_centers, State == input$state), "Long", "Lat"), weight = 3, color = "black")
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

