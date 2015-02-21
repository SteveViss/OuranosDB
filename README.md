Ouranos database
=========

Importation of General Circulation Models downscaled for North America (HDF5 format, version >7.4, ```*.mat```) into a spatial PostgreSQL database.

**Database schema:**

![DB_archi](/archi_sql/modclim_db.png)

**HDF5 structure:**

|group             |name         |otype       |dclass |dim              |
|:-----------------|:------------|:-----------|:------|:----------------|
|/                 |out          |H5I_GROUP   |       |                 |
|/out              |lat          |H5I_GROUP   |       |                 |
|/out/lat          |data         |H5I_DATASET |FLOAT  |720 x 1392       |
|/out              |lon          |H5I_GROUP   |       |                 |
|/out/lon          |data         |H5I_DATASET |FLOAT  |720 x 1392       |
|/out              |mask         |H5I_GROUP   |       |                 |
|/out/mask         |data         |H5I_DATASET |FLOAT  |720 x 1392       |
|/out              |pr           |H5I_GROUP   |       |                 |
|/out/pr           |data         |H5I_DATASET |FLOAT  |120 x 720 x 1392 |
|/out              |tasmax       |H5I_GROUP   |       |                 |
|/out/tasmax       |data         |H5I_DATASET |FLOAT  |120 x 720 x 1392 |
|/out              |tasmin       |H5I_GROUP   |       |                 |
|/out/tasmin       |data         |H5I_DATASET |FLOAT  |120 x 720 x 1392 |
|/out              |time_vectors |H5I_GROUP   |       |                 |
|/out/time_vectors |data         |H5I_DATASET |FLOAT  |120 x 3          |

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
	
**Command line example** importing all rasters for the model: gcm1_cccma_cgcm3_1-sresa1b-run1

	python imp_rasters_ouranos.py -f mat_files -m gcm1_cccma_cgcm3_1-sresa1b-run1


### Evaluate performance using line_profiler module

#### Memory 

	python -m memory_profiler imp_rasters_ouranos.py -f mat_files -m gcm1_cccma_cgcm3_1-sresa1b-run1 > mem_profile.txt