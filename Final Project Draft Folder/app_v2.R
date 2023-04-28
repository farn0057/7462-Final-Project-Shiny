library(shiny)
library(leaflet)
library(osmdata)
library(jsonlite)
library(lubridate)
library(tidyverse)
library(ggplot2)
library(reshape2)
library(gt)
library(paletteer)
library(plotly)
library(flexdashboard)
library(tidycensus)
library(osmdata)
library(sf)
library(ggmap)
library(tigris)
library(viridis, quietly = TRUE)
library(leaflet.minicharts)
library(htmltools)
library(geosphere)
#library(mapview)
source("aurora_functions.R")


json_url <- "https://services.swpc.noaa.gov/json/ovation_aurora_latest.json"
json_data <- fromJSON(json_url)
timestamp_utc <-c(json_data$`Observation Time`,json_data$`Forecast Time`) 
timestamp_cst <- with_tz(ymd_hms(timestamp_utc, tz = "UTC"), "America/Chicago")
timestamp_str <- substr(as.character(timestamp_cst),1,38)





ui <- fluidPage(
  tags$style(type="text/css", "body {background-color:  #000033}"),
  tags$style(".big-button { font-size: 14px; padding: 4px 7px; }"),
  tags$a(href = "https://www.swpc.noaa.gov/products/27-day-outlook-107-cm-radio-flux-and-geomagnetic-indices", target = "_blank",
         tags$button(class = "big-button","27 day Aurora forecast")),
  tags$a(href = "https://www.windy.com/-Clouds-clouds?clouds,44.996,-97.097,5,m:eYvadFK", target = "_blank",
         tags$button(class = "big-button","Clouds map")),
  
  tags$head(tags$style(
    HTML(
      "body {
        background-image: url('https://apod.nasa.gov/apod/image/2304/AlphaCamelopardis_s3100.png');
        background-repeat: no-repeat;
        background-position: center center;
        background-attachment: fixed;
        background-size: cover;
      }"
    )
  )),
  titlePanel(tags$h1("Northern Lights and Star Chasing Guidance", style = "color: white")),
  
  leafletOutput("map", height = "500px", width = "100%"),
  div(id = "my-iframe", style = "height: 70px;"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("longitude", "Longitude:", min = min(forecast_df$longitude), 
                  max = max(forecast_df$longitude), value = -90.5500),
      sliderInput("latitude", "Latitude:", min = min(forecast_df$latitude), 
                  max = max(forecast_df$latitude), value = 47.9167)
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Energy Deposition",
                 h4("Approximate Energy Deposition(ergs/cm2): ", style = "color: white;"),
                 verbatimTextOutput("forecast_output"),
                 h4("Forecast Time ",style = "color: white;"),
                 verbatimTextOutput("timestamp_text")),
        tabPanel("Plot", plotOutput("forecast_plot")),
        tabPanel("Radio Blackout Forecast",
                 tableOutput("table1"), style = "color: white;"),
        tabPanel("Solar Radiation Storm Forecast",
                 tableOutput("table2"), style = "color: white;")
      )
    )
  ),
  div(id = "my-iframe", style = "height: 70px;"),
  tags$iframe(src="https://stellarium-web.org/p/observations", width="100%", height="500")
  
  )

server <- function(input, output) {
  # Extract forecast data as data frame and rename columns
  forecast_df <- as.data.frame(json_data$coordinates)
  colnames(forecast_df) <- c("longitude", "latitude", "forecast")
  
  
  output$map <- renderLeaflet({
    osmdata <- opq(bbox = "Cook County, MN") %>% 
      add_osm_feature(key = "tourism", value = c("camp_site", "viewpoint"))%>%
      osmdata_sf()      
    
    col_pal <- leaflet::colorFactor(palette = "viridis", 
                                    domain = c("camp_site", "viewpoint"))  
   
     #Create a reactive variable to store the selected points:
    selected_points <- reactiveValues()
    #create lng and lat data
    # Convert osm_points to an sf object
    osm_points_sf <- st_as_sf(osmdata$osm_points)
    
    # Convert the geometry column to a data.frame
    osm_points_df <- st_coordinates(osm_points_sf)
    
    # Set column names
    colnames(osm_points_df) <- c("Longitude", "Latitude")
    
    # Clean the coordinator
    osm_points_sf$geometry <- gsub("POINT \\((.*)\\)", "\\1", osm_points_sf$geometry)
    
    #split out the longtitude and the latitude
    my_var_split <- matrix(nrow=length(osm_points_sf$geometry), ncol=2)
    
    for (i in 1:length(osm_points_sf$geometry)) {
      my_var_split[i,] <- as.numeric(unlist(strsplit(gsub("[c()]", "", osm_points_sf$geometry[i]), ",")))
    }
    
    observeEvent(input$map_click, {
      click <- input$map_click
      lat <- click$lat
      lng <- click$lng
      
      closest_point <- NULL
      
      if (!is.na(lat) && !is.na(lng)) {
        my_var_split <- as.data.frame(matrix(as.numeric(strsplit(gsub("[c()]", "", osm_points_sf$geometry), ",")[[1]]), ncol=2, byrow=T))
        closest_point <- my_var_split[which.min(geosphere::distm(
          c(lng, lat), 
          c(my_var_split[,1],my_var_split[,2]),
          fun = distVincentyEllipsoid
        )), ]
      }
      
      if (!is.null(closest_point)) {
        # Add the point to the selected points list
        selected_points$points <- rbind(selected_points$points, closest_point)
      }
    })
    
    
    osmdata$osm_points$lng<-my_var_split[,1]
    osmdata$osm_points$lat<-my_var_split[,2]
    leaflet(data = filter(osmdata$osm_points, tourism %in% c("camp_site", "viewpoint"))) %>%
      addTiles() %>%
      addCircleMarkers(
        color = ~col_pal(tourism), 
        opacity="0.8",
        weight="2",
        radius="2",
        label = ~name, 
        labelOptions = labelOptions(
          textOnly = TRUE, 
          direction = "auto",
          fontSize = "30px", 
          fontColor = "black", 
          boxshadow = "3px 3px rgba(0,0,0,0.25)",
          textShadow = "3px 3px white"
        ),
        popup = paste0("Latitude: ", round(osmdata$osm_points$lat, 6), "<br>",
                       "Longitude: ", round(osmdata$osm_points$lng, 6), "<br>",
                       "Camp Size: ", osmdata$osm_points$camp_site)
        ) %>%
      addLegend(      
        position = "bottomright",
        title = "Viewpoints and Camp Sites for Night Sky Gazing",
        colors = col_pal(c("camp_site", "viewpoint")),
        labels = c("Camp Sites", "Lookout Viewpoints"),
        opacity = 1,
        labFormat = labelFormat(
          label = function(label, type) {
            if (type == "color") {
              return(NULL)
            } else {
              return("Click a point to see details")
            }
          }
        )
      )
  })
  
  output$timestamp_text<-renderText(timestamp_str)
  output$forecast_output <- renderText({
    
      forecast <- get_forecast(input$longitude, input$latitude, forecast_df)
      
  })
  
  # Output the forecast plot
  output$forecast_plot <- renderPlot({
    
      plot_kp
   
  })
  
  # Output table 1
  output$table1 <- renderTable({
        rb
      
  })
  
  # Output table 2
  output$table2 <- renderTable({
      
          srs
       
    })
  
}

shinyApp(ui, server)

