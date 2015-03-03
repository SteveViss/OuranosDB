check_res <- function(lon,lat){

    rs = 0

    if(all(dim(lat) == dim(lon)) == FALSE){
      write("lat/lon lattices with different dimensions...", stderr())
    }

    reso <- round(get_res(lon,lat),digit=3)

    if(round((range(lat)[2]-range(lat)[1])/nrow(lat),digit=3) != reso){
        write("lat resolution is not constant...", stderr())
        rs = rs +1
    }

    if(round((range(lon)[2]-range(lon)[1])/ncol(lon),digit=3) != reso){
        write("lon resolution is not constant...", stderr())
        rs = rs +1
    }

    return(rs)
}

get_res <- function(lon,lat){


    resx <- lon[nrow(lon),2] - lon[nrow(lon),1]
    resy <- lat[nrow(lat)-1,1] - lat[nrow(lat),1]

    if(round(resx,digit=6) == round(resy,digit=6)){
        return(resx)
    } else {
        warning("raster resolution differs...")
        return(list("resx"=resx,"resy"=resy))
    }
}

get_ext <- function(lon,lat){

    ext <- extent(as.numeric(c(range(lon),range(lat))))
    return(ext)

}

write_stack_dates <- function(arr_var){

    st <- stack()

    for (t in 1:length(dates)){
        rs <- raster(as.matrix(arr_var[[1]][t,,]))
        extent(rs) <- ext
        projection(rs) <- CRS("+proj=longlat +ellps=GRS80 +datum=NAD83 +no_defs ")
        st <- addLayer(st,rs)
    }

    names(st) <- dates


    invisible(writeRaster(stack(st), str_c(argList$folder_outputs,str_replace_all(argList$hdf,".mat",""),"/",arr_var[[2]],"-",str_replace_all(argList$hdf,".mat",""),"-", str_replace_all(names(st),"[X.]",""),".tif"), bylayer=TRUE, format='GTiff',overwrite=TRUE))

}

pg_export <- function(x) {

    cmd_export <- str_c("python ../../prg/raster2pgsql.py -a -s 4326 -F -r ",x," -f raster -k 10x10 -t ouranos_dev.mod_rs_ouranos | psql -h ", argList$serverhost ," -p ", argList$port, " -d ", argList$database, " -U ", argList$user)

    system(cmd_export, ignore.stdout=TRUE, wait=TRUE)

    file.remove(x)
}