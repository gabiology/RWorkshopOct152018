# Exploration file for looking at Debeers behavioural monitoring data.
# modified for R_workshop Oct 15 2018

## <--- double comments for workshop comments


# Setup ----
## this removed all objects in the environment - useful when you've fixed a bug and you're running the file again in the same R session.
rm(list = ls())
## this sets the directory that your R session understands as its home. It becomes the default read and write location.
setwd("~/GitHub/behaviour_data_exploration")

# importing
## tidyverse is a suite of bundled packages. It includes data management, wrangling, and visualization tools.
library(tidyverse)
## lubridate includes tools for working with time data - ignore everything Mike told you, never do it yourself.
## BEWARE THE EXCEL GREMLINS - excel fucks with datetime data. Make sure when opening and looking at data that includes datetime that they haven't fucked around.
library(lubridate)

# Load data ----
# Load in data
gk <- read.csv("~/Google Drive/masters/UNBC/R_workshop/data/GK_2014.csv", T, ",")

# deal with the datetimes
## well, first we have to change the data type to string (or "character").
gk$obv_date <- as.character(gk$obv_date)
gk$obv_time <- as.character(gk$obv_time)

## a cursory check will show some missing values, so let's just lose those rows
gk$obv_date[gk$obv_date == ""]
gk$obv_time[gk$obv_time == ""]
gk$obv_time[gk$obv_date == ""]
gk <- gk[gk$obv_date != "",]

## now we'll combine the two fields before we parse the date times
gk$obv_datetime <- paste(gk$obv_date, gk$obv_time, sep = " ")

# parse the datetimes
gk$datetime <- dmy_hm(gk$obv_datetime)

# EXERCISE 1 ----
## Now we're going to do the same thing for the stressor datetimes!
## The two fields you'll use are "obv_date" and "stressor_time". Call your new field "stressor_datetime".
## fill in the code you would need to redo it here.


# Continue cleaning the dataset ----
# reduce the fields in the dataset for ease of use.
## Most of the removed fields aren't present enough to be useful for any analysis.
## we're deselecting a bunch of fields here. It's to simplify the dataset. Notice that I'm calling the function from the specific package "dplyr". This is due to package conflict. Try it without the "dplyr::" part to see what I mean. Unfortunately there isn't a good fix for function name conflicts in R. You just need to keep on top of it and catch these conflicts as you find them. Python does this much better. "Namespaces are a honking great idea."
gk <- dplyr::select(gk, -Waypoint, -air_temp_C, -weather, -wind_kmh, -wind_direction_from, -wind_comment, -crew, -num_caribou_observed, -obv_time, -obv_date, stressor_time)

# Make the behaviour data proportion data instead of count data
## check which columns have NA values
for(i in 1:ncol(gk)){
  if(anyNA(gk[,i])){
    print(names(gk)[i])
  }
}

# make nas into 0s for behaviour group sizes (awkward, but works)
gk0s <- dplyr::select(gk, -stressor_datetime, -stressor_distance_m) # only other field with NAs that conflicts with this shortcut
gk0s[is.na(gk0s)] <- 0
gk0s <- cbind(gk0s, dplyr::select(gk, stressor_datetime, stressor_distance_m))
gk <- gk0s
rm(gk0s)

# make proportion data for each behaviour
gk <- mutate(gk, bedding_prop = bedding / group_size)
gk <- mutate(gk, foraging_prop = foraging / group_size)
gk <- mutate(gk, standing_prop = standing / group_size)
gk <- mutate(gk, alert_prop = alert / group_size)
gk <- mutate(gk, walking_prop = walking / group_size)
gk <- mutate(gk, trotting_prop = trotting / group_size)
gk <- mutate(gk, running_prop = running / group_size)



# EXERCISE 2 ----
## Separate out the "comp" field into three fields - male, female, young.
## We want to be able to look at the groups with reference to the presence of males, females, and/or young. The current field is hard to work with.
## fill in the code you would need to redo it here.


# EXERCISE 3 ----
# What is the average group foraging proportion?
## Let's do this one together as an example of using pipes, grouping, and summarizing.
a <- gk %>%
  group_by(group_id) %>%
  summarize(foraging_prop_mean = mean(foraging_prop))

## plot the results 












