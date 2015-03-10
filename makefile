# Makefile to export GCMs from Ouranos into a PostgreSQL database
# Feb 22, 2015
# Adapted from STModel-Data repo, by Matt Talluto and Steve Vissault

HDF_FOLDER=./mat_files/
OUT_FOLDER=./out_files/
HOST=localhost
PORT=5433
DBNAME=quicc_for_dev
USER=postgres

# HDF_FOLDER = ./mat_files/
# OUT_FOLDER = ./out_files/
# HOST = 132.219.137.38
# PORT = 5432
# DBNAME = mffp
# USER = svissault

db: archi_sql/ouranos_sch.sql
	psql -h $(HOST) -p $(PORT) -d $(DBNAME) -U $(USER) -f archi_sql/ouranos_sch.sql

splitFiles: $(HDF_FOLDER)*
	bash splitFiles.sh $(HDF_FOLDER)

clean_tif:
	rm -r $(OUT_FOLDER)*

clean_db:
	psql -h $(HOST) -p $(PORT) -d $(DBNAME) -U $(USER) -c "DROP TABLE IF EXISTS clim_rs.fut_clim_vars CASCADE;"

vac_db:
	vacuumdb  -U ${USER} -h ${HOST} -p ${PORT} -d ${DBNAME} --analyze --verbose

clean: clean_db clean_tif
