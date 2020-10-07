library(leaflet)
library(DT)




# Create a page with several tabs
splitLayout(cellWidths=c("40%","60%"),

  ## INTERACTTIVE MAP (LEFT) ###################################################

  div(class="outer",
    
    # Include our custom CSS  
    tags$head(
      tags$link(rel="stylesheet", type="text/css", href="styles.css")
    ),
    
    # If not using custom CSS, set height of leafletOutput to a number instead of percent
    leafletOutput("map", width="40%", height="100%"),
    
    # Add a control panel on the left to set the map representation
    absolutePanel(id="controls", class="panel panel-default",
                  top="auto", left=5, right="auto", bottom="auto",
                  width="auto", height="auto",
                  
                  # Let the user set the representation mode of the data: proportionnal 
                  # circles or choropleth map. 
                  radioButtons("maptype", h4("Représentation :"),
                               c("Densité (/km2)"="density",
                                 "Cercles proportionnels"="circles"),
                               selected="circles" 
                  )#,
                  
                  # If proportionnal circles chosen, allow user to adjust the circles size
                  # conditionalPanel("input.maptype == 'circles'",
                  #   sliderInput("size", h5("Taille des cercles :"),
                  #               min=0.1, max=1, value=0.5, step=0.1)
                  # )
    ),
    
    # Add a clickable logo of Geomatica
    absolutePanel(id="logo", class="card", bottom=3, left=3, fixed=TRUE,
                  tags$a(href='https://www.geomatica-services.com/', 
                    tags$img(src='logo_geomatica.jpeg', height=30))
    )
    
  ),
  
  
  ## DATA EXPLORER (RIGHT) ####################################################
  
  fluidPage(
    
    # Control Panel in topright corner
    fluidRow(
      # Filter NGOS by their different domains of intervention
      column(4, selectizeInput("keywords", "Mots-clés :",
                               choices=c("All"="", keywords),
                               multiple=TRUE)
      ),
      # Filter ONGs in function of the number of regions of locations
      column(4, numericInput("minreg", "Nb min. de régions :",
                             min=1, max=14, value=1)
      ),
      # Allow user to display or not wanted columns
      column(4, selectizeInput("show_cols", "Colonnes à afficher :",
                               choices=names(ongCols),
                               selected=names(ongCols)[2:3],
                               multiple=TRUE)
      )
    ),
    
    # Display the data table below
    hr(),
    fluidRow(
      column(12, DT::dataTableOutput("table"))
    )
  )
)