### Build grid based on bound coordinates fron HDF5 file
### By Steve Vissault


# Set wd and import file --------------------------------------------------

setwd("~/Documents/Maitrise/StageMFFP/BD_CLIM/BOUND_FILES/")
ls_files  <- list.files(getwd(),pattern=".csv")

require(sp)
require(ggplot2)
require(ggmap)
require(stringr)

system("mkdir -p out_png")

# functions  ------------------------------------------------------------
create_poly <- function(x){ 
  x <- as.numeric(x)
  lon  <- c(x[4],x[4],x[3],x[3],x[4])
  lat  <- c(x[2],x[1],x[1],x[2],x[2])
  df_sp  <- data.frame(lon=lon,lat=lat)
  poly  <- Polygon(coords=df_sp,hole=F)
}
create_map  <- function(x){
  bound_files  <- read.csv(x)
  ls_polys  <- apply(bound_files,1,create_poly)
  muli_polys = Polygons(ls_polys,1)
  sp_polys = SpatialPolygons(list(muli_polys))
  
  sp_polys@proj4string = CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0")
  
  gg_dat  <- fortify(sp_polys)
  
  theme_set(theme_grey(base_size = 18))
  
  qmap(zoom=8, maptype = 'terrain',extent ="normal",
       location = c(range(gg_dat$long)[1],range(gg_dat$lat)[1],
                    range(gg_dat$long)[2],range(gg_dat$lat)[2])) + 
    geom_polygon(data=gg_dat, aes(x=long,y=lat,group=group),colour="grey30",alpha=0.4) +
    scale_x_continuous(expand=c(0,0)) + scale_y_continuous(expand=c(0,0))+ 
    xlab("Longitude") + ylab("Latitude")
  ggsave(paste("./out_png/",str_replace(string = x, ".csv",".png"),sep=""),width=8,height = 8)
  
  #Clean repo
  system("rm ggmapTemp*")
  system("rm .RData")
}

lapply(ls_files,create_map)

