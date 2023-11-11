library(shiny)
library(leaflet)

ui <- dashboardPage(
  skin = "black",
  
  # ----------------------------------------------------------------------------
  # HEADER
  # ----------------------------------------------------------------------------
  
  dashboardHeader(
    title = "ESIEE Paris",
    
    dropdownMenu(
      type = "messages",
      icon = icon("far fa-calendar"),
      headerText = textOutput("date")
    ),
    
    dropdownMenu(
      type = "messages",
      icon = icon("far fa-copyright"),
      headerText = HTML(
      "Copyright © 2023 / 2024 <br> 
      CARANGEOT Hugo / SALI--ORLIANGE Lucas <br> 
      Encadrés par Monsieur COURIVAUD D. <br> 
      DSIA-4101A : Python pour la Data Science")
    )
  ),
  
  # ----------------------------------------------------------------------------
  # SIDEBAR
  # ----------------------------------------------------------------------------
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Histogramme", tabName = "histogram", 
               icon = icon("chart-simple")),
      menuItem("Cartographie", tabName = "map", 
               icon = icon("map-location")),
      menuItem("Pie Chart", tabName = "piechart", 
               icon = icon("chart-pie")),
      menuItem("Distribution", tabName = "distribution", 
               icon = icon("th"))
    )
  ),
  
  # ----------------------------------------------------------------------------
  # BODY
  # ----------------------------------------------------------------------------
  dashboardBody(
    tabItems(
      
      # ------------------------------------------------------------------------
      # HISTOGRAM
      # ------------------------------------------------------------------------
      
      tabItem(
        tabName = "histogram",
        fluidRow(
          box(
            title = "Distribution des carburants",
            status = "primary",
            solidHeader = TRUE,
            collapsible = FALSE,
            width = 12,
            
            selectInput(
              "fuel",
              "Sélectionnez le carburant",
              choices = c("Gazole", "SP98", "SP95", "E85", "E10", "GPLc")
            ),
            
            plotOutput("histogram", height = 750),
          )
        ),
      ),
      
      # ------------------------------------------------------------------------
      # CARTOGRAPHY
      # ------------------------------------------------------------------------
      
      tabItem(
        tabName = "map",
        fluidRow(
          box(
            title = "Cartographie des différentes stations en France",
            status = "primary",
            solidHeader = TRUE,
            collapsible = FALSE,
            width = 12,
            
            leafletOutput("map", height = 800)
          )
        )
      ),
      
      # ------------------------------------------------------------------------
      # PIE CHART
      # ------------------------------------------------------------------------
      
      tabItem(
        tabName = "piechart",
        
        tabBox(
          title = "Distribution par Région",
          width = 12,
          
          # First pie chart
          tabPanel(tags$h3("Distribution des Stations par Région", 
                           style = "font-size: 20px;"),
                   plotOutput("piereg", height = 800)),
          
          # Second pie chart
          tabPanel(tags$h3("Distribution des Villes avec au moins 1 station par 
                           Région", style = "font-size: 20px;"),
                   plotOutput("piecit", height = 800))
        )
      ),
      
      # ------------------------------------------------------------------------
      # DISTRIBUTION
      # ------------------------------------------------------------------------
      
      tabItem(
        tabName = "distribution",
      
        selectInput(
          "fuel2",
          "Sélectionnez le carburant",
          choices = c("Gazole", "SP98", "SP95", "E85", "E10", "GPLc")
        ),
        
        fluidRow(
          box(
            title = "Valeurs extrêmes",
            status = "primary",
            solidHeader = TRUE,
            collapsible = FALSE,
            width = 12,
            class = "test",

            infoBoxOutput("lowest_dep_Box", width = 3),
            infoBoxOutput("highest_dep_Box", width = 3),
            infoBoxOutput("lowest_region_Box", width = 3),
            infoBoxOutput("highest_region_Box", width = 3)
          )
        )
      )
    )
  )
)
