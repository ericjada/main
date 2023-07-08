# Packages
library(tidyverse)
library(geosphere)
library(lubridate)

# Set the directory path where your CSV files are located
directory_path <- "~/Coursera/Case Study 1 How does a bike-share navigate speedy success/unzipped"

# Get a list of all CSV files in the directory
csv_files <- list.files(directory_path, pattern = "\\.csv$", full.names = TRUE)

# Create an empty list to store individual data frames
data_frames <- list()

# Loop through each CSV file and read it into a data frame
for (file in csv_files) {
  data <- read.csv(file)
  data_frames[[file]] <- data
}

# Combine all data frames into a single data frame
combined_df <- do.call(rbind, data_frames)

## SUMMARY ##
summary(combined_df)
#############

# Create new column for day of the week / new column day_of_week
combined_df <- combined_df %>%
  mutate(day_of_week = wday(started_at, label = TRUE))

# Calculate the ride duration in minutes / new column ride_duration
combined_df$ride_duration <- as.numeric(difftime(combined_df$ended_at, combined_df$started_at, units = "mins"))

# it appears that there might be some issues with the ride duration values. 
# The minimum value of -10353.35 and the maximum value of 41387.25 seem unusual 
# for ride duration in minutes.


## Adding distance_meters & distance_miles columns

# Calculate distance in meters between start and end coordinates
combined_df$distance_meters <- distGeo(
  cbind(combined_df$start_lng, combined_df$start_lat),
  cbind(combined_df$end_lng, combined_df$end_lat)
)

# Convert distance in meters to miles
combined_df$distance_miles <- combined_df$distance_meters * 0.000621371


## Duplicates

# Check for duplicates in the combined_df dataset
duplicates <- duplicated(combined_df)

# Count the number of duplicates
num_duplicates <- sum(duplicates)

# Remove duplicated rows
#combined_df <- combined_df[!duplicated(combined_df), ]


# Remove rows with NA values from the combined_df data frame
combined_df <- na.omit(combined_df)


# To identify and potentially remove distance outliers from your combined_df 
# data frame, you can apply a similar approach as with ride duration outliers. 
# One common technique is to use z-scores to identify observations that are 
# significantly different from the mean. Here's an example of how you can 
# identify and handle outliers:

## MILES OUTLIERS
# Calculate z-scores for the distance_miles column
z_scores <- scale(combined_df$distance_miles)

# Define a threshold for distance outliers (e.g., z-score greater than 3 or less than -3)
threshold <- 3

# Identify rows with distance outliers
outlier_rows <- abs(z_scores) > threshold

# Count the number of outliers
num_outliers <- sum(outlier_rows)

# Optionally, you can remove the outliers from the combined_df data frame
combined_df <- combined_df[!outlier_rows, ]

## METERS OUTLIERS
# Calculate z-scores for the distance_meters column
z_scores_distance <- scale(combined_df$distance_meters)

# Define a threshold for distance_meters outliers (e.g., z-score greater than 3 or less than -3)
threshold_distance <- 3

# Identify rows with distance_meters outliers
outlier_rows_distance <- abs(z_scores_distance) > threshold_distance

# Count the number of distance_meters outliers
num_outliers_distance <- sum(outlier_rows_distance)

# Optionally, you can remove the outliers from the combined_df data frame
combined_df <- combined_df[!outlier_rows_distance, ]


## DURATION OUTLIERS
# Calculate z-scores for the ride_duration column
z_scores_duration <- scale(combined_df$ride_duration)

# Define a threshold for ride_duration outliers (e.g., z-score greater than 3 or less than -3)
threshold_duration <- 3

# Identify rows with ride_duration outliers
outlier_rows_duration <- abs(z_scores_duration) > threshold_duration

# Count the number of ride_duration outliers
num_outliers_duration <- sum(outlier_rows_duration)

# Optionally, you can remove the outliers from the combined_df data frame
combined_df <- combined_df[!outlier_rows_duration, ]

## Remove negative duration values from the combined_df data frame
combined_df <- combined_df[combined_df$ride_duration >= 0, ]

# convert the ride_duration column to numeric and the started_at and ended_at 
# columns to date/time
combined_df$ride_duration <- as.numeric(combined_df$ride_duration)
combined_df$started_at <- as.POSIXct(combined_df$started_at)
combined_df$ended_at <- as.POSIXct(combined_df$ended_at)

# Remove the "ride_id", "start_station_id", and "end_station_id" columns
combined_df <- combined_df[, !(names(combined_df) %in% c("ride_id", "start_station_id", "end_station_id"))]

# round distance_meters, distance_miles, and duration_min columns to 2 decimal places
combined_df$distance_meters <- round(combined_df$distance_meters, 2)
combined_df$distance_miles <- round(combined_df$distance_miles, 2)
combined_df$ride_duration <- round(combined_df$ride_duration, 2)

# Filter the data for annual members and casual riders separately
annual_members <- combined_df[combined_df$member_casual == "member", ]
casual_riders <- combined_df[combined_df$member_casual == "casual", ]

# Calculate the average ride duration for annual members and casual riders
avg_ride_duration <- tapply(annual_members$ride_duration, annual_members$day_of_week, mean)
avg_ride_duration_casual <- tapply(casual_riders$ride_duration, casual_riders$day_of_week, mean)

# Calculate the average distance for annual members and casual riders
avg_distance <- tapply(annual_members$distance_miles, annual_members$day_of_week, mean)
avg_distance_casual <- tapply(casual_riders$distance_miles, casual_riders$day_of_week, mean)


## Visuals
# Create a bar plot to compare the average ride duration between annual members and casual riders
barplot(rbind(avg_ride_duration, avg_ride_duration_casual),
        beside = TRUE,
        names.arg = c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"),
        xlab = "Day of Week",
        ylab = "Average Ride Duration (minutes)",
        main = "Average Ride Duration by Day of Week",
        col = c("blue", "red"))

# Manually position and adjust the size of the legend
legend("bottomright",
       legend = c("Annual Members", "Casual Riders"),
       fill = c("blue", "red"),
       cex = 0.5)  # Adjust the value of cex to make the legend smaller


# Create a bar plot to compare the average distance between annual members and casual riders
barplot(rbind(avg_distance, avg_distance_casual),
        beside = TRUE,
        names.arg = c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"),
        xlab = "Day of Week",
        ylab = "Average Distance (miles)",
        main = "Average Distance by Day of Week",
        col = c("blue", "red"))

# Manually position and adjust the size of the legend
legend("bottomright",
       legend = c("Annual Members", "Casual Riders"),
       fill = c("blue", "red"),
       cex = 0.5)  # Adjust the value of cex to make the legend smaller

# Calculate the ride frequency for annual members and casual riders
ride_frequency <- table(combined_df$member_casual)

# Plotting the ride frequency
ggplot(data = NULL, aes(x = factor(names(ride_frequency)), y = ride_frequency)) +
  geom_bar(stat = "identity", fill = "blue", width = 0.5) +
  labs(x = "User Type", y = "Ride Frequency", title = "Ride Frequency by User Type") +
  scale_y_continuous(labels = scales::comma)

# Plotting histograms for ride duration distribution
ggplot(combined_df, aes(x = ride_duration, fill = member_casual)) +
  geom_histogram(binwidth = 2, position = "identity", alpha = 0.7) +
  facet_wrap(~ member_casual, ncol = 1) +
  labs(x = "Ride Duration (minutes)", y = "Frequency", title = "Ride Duration Distribution by User Type") +
  scale_x_continuous(labels = scales::comma) +
  scale_y_continuous(labels = scales::comma)
  

# Plotting histograms for ride distance distribution
ggplot(combined_df, aes(x = distance_miles, fill = member_casual)) +
  geom_histogram(binwidth = 0.5, position = "identity", alpha = 0.7) +
  facet_wrap(~ member_casual, ncol = 1) +
  labs(x = "Ride Distance (miles)", y = "Frequency", title = "Ride Distance Distribution by User Type")

##
# Calculate the most popular start and end stations for annual members and casual riders
popular_start_stations <- combined_df %>%
  group_by(member_casual, start_station_name) %>%
  summarise(total_rides = n()) %>%
  top_n(10, total_rides) %>%
  arrange(member_casual, desc(total_rides))

popular_end_stations <- combined_df %>%
  group_by(member_casual, end_station_name) %>%
  summarise(total_rides = n()) %>%
  top_n(10, total_rides) %>%
  arrange(member_casual, desc(total_rides))

# Create bar plots for popular start and end stations
ggplot(popular_start_stations, aes(x = reorder(start_station_name, -total_rides), y = total_rides, fill = member_casual)) +
  geom_bar(stat = "identity", width = 0.5) +
  labs(x = "Start Station", y = "Number of Rides", title = "Popular Start Stations by User Type") +
  theme_minimal() +
  coord_flip()

ggplot(popular_end_stations, aes(x = reorder(end_station_name, -total_rides), y = total_rides, fill = member_casual)) +
  geom_bar(stat = "identity", width = 0.5) +
  labs(x = "End Station", y = "Number of Rides", title = "Popular End Stations by User Type") +
  theme_minimal() +
  coord_flip()

# Calculate the average number of rides per day for annual members and casual riders
ride_counts_by_day <- combined_df %>%
  group_by(member_casual, day_of_week) %>%
  summarise(ride_count = n()) %>%
  mutate(ride_count_avg = ride_count / n_distinct(day_of_week))

# Define the order of the days of the week
day_order <- c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")

# Create a bar plot to visualize ride patterns by the day of the week
ggplot(ride_counts_by_day, aes(x = day_of_week, y = ride_count_avg, fill = member_casual)) +
  geom_bar(stat = "identity", width = 0.5) +
  labs(x = "Day of Week", y = "Average Number of Rides", title = "Ride Patterns by Day of the Week") +
  scale_x_discrete(limits = day_order) +
  scale_y_continuous(labels = scales::comma) +  # Format y-axis labels with commas
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust = 1))


# Calculate average ride duration for casual riders
casual_avg_duration <- combined_df %>%
  filter(member_casual == "casual") %>%
  summarise(avg_duration = mean(ride_duration))

# Calculate average ride duration for annual members
member_avg_duration <- combined_df %>%
  filter(member_casual == "member") %>%
  summarise(avg_duration = mean(ride_duration))

# Print the results
casual_avg_duration
member_avg_duration



# Write altered csv file
write.csv(combined_df, file = "combined_df.csv", row.names = FALSE)