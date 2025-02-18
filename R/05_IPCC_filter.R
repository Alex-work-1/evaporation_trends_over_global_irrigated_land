##
#Step 5: IPCC conversion
##

source("./source/main.R")


# --- Step 1: import data ---
IPCC <- read.csv(paste0(PATH_MASK, "IPCC masks.csv"))


# --- Step 2: convert to data table format ---

IPCC <- as.data.table(IPCC)

# --- Step 3: Filter croplands class ---

IPCC <- IPCC[`land_cover_short_class` == "Croplands"]


# --- Step 4: Convert as vector layer ---

# convert data table to sf object (vector GIS layer)
IPCC <- st_as_sf(IPCC, 
                 coords = c("lon", "lat"),
                 crs = 4326 # set coordinate system to WGS 84 (EPSG: 4326).
)



# --- Step 5: Export as shape file
st_write(IPCC, paste0(PATH_MASK, "IPCC cropland points.shp"))
