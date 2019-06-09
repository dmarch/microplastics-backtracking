#----------------------------------------------------------------------
# 02_combine_simulations.R
#----------------------------------------------------------------------


# Load dependencies
source("scr/config.R")
source("scr/utils.R")

# Select summary files
sfiles <- list.files(path_output, pattern = "_summary.csv", full.names = TRUE)

# Combine all files into data.frame
data_list <- list()
for (i in 1:length(sfiles)){
  data_list[[i]]<-read.csv(sfiles[i])
}
data <- rbindlist(data_list)

# Get overall metrics per simulation
half_life <- median(data$ellapsed_time_hours)
msl <- median(data$straight_line_km)

# plot map with locations of origin
p <- plotOrigin(data)
p

# make a raster map counting the number of particles at their origin
rc <- rcount(lon = data$first_lon, lat = data$first_lat, res = c(0.1, 0.1), crs = CRS("+proj=longlat +datum=WGS84"))

# make plot
# import land mask
data(countriesHigh, package = "rworldxtra", envir = environment())
landmask <- countriesHigh
p <- plotDensity(rc, landmask)
p

