##
#Step 3: Slope calculations [global annual cropland trend] (linear regression and loess)
##
source("./source/main.R")


# --- Step 1: Define necessary variables ---
gleam_dt_joined <- data.table()


# --- Step 2: Get the data paths ---
evap_data_paths <- list.files(path = PATH_SAVE, 
                              full.names = TRUE, 
                              pattern = "yearly_cropped_\\S+C\\d\\S?.rds") #select all files which contain _cropped_ and end with .rds


# --- Step 3: preprocess data  ---
# loop through every masked ET data files 
for (evap_data_path in evap_data_paths) {
  # import ET data
  gleam_dataframe <- readRDS(evap_data_path)
  
  
  # convert to data table format
  gleam_datatable <- as.data.table(gleam_dataframe)
  
  # convert text date into date object
  gleam_datatable[, Date := as.Date(Date, format = "%Y-%m-%d")]
  
  # get the world evapotranspiration mean by date
  gleam_datatable_mean <- gleam_datatable %>%
    na.omit() %>%
    group_by(Date) %>%
    summarise(`Mean evapotranspiration [mm]` = mean(`evap`)) %>%
    as.data.table() # convert the result to data table for future use
  
  
  # --- Step 4: Get summary of linear regression ---
  
  # Get the category name
  category_name <- get_file_name(evap_data_path)
  category_name <- str_split_i(category_name, "_", -1)

  
  # conduct a global linear regression analysis
  model <- lm(`Mean evapotranspiration [mm]` ~ Date, data = gleam_datatable_mean)
  
  
  ## Save model summary
  # Get file name
  output_file_name <- paste0("Global linear regression ", category_name)
  # Capture console output
  sink(paste0(PATH_RESULTS, output_file_name, ".txt"))
  # print out the text results of a global linear regression analysis
  print(summary(model))
  # Stop capturing console output
  sink()
  
  
  # --- Step 5: Get summary of LOESS smoothing ---
  # Preparation: add a numeric date column for loess() function which works only with numeric formats
  gleam_datatable_mean[, Date_numeric := as.numeric(Date)]
  
  # Conduct a LOESS smoothing
  model <- loess(`Mean evapotranspiration [mm]` ~ Date_numeric, data = gleam_datatable_mean)
  
  ## Save model summary
  # Get file name
  output_file_name <- paste0("Global LOESS smoothing ", category_name)
  # Capture console output
  sink(paste0(PATH_RESULTS, output_file_name, ".txt"))
  # print out the text results of a global linear regression analysis
  print(summary(model))
  # Stop capturing console output
  sink()
  
  
  # --- Step 6: Create the joined ET data table ---
  
  gleam_datatable_mean[, Class := category_name]
  
  # join
  gleam_dt_joined <- rbind(gleam_dt_joined, gleam_datatable_mean)
  
}



# --- Step 7: Visualize ---

ggplot(gleam_dt_joined, aes(x = Date, y = `Mean evapotranspiration [mm]`)) +
  geom_line() +
  geom_smooth(method = "lm",
              se = FALSE,
              color = "red") +
  geom_smooth(method = "loess",
              se = FALSE,
              color = "blue") +
  labs(x = "Time (year)", y = "Evapotranspiration (mm / year)") +
  theme_classic() +
  labs(title = "Linear regression trend and LOESS smoothing") +
  facet_wrap(vars(Class), ncol = 3, shrink = FALSE, scales = "free")

# --- Step 8: Save the results  ---
# Save plot
ggsave(
  filename = "Linear regression trend and LOESS smoothing.png",
  path = PATH_RESULTS,
  device = "png",
  plot = last_plot(),
  create.dir = TRUE
)


# --- Step 9: Free the total unused RAM space ---
# call garbage collector to free unused RAM space
gc()
