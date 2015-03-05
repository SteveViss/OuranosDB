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

write_stack_by_vars <- function(t){

    rs_date <- dates[t]

    rs_tmin <- raster(as.matrix(ls_arr_vars$tasmin[t,,]))
    rs_tmax <- raster(as.matrix(ls_arr_vars$tasmax[t,,]))
    rs_pr <- raster(as.matrix(ls_arr_vars$pr[t,,]))

    extent(rs_tmin) <- extent(rs_tmax) <- extent(rs_pr) <- ext
    projection(rs_tmin) <- projection(rs_tmax) <- projection(rs_pr) <- CRS("+proj=longlat +ellps=GRS80 +datum=NAD83 +no_defs ")

    st <- stack(rs_tmin,rs_tmax,rs_pr)

    names(st) <- c("tmin","tmax","pr")

    invisible(writeRaster(stack(st), str_c(argList$folder_outputs,str_replace_all(argList$hdf,".mat",""),"/",str_replace_all(argList$hdf,".mat",""),"-", str_replace_all(rs_date,"[X.]",""),".tif"), format='GTiff',overwrite=TRUE))

    rm(st)
}

pg_export <- function(outdir) {

    cmd_export <- str_c(argList$rs2pg," -a -s 4326 -f raster -r -Y ",outdir,"*.tif -F -t 144x90 ouranos_dev.mod_rs_ouranos 2>/dev/null | psql -h ", argList$serverhost ," -p ", argList$port, " -d ", argList$database, " -U ", argList$user)

    system(cmd_export,ignore.stdout = TRUE,ignore.stderr = TRUE, wait=TRUE)

}