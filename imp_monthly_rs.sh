#!/bin/bash

MAT_FILE=$1
INPUT_FOLDER=$2
OUPUT_FOLDER=$3
HOST=localhost
PORT=5433
DBNAME=quicc_for_dev
USER=postgres

#Rscript ./ext/extract_monthly_rs.r -f $1 -i $2 -o $3

cd $3$1

TiffFiles=(`ls *.tif`)

for file in ${TiffFiles[*]}; do
    python ../../imp/raster2pgsql.py -a -s 4326 -F -r $file -f raster -k 100x100 -t ouranos_dev.rs_content_tbl | psql -h $HOST -p $PORT -d $DBNAME -U $USER > ../../log.stout
    rm $file
done