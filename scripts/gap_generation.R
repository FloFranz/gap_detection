#-------------------------------------------------------------
# Name:         gap_generation.R
# Description:  Script automatically generates canopy gaps as
#               training polygons for the deep learning model.
#               An airborne laserscanning (ALS)-based canopy 
#               height model (CHM) in 0.5 m resolution is used
#               for this task.
# Contact:      florian.franz@nw-fva.de
#-------------------------------------------------------------




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

# select forestry district 'Hilwartshausen'
revier <- nlf_org[nlf_org$REVIERNAME == 'Hilwartshausen',]

# crop CHM to selected forestry district
chm_revier <- terra::crop(chm_solling, revier, mask = T)

# smooth cropped CHM
w <- matrix(1, 3, 3)
chm_revier <- terra::focal(chm_revier, w, fun = mean, na.rm = T)

# quick overview
par_org <- par()
par(mfrow = c(1,2))
terra::plot(chm_solling, col = viridis::viridis(50))
terra::plot(revier$geometry, border = 'white', lwd = 2, add = T)
terra::plot(chm_revier, col = viridis::viridis(50))
par(par_org)




