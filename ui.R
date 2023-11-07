library(shiny)
library(leaflet)


ui <- fluidPage(
  tags$head(
    tags$style(
      HTML(
        "
        /* -------------------------------------------------------------------*/
        /* Body */
        /* -------------------------------------------------------------------*/
        
        .title-tab {
          font-family: 'Arial', 'sans-serif';
          text-decoration: underline;
          background = #1A1A1A;
          margin-bottom : 25px;
          text-align: center;
          font-weight: bold;
          font-size: 25px;
        }
        
        /* Make the map take up the full space of the tab */
        #map {
          height: 100%;
          width: 100%;
        }
        "
      )
    )
  ),
  
  navbarPage(
    "ESIEE PARIS",
    
    tabPanel(
      "Histogramme",
      
      div(
        class = "title-tab",
        "Distribution des stations essence en France"
      ),
      
      mainPanel(
        
        selectInput("fuel", 
                    "Sélectionnez le carburant", 
                    choices = c("Gazole", "SP98", "SP95", "E85", "E10", "GPLc")
        ),
        
        plotOutput("histogram"),
      ),
    ),
    
    tabPanel(
      "Cartographie",
      
      div(
        class = "title-tab",
        "Répartition des stations en France par ville et prix des carburants"
      ),
      
      mainPanel(
        leafletOutput("map", height = "800px", width = "1800px")
      ),
    )
  )
)
