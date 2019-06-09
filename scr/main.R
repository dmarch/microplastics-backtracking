#----------------------------------------------------------------------
# 01_process_trackpy.R      Process trackpy files
#----------------------------------------------------------------------

# Load dependencies
source("scr/config.R")
source("scr/utils.R")

# Get list of all backtracking files
# nc files from trackpy
bfiles <- list.files(path_backtracking, pattern = ".nc", full.names = TRUE)

# Process each ncfile sequentially
for (i in 1:length(bfiles)){
  
  # print loop status
  print(paste("Processing file", i, "from", length(bfiles)))
  
  # select file
  ncfile <- bfiles[i]
  file_name <- file_path_sans_ext(basename(ncfile))
  
  # convert track file to data.frame
  df <- track2df(ncfile)
  write.csv(df, file = paste0(path_output, file_name, ".csv"), row.names = FALSE)

  # get summary information for each particle
  df_sum <- getSummary(df)
  write.csv(df_sum, file = paste0(path_output, file_name, "_summary.csv"), row.names = FALSE)
  
  # get overall metrics per simulation
  half_life <- median(df_sum$ellapsed_time_hours)
  msl <- median(df_sum$straight_line_km)
  
  # plot trajectory map per simulation
  pngfile <- paste0(path_output, file_name, ".png")
  png(pngfile, width=1000, height=600)
  p <- mapTracks(df, title = paste("Half life(h):", half_life, "MSL(km):", msl))
  print(p)
  dev.off()
}


