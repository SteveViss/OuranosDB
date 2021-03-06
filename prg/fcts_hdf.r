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

write_stack_by_vars <- function(dates,agg='annual',rs_crop=TRUE){

    dates <- data.frame(fulldate=dates,year=format(dates,'%Y'),id_rows=seq(1,length(dates),1))

    # Crop for the eastern part of US
    ext_crop <- ext
    ext_crop[c(1,4)] <- c(-97,63)

    if (agg == 'monthly') {

        for (t in 1:dim(dates)[1]){
            rs_date <- dates[t,1]

            tp_tasmin <- as.matrix(ls_arr_vars$tasmin[t,,])
            tp_tasmax <- as.matrix(ls_arr_vars$tasmax[t,,])
            tp_pr <- as.matrix(ls_arr_vars$pr[t,,])

            tp_tasmin[which(tp_tasmin=='NaN')] <- NA
            tp_tasmax[which(tp_tasmax=='NaN')] <- NA
            tp_pr[which(tp_pr=='NaN')] <- NA

            rs_tmin <- raster(tp_tasmin)
            rs_tmax <- raster(tp_tasmax)
            rs_pr <- raster(tp_pr)

            extent(rs_tmin) <- extent(rs_tmax) <- extent(rs_pr) <- ext
            projection(rs_tmin) <- projection(rs_tmax) <- projection(rs_pr) <- CRS("+proj=longlat +ellps=GRS80 +datum=NAD83 +no_defs ")

            st <- stack(rs_tmin,rs_tmax,rs_pr)

            if(rs_crop==TRUE){st<-crop(st,ext_crop)}

            names(st) <- c("tmin","tmax","pr")
            NAvalue(st) <- -9999

            invisible(writeRaster(stack(st), str_c(argList$folder_outputs,str_replace_all(argList$hdf,".mat",""),"/",names(st),"-",str_replace_all(argList$hdf,".mat",""),"-", str_replace_all(rs_date,"[X.]",""),".asc"), format='ascii',overwrite=TRUE,bylayer=TRUE))

            rm(st,rs_tmin,rs_tmax,rs_pr,tp_tasmin,tp_tasmax,tp_pr)
        }

    } else if(agg=='annual_biovars'){


        #Get min and max rowid for each year
        summary_dates <- as.data.frame(dates %>% group_by(year) %>% summarise(min_row=min(id_rows),max_row=max(id_rows)))

        for (r in 1:dim(summary_dates)[1]){
            st_final <- st_tmin <- st_tmax <- st_pr <- stack()
            yr <- summary_dates[r,1]

            for (l in summary_dates[r,2]:summary_dates[r,3]){
                # Storing layers (one year)
                tp_tasmin <- as.matrix(ls_arr_vars$tasmin[l,,])
                tp_tasmax <- as.matrix(ls_arr_vars$tasmax[l,,])
                tp_pr <- as.matrix(ls_arr_vars$pr[l,,])

                tp_tasmin[which(tp_tasmin=='NaN')] <- NA
                tp_tasmax[which(tp_tasmax=='NaN')] <- NA
                tp_pr[which(tp_pr=='NaN')] <- NA

                rs_tmin <- raster(tp_tasmin)
                rs_tmax <- raster(tp_tasmax)
                rs_pr <- raster(tp_pr)

                st_tmin <- addLayer(st_tmin,rs_tmin)
                st_tmax <- addLayer(st_tmax,rs_tmax)
                st_pr <- addLayer(st_pr,rs_pr)

                rm(rs_tmin,rs_tmax,rs_pr,tp_tasmin,tp_tasmax,tp_pr)
            }

            #Set proj and extent
            extent(st_tmin) <- extent(st_tmax) <- extent(st_pr) <- ext
            projection(st_tmin) <- projection(st_tmax) <- projection(st_pr) <- CRS("+proj=longlat +ellps=GRS80 +datum=NAD83 +no_defs ")

            #Set NA value
            NAvalue(st_tmin) <- NAvalue(st_tmax) <- NAvalue(st_pr) <- -9999

            # Crop on area
            if(rs_crop==TRUE){
                st_tmin <-  crop(st_tmin,ext_crop)
                st_tmax <- crop(st_tmax,ext_crop)
                st_pr <- crop(st_pr,ext_crop)
            }

            bios <- biovars(st_pr,st_tmin,st_tmax)

            invisible(writeRaster(bios, str_c(argList$folder_outputs,str_replace_all(argList$hdf,".mat",""),"/",names(bios),"-",str_replace_all(argList$hdf,".mat",""),"-", yr,".asc"), format='ascii',overwrite=TRUE,bylayer=TRUE))

        }

    } else {
        write("you need to specify temporal aggregation (monthly/annual_biovars)...", stderr())
    }

}

pg_export <- function(outdir) {

    cmd_export <- str_c(argList$rs2pg," -a -s 4326 -f raster -r -Y ",outdir,"*.asc -F -t auto clim_rs.fut_clim_vars 2>/dev/null | psql -h ", argList$serverhost ," -p ", argList$port, " -d ", argList$database, " -U ", argList$user)

    system(cmd_export,ignore.stdout = TRUE,ignore.stderr = TRUE, wait=TRUE)

}