#!/bin/bash
MATFOLD=./mat_files/
OUTFOLD=./out_files/
HOST=localhost
PORT=5433
DBNAME=quicc_for_dev
USER=postgres

cd $1
MatFiles=(`ls *.mat`)
cd ..

for mat_file in ${MatFiles[*]}; do
    Rscript ./prg/extract_monthly_rs.r -f ${mat_file[*]%.*} -i $MATFOLD -o $OUTFOLD -s "localhost" -p "5433" -d "quicc_for_dev" -u "postgres" mat &> dev/null &
done