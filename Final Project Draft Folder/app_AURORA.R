#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(shiny)
library(jsonlite)
library(lubridate)
library(dplyr)
library(tidyr)
library(ggplot2)
library(reshape2)

source("aurora_functions.R")


json_url <- "https://services.swpc.noaa.gov/json/ovation_aurora_latest.json"
json_data <- fromJSON(json_url)
timestamp_utc <-c(json_data$`Observation Time`,json_data$`Forecast Time`) 
timestamp_cst <- with_tz(ymd_hms(timestamp_utc, tz = "UTC"), "America/Chicago")
timestamp_str <- substr(as.character(timestamp_cst),1,38)



ui <- fluidPage(
  tags$a(href = "https://www.swpc.noaa.gov/products/27-day-outlook-107-cm-radio-flux-and-geomagnetic-indices", target = "_blank",
         tags$button("27 day Aurora forecast")),
  tags$a(href = "https://www.windy.com/-Clouds-clouds?clouds,44.996,-97.097,5,m:eYvadFK", target = "_blank",
         tags$button("Clouds map")),
  titlePanel("Aurora Forecast"),
  sidebarLayout(
      sidebarPanel(
        conditionalPanel(condition = "input.forecast_type == '30_minutes'",
                         selectInput("longitude", "Longitude:", choices = unique(forecast_df$longitude)),
                         selectInput("latitude", "Latitude:", choices = unique(forecast_df$latitude))),
        radioButtons("forecast_type", "Choose forecast type:", choices = c("30_minutes", "3_days"), selected = "30_minutes")
                         )
        
      ,
    mainPanel(
      h4("Approximate Energy Deposition(ergs/cm2): "),
      verbatimTextOutput("forecast_output"),
      h4("Forecast Time "),
      verbatimTextOutput("timestamp_text"),
      plotOutput("forecast_plot"),
      tableOutput("table1"),
      tableOutput("table2")
    )))
  


server <- function(input, output) {
  
  
  # Extract forecast data as data frame and rename columns
  forecast_df <- as.data.frame(json_data$coordinates)
  colnames(forecast_df) <- c("longitude", "latitude", "forecast")
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

shinyApp(ui = ui, server = server)