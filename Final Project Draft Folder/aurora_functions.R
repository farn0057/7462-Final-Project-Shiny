library(jsonlite)
library(lubridate)
library(dplyr)
library(tidyr)
library(ggplot2)
library(reshape2)

#3 day forecast
forecast_url <- "https://services.swpc.noaa.gov/text/3-day-forecast.txt"
forecast_text <- readLines(forecast_url)
k<-forecast_text[14]
df_kp0 <-forecast_text[15:22]
# split the string by whitespace characters
k_split <- unlist(strsplit(k, "\\s+"))
k_combined <- paste(k_split, collapse = " ")

# extract the relevant elements
k_dates <- substr(k_combined, start = 1, stop = nchar(k_combined))
k_dates <- gsub(" ", "", k_dates)
k_split <- strsplit(k_dates, "(?<=.{5})", perl = TRUE)[[1]]


#clean the data
df_kp1 <- matrix(nrow=8, ncol=7)
for (i in 1:8){
  row_vals <- unlist(strsplit(df_kp0[i], "\\s+"))
  df_kp1[i,1] <- row_vals[1]
  df_kp1[i,2] <- as.numeric(row_vals[2])
  df_kp1[i,3] <- ifelse(grepl("G", row_vals[3]), row_vals[3], NA)
  df_kp1[i,4] <- ifelse(grepl("G", row_vals[3]),as.numeric(row_vals[4]),as.numeric(row_vals[3]))
  df_kp1[i,5] <- ifelse(grepl("G", row_vals[5]), row_vals[5], NA)
  df_kp1[i,6] <- ifelse(grepl("G", row_vals[3]),ifelse(grepl("G", row_vals[5]),as.numeric(row_vals[6]),
                                                   as.numeric(row_vals[5])),as.numeric(row_vals[4]))
  df_kp1[i,7] <- ifelse(grepl("G", row_vals[7]), row_vals[7], NA)
}

colnames(df_kp1) <- c("time", k_split[1],'tag',k_split[2],'tag',k_split[3],'tag')
keep_cols <- which(!grepl("tag", colnames(df_kp1)))
df_kp1<-df_kp1[,keep_cols]
df_kp1<-as.data.frame(df_kp1)

# convert the times to CST timezone
utc_to_cst <- function(hour_range) {
  # split the hour range into start and end hours
  start_hour <- as.integer(substring(hour_range, 1, 2))
  end_hour <- as.integer(substring(hour_range, 4, 5))
  
  # convert the start and end hours to POSIXct format in UTC timezone
  start_time <- as.POSIXct(paste(Sys.Date(), sprintf("%02d:00:00", start_hour)), tz = "UTC")
  end_time <- as.POSIXct(paste(Sys.Date(), sprintf("%02d:00:00", end_hour)), tz = "UTC")
  
  # convert the start and end times to CST timezone
  start_time_cst <- with_tz(start_time, "America/Chicago")
  end_time_cst <- with_tz(end_time, "America/Chicago")
  
  # combine the start and end times into a character string
  time_range_cst <- paste(format(start_time_cst, "%H:%M"), format(end_time_cst, "%H:%M"), sep = "-")
  
  return(time_range_cst)
}

# apply the utc_to_cst function to the time column
df_kp1$time <- sapply(df_kp1$time, utc_to_cst)

kp_data_long <- reshape2::melt(df_kp1, id.vars = "time", variable.name = "Date", value.name = "kp")

plot_kp <- 
  # Create a bar plot for each day using facet_wrap
  ggplot(kp_data_long, aes(y = time, x = kp, fill = Date)) +
    geom_bar(stat = "identity") +
    facet_wrap(~ Date, ncol = 3) +
    scale_fill_manual(values = c("#FF6666", "#66CCFF", "#99CC33")) + # Set custom fill colors
    ylab("") +
    xlab("kp Value") +
    ggtitle("kp Value for Different Time (CST) in the latest three Days")

#Radio Blackout Forecast for the latest three days
rb<-forecast_text[45:49]
#Solar Radiation Storm Forecast for the latest three days
srs<-forecast_text[32:35]

#30 minutes forecast

# Read in JSON file from URL
json_url <- "https://services.swpc.noaa.gov/json/ovation_aurora_latest.json"
json_data <- fromJSON(json_url)

# Extract forecast data as data frame and rename columns
forecast_df <- as.data.frame(json_data$coordinates)
colnames(forecast_df) <- c("longitude", "latitude", "forecast")

timestamp_utc <-c(json_data$`Observation Time`,json_data$`Forecast Time`) 
timestamp_cst <- with_tz(ymd_hms(timestamp_utc, tz = "UTC"), "America/Chicago")

get_forecast <- function(longitude, latitude,forecast_df) {
  forecast <- forecast_df[forecast_df$longitude == longitude & forecast_df$latitude == latitude, "forecast"]
  return(forecast)
}

