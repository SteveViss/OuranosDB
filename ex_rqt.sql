-- QUERIES EXAMPLES

-- Coords of all cells

SELECT x, y, val, ST_X(geom),ST_Y(geom) FROM (SELECT (ST_PixelAsCentroids(raster, 1)).* FROM ouranos_dev.rs_content_tbl WHERE rs_id = 2) AS test;
SELECT (ST_PixelAsCentroids(raster, 1)).* FROM ouranos_dev.rs_content_tbl WHERE rs_id = 2;

-- Metadata of all rasters

 SELECT (md).*, (bmd).* 
 FROM (SELECT ST_Metadata(raster) AS md, 
              ST_BandMetadata(raster) AS bmd 
       FROM ouranos_dev.rs_content_tbl LIMIT 1
      ) foo;




-- ANNUAL RASTER BY BIOVARS

CREATE MATERIALIZED VIEW ouranos_dev.testunion AS (SELECT rs_metadata_tbl.bioclim_var, extract(year from rs_content_tbl.rs_date) as year_date,ST_Union(raster, 'MEAN') AS union_raster FROM ouranos_dev.rs_content_tbl
INNER JOIN ouranos_dev.rs_metadata_tbl ON ouranos_dev.rs_content_tbl.md_id_rs_metadata_tbl = ouranos_dev.rs_metadata_tbl.md_id
GROUP BY rs_metadata_tbl.bioclim_var,extract(year from rs_content_tbl.rs_date));

-----
-- Tester intercept with geom_polygon


-- Get Stats

SELECT (stats).* FROM (SELECT ST_SummaryStats(union_raster) AS stats FROM ouranos_dev.testUnion) As foo;

-- MONTHLY RASTER BY BIOVARS

DROP MATERIALIZED VIEW ouranos_dev.testMonthlyUnion;
CREATE MATERIALIZED VIEW ouranos_dev.testMonthlyUnion AS (SELECT rs_metadata_tbl.bioclim_var,extract(month from rs_content_tbl.rs_date) as Month_date,extract(year from rs_content_tbl.rs_date) as Year_date,ST_Union(raster, 'MEAN') AS UnionT FROM ouranos_dev.rs_content_tbl
INNER JOIN ouranos_dev.rs_metadata_tbl ON ouranos_dev.rs_content_tbl.md_id_rs_metadata_tbl = ouranos_dev.rs_metadata_tbl.md_id
GROUP BY rs_metadata_tbl.bioclim_var,extract(month from rs_content_tbl.rs_date),extract(year from rs_content_tbl.rs_date));

-----

-- Get Stats

SELECT (stats).* FROM (SELECT ST_SummaryStats(UnionT) AS stats FROM ouranos_dev.testMonthlyUnion) As foo;
