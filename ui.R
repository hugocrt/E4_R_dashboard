library(shiny)
library(leaflet)


ui <- fluidPage(
  tags$head(
    tags$style(
      HTML(
        "
        /* Body */
        .title-tab {
          text-align: center;
          text-decoration: underline;
        }
        "
      )
    )
  ),
  
  navbarPage(
    "ESIEE PARIS",
    
    tabPanel(
      "Accueil",
      div(
        class = "title-tab",
        "Prix et répartition des carburants par ville en France métropolitaine"
      ),
    ),
    
    tabPanel(
      "Histogramme",
      div(
        class = "title-tab",
        "Distribution des stations essence en France"
      ),
      div(
        class = "histogram-content",
        
        selectInput("fuel", 
                    "Sélectionnez le carburant", 
                    choices = c("Gazole", "SP98", "SP95", "E85", "E10", "GPLc")
                    ),
        
        plotOutput("histogram")
      )
    ),
    
    tabPanel(
      "Cartographie",
      div(
        class = "title-tab",
        "Répartition des stations en France par ville et prix des carburants"
      ),
      
      leafletOutput("map")
    ),
    
    tabPanel(
      "Liens",
      div(
        class = "title-tab",
        "Relation entre les données"
      ),
    )
  )
)
