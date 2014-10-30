Ouranos
=========

Importation tests for Regional Climatic Models (HDF5 format, version >7.4, ```*.mat```) outputs into PostGIS raster objects.

Dependencies
============

### Librairies 

**Python (2.7+):**

	import h5py
	import numpy
	import pandas

**R (3.0+):**

	require(sp)
	require(ggplot2)
	require(ggmap)
	require(stringr)

**PostgreSQL (9.3):**

	CREATE EXTENSION postgis;

Getting started
===============

#### 1. Create, prepare database and import db architecture:

	psql -h localhost -p 5432 -U user -c "CREATE DATABASE ouranos_db"
	psql -h localhost -p 5432 -U -c "CREATE DATABASE ouranos_db;"
	psql -h localhost -p 5432 -U -c "CREATE EXTENSION postgis;;"
	psql -h localhost -p 5432 -U -c "\i ./archi_sql/modclim_db.sql;"


#### 2. Add Ouranos files (```.mat```) in mat_files folder

#### 3. Execute command:

	git clone git@github.com:SteveViss/OuranosDB.git
	cd Ouranos
	python ./imp_rasters_ouranos.py --log=INFO
