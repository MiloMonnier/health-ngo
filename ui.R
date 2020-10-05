library(leaflet)

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


# with custom CSS and finer control over the body (100%-100%)
navbarPage("ONG de la santé au Sénégal", id="nav",
  
  
  ## INTERACTTIVE MAP ########################################################
  
  tabPanel("Carte interactive",
    div(class="outer",
      
      # Include our custom CSS
      tags$head(
        tags$link(rel="stylesheet", type="text/css", href="styles.css")
      ),
      
      # If not using custom CSS, set height of leafletOutput to a number instead of percent
      leafletOutput("map", width="100%", height="100%"),
      
      # Add a control panel on the left to set the map representation
      absolutePanel(id="controls", class="panel panel-default",
                    top=30, left="auto", right=10, bottom="auto",
                    width=300, height="auto", draggable=TRUE,
                    
                    # Filter NGOS by the domains of intervention
                    selectInput("sectors", h4("Secteurs d'intervention :"),
                                choices=c("Tout"="", keywords), multiple=TRUE
                    ),

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
      absolutePanel(id="logo", class="card", bottom=20, right=5, fixed=TRUE,
                    tags$a(href='https://www.geomatica-services.com/', 
                      tags$img(src='logo_geomatica.jpeg', height=50))
      )
      
    )
  ),
  
  
  ## DATA EXPLORER #############################################################
  
  tabPanel("Explorateur"
         
    
  )

  
)