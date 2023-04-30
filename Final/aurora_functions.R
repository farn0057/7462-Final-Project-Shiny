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
kp_data_long <- reshape2::melt(df_kp1, id.vars = "time", variable.name = "Date", value.name = "kp")
# Create a new variable that combines Date and time
kp_data_long$datetime <- as.POSIXct(paste(kp_data_long$Date, kp_data_long$time), format="%b%d %H-%MUT")

# Remove the original Date and time variables
kp_data_long$Date <- NULL
kp_data_long$time <- NULL


# convert the times to CST timezone
# split the datetime into date and time components in CST timezone
# convert the datetime to CST timezone and format as month:date:hour:minute
utc_to_cst <- function(datetime) {
  # convert the datetime to POSIXct format in UTC timezone
  datetime_utc <- as.POSIXct(datetime, format="%b%d %H-%MUT", tz = "UTC")
  
  # convert the datetime to CST timezone
  datetime_cst <- with_tz(datetime_utc, "America/Chicago")
  
  # format the datetime as month:date:hour:minute
  datetime_cst_formatted <- format(datetime_cst, "%b:%d:%H:%M")
  
  return(datetime_cst_formatted)
}

kp_data_long$datetime <- sapply(kp_data_long$datetime, utc_to_cst)

kp_data_long <- kp_data_long %>%
  separate(datetime, into = c("col1", "col2", "col3", "col4"), sep = ":") %>%
  unite(Date, col1, col2, sep = ":") %>%
  unite(time, col3, col4, sep = ":") %>%
  select(Date, time, kp)



plot_kp <- 
  # Create a bar plot for each day using facet_wrap
  ggplot(kp_data_long, aes(x = time, y = kp, fill = Date)) +
  geom_col() +
  facet_wrap(~ Date, ncol = 3) +
  scale_fill_manual(values = c("#FF6666", "#66CCFF", "#99CC33")) + # Set custom fill colors
  ylab("Kp Value") +
  xlab("") +
  coord_flip()+
  ggtitle("kp Value for Different Time (CST) in the latest three Days")

#Radio Blackout Forecast for the latest three days
rb<-forecast_text[46:49]
#Solar Radiation Storm Forecast for the latest three days
srs<-forecast_text[33:36]

#30 minutes forecast

# Read in JSON file from URL
json_url <- "https://services.swpc.noaa.gov/json/ovation_aurora_latest.json"
json_data <- fromJSON(json_url)

# Extract forecast data as data frame and rename columns
forecast_df <- as.data.frame(json_data$coordinates)
colnames(forecast_df) <- c("longitude", "latitude", "forecast")

forecast_df$longitude <- (forecast_df$longitude + 180) %% 360 - 180

timestamp_utc <-c(json_data$`Observation Time`,json_data$`Forecast Time`) 
timestamp_cst <- with_tz(ymd_hms(timestamp_utc, tz = "UTC"), "America/Chicago")

get_forecast <- function(longitude, latitude,forecast_df) {
  forecast <- forecast_df[forecast_df$longitude == longitude & forecast_df$latitude == latitude, "forecast"]
  return(forecast)
}

