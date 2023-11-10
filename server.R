# Select the python.exe in the user's PATH
library(reticulate)
library(shiny)
library(readr)
library(dplyr)
library(leaflet)
library(htmltools)

source_python("main.py")

# Load CSV data
processed_data <- read_csv("data_processor/processed_data.csv")

# Fuels selected
fuels <- c("Gazole", "SP98", "SP95", "E85", "E10", "GPLc")
a
server <- function(input, output, session) {
  
  # ----------------------------------------------------------------------------
  # Histogram
  # ----------------------------------------------------------------------------
  
  selected_fuel_data <- reactive({
    fuel <- input$fuel
    filtered_data <- processed_data[, fuel, drop = FALSE]
    return(filtered_data)
  })
  
  output$histogram <- renderPlot({
    fuel <- input$fuel
    data <- selected_fuel_data()
    
    # Filter out NA and non-numeric values
    data <- na.omit(data)
    data <- data[is.na(data) == FALSE]
    
    # Handle the case when all values are missing or non-numeric
    if (length(data) == 0) {
      return(NULL)
    }
    
    # Define the limit dynamically 
    x_min <- min(data) - 0.02
    x_max <- max(data) + 0.02
    
    
    hist(
      data, 
      main = paste("Histogramme des prix en France du", fuel),
      xlab = paste("Prix du", fuel, "en €"),
      ylab = "Occurences",
      xlim = c(x_min, x_max),
      col = "lightblue",
      border = "black"
    )
  })
  
  # ----------------------------------------------------------------------------
  # Cartography
  # ----------------------------------------------------------------------------
  
  # Define the coordinates of the fuel stations
  points <- eventReactive(input$recalc, {
    data.frame(
      latitude = processed_data$Latitude,
      longitude = processed_data$Longitude
    )
  }, ignoreNULL = FALSE)
  
  # Function to generate the popup content
  generatePopupContent <- function(data) {
    # Print the name of the city
    popupContent <- paste("<strong><h5>", data$cp_ville, "</strong></h5>")
    
    # Print the fuel and the prices associated
    for (fuel in fuels) {
      values <- data[[fuel]]
      
      formatted_values <- ifelse(is.na(values), 
                                 paste(
                                   "<span style='color:red;'>
                                   Non disponible
                                   </span>"), 
                                 paste(sprintf("%.3f", values), "€/L")
                                 )
      
      popupContent <- paste(popupContent, "<strong>", fuel, ":</strong> ", 
                            formatted_values, "<br>", sep = " ")
    }
    
    # Print the occurrences of fuel stations in the city
    popupContent <- paste(popupContent, 
                          "<br><strong>Nombre de stations:</strong> ",
                          data[["Nombre de stations"]], "<br>")
    
    return(popupContent)
  }
  
  output$map <- renderLeaflet({
    leaflet(processed_data) %>%
      # Background selection
      addProviderTiles(providers$Stadia.StamenTonerLite, 
                       options = providerTileOptions(
                         noWrap = FALSE,
                         minZoom = 5)
      ) %>%
      addMarkers(
        # Points to display
        data = points(),
        # Allow clustering
        clusterOptions = markerClusterOptions(),
        # Content when clicking on Popup
        popup = ~generatePopupContent(processed_data)
      ) %>%
      setMaxBounds(lng1 = -20,lat1 = 33,lng2 = 24,lat2 = 55)
  })
}
