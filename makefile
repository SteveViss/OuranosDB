# Makefile to export GCMs from Ouranos into a PostgreSQL database
# Feb 22, 2015
# Adapted from STModel-Data repo, by Matt Talluto and Steve Vissault

HDF_FOLDER = ./mat_files/
OUT_FOLDER = ./out_files/
HOST = localhost
PORT = 5433
DBNAME = quicc_for_dev
USER = postgres

all: db

db: archi_sql/ouranos_sch.sql
	psql -h $(HOST) -p $(PORT) -d $(DBNAME) -U $(USER) -f archi_sql/ouranos_sch.sql

splitFiles: $(HDF_FOLDER)*
	bash splitFiles.sh $(HDF_FOLDER)

run: ext/extract_monthly_rs.r ext/fcts_hdf.r ./imp_monthly_rs.sh

clean_tif:
	rm -r $(OUT_FOLDER)*

clean_db:
	psql -h $(HOST) -p $(PORT) -d $(DBNAME) -U $(USER) -c "DROP SCHEMA IF EXISTS ouranos_dev CASCADE;"

clean: clean_db clean_tif
