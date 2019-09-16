#----------------------------------------------------------------------
# utils.R         Suite of functions to process backtracking files
#----------------------------------------------------------------------
# getSummary      Get summary data for each particle from a trackpy file
# mapTracks       Plot map with particles from a trackpy file
# plotDensity     Plot density map
# plotOrigin      Plot map with origin locations
# trackpy2df      Convert trackpy file into data frame
# rcount          Raster map counting the number of particles



#------------------------------------------------------------------
# getSummary       Get summary data for each particle from a trackpy file
#------------------------------------------------------------------
getSummary <- function(df){
  # input is a data.frame of trajectories (see trackpy2df)
  # output is a data.frame with summary data for each particle
  
  # Load dependencies
  library(dplyr)
  library(geosphere)
  
  # Order data.frame by id and date
  df <- arrange(df, id, time)
  
  # Summarize particles
  # Extract first and last locations
  # Calculate time and distance travelled
  sum <- df %>%
    group_by(id) %>%
    summarize(last_time = last(time),
              last_lon = last(lon),
              last_lat = last(lat),
              first_time = first(time),
              first_lon = first(lon),
              first_lat = first(lat),
              ellapsed_time_hours = as.numeric(difftime(last_time, first_time, units = "hours")),
              straight_line_km = round(distGeo(c(first_lon, first_lat), c(last_lon, last_lat))/1000) #km
    )
  
  # Return data.frame
  return(sum)
  
}


#-----------------------------------------------------------------
# mapTracks       Plot map with particles from a trackpy file
#-----------------------------------------------------------------
mapTracks  <- function (data, extend = 0, title = NULL){
  
  # Load libraries and dependencies
  library(ggplot2)
  
  # Import world map
  data(countriesHigh, package = "rworldxtra", envir = environment())
  wm <- suppressMessages(fortify(countriesHigh))
  
  ### Define extension for plot
  xl <- extendrange(data$lon, f = extend)
  yl <- extendrange(data$lat, f = extend)
  
  ### Plot
  p <- ggplot() +
    geom_polygon(data = wm, aes_string(x = "long", y = "lat", group = "group"),
                 fill = grey(0.8)) +
    coord_quickmap(xlim = xl, ylim = yl, expand = TRUE) +
    xlab("Longitude") +
    ylab("Latitude") +
    geom_path(data = data,
              aes_string(x = "lon", y = "lat", group = "id"),
              size=0.5, alpha=0.05, color="red") +
    theme_light() +
    ggtitle(title)
  
  return(p)
  
}
#-----------------------------------------------------------------


#-----------------------------------------------------------------
# plotDensity     Plot density map
#-----------------------------------------------------------------
plotDensity <- function(m, landmask){
  
  # set color ramp
  colr <- colorRampPalette(rev(brewer.pal(11, 'Spectral')))
  
  # set min max values
  min <- minValue(m)
  max <- maxValue(m)
  
  # plot map
  p <- levelplot(m, pretty = FALSE, margin = FALSE, col.regions = colr,
                 zscaleLog = FALSE,
                 at = seq(min, max, len = 101), scales = list(draw = TRUE))
  
  # add landmask
  p <- p + latticeExtra::layer(sp.polygons(landmask, col="gray30", fill="grey80", lwd=1))
  
  # return plot
  return(p)
}
#-----------------------------------------------------------------


#-----------------------------------------------------------------
# plotOrigin       Plot map with origin locations
#-----------------------------------------------------------------
plotOrigin  <- function (data, title = NULL){
  
  # Load libraries and dependencies
  library(ggplot2)
  
  # Import world map
  data(countriesHigh, package = "rworldxtra", envir = environment())
  wm <- suppressMessages(fortify(countriesHigh))
  
  ### Define extension for plot
  xl <- extendrange(data$first_lon, f = 0.1)
  yl <- extendrange(data$first_lat, f = 0.1)
  
  ### Plot
  p <- ggplot() +
    geom_polygon(data = wm, aes_string(x = "long", y = "lat", group = "group"),
                 fill = grey(0.8)) +
    coord_quickmap(xlim = xl, ylim = yl, expand = TRUE) +
    xlab("Longitude") +
    ylab("Latitude") +
    
    geom_point(data = data,
               aes_string(x = "first_lon", y = "first_lat", group = NULL),
               size = 1, alpha=0.05, color="red") +
    theme_light() +
    ggtitle(title)
  
  return(p)
}
#-----------------------------------------------------------------


#------------------------------------------------------------------
# trackpy2df      Convert trackpy file into data frame
#------------------------------------------------------------------
track2df <- function(ncfile){
  # Input is a nc file from trackpy
  # output is a data.frame
  
  # Load dependencies
  require(ncdf4)
  
  # Open netcdf
  nc <- nc_open(ncfile)  # open in write mode to store new data
  
  # Get global data
  id <- nc$dim$ntrac$vals  # virtual particle id
  tp <- length(id)  # number of virtual particles
  ts <- nc$dim$nt$len  # number of time steps
  
  # Get track data for all particles (whole matrix)
  mlat <- ncvar_get(nc, varid="latp", start=c(1,1), count=c(ts,tp))  # [nt=201,ntrac=959], [nt,ntrac]   
  mlon <- ncvar_get(nc, varid="lonp", start=c(1,1), count=c(ts,tp))  # [nt=201,ntrac=959]
  mt <- ncvar_get(nc, varid="tp", start=c(1,1), count=c(ts,tp))   # [nt=201,ntrac=959]
  
  # close nc
  nc_close(nc)
  
  # Convert to data.frame
  lon <- as.vector(mlon[,])
  lat <- as.vector(mlat[,])
  time <- as.vector(mt[,])
  id <- rep(id, each=ts)
  dt <- data.frame(id, time, lon, lat)
  
  # filter NA data (beached particles)
  # trackpy assigns NA once the particle reaches the coastline
  na_lon <- which(is.na(dt$lon))
  dt <- dt[-na_lon,]
  
  # Convert time to POSIXct
  dt$time <- as.POSIXct(dt$time, origin = "1968-05-23", tz = "UTC")  # seconds since 1968-05-23 00:00:00 GMT
  
  # return data.frame
  return(dt)
}
#------------------------------------------------------------------


#-----------------------------------------------------------------
# rcount       Raster map counting the number of particles
#-----------------------------------------------------------------
rcount <- function(lon, lat, res = c(0.05, 0.05), crs = CRS("+proj=longlat +datum=WGS84")){
  
  # get bounding box
  e <- extent(c(min(lon), max(lon), min(lat), max(lat)))
  
  # create raster
  r <- raster(e + 0.5, res = res, crs = crs)
  
  # count number of particles per cell
  rc <- rasterize(cbind(lon, lat), r, fun="count")
  return(rc) 
}
#-----------------------------------------------------------------