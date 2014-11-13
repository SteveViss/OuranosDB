### Visualize data from postgreSQL
### By Steve Vissault


# Set wd --------------------------------------------------
setwd('./out_files/')

# Libraries 
#install.packages("RPostgreSQL")
require('RPostgreSQL')
require('raster')
require('ggplot2')
require('ggmap')

dbname <- "quicc_clim"
dbuser <- "postgres"
dbpass <- "maple"
dbhost <- "localhost"
dbport <- 5433

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host=dbhost, port=dbport, dbname=dbname,
                 user=dbuser, password=dbpass) 

#### Query Test
rasters_db  <- "SELECT rs_date, var, ST_X(geom) as lon,ST_Y(geom) as lat, val FROM (SELECT bioclim_var as var, rs_date, (ST_PixelAsCentroids(raster, 1)).* FROM clim_ouranos_dev.rs_content_tbl INNER JOIN clim_ouranos_dev.rs_metadata_tbl ON clim_ouranos_dev.rs_content_tbl. md_id_rs_metadata_tbl = clim_ouranos_dev.rs_metadata_tbl.md_id WHERE extract(year from rs_content_tbl.rs_date) = 1971 AND extract(month from rs_content_tbl.rs_date) = 1  AND extract(day from rs_content_tbl.rs_date) < 6) AS subquery;"
rasters_df <- dbGetQuery(con, rasters_db)

ggdat = rasters_df

ggdat$rs_date <- as.factor(ggdat$rs_date)
ggdat$var <- as.factor(ggdat$var)


#### Visu
theme_set(theme_grey(base_size = 18))

map = ggplot() + 
geom_tile(data=ggdat, aes(x=lon,y=lat,color=val,fill=val)) +
facet_grid(rs_date~var) +
scale_x_continuous(expand=c(0,0)) + scale_y_continuous(expand=c(0,0))+ 
xlab("Longitude") + ylab("Latitude") + coord_equal()


ggsave(map,file="rasters_5dates_PostgreSQL.pdf",height=12,width=18)
