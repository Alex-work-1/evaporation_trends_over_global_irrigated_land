# Load required libraries
source("./source/main.R")

# Estimate the average values per grid cell for the periods 1980–1999 and 
# 2000–2019 and generate five Budyko plots (one per change class), each displaying: 
#   
#   Two Budyko curves, one for each period, to visualize changes over time. 



classes <- list("C1a", "C1b", "C1c", "C2", "C3")


crop_date_1 <- c(1980, 1999) # c(x, y) - conduct analysis over the vector of years from x year to y year (integers only)
crop_date_2 <- c(2000, 2019) # c(x, y) - conduct analysis over the vector of years from x year to y year (integers only)


data_paths <- list.files(path = PATH_SAVE, 
                              full.names = TRUE, 
                              pattern = "monthly_cropped_\\S+C\\d\\S?.rds") #select all files which contain _cropped_ and end with .rds



for(class in classes){
  # get path to ET cropped by class
  evap_data_path <- grep(paste0("_e_mm\\S+", class), data_paths, value = TRUE)
  pet_data_path <- grep(paste0("pet\\S+", class), data_paths, value = TRUE)
  precip_data_path <- grep(paste0("mswx\\S+", class), data_paths, value = TRUE)
  
  
  # import ET data
  ET_dframe <- readRDS(evap_data_path)
  pet_dframe <- readRDS(pet_data_path)
  precip_dframe <- readRDS(precip_data_path)
  
  ET_dtable <- as.data.table(ET_dframe)
  
  rm(ET_dframe)
  ET_dtable[, Date := as.Date(Date, format = "%Y-%m-%d")]
  
  
  ET_dtable_mean <- ET_dtable %>%
    na.omit() %>%
    mutate(`Year` = year(`Date`)) %>%
    group_by(Year,lon, lat) %>%
    summarise(`ET` = mean(`ET`), .groups = "keep") %>%
    ungroup() %>%
    as.data.table() # convert the result to data table for future use
  
  
  ET_dtable_mean_2 <- ET_dtable_mean[Year >= crop_date_2[1] 
                                     & Year <= crop_date_2[2],]
  ET_dtable_mean <- ET_dtable_mean[Year >= crop_date_1[1] 
                                   & Year <= crop_date_1[2],]
  
  
  ET_dtable_mean <- ET_dtable_mean %>%
    group_by(lon, lat) %>%
    summarise(`ET` = mean(`ET`), .groups = "keep") %>%
    as.data.table() # convert the result to data table for future use
  rm(ET_dtable)
  
  ET_dtable_mean_2 <- ET_dtable_mean_2 %>%
    group_by(lon, lat) %>%
    summarise(`ET` = mean(`ET`), .groups = "keep") %>%
    as.data.table() # convert the result to data table for future use
  
  
  pet_dtable <- as.data.table(pet_dframe)
  rm(pet_dframe)
  
  pet_dtable[, Date := as.Date(Date, format = "%Y-%m-%d")]
  
  PET_dtable_mean <- pet_dtable %>%
    na.omit() %>%
    mutate(`Year` = year(`Date`)) %>%
    group_by(Year,lon, lat) %>%
    summarise(`PET` = mean(`PET`), .groups = "keep") %>%
    ungroup() %>%
    as.data.table() # convert the result to data table for future use
  
  PET_dtable_mean_2 <- PET_dtable_mean[Year >= crop_date_2[1] 
                                       & Year <= crop_date_2[2],]
  PET_dtable_mean <- PET_dtable_mean[Year >= crop_date_1[1] 
                                     & Year <= crop_date_1[2],]
  
  PET_dtable_mean <- PET_dtable_mean %>%
    group_by(lon, lat) %>%
    summarise(`PET` = mean(`PET`), .groups = "keep") %>%
    as.data.table() # convert the result to data table for future use
  rm(pet_dtable)
  
  PET_dtable_mean_2 <- PET_dtable_mean_2 %>%
    group_by(lon, lat) %>%
    summarise(`PET` = mean(`PET`), .groups = "keep") %>%
    as.data.table() # convert the result to data table for future use
  
  
  
  precip_dtable <- as.data.table(precip_dframe)
  rm(precip_dframe)
  precip_dtable[, Date := as.Date(Date, format = "%Y-%m-%d")]
  
  precip_dtable_mean <- precip_dtable %>%
    na.omit() %>%
    mutate(`Year` = year(`Date`)) %>%
    group_by(Year,lon, lat) %>%
    summarise(`Precipitation` = mean(`Precipitation`), .groups = "keep") %>%
    ungroup() %>%
    as.data.table() # convert the result to data table for future use
  
  precip_dtable_mean_2 <- precip_dtable_mean[Year >= crop_date_2[1] 
                                             & Year <= crop_date_2[2],]
  precip_dtable_mean <- precip_dtable_mean[Year >= crop_date_1[1] 
                                           & Year <= crop_date_1[2],]
  
  precip_dtable_mean <- precip_dtable_mean %>%
    group_by(lon, lat) %>%
    summarise(`Precipitation` = mean(`Precipitation`), .groups = "keep") %>%
    as.data.table() # convert the result to data table for future use
  rm(precip_dtable)
  
  precip_dtable_mean_2 <- precip_dtable_mean_2 %>%
    group_by(lon, lat) %>%
    summarise(`Precipitation` = mean(`Precipitation`), .groups = "keep") %>%
    as.data.table() # convert the result to data table for future use
  
  
  
  merged_data <- merge.data.table(ET_dtable_mean, PET_dtable_mean, by = c("lon", "lat"))
  merged_data <- merge.data.table(merged_data, precip_dtable_mean, by = c("lon", "lat"))
  
  merged_data_2 <- merge.data.table(ET_dtable_mean_2, PET_dtable_mean_2, by = c("lon", "lat"))
  merged_data_2 <- merge.data.table(merged_data_2, precip_dtable_mean_2, by = c("lon", "lat"))
  
  
  
  ET <- merged_data$ET
  PET <- merged_data$PET
  P <- merged_data$Precipitation
  
  ET_2 <- merged_data_2$ET
  PET_2 <- merged_data_2$PET
  P_2 <- merged_data_2$Precipitation
  
  rm(merged_data, ET_dtable_mean, PET_dtable_mean, precip_dtable_mean)
  rm(merged_data_2, ET_dtable_mean_2, PET_dtable_mean_2, precip_dtable_mean_2)
  
  # Compute Aridity Index (φ) and Evaporation Index (ω)
  phi <- PET / P
  omega_obs <- ET / P
  
  phi_2 <- PET_2 / P_2
  omega_obs_2 <- ET_2 / P_2
  
  # # Define theoretical Budyko function
  # budyko_theoretical <- function(phi) {
  #   return(phi / (1 + phi))
  # }
  
  # Define flexible Budyko function for fitting
  budyko_fit <- function(phi, c1, c2) {
    return(c1 * phi / (1 + c2 * phi))
  }
  
  # Perform nonlinear least squares fitting
  fit <- nlsLM(omega_obs ~ budyko_fit(phi, c1, c2), 
               start = list(c1 = 1, c2 = 1),
               control = nls.lm.control(maxiter = 100))
  fit_2 <- nlsLM(omega_obs_2 ~ budyko_fit(phi_2, c1, c2), 
                 start = list(c1 = 1, c2 = 1),
                 control = nls.lm.control(maxiter = 100))
  
  # Extract fitted parameters
  params <- coef(fit)
  c1_opt <- params["c1"]
  c2_opt <- params["c2"]
  
  params_2 <- coef(fit_2)
  c1_opt_2 <- params_2["c1"]
  c2_opt_2 <- params_2["c2"]
  
  # Generate data for plotting the curves
  phi_range <- seq(min(phi), max(phi), length.out = length(phi))
  phi_range_2 <- seq(min(phi_2), max(phi_2), length.out = length(phi_2))
  
  # omega_theoretical <- budyko_theoretical(phi_range)
  omega_fitted <- budyko_fit(phi_range, c1_opt, c2_opt)
  
  omega_fitted_2 <- budyko_fit(phi_range_2, c1_opt_2, c2_opt_2)
  
  
  # Create a data frame for visualization
  plot_data <- data.frame(
    phi = phi,
    omega_obs = omega_obs
  )
  
  plot_data_2 <- data.frame(
    phi_2 = phi_2,
    omega_obs_2 = omega_obs_2
  )
  
  curve_data <- data.frame(
    phi_range = phi_range,
    # omega_theoretical = omega_theoretical,
    omega_fitted = omega_fitted
  )
  
  curve_data_2 <- data.frame(
    phi_range_2 = phi_range_2,
    # omega_theoretical = omega_theoretical,
    omega_fitted_2 = omega_fitted_2
  )
  
  
  
  
  # Compute R-squared for goodness-of-fit
  residuals <- omega_obs - budyko_fit(phi, c1_opt, c2_opt)
  ss_res <- sum(residuals^2)
  ss_tot <- sum((omega_obs - mean(omega_obs))^2)
  r_squared <- round(1 - (ss_res / ss_tot), 2)
  
  residuals_2 <- omega_obs_2 - budyko_fit(phi_2, c1_opt_2, c2_opt_2)
  ss_res_2 <- sum(residuals_2^2)
  ss_tot_2 <- sum((omega_obs_2 - mean(omega_obs_2))^2)
  r_squared_2 <- round(1 - (ss_res_2 / ss_tot_2), 2)
  
  # Print R-squared value
  print(paste("R-squared:", round(r_squared, 2)))
  print(paste("R-squared:", round(r_squared_2, 2)))
  
  
  
  
  
  
  
  
  
  
  # Plot observed data, theoretical curve, and fitted curve
  ggplot() +
    geom_point(data = plot_data, aes(x = phi, y = omega_obs), color = "blue", alpha = 0.6, size = 1) +
    # geom_line(data = curve_data, aes(x = phi_range, y = omega_theoretical), color = "red", linetype = "dashed", size = 1) +
    geom_point(data = plot_data_2, aes(x = phi_2, y = omega_obs_2), color = "orange", alpha = 0.6, size = 1) +
    # geom_line(data = curve_data, aes(x = phi_range, y = omega_theoretical), color = "red", linetype = "dashed", size = 1) +
    geom_line(data = curve_data_2, aes(x = phi_range_2, y = omega_fitted_2), color = "red", size = 1) +
    geom_line(data = curve_data, aes(x = phi_range, y = omega_fitted), color = "green", size = 1) +  
    coord_cartesian(xlim = c(0, 5), ylim = c(0, 2)) +  
    labs(
      x = "Aridity Index (φ = PET/P)",
      y = "Evaporation Index (ω = ET/P)",
      title = paste0("Budyko Curve over ", class, " class"),
      subtitle = paste0("R-squared: (1980 - 1999) = ", r_squared, ", (2000 - 2019) = ",  r_squared_2)
    ) +
    theme_classic() +
    theme(text = element_text(size = 12))
  
  ggsave(
    filename = paste0("Budyko Curve over ", class, " class.png"),
    path = PATH_RESULTS,
    device = "png",
    plot = last_plot(),
    create.dir = TRUE
  )
  
  
}
rm(list = ls())
