# The MIT License (MIT)
#
# Copyright (c) 2015 Steve Vissault
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


##### DESCRIPTION
# Load GCMs downscaled (HDF5 files) and provided by Ouranos into a postgreSQL database


# source("http://bioconductor.org/biocLite.R")
# biocLite("rhdf5")

rm(list=ls())

require(rhdf5)
require(rgdal)
require(raster)
require(stringr)

source("fcts_hdf.r")

hfile <- "monthlyNRCAN+CSIRO_QCCCE-CSIRO_Mk3_6_0-r1i1p1_historical+rcp60-190001-190912"
out_path <- "./out_files/"

path_hfile<- paste0("./mat_files/",hfile,".mat")
content <- h5ls(path_hfile)

lat <- h5read(path_hfile,"/out/lat")$data
lon <- h5read(path_hfile,"/out/lon")$data
times <- h5read(path_hfile,"/out/time_vectors")$data
ext <- get_ext(lon,lat)
ls_arr_vars <- list(    list(values=h5read(path_hfile,"/out/tasmin")$data, name="tasmin"),
                        list(values=h5read(path_hfile,"/out/tasmax")$data, name="tasmax"),
                        list(values=h5read(path_hfile,"/out/pr")$data, name="pr"))

dates <- as.Date(paste(times[,1],times[,2],times[,3],sep="-"))

if(check_res(lon,lat)>0){
    stop("Program stopped by raster errors...",call.=TRUE)
}

invisible(lapply(ls_arr_vars,write_stack_dates,dates,ext,out_path))

