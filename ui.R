library(leaflet)
library(DT)

keywords = c(
  "agriculture",
  "education",
  "enfance",
  "sante",
  "vih",
  "sida",
  "iec"
)
names(keywords) = str_to_title(keywords)


# Create a page with several tabs
splitLayout(cellWidths=c("40%","60%"),

  ## LEFT: INTERACTTIVE MAP ####################################################

  div(class="outer",
    
    # Include our custom CSS  
    tags$head(
      tags$link(rel="stylesheet", type="text/css", href="styles.css")
    ),
    
    # If not using custom CSS, set height of leafletOutput to a number instead of percent
    leafletOutput("map", width="40%", height="100%"),
    
    # Add a control panel on the left to set the map representation
    absolutePanel(id="controls", class="panel panel-default",
                  top=30, left=10, right="auto", bottom="auto",
                  width=300, height="auto", draggable=TRUE,
                  

                  
                  # Let the user set the representation mode of the data: proportionnal 
                  # circles or choropleth map. 
                  radioButtons("maptype", h4("Représentation :"),
                               c("Densité (/km2)"="density",
                                 "Cercles proportionnels"="circles"),
                               selected="circles" 
                  ),
                  
                  # If proportionnal circles chosen, allow user to adjust the circles size
                  conditionalPanel("input.maptype == 'circles'",
                    sliderInput("size", h5("Taille des cercles :"),
                                min=0.1, max=1, value=0.5, step=0.1)
                  )
    ),
    
    # Add a clickable logo of Geomatica
    absolutePanel(id="logo", class="card", bottom=3, left=3, fixed=TRUE,
                  tags$a(href='https://www.geomatica-services.com/', 
                    tags$img(src='logo_geomatica.jpeg', height=30))
    )

  ),
  
  
  ## DATA EXPLORER #############################################################
  fluidRow(
    
    # Filter NGOS by their different domains of intervention
    column(6,
      selectInput("sectors", "Secteurs d'intervention:", keywords, multiple=TRUE)
    ),
    column(6,
      verbatimTextOutput("txt")
    ),
    
    # Display the data table below
    hr(),
    column(12,
      DT::dataTableOutput("table")
    )
  )

)