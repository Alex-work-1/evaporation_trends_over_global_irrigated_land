##
#Step 4: Sen's slope calculations [map]
##

source("./source/main.R")



# --- Step 1: make function ---


normalized_sen_slope_calc <- function(crop_dates, data_paths, col_name, 
                                      p_value_max, path_save_sen_slope) {
  # Calculates normalized Sen's slope and exports it as raster with 
  # vector significant points.
  # Args:
  #  crop_dates: List of vectors to crop dates. (list of vectors)
  #  data_paths: path to the data files. (list of strings)
  #  col_name: Name of imported data table data column. (string)
  #  p_value_max: Maximum p value to include. (integer)
  #  path_save_sen_slope: path where to save processed data. (string)
  # Returns:
  #  Void.
  
  # --- Step 2: Loop through categories and date ranges ---
  for (crop_date in crop_dates) {
    # extract vector date range (crop_date is a list with a vector of dates inside)
    crop_date <- unlist(crop_date)
    
    for (data_path in data_paths) {
      # --- Step 3: Load the data in data table format ---
      # Load data
      data_dframe <- readRDS(data_path)
      
      # convert to data table format
      data_dtable <- as.data.table(data_dframe)
      
      
      # remove unused data frame to save memory
      rm(data_dframe)
      
      
      
      # --- Step 4: Prepare the data  ---
      # remove all rows with NAs
      data_dtable <- na.omit(data_dtable)
      
      # convert text date into date object
      data_dtable[, Date := as.Date(Date, format = "%Y-%m-%d")]
      
      
      
      # --- Step 5: crop data by date range  ---
      
      data_dtable <- data_dtable[lubridate::year(Date) >= crop_date[1]
                                         &
                                           lubridate::year(Date) <= crop_date[2], ]
      
      # --- Step 6: Apply Mann-Kendall Trend Test over normalized ET data ---
      
      data_column <- eval(parse(text=paste("data_dtable$", col_name, sep = "")))
      sen_slope <- data_dtable[, as.list(tryCatch(
        mkttest((data_column - mean(data_column, na.rm = TRUE)) / sd(data_column, na.rm = TRUE))[c(2, 5)],
        error = function(e) {
          print(e)
        }
      )), .(lon, lat)]
      # Clear the memory by removing unused table
      rm(data_dtable)
      
      # --- Step 7: Select only significant results as vector layer ---
      # select required p value
      sen_slope_pvalue <- sen_slope[`P-value` < p_value_max, ]
      # remove unnecessary column
      sen_slope_pvalue <- sen_slope_pvalue[, `Sen's slope` := NULL]
      
      # convert data table to sf object (vector GIS layer)
      sen_slope_pvalue <- st_as_sf(sen_slope_pvalue,
                                        coords = c("lon", "lat"),
                                        crs = 4326 # set coordinate system to WGS 84 (EPSG: 4326).
                                        )
                                        
      
      
      
      # --- Step 8: Export Sen's slope as raster and p value points as vector layers ---
      # define and create save folder
      path_save_sen_slope_dates <- paste0(path_save_sen_slope, 
                                          crop_date[1], " - ", crop_date[2], "/")
      dir.create(path_save_sen_slope_dates)
      
      
      # extract category name
      category_name <- str_split_i(get_file_name(data_path), "_", -1)
      
      # save file name
      save_file_name <- paste0("sen_slope_",
                               crop_date[1],
                               "_",
                               crop_date[2],
                               "_",
                               data_scope,
                               "_",
                               category_name)
      
      ## p-value export
      st_write(sen_slope_pvalue,
               paste0(path_save_sen_slope_dates, save_file_name, ".shp"))
      
      ## Sen's slope export
      # delete the "P-value" column, to avoid multiple bands in the result
      sen_slope <- sen_slope[, `P-value` := NULL]
      
      # convert data table into raster object
      sen_slope <- rasterFromXYZ(sen_slope)
      
      
      
      # export raster into subfolder in .tif format
      writeRaster(
        sen_slope,
        filename = paste0(path_save_sen_slope_dates, save_file_name, ".tif"),
        format = "GTiff",
        overwrite = TRUE
      )
      
      # call a garbage collector to automatically free the unused memory
      gc()
    }
    
  }
  
}






# --- Step 9: create ET save directory ---
path_save_sen_slope <- paste0(PATH_SAVE, 'sen_slope/')
dir.create(path_save_sen_slope)

# --- Step 10: define ET variables ---
data_scope <- "monthly"

crop_dates <- list(c(1980, 2019)) # c(x, y) - conduct analysis over the list of years from x year to y year (integers only)

p_value_max <- 0.05

col_name <- "ET"

# --- Step 11: Load ET paths ---
data_paths <- list.files(path = PATH_SAVE, 
                              full.names = TRUE, 
                              pattern = paste0("gleam_e\\S+",
                                               data_scope, 
                                               "_cropped_\\S+C\\d\\S?.rds")) #select all files which contain _cropped_ and end with .rds


# --- Step 12: Call the function with ET parameters ---

normalized_sen_slope_calc(crop_dates, data_paths, col_name, 
                          p_value_max, path_save_sen_slope)








# --- Step 13: create precipitation save directory ---
path_save_sen_slope <- paste0(PATH_SAVE, 'sen_slope_precip/')
dir.create(path_save_sen_slope)

# --- Step 14: define precipitation variables ---
data_scope <- "monthly"

crop_dates <- list(c(1980, 2019)) # c(x, y) - conduct analysis over the list of years from x year to y year (integers only)

p_value_max <- 0.05

col_name <- "Precipitation"

# --- Step 15: Load precipitation paths ---
data_paths <- list.files(path = PATH_SAVE, 
                         full.names = TRUE, 
                         pattern = paste0("mswx\\S+",
                                          data_scope, 
                                          "_cropped_\\S+C\\d\\S?.rds")) #select all files which contain _cropped_ and end with .rds


# --- Step 16: Call the function with precipitation parameters ---

normalized_sen_slope_calc(crop_dates, data_paths, col_name, 
                          p_value_max, path_save_sen_slope)














# --- Step 17: create PET save directory ---
path_save_sen_slope <- paste0(PATH_SAVE, 'sen_slope_PET/')
dir.create(path_save_sen_slope)

# --- Step 18: define PET variables ---
data_scope <- "monthly"

crop_dates <- list(c(1980, 2019)) # c(x, y) - conduct analysis over the list of years from x year to y year (integers only)

p_value_max <- 0.05

col_name <- "PET"

# --- Step 19: Load ET paths ---
data_paths <- list.files(path = PATH_SAVE, 
                         full.names = TRUE, 
                         pattern = paste0("gleam\\S+pet\\S+",
                                          data_scope, 
                                          "_cropped_\\S+C\\d\\S?.rds")) #select all files which contain _cropped_ and end with .rds


# --- Step 20: Call the function with ET parameters ---

normalized_sen_slope_calc(crop_dates, data_paths, col_name, 
                          p_value_max, path_save_sen_slope)








# --- Step 21: Clear RAM ---

  
# Clear session from all objects for memory optimization
rm(list = ls())

