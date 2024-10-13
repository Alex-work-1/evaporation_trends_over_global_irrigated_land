##
#Step 4: Slope calculations [map]
##

source("./source/main.R")

## --- Step 1 Load the data ---

# load data 
gleam_nc <- brick(paste0(PATH_DATA, GLEAM_EVAP_MONTHLY))


## --- Step 2 Calculate the slopes ---

## Calculating trends for the whole croplands map
slopes <- pRecipe::trend(gleam_nc)


## --- Step 3 Save the result ---

#Save map of slopes
writeRaster(slopes, 
            filename=paste0(PATH_SAVE, 
                            "gleam_198001_20211_025_trend_monthly.tif"), 
            format="GTiff", overwrite=TRUE)
