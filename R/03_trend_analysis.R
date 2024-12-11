##
#Step 3: Slope calculations [global annual cropland trend] (linear regression and loess)
##
source("./source/main.R")

# --- Step 1: Get the data paths ---
evap_data_paths <- list.files(path = PATH_SAVE, 
                              full.names = TRUE, 
                              pattern = "yearly_cropped_\\S+C\\d\\S?.rds") #select all files which contain _cropped_ and end with .rds





# --- Step 2:Loop through each data path ---

for(evap_data_path in evap_data_paths){
  # --- Step 3: Load and convert data into data table format  ---
  # Load data
  gleam_dataframe <- readRDS(evap_data_path)
  
  # convert to data table format
  gleam_datatable <- as.data.table(gleam_dataframe)
  
  # convert text date into date object
  gleam_datatable[, Date := as.Date(Date, format = "%Y-%m-%d")] 
  
  # --- Step 4: Linear trend analysis  ---
  # get the world evapotranspiration mean by date
  gleam_datatable_mean <- gleam_datatable %>%
    na.omit() %>%
    group_by(Date) %>%
    summarise(`Mean evapotranspiration [mm]` = mean(`evap`)) %>%
    as.data.table() # convert the result to data table for future use
  
  # conduct a global linear regression analysis
  model <- lm(`Mean evapotranspiration [mm]` ~ Date, data = gleam_datatable_mean)
  
  
  # --- Step 5: Visualize ---
  # Visualization  of a global linear regression analysis
  # Get the category name
  category_name <- get_file_name(evap_data_path)
  category_name <- str_split_i(category_name, "_", -1)
  
  
  ggplot(gleam_datatable_mean, aes(x = Date, y = `Mean evapotranspiration [mm]`)) +
    geom_line() +
    geom_smooth(method = "lm", se = FALSE, color = "red") +
    labs(x = "Date", y = "Mean evapotranspiration [mm]") +
    theme_classic() +
    labs(title = paste0("Linear regression trend (", category_name,")" ), 
         subtitle = paste0("y = ", 
                           model$coefficients[2], 
                           "x + " , 
                           model$coefficients[1]))
  
  # --- Step 6: Save the results  ---
  
  # Get file name
  output_file_name <- paste0("Global linear regression ", category_name)
  # Save plot
  ggsave(filename = paste0(output_file_name, ".png"),
         path = PATH_RESULTS,
         device = "png",
         plot = last_plot(),
         create.dir = TRUE)
  
  
  ## Save model summary
  
  # Capture console output
  sink(paste0(PATH_RESULTS, output_file_name, ".txt"))
  # print out the text results of a global linear regression analysis
  print(summary(model))
  # Stop capturing console output
  sink()
  
  # --- Step 7: Partially free the unused RAM space ---
  # remove "model" object and "output_file_name" variable from the memory in order to free the memory and avoid any variable name conflicts in future
  rm(model) 
  rm(output_file_name) 
  
  # --- Step 8: Apply LOESS smoothing ---
  
  # Preparation: add a numeric date column for loess() function which works only with numeric formats
  gleam_datatable_mean[, Date_numeric := as.numeric(Date)] 
  
  # Conduct a LOESS smoothing
  model <- loess(`Mean evapotranspiration [mm]` ~ Date_numeric, 
                 data = gleam_datatable_mean)
  
  
  
  
  
  # --- Step 9: Visualize ---
  # Visualization  of a LOESS smoothing
  
  ggplot(gleam_datatable_mean, aes(x = Date, y = `Mean evapotranspiration [mm]`)) +
    geom_line() +
    geom_smooth(method = "loess", se = FALSE, color = "red") +
    labs(x = "Date", y = "Mean evapotranspiration [mm]") +
    theme_classic() +
    labs(title = 
           paste0("LOESS smoothing of global, mean evapotranspiration trend (", 
                  category_name, 
                  ")"
                  ) 
         )
  
  # --- Step 10: Save the results  ---
  
  # Get file name
  output_file_name <- paste0("Global LOESS smoothing ", category_name)
  # Save plot
  ggsave(filename = paste0(output_file_name, ".png"),
         path = PATH_RESULTS,
         device = "png",
         plot = last_plot(),
         create.dir = TRUE)
  
  ## Save model summary
  
  # Capture console output
  sink(paste0(PATH_RESULTS, output_file_name, ".txt"))
  # print out the text results of a global linear regression analysis
  print(summary(model))
  # Stop capturing console output
  sink()
  
  
  
  # --- Step 11: Free the total unused RAM space ---
  # call garbage collector to free unused RAM space
  gc()
  
  
}
