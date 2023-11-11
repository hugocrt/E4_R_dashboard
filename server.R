library(shiny)
library(readr)
library(dplyr)
library(leaflet)
library(ggplot2)
library(reticulate)

# run main.py -> un-comment for the last update !
# source_python("main.py")

# Load CSV data
processed_data <- read_csv("data_processor/processed_data.csv")

# Date of retrieve (TO COMPLETE)
last_update <- readLines("date.txt")

# Fuels selected
fuels <- c("Gazole", "SP98", "SP95", "E85", "E10", "GPLc")

server <- function(input, output, session) {
  
  # ----------------------------------------------------------------------------
  # DATE FOR SIDEBAR
  # ----------------------------------------------------------------------------
  
  output$date <- renderText(
    return(last_update)
  )
  
  # ----------------------------------------------------------------------------
  # HISTOGRAM
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
      border = "black",
      breaks = min(30, length(unique(data)))
    )
  })
  
  # ----------------------------------------------------------------------------
  # CARTOGRAPHY
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
        data = points(),
        clusterOptions = markerClusterOptions(),
        popup = ~generatePopupContent(processed_data)
      ) %>%
      setMaxBounds(lng1 = -20,lat1 = 33,lng2 = 24,lat2 = 55)
  })
  
  # ----------------------------------------------------------------------------
  # PIE CHART
  # ----------------------------------------------------------------------------
  
  generate_pie_chart <- function(data) {
    ggplot(data, aes(x = "", y = value, fill = Région)) +
      geom_bar(stat = "identity", width = 1) +
      coord_polar("y", start = 0) +
      theme(
        axis.text.x = element_blank(),
        axis.title.x = element_blank(), 
        axis.title.y = element_blank(),
        legend.text = element_text(size = 25),
        legend.title = element_text(size = 30),
        legend.spacing = unit(1, "cm"),
        panel.background = element_blank()
      ) +
      geom_text(aes(label = scales::percent(value/sum(value))), 
                position = position_stack(vjust = 0.5)) +
      guides(fill = guide_legend(title.position = "top", title.vjust = 2))
  }
  
  # Data used in pie chart: fuel station / region
  data_region <- processed_data %>%
    group_by(Région) %>%
    summarise(value = sum(`Nombre de stations`))
  
  df_reg <- data.frame(
    Région = data_region$Région,
    value = data_region$value
  )
  
  output$piereg <- renderPlot({
    generate_pie_chart(df_reg)
  })
  
  # Data used in pie chart: city with 1 or more fuel station / region
  data_city <- processed_data %>%
    filter(`Nombre de stations` > 0)
  
  city_counts <- data_city %>%
    group_by(Région) %>%
    summarise(value = n_distinct(cp_ville))
  
  df_cit <- data.frame(
    Région = city_counts$Région,
    value = city_counts$value
  )
  
  output$piecit <- renderPlot({
    generate_pie_chart(df_cit)
  })
  
  # ----------------------------------------------------------------------------
  # DISTRIBUTION
  # ----------------------------------------------------------------------------
  
  # Filter data according to the fuel
  get_selected_data <- function(fuel, grouping_column) {
    processed_data %>%
      filter(!is.na((!!sym(fuel)))) %>%
      group_by({{ grouping_column }}) %>%
      summarise(average_price = mean(!!sym(fuel), na.rm = TRUE))
  }
  
  # Max/Min indices
  get_max_min_indices <- function(selected_data, max_index, min_index) {
    max_index(which.max(selected_data$average_price))
    min_index(which.min(selected_data$average_price))
  }
  
  # Regions
  selected_data_reg <- reactive({
    fuel <- input$fuel2
    get_selected_data(fuel, Région)
  })
  
  # Department
  selected_data_dpt <- reactive({
    fuel <- input$fuel2
    get_selected_data(fuel, Département)
  })
  
  # Reactive values for Max/Min
  max_index_reg <- reactiveVal(NULL)
  min_index_reg <- reactiveVal(NULL)
  
  max_index_dpt <- reactiveVal(NULL)
  min_index_dpt <- reactiveVal(NULL)
  
  # Observe Max/Min Region & Department
  observe({
    selected_data <- selected_data_reg()
    get_max_min_indices(selected_data, max_index_reg, min_index_reg)
  })
  
  observe({
    selected_data <- selected_data_dpt()
    get_max_min_indices(selected_data, max_index_dpt, min_index_dpt)
  })
  
  # InfoBox content
  render_infoBox <- function(title, selected_data, index, is_region, 
                             high = TRUE) 
    {
    renderInfoBox({
      icon_class <- if (high) {
        "fas fa-arrow-up-right-dots"
      } else {
        "fas fa-arrow-down"
      }
      
      color <- if (high) {
        "red"
      } else {
        "green"
      }
      
      infoBox(
        title,
        if (!is.null(index())) {
          if (is_region) {
            paste(selected_data()$Région[index()], " - ",
                  sprintf("%.3f", selected_data()$average_price[index()]),
                  " €/L")
          } else {
            paste(selected_data()$Département[index()], " - ",
                  sprintf("%.3f", selected_data()$average_price[index()]), 
                  " €/L")
          }
        } else {
          "N/A"
        },
        
        icon = icon(icon_class),
        color = color,
      )
    })
  }
  
  # Lowest Region/Department
  output$lowest_region_Box <- render_infoBox("Région la moins chère", 
                                             selected_data_reg, 
                                             min_index_reg, TRUE, FALSE)
  output$lowest_dep_Box <- render_infoBox("Département le moins cher", 
                                          selected_data_dpt, 
                                          min_index_dpt, FALSE, FALSE)
  
  # Highest Region/Department
  output$highest_region_Box <- render_infoBox("Région la plus chère", 
                                              selected_data_reg, 
                                              max_index_reg, TRUE)
  output$highest_dep_Box <- render_infoBox("Département le plus cher", 
                                           selected_data_dpt, 
                                           max_index_dpt, FALSE)
}
