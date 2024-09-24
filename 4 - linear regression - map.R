##
#Step 4: Slope calculations [map]
##

# load libraries
library(raster)
library(pRecipe)
library(data.table)
library(ggplot2)


# load data 
gleam_nc <- brick("./data/processed/gleam-v3-8a_e_mm_croplands_198001_202112_025_monthly.nc")




## Calculating trends for the whole croplands map
slopes <- pRecipe::trend(gleam_nc)

# convert to the format suitable for ggplot (visualization)
slopes_df <- raster::as.data.frame(slopes, xy=TRUE)
slopes_df <- na.omit(slopes_df)
slopes_dt <- as.data.table(slopes_df)
slopes_dt <- as.data.table(melt(slopes_dt, id.vars = c("x", "y")))
setnames(slopes_dt, colnames(slopes_dt), c('lon','lat','time','slope'))
slopes_dt[, time := as.Date(time, format = "%Y.%m.%d")]

# Visualization of results
ggplot()+
  geom_tile(data = slopes_dt, aes(x=lon, y=lat, fill=slope))+
  borders(colour = "black")+
  scale_fill_gradient2(low = "red", high = "darkblue", midpoint = 0, mid = "white")+
  theme_bw()


# Save plot
ggsave(filename = "Linear regression map.pdf",
       path = "./data/results/",
       device = "pdf",
       plot = last_plot(),
       create.dir = TRUE)

