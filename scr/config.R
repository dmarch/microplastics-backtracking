#---------------------------------------------------------------
# config.R        Load libraries and set paths
#---------------------------------------------------------------

# Load libraries
library(ncdf4)
library(data.table)
library(geosphere)
library(rworldxtra)
library(tools)
library(raster)
library(RColorBrewer)
library(rasterVis)


# Set path to folder with backtracking files (nc)
path_backtracking <- "U:/Data/microplastics-backtracking/trajectories_plastics_Mallorca_backtracking_summer_2017_180d/"

# Set path to store output files
path_output <- "U:/Data/microplastics-backtracking/output/"
