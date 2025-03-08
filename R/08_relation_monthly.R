##
#Step 8: Linear regression analysis on ET and PET; and ET and Precipitation over classes
##
source("./source/main.R")

# --- Step 1: Define variables  ---

crop_date <- c(1980, 2019) # c(x, y) - conduct analysis over the vector of years from x year to y year (integers only)

classes <- list("C1a", "C1b", "C1c", "C2", "C3")

data_paths <- list.files(path = PATH_SAVE,
                              full.names = TRUE,
                              pattern = "monthly_cropped_hilda\\S+C\\d\\S?.rds") #select all files which contain _cropped_ and end with .rds


# --- Step 2: Loop through classes  ---
for( class in classes){
  # --- Step 3: Format and crop ET  ---
  
  # get path to ET cropped by class
  ET_data_path <- grep(paste0("_e_mm\\S+", class), data_paths, value = TRUE)

  # import ET data
  ET_dframe <- readRDS(ET_data_path)
  
  
  # convert to data table format
  ET_dtable <- as.data.table(ET_dframe)
  
  rm(ET_dframe, ET_data_path)
  
  # convert text date into date object
  ET_dtable[, Date := as.Date(Date, format = "%Y-%m-%d")]
  
  # constrain data table by the dates of interest
  ET_dtable <- ET_dtable[lubridate::year(Date) >= crop_date[1] 
                         & lubridate::year(Date) <= crop_date[2],]
  
  
  # get the world data mean
  ET_datatable_mean <- ET_dtable %>%
    na.omit() %>%
    group_by(Date) %>%
    summarise(`ET` = mean(`ET`)) %>%
    as.data.table() # convert the result to data table for future use
  
  rm(ET_dtable)
  
  # --- Step 4: Format and crop Precipitation  ---

  # get path to Precipitation cropped by class
  precip_data_path <- grep(paste0("mswx\\S+", class), data_paths, value = TRUE)
  
  # import Precipitation data
  precip_data_dframe <- readRDS(precip_data_path)
  
  
  # convert to data table format
  precip_data_dtable <- as.data.table(precip_data_dframe)
  
  # clear ram
  rm(precip_data_dframe, precip_data_path)
  
  # convert text date into date object
  precip_data_dtable[, Date := as.Date(Date, format = "%Y-%m-%d")]
  
  # constrain data table by the dates of interest
  precip_data_dtable <- precip_data_dtable[lubridate::year(Date) >= crop_date[1] 
                             & lubridate::year(Date) <= crop_date[2],]
  
  
  # get the world data mean 
  precip_datatable_mean <- precip_data_dtable %>%
    na.omit() %>%
    group_by(Date) %>%
    summarise(`Precipitation` = mean(`Precipitation`)) %>%
    as.data.table() # convert the result to data table for future use
  
  # clear ram
  rm(precip_data_dtable)
  
  
  
  
  # --- Step 5:  Format and crop PET  ---
  # get path to PET cropped by class
  PET_data_path <- grep(paste0("_pet_mm\\S+", class), data_paths, value = TRUE)
  
  # import PET data
  PET_data_dframe <- readRDS(PET_data_path)
  
  
  # convert to data table format
  PET_data_dtable <- as.data.table(PET_data_dframe)
  
  # clear ram
  rm(PET_data_dframe, PET_data_path)
  
  # convert text date into date object
  PET_data_dtable[, Date := as.Date(Date, format = "%Y-%m-%d")]
  
  # constrain data table by the dates of interest
  PET_data_dtable <- PET_data_dtable[lubridate::year(Date) >= crop_date[1] 
                                           & lubridate::year(Date) <= crop_date[2],]
  
  
  # get the world data mean
  PET_datatable_mean <- PET_data_dtable %>%
    na.omit() %>%
    group_by(Date) %>%
    summarise(`PET` = mean(`PET`)) %>%
    as.data.table() # convert the result to data table for future use
  
  # clear ram
  rm(PET_data_dtable)
  
  
  
  
  # --- Step 6: Merge 3 data tables  ---
  merged_data <- merge(PET_datatable_mean, precip_datatable_mean)
  merged_data <- merge(merged_data, ET_datatable_mean)
  rm(PET_datatable_mean, precip_datatable_mean, ET_datatable_mean)
  
  # --- Step 7: Make linear regression analysis  ---
  model_PET <- lm(`ET` ~ `PET`, data = merged_data)
  model_precipitation <- lm(`ET` ~ `Precipitation`, data = merged_data)
  
  # --- Step 8: Save summary of model  ---
  # Get file name
  output_file_name_PET <- paste0("Global linear regression of ET and PET over ", 
                                 class)
  # Capture console output
  sink(paste0(PATH_RESULTS, output_file_name_PET, ".txt"))
  # print out the text results of a global linear regression analysis
  print(summary(model_PET))
  # Stop capturing console output
  sink()
  
  # Get file name
  output_file_name_precip <- paste0("Global linear regression of ET and Precipitation over ", 
                                 class)
  # Capture console output
  sink(paste0(PATH_RESULTS, output_file_name_precip, ".txt"))
  # print out the text results of a global linear regression analysis
  print(summary(model_precipitation))
  # Stop capturing console output
  sink()
  
  
  # --- Step 9: Extract r-squared  ---
  r_sq_PET <- round(summary(model_PET)$adj.r.squared, 2)
  r_sq_precip <- round(summary(model_precipitation)$adj.r.squared, 2)
  
  # --- Step 10: Visualize  ---
  ## PET
  ggplot(merged_data, aes(x = ET, y = PET)) +
    geom_point() +
    geom_smooth(method = "lm",
                se = FALSE,
                color = "red") +
    labs(x = "Actual Evapotranspiration (mm / month)", y = "Potential Evapotranspiration (mm / month)") +
    theme_classic() +
    labs(title = "Linear regression of ET and PET", subtitle = paste0("R-squared = ", r_sq_PET), caption = paste0("Class: ", class))
  
  # Save plot
  ggsave(
    filename = paste0("Linear regression of ET and PET ", class, ".png"),
    path = PATH_RESULTS,
    device = "png",
    plot = last_plot(),
    create.dir = TRUE
  )
  
  ggplot(merged_data, aes(x = ET, y = Precipitation)) +
    geom_point() +
    geom_smooth(method = "lm",
                se = FALSE,
                color = "red") +
    labs(x = "Actual Evapotranspiration (mm / month)", y = "Precipitation (mm / month)") +
    theme_classic() +
    labs(title = "Linear regression of ET and PET", subtitle = paste0("R-squared = ", r_sq_precip), caption = paste0("Class: ", class))
  
  # Save plot
  ggsave(
    filename = paste0("Linear regression of ET and Precipitation ", class, ".png"),
    path = PATH_RESULTS,
    device = "png",
    plot = last_plot(),
    create.dir = TRUE
  )
  
  
  rm(merged_data, model_PET, model_precipitation)
  
}








# --- Step 11: Clear RAM ---
# Clear session from all objects for memory optimization
rm(list = ls())