##
#Step 3: Slope calculations [global cropland trend]
##
source("./source/main.R")

# --- Step 1: Get the data paths ---
evap_data_paths <- list.files(path = PATH_SAVE, 
                              full.names = TRUE, 
                              pattern = "yearly_cropped_\\S+C\\d.rds") #select all files which contain _cropped_ and end with .rds





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
    summarise(`Mean evapotranspiration [mm]` = mean(`evap`))
  
  # conduct a global linear regression analysis
  model <- lm(`Mean evapotranspiration [mm]` ~ Date, data = gleam_datatable_mean)
  
  
  # --- Step 5: Visualize ---
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
  
  # --- Step 6: Save the results  ---
  # Get the category name
  category_name <- get_file_name(evap_data_path)
  category_name <- str_sub(category_name, -2)
  
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
  
  # --- Step 7: Free the unused RAM space ---
  # call garbage collector to free unused RAM space
  gc()
  
}
