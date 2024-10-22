##
#Step 5: Sen's slope calculations [map]
##

source("./source/main.R")


# --- Step 1: create save directory ---

path_save_sen_slope <- paste0(PATH_SAVE, 'sen_slope/')
dir.create(path_save_sen_slope)



# --- Step 2: define variables ---
data_scope <- "monthly"

crop_dates <- list(c(1980, 2000), c(2001, 2021), c(1980, 2021)) # c(x, y) - conduct analysis over the list of years from x year to y year (integers only)

p_value_max <- 0.05

# --- Step 3: Load paths ---
evap_data_paths <- list.files(path = PATH_SAVE, 
                              full.names = TRUE, 
                              pattern = paste0(data_scope, 
                                               "_cropped_\\S+C\\d.rds")) #select all files which contain _cropped_ and end with .rds





# --- Step 4: Loop through categories and date ranges ---
for(crop_date in crop_dates){
  # extract vector date range (crop_date is a list with a vector of dates inside)
  crop_date <- unlist(crop_date)
  
  for(evap_data_path in evap_data_paths){
    
    # --- Step 5: Load the data in data table format ---
    # Load data
    gleam_dataframe <- readRDS(evap_data_path)
    
    # convert to data table format
    gleam_datatable <- as.data.table(gleam_dataframe)
    

    # remove unused data frame to save memory
    rm(gleam_dataframe)
    
    
    
    # --- Step 6: Prepare the data  ---
    # remove all rows with NAs
    gleam_datatable <- na.omit(gleam_datatable)
    
    # convert text date into date object
    gleam_datatable[, Date := as.Date(Date, format = "%Y-%m-%d")] 
    
    
    
    # --- Step 7: crop data by date range  ---
    
    gleam_datatable <- gleam_datatable[lubridate::year(Date) >= crop_date[1] 
                                       & lubridate::year(Date) <= crop_date[2],]
    
    # --- Step 8: Apply Mann-Kendall Trend Test over normalized ET data ---
    evap_sen_slope <- gleam_datatable[, as.list(
      tryCatch(
        mkttest((evap - mean(evap, na.rm = TRUE)) / sd(evap, na.rm = TRUE))[c(2, 5)],
        error = function(e) {print(e)})
    ), .(lon, lat)
    ]
    # Clear the memory by removing unused table
    rm(gleam_datatable)
    
    
    # --- Step 9: Select only significant results ---
    evap_sen_slope <- evap_sen_slope[`P-value` < p_value_max, ]
    
    
    # --- Step 10: Export as a raster file ---
    # delete the "P-value" column, to avoid multiple bands in the result
    evap_sen_slope <- evap_sen_slope[, `P-value` := NULL]
    
    # convert data table into raster object
    evap_sen_slope <- rasterFromXYZ(evap_sen_slope)
    
    # define and create save folder
    path_save_sen_slope_dates <- paste0(path_save_sen_slope, 
                                  crop_date[1], 
                                  " - ", 
                                  crop_date[2],
                                  "/")
    dir.create(path_save_sen_slope_dates)
    
    
    # extract category name
    category_name <- str_sub(get_file_name(evap_data_path), start = -8)
    
    # export raster into subfolder in .tif format
    writeRaster(evap_sen_slope,
                filename=paste0(path_save_sen_slope_dates,
                                "sen_slope_",
                                crop_date[1], 
                                "_", 
                                crop_date[2],
                                "_",
                                data_scope,
                                "_",
                                category_name,
                                ".tif"),
                format="GTiff", overwrite=TRUE)
    
    # call a garbage collector to automatically free the unused memory
    gc()
  }
  
}
  



