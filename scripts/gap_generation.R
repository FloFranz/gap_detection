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
orga_path <- file.path(raw_data_dir, 'orga')



# 02 - data reading
#-------------------

# CHM
chm_solling <- terra::rast(file.path(chm_path, 'chm_solling.tif'))
chm_solling

# forest boundaries
nlf_org <- sf::st_read(file.path(orga_path, 'NLF_Org_2022.shp'))
nlf_org



# 03 - data preparation
#-------------------------------------

# assign CRS to CHM (ETRS89 / UTM zone 32N)
terra::crs(chm_solling) <- 'EPSG:25832'

# select forestry districts 
# 'Hilwartshausen' and 'Fredelsloh'
revier_hilwartshausen <- nlf_org[nlf_org$REVIERNAME == 'Hilwartshausen',]
revier_fredelsloh <- nlf_org[nlf_org$REVIERNAME == 'Fredelsloh',]

# crop CHM to selected forestry districts
chm_revier_hilwartshausen <- terra::crop(chm_solling, 
                                         revier_hilwartshausen,
                                         mask = T)
chm_revier_fredelsloh <- terra::crop(chm_solling, 
                                     revier_fredelsloh,
                                     mask = T)

# smooth cropped CHM
w <- matrix(1, 3, 3)
chm_revier_hilwartshausen <- terra::focal(chm_revier_hilwartshausen,
                                          w, fun = mean, na.rm = T)
chm_revier_fredelsloh <- terra::focal(chm_revier_fredelsloh,
                                      w, fun = mean, na.rm = T)

# quick overview
par_org <- par()
par(mfrow = c(1,2))
terra::plot(chm_solling, col = viridis::viridis(50))
terra::plot(revier_hilwartshausen$geometry, border = 'white', lwd = 2, add = T)
terra::plot(chm_revier_hilwartshausen, col = viridis::viridis(50))
par(par_org)

par_org <- par()
par(mfrow = c(1,2))
terra::plot(chm_solling, col = viridis::viridis(50))
terra::plot(revier_fredelsloh$geometry, border = 'white', lwd = 2, add = T)
terra::plot(chm_revier_fredelsloh, col = viridis::viridis(50))
par(par_org)



# 04 - automatic canopy gap detection
#-------------------------------------

# determine overstory height
# assuming overstory height is the
# 95th percentile of the height values
overstory_height <- stats::quantile(chm_revier_fredelsloh,
                                    probs = 0.95,
                                    na.rm = T)

# define height threshold for gaps:
# areas where vegetation height
# is less than half of overstory height
half_overstory_height <- overstory_height / 2

# function getForestGaps from the
# ForestGapR package is used
# to get canopy gaps
# --> https://github.com/carlos-alberto-silva/ForestGapR
# min. size 10m², max. size 5000m²
canopy_gaps <- ForestGapR::getForestGaps(
  chm_layer = chm_revier_fredelsloh,
  threshold = half_overstory_height,
  size = c(10,5000)
  )

# convert raster to vector (polygons)
canopy_gaps <- terra::as.polygons(
  canopy_gaps,
  round = T,
  aggregate = T,
  values = F
  )

# convert to an sf object
canopy_gaps <- sf::st_as_sf(canopy_gaps)

# write to disk
if (!file.exists(file.path(
  processed_data_dir, 'gap_polygons', 'gap_polys_fredelsloh.shp'))) {
 
  dir.create(file.path(processed_data_dir, 'gap_polygons'), recursive = T)
  sf::st_write(canopy_gaps,
               file.path(processed_data_dir,
                         'gap_polygons',
                         'gap_polys_fredelsloh.shp'))
  
} else {
    
  canopy_gaps <- sf::st_read(file.path(
    processed_data_dir, 'gap_polygons', 'gap_polys_fredelsloh.shp'))
  
}

# quick overview
terra::plot(chm_revier_fredelsloh, col = viridis::viridis(50))
terra::plot(canopy_gaps$geometry,
            border = 'red',
            lwd = 0.5,
            add = T)

# quick overview of a smaller subset
ext <- terra::ext(546423.5, 548000, 5728983, 5731000)
chm_revier_ext <- terra::crop(chm_revier, ext, mask = T)
terra::plot(chm_revier_ext, col = viridis::viridis(50))
terra::plot(canopy_gaps$geometry,
            border = 'white',
            lwd = 0.5,
            add = T)


