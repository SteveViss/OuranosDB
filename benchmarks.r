### Assess PostgreSQL performance on Ouranos_db

setwd("./")

#install.packages("RPostgreSQL")
require("RPostgreSQL")

## use when on campus
dbname <- "mffp"
dbuser <- "svissault"
dbhost <- "132.219.137.38"
dbport <- 5432
drv <- dbDriver("PostgreSQL")

con <- dbConnect(drv, host=dbhost, port=dbport, dbname=dbname,
                 user=dbuser)

# Interception (varier nombre de points)
# Toutes les variables bioclimatiques pour la période de référence 1970-2000

#cat("Starting intercept benchmarking... \n")

#bench_intercepts <- function(n){

#cat("n_plots: ",n," \n")

#ptm <- proc.time()
#query <- paste("EXPLAIN ANALYZE SELECT plot_id, var, yr,mod,run,scenario, ST_Value(raster,coord_postgis,false) AS val
#     FROM (SELECT * FROM rdb_quicc.localisation ORDER BY RANDOM() LIMIT ", n, ") as plots_location,
#     clim_rs.fut_clim_biovars
#     WHERE ST_Intersects(raster,coord_postgis)
#    AND yr >= 1970 AND yr <= 2000 AND var='bio1'",sep="")
#dbGetQuery(con,query)
#execTime <- (proc.time() - ptm)[3]

#df_out <- data.frame(n_plots=n,exTime=execTime)
#return(df_out)

#}

#n_plots <- c(1,10,50,100,500,1000,5000,10000,50000,100000)

#res_benchIntercepts <- sapply(n_plots,bench_intercepts)
#save(res_benchIntercepts,file="res_benchIntercepts.robj")

#### Benchmark agg temporelle

#cat("Starting temporelle aggragation benchmarking... \n")

#bench_agg_temp <- function(n_years){

#cat("n_years: ",n_years," \n")

#ptm <- proc.time()
#query <- paste("EXPLAIN ANALYZE SELECT var , mod, run, scenario, ST_Union(raster,'MEAN') AS agg_rast
#    FROM clim_rs.fut_clim_biovars
#    WHERE yr >= 1970 AND yr <=",1970+n_years," AND var='bio1'  
#    GROUP BY var, mod, run, scenario",sep="")
#dbGetQuery(con,query)
#execTime <- (proc.time() - ptm)[3]

#df_out <- data.frame(n_years = n_years, exTime = execTime)

#return(df_out)

#}

#n_years <- c(2,5,10,20,30,50,70,100)

#res_benchAggTemporelle <- sapply(n_years,bench_agg_temp)
#save(res_benchAggTemporelle,file="res_benchAggTemporelle.robj")

# Découpage (Découpage des rasters par région du québec)
# Toutes les variables bioclimatiques pour toutes les années

cat("Starting crop benchmarking... \n")

bench_crop <- function(i){

cat("n_poly: ",i," \n")

ptm <- proc.time()
query <- paste("EXPLAIN ANALYZE SELECT ST_Clip(raster,poly.geom)
   FROM clim_rs.fut_clim_biovars,
   (SELECT ST_Transform(geom,4326) as geom FROM map_qc.regio_s WHERE gid =", i,") as poly
   WHERE ST_Intersects(raster,poly.geom) AND var='bio1' AND yr >= 1970 AND yr <= 2000",sep="")
dbGetQuery(con,query)
execTime <- (proc.time() - ptm)[3]

df_out <- data.frame(n_poly = i ,exTime = execTime)

return(df_out)

}

id_poly <- seq(4,20,1)

res_benchCrop <- sapply(id_poly,bench_crop)
save(res_benchCrop,file="res_benchCrop.robj")

