Ouranos database
=========

Importation of Regional Climatic Models outputs (HDF5 format, version >7.4, ```*.mat```) into a spatial PostgreSQL database.

**Database schema:**

![DB_archi](/archi_sql/modclim_db.png)

Dependencies
============

### Librairies 

**Python (2.7+):**

	import h5py
	import numpy
	import pandas

**PostgreSQL (9.3) with PostGIS (2.1+):**

	CREATE EXTENSION postgis;

Getting started
===============

#### 1. Create, prepare database and import db architecture:

	psql -h localhost -p 5432 -U user -c "CREATE DATABASE ouranos_db"
	psql -h localhost -p 5432 -U user -d ouranos_db -c "CREATE EXTENSION postgis;"
	psql -h localhost -p 5432 -U user -d ouranos_db -c "\i ./archi_sql/modclim_db.sql;"


#### 2. Add Ouranos files (```.mat```) in mat_files folder

#### 3. Execute command:

	git clone git@github.com:SteveViss/OuranosDB.git
	cd OuranosDB
	python ./imp_rasters_ouranos.py --log=INFO
