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

source("aurora_functions.R")


json_url <- "https://services.swpc.noaa.gov/json/ovation_aurora_latest.json"
json_data <- fromJSON(json_url)
timestamp_utc <-c(json_data$`Observation Time`,json_data$`Forecast Time`) 
timestamp_cst <- with_tz(ymd_hms(timestamp_utc, tz = "UTC"), "America/Chicago")
timestamp_str <- substr(as.character(timestamp_cst),1,38)

ui <- fluidPage(
  tags$style(type="text/css", "body {background-color:  #000000}"),
  tags$a(href = "https://www.swpc.noaa.gov/products/27-day-outlook-107-cm-radio-flux-and-geomagnetic-indices", target = "_blank",
         tags$button("27 day Aurora forecast")),
  tags$a(href = "https://www.windy.com/-Clouds-clouds?clouds,44.996,-97.097,5,m:eYvadFK", target = "_blank",
         tags$button("Clouds map")),
  titlePanel(tags$h1("Northern Lights and Star Chasing Guidance", style = "color: white")),
  
  leafletOutput("map", height = "500px", width = "500px"),
  tags$iframe(src="https://stellarium-web.org/p/observations", width="100%", height="400"),
  tags$iframe(src="https://apod.nasa.gov/apod/astropix.html", width="50%", height="200"),
  sidebarLayout(
    sidebarPanel(
      conditionalPanel(condition = "input.forecast_type == '30_minutes'",
                       selectInput("longitude", "Longitude:", choices = unique(forecast_df$longitude)),
                       selectInput("latitude", "Latitude:", choices = unique(forecast_df$latitude))),
      radioButtons("forecast_type", "Choose forecast type:", choices = c("30_minutes", "3_days"), selected = "30_minutes")
    )
    
    ,
    mainPanel(
      h4("Approximate Energy Deposition(ergs/cm2): ", style = "color: white;"),
      verbatimTextOutput("forecast_output"),
      h4("Forecast Time ",style = "color: white;"),
      verbatimTextOutput("timestamp_text"),
      plotOutput("forecast_plot"),
      tableOutput("table1"),
      tableOutput("table2")
    ))
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
        ) ) %>%
      addLegend(      
        position = "bottomright",
        title = "Viewpoints and Camp Sites for Night Sky Gazing",
        colors = col_pal(c("camp_site", "viewpoint")),
        labels = c("Camp Sites", "Lookout Viewpoints")
      )
  })
  
  output$timestamp_text<-renderText(timestamp_str)
  output$forecast_output <- renderText({
    if(input$forecast_type == "30_minutes") {
      forecast <- get_forecast(input$longitude, input$latitude, forecast_df)
      return(forecast)}else {
        NA
      }
  })
  
  # Output the forecast plot
  output$forecast_plot <- renderPlot({
    if(input$forecast_type == "30_minutes") {
      "N/A"
    } else {
      plot_kp
    }
  })
  
  # Output table 1
  output$table1 <- renderTable({
    if(input$forecast_type == "30_minutes") {
      "N/A" } else {
        rb
      }
  })
  
  # Output table 2
  output$table2 <- renderTable(
    {
      if(input$forecast_type == "30_minutes") {
        "N/A"} else {
          srs
        }
    })
  
}

shinyApp(ui, server)

