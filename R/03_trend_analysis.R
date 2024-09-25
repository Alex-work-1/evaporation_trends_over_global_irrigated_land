##
#Step 3: Slope calculations [global trend]
##

# load libraries

library("data.table")
library("dplyr")
library(ggplot2)
library(pRecipe)


# Load data
gleam_dataframe <- readRDS("data/processed/gleam_e_dt_1980_2021_monthly.rds")

# convert to data table format
gleam_datatable <- as.data.table(gleam_dataframe)

# convert text date into date object 
gleam_datatable[, Date := as.Date(Date, format = "%Y-%m-%d")]



## linear trend for mean global ET 
# get the world evapotranspiration mean by date
gleam_datatable_mean <- gleam_datatable %>%
  group_by(Date) %>%
  summarise(`Mean evapotranspiration [mm]` = mean(`Evapotranspiration [mm]`))

# conduct a global linear regression analysis
model <- lm(`Mean evapotranspiration [mm]` ~ Date, data = gleam_datatable_mean)

# print out the text results of a global linear regression analysis
summary(model)

# Visualization  of a global linear regression analysis

ggplot(gleam_datatable_mean, aes(x = Date, y = `Mean evapotranspiration [mm]`)) +
  geom_line() +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  labs(x = "Date", y = "Mean evapotranspiration [mm]") +
  theme_classic() +
  labs(title = "Linear regression trend", 
       subtitle = paste0("y = ", 
                         model$coefficients[2], 
                         "x + " , 
                         model$coefficients[1]))

# Save plot
ggsave(filename = "Global linear regression.png",
       path = "./data/results/",
       device = "png",
       plot = last_plot(),
       create.dir = TRUE)

