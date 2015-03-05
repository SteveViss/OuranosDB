#!/bin/bash
HOST=localhost ### Modifier pour l'adresse IP MFFP
PORT=5432
DBNAME=ouranos_dev
USER=svissault

## Pour le password - écrire un fichier .pgpass
## Taille de la base de données finale: 46 Go

## Ressources by job:
## 3.6 to 4.2 Go of RAM
## 1,548 Go of Disk space
## 16 minutes estimées sur ma machine

MatFiles=(`$ find ./mat_files/ -name "*.mat" -type f -printf "%f\n"`)

for mat_file in ${MatFiles[*]}; do
    Rscript ./prg/extract_monthly_rs.r -f ${mat_file[*]%.*} -b "/software6/apps/postgresql/9.3.5/bin/raster2pgsql" -s $HOST -p $PORT -d $DBNAME -u  >> prog.log &
done