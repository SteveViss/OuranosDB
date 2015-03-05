Ouranos database
=========

Importation of General Circulation Models downscaled for North America (HDF5 format, version >7.4, ```*.mat```) into a spatial PostgreSQL database.

**Database schema:**

![DB_archi](/archi_sql/ouranos_sch.png)

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