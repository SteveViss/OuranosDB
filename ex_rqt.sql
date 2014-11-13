-- QUERIES EXAMPLES

-- Coords of all cells

SELECT x, y, val, ST_X(geom),ST_Y(geom) FROM (SELECT (ST_PixelAsCentroids(raster, 1)).* FROM clim_ouranos_dev.rs_content_tbl WHERE rs_id = 2) AS test;
SELECT (ST_PixelAsCentroids(raster, 1)).* FROM clim_ouranos_dev.rs_content_tbl WHERE rs_id = 2;

-- Metadata of all rasters

 SELECT (md).*, (bmd).* 
 FROM (SELECT ST_Metadata(raster) AS md, 
              ST_BandMetadata(raster) AS bmd 
       FROM clim_ouranos_dev.rs_content_tbl LIMIT 1
      ) foo;

-- Tester intercept (geom_point; geom_polygon)



-- ANNUAL RASTER BY BIOVARS

CREATE MATERIALIZED VIEW clim_ouranos_dev.testunion AS (SELECT rs_metadata_tbl.bioclim_var, extract(year from rs_content_tbl.rs_date) as year_date,ST_Union(raster, 'MEAN') AS union_raster FROM clim_ouranos_dev.rs_content_tbl
INNER JOIN clim_ouranos_dev.rs_metadata_tbl ON clim_ouranos_dev.rs_content_tbl.md_id_rs_metadata_tbl = clim_ouranos_dev.rs_metadata_tbl.md_id
GROUP BY rs_metadata_tbl.bioclim_var,extract(year from rs_content_tbl.rs_date));

-----

-- Get Stats

SELECT (stats).* FROM (SELECT ST_SummaryStats(union_raster) AS stats FROM clim_ouranos_dev.testUnion) As foo;

-- MONTHLY RASTER BY BIOVARS

DROP MATERIALIZED VIEW clim_ouranos_dev.testMonthlyUnion;
CREATE MATERIALIZED VIEW clim_ouranos_dev.testMonthlyUnion AS (SELECT rs_metadata_tbl.bioclim_var,extract(month from rs_content_tbl.rs_date) as Month_date,extract(year from rs_content_tbl.rs_date) as Year_date,ST_Union(raster, 'MEAN') AS UnionT FROM clim_ouranos_dev.rs_content_tbl
INNER JOIN clim_ouranos_dev.rs_metadata_tbl ON clim_ouranos_dev.rs_content_tbl.md_id_rs_metadata_tbl = clim_ouranos_dev.rs_metadata_tbl.md_id
GROUP BY rs_metadata_tbl.bioclim_var,extract(month from rs_content_tbl.rs_date),extract(year from rs_content_tbl.rs_date));

-----

-- Get Stats

SELECT (stats).* FROM (SELECT ST_SummaryStats(UnionT) AS stats FROM clim_ouranos_dev.testMonthlyUnion) As foo;
