#----------------------------------------------------------------------------
# Name:         gap_generation.R
# Description:  Script automatically generates canopy gaps as
#               training and testing polygons for the deep learning model.
#               For this purpose, the ForestGapR package is applied 
#               to an airborne laserscanning (ALS)-based canopy 
#               height model (CHM) in 0.5 m resolution.
#               See publication to the package:
#               Silva et al. 2019,  https://doi.org/10.1111/2041-210X.13211
# Contact:      florian.franz@nw-fva.de
#----------------------------------------------------------------------------



# source setup script
source('src/setup.R', local = T)



# 01 - set file paths
#---------------------

chm_path <- file.path(raw_data_dir, 'nDSM')
dop_path <- file.path(raw_data_dir, 'DOP')
orga_path <- file.path(raw_data_dir, 'orga')



# 02 - data reading
#-------------------

# CHM
chm_solling <- terra::rast(file.path(chm_path, 'chm_solling.tif'))
chm_solling

# DOPs
dop_train <- terra::rast(file.path(dop_path, 'dop_train.tif'))
dop_test <- terra::rast(file.path(dop_path, 'dop_test.tif'))
dop_train
dop_test



# 03 - data preparation
#-------------------------------------

# assign CRS to CHM (ETRS89 / UTM zone 32N)
terra::crs(chm_solling) <- 'EPSG:25832'

# crop CHMs to DOPs extent
chm_train <- terra::crop(chm_solling,
                         dop_train)

chm_test <- terra::crop(chm_solling,
                        dop_test)

# smooth cropped CHMs
w <- matrix(1, 3, 3)
chm_train <- terra::focal(chm_train, w, fun = mean, na.rm = T)
chm_test <- terra::focal(chm_test, w, fun = mean, na.rm = T)

# quick overview
par_org <- par()
par(mfrow = c(1,2))
terra::plot(chm_train, col = viridis::viridis(50))
terra::plotRGB(dop_train, r = 1, g = 2, b = 3, stretch = 'lin', axes = T, mar = 3)
par(par_org)



# 04 - automatic canopy gap detection
#-------------------------------------

# function to detect gaps in the CHMs 
gap_detection <- function(chm_raster, output_name) {
  
  # determine overstory height assuming overstory height
  # is the 95th percentile of the height values
  overstory_height <- stats::quantile(chm_raster,
                                      probs = 0.95,
                                      na.rm = TRUE)
  
  # define height threshold for gaps:
  # areas where vegetation height
  # is less than half of overstory height
  half_overstory_height <- overstory_height / 2
  
  # function getForestGaps from the ForestGapR package
  # is used to get canopy gaps
  # --> https://github.com/carlos-alberto-silva/ForestGapR
  # min. size 10m², max. size 5000m²
  canopy_gaps <- ForestGapR::getForestGaps(
    chm_layer = chm_raster,
    threshold = half_overstory_height,
    size = c(10,5000)
  )
  
  # convert raster to vector (polygons)
  canopy_gaps <- terra::as.polygons(
    canopy_gaps,
    round = TRUE,
    aggregate = TRUE,
    values = FALSE
  )
  
  # convert to an sf object
  canopy_gaps <- sf::st_as_sf(canopy_gaps)
  
  # define output file path
  output_file_path <- file.path(processed_data_dir, 'gap_polygons', paste0(output_name, '.shp'))
  
  # write to disk
  if (!file.exists(output_file_path)) {
    
    dir.create(file.path(processed_data_dir, 'gap_polygons'), recursive = T)
    sf::st_write(canopy_gaps, output_file_path)
    
  } else {
    
    # if the file already exists, read it
    canopy_gaps <- sf::st_read(output_file_path)
    
  }
  
  return(canopy_gaps)
  
}

# apply function to chm_train and chm_test
canopy_gaps_train <- gap_detection(chm_train, 'gap_polys_train')
canopy_gaps_test <- gap_detection(chm_test, 'gap_polys_test')

# quick overview
par_org <- par()
par(mfrow = c(1,2))
terra::plot(chm_train, col = viridis::viridis(50))
terra::plot(canopy_gaps_train$geometry,
            border = 'red',
            lwd = 0.5,
            add = T)
terra::plot(chm_test, col = viridis::viridis(50))
terra::plot(canopy_gaps_test$geometry,
            border = 'red',
            lwd = 0.5,
            add = T)
par(par_org)

# quick overview of a smaller subset
ext <- terra::ext(546400, 547000, 5730000, 5730500)
chm_train_ext <- terra::crop(chm_train, ext, mask = T)
terra::plot(chm_train_ext, col = viridis::viridis(50))
terra::plot(canopy_gaps_train$geometry,
            border = 'red',
            lwd = 0.5,
            add = T)


