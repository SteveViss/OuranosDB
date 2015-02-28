# install dependancies

if(!require(rhdf5)){
    source("http://bioconductor.org/biocLite.R")
    biocLite("rhdf5")
}
if(!require(rgdal)){install.packages('rgdal',repos='http://cran.skazkaforyou.com/')}
if(!require(raster)){install.packages('raster',repos='http://cran.skazkaforyou.com/')}
if(!require(argparse)){install.packages('argparse',repos='http://cran.skazkaforyou.com/')}
if(!require(stringr)){install.packages('stringr',repos='http://cran.skazkaforyou.com/')}
