# microplastics-backtracking

Process and analyse backtracking trajectories from microplastics


## Description

This repository accompanies the article "". It contains the R code to post-process backtracking trajectories of virtual particles that represent microplastics. Microplastic samples were collected by the Spanish Institute of Oceanography. Then, numerical simulations were performed by the Balearic Islands Coastal Observing and Forecasting System.


## Getting Started
1. Edit paths to input and output data (scr/config.R)
2. Post-process trackpy files (scr/01_process_trackpy.R)
3. Combine summarized information from all particles (scr/02_combine_simulations.R)


Note that the script scr/utils.R contains custom functions for the processing and analysis of trackpy files.


## Installation

The R code can be downloaded from the following [link](https://github.com/dmarch/ais-anchor/archive/master.zip). Additionaly, check out this guideline at the [Rstudio website](https://support.rstudio.com/hc/en-us/articles/200532077-Version-Control-with-Git-and-SVN) for installing Git on your computer and creating a new project.


## Requirements
* R-studio with R >= 3.6.0


## License

Copyright (c) 2019 David March  
Licensed under the [MIT license](https://github.com/dmarch/microplastics-backtracking/blob/master/LICENSE).

