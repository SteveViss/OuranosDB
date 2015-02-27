#!/bin/bash
HOST=localhost
PORT=5433
DBNAME=quicc_for_dev
USER=postgres

cd $1
MatFiles=(`ls *.mat`)
cd ..

for mat_file in ${MatFiles[*]}; do

    Rscript ./ext/extract_monthly_rs.r -f ${mat_file[*]%.*} -i $1 -o $2

    cd $2${mat_file%.*}

    TiffFiles=(`ls *.tif`)

    for tiff_file in ${TiffFiles[*]}; do
        python ../../imp/raster2pgsql.py -a -s 4326 -F -r $tiff_file -f raster -k 100x100 -t ouranos_dev.rs_content_tbl | psql -h $HOST -p $PORT -d $DBNAME -U $USER &>/dev/null
        rm $tiff_file
    done

    cd ..
    rm -r ${mat_file%.*}

done