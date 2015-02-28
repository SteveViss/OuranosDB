#!/usr/bin/Rscript

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

require(argparse)

# handle command line arguments
parser<- ArgumentParser()
parser$add_argument('-f', '--hdf', help='Set target file (HDF5 file with ouranos structure)')
parser$add_argument('-o', '--folder_outputs', default='./out_files/', help='set outputs directory')
parser$add_argument('-i', '--folder_inputs', default='./mat_files/', help='set inputs directory')
parser$add_argument('-s', '--serverhost', help='database server host')
parser$add_argument('-p', '--port', default='5432', help='database port')
parser$add_argument('-d', '--database', help='database name')
parser$add_argument('-u', '--user', help='database user')
argList = parser$parse_args()

# source("http://bioconductor.org/biocLite.R")
# biocLite("rhdf5")

# Librairies
if(!require(rhdf5)){install.packages('rhdf5',repos='http://cran.skazkaforyou.com/')}
if(!require(rgdal)){install.packages('rgdal',repos='http://cran.skazkaforyou.com/')}
if(!require(raster)){install.packages('raster',repos='http://cran.skazkaforyou.com/')}
if(!require(argparse)){install.packages('argparse',repos='http://cran.skazkaforyou.com/')}
if(!require(stringr)){install.packages('stringr',repos='http://cran.skazkaforyou.com/')}

require(rhdf5)
require(rgdal)
require(raster)
require(stringr)

source("./prg/fcts_hdf.r")

# Fix possible issue with extension file
if(str_detect(argList$hdf,".mat") == FALSE) {argList$hdf <- str_c(argList$hdf,".mat")}

######################################################################
# Set variable

pathFile <- str_c(argList$folder_inputs,argList$hdf)
lat <- h5read(pathFile,"/out/lat")$data
lon <- h5read(pathFile,"/out/lon")$data
times <- h5read(pathFile,"/out/time_vectors")$data
ext <- get_ext(lon,lat)

ls_arr_vars <- list(
    list(values=h5read(pathFile,"/out/tasmin")$data, name="tasmin"),
    list(values=h5read(pathFile,"/out/tasmax")$data, name="tasmax"),
    list(values=h5read(pathFile,"/out/pr")$data, name="pr"))

dates <- as.Date(paste(times[,1],times[,2],times[,3],sep="-"))


######################################################################
# Check raster integrity

if(check_res(lon,lat)>0){
    stop("Program stopped by raster errors...",call.=TRUE)
}

######################################################################
# Manage outputs dir

dir_outputs <- str_c(argList$folder_outputs,str_replace_all(argList$hdf,".mat",""),"/")
dir.create(dir_outputs, showWarnings = FALSE)

######################################################################
# Run extraction

invisible(lapply(ls_arr_vars,write_stack_dates))

# free memory
rm(c(ls_arr_vars,lat,lon,times,dates,ext))

######################################################################
# Run exportation to postgres SQL

ls_tif <- list.files(dir_outputs)
ls_tif <- ls_tif[str_detect(ls_tif,".tif")]
setwd(str_c(argList$folder_outputs,str_replace_all(argList$hdf,".mat","")))

invisible(sapply(ls_tif,pg_export))