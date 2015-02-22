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

write_stack_dates <- function(arr_var,dates=dates,ext=ext,out_path=out_path){

    st <- stack()

    for (t in 1:length(dates)){
        rs <- raster(as.matrix(arr_var$values[t,,]))
        extent(rs) <- ext
        projection(rs) <- CRS("+proj=longlat +ellps=GRS80 +datum=NAD83 +no_defs ")
        st <- addLayer(st,rs)
    }

    names(st) <- dates


    invisible(writeRaster(stack(st), paste0(out_path,arr_var$name,"-",hfile,"-", gsub("[.X]","",as.character(names(st))),".tif"), bylayer=TRUE, format='GTiff',overwrite=TRUE))

}