library(leaflet)


# We use bootstrapPage rather than fluidPagein order to give full extent to the map
# with custom CSS and finer control over the body (100%-100%)
bootstrapPage(
# navBarPage(
  
  tags$style(type="text/css", "html, body {width:100%;height:100%}"),
  
  # If not using custom CSS, set height of leafletOutput to a number instead of percent
  leafletOutput("map", width="100%", height="100%"),
  
  # Add a control panel on the left to set the map representation
  absolutePanel(id="controls", class="panel panel-default",# Set roads colors
                fixed=TRUE, draggable=TRUE,
                top=100, left=20, right="auto", bottom="auto",
                width="auto", height="auto",
                
                # Let the user set the representation mode of the data: proportionnal 
                # circles or choropleth map. 
                radioButtons("maptype", "Map representation:",
                             c("Proportionnal circles"="circles",
                               "Density"="density")
                ),
                # If density choropleth map is chosen, let the choice between /hab or /km2
                conditionalPanel("input.maptype == 'density'",
                                 radioButtons("chorotype", NULL,
                                              c("/km2"="km",
                                                "/hab"="hab")
                                 )
                )
  )
  
  
)