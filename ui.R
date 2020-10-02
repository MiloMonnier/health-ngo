library(leaflet)

keywords = c(
  "all",
  "agriculture",
  "education",
  "enfance",
  "sante",
  "vih",
  "sida",
  "iec"
)
names(keywords) = str_to_title(keywords)


# We use bootstrapPage rather than fluidPagein order to give full extent to the map
# with custom CSS and finer control over the body (100%-100%)
bootstrapPage(
  
  tags$style(type="text/css", "html, body {width:100%;height:100%}"),
  
  # If not using custom CSS, set height of leafletOutput to a number instead of percent
  leafletOutput("map", width="100%", height="100%"),
  
  # Add a control panel on the left to set the map representation
  absolutePanel(id="controls", class="panel panel-default",# Set roads colors
                fixed=TRUE, draggable=TRUE,
                top=10, left="auto", right=10, bottom="auto",
                width="auto", height="auto",
                
                # Filter NGOS by the domains of intervention
                selectInput(
                  "domaine", "Domaine d'intervention :",
                  choices=keywords, selected="all"
                ),
                
                # Let the user set the representation mode of the data: proportionnal 
                # circles or choropleth map. 
                radioButtons("maptype", "Type de représentation :",
                             c("Cercles proportionnels"="circles",
                               "Densité (/km2)"="density")
                ),
                conditionalPanel(
                  condition = "input.matype == 'circles",
                  numericInput("a", "Size factor", value=0.1, min=0.1, max=2, step=0.1)
                )
  )
)

