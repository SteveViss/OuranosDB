-- Exemple de RQT:
SELECT x, y, val, ST_X(geom),ST_Y(geom) FROM (SELECT (ST_PixelAsCentroids(raster, 1)).* FROM modclim.rs_content_tbl WHERE rs_id = 2) AS test;
SELECT (ST_PixelAsCentroids(raster, 1)).* FROM modclim.rs_content_tbl WHERE rs_id = 2;

 SELECT (md).*, (bmd).* 
 FROM (SELECT ST_Metadata(raster) AS md, 
              ST_BandMetadata(raster) AS bmd 
       FROM modclim.rs_content_tbl LIMIT 1
      ) foo;

 -- Tester intercept (geom_point; geom_polygon)

 -- Tester average
DROP MATERIALIZED VIEW modclim.testUnion;
CREATE MATERIALIZED VIEW modclim.testUnion AS (SELECT ST_Union(raster, 'MEAN') AS UnionT FROM modclim.rs_content_tbl
INNER JOIN modclim.rs_metadata_tbl ON modclim.rs_content_tbl.md_id_rs_metadata_tbl = modclim.rs_metadata_tbl.md_id
GROUP BY rs_metadata_tbl.bioclim_var);

SELECT (stats).* FROM (SELECT ST_SummaryStats(UnionT) AS stats FROM modclim.testUnion) As foo;

DROP MATERIALIZED VIEW modclim.testMonthlyUnion;
CREATE MATERIALIZED VIEW modclim.testMonthlyUnion AS (SELECT rs_metadata_tbl.bioclim_var,extract(month from rs_content_tbl.rs_date) as Month_date,extract(year from rs_content_tbl.rs_date) as Year_date,ST_Union(raster, 'MEAN') AS UnionT FROM modclim.rs_content_tbl
INNER JOIN modclim.rs_metadata_tbl ON modclim.rs_content_tbl.md_id_rs_metadata_tbl = modclim.rs_metadata_tbl.md_id
GROUP BY rs_metadata_tbl.bioclim_var,extract(month from rs_content_tbl.rs_date),extract(year from rs_content_tbl.rs_date));

SELECT (stats).* FROM (SELECT ST_SummaryStats(UnionT) AS stats FROM modclim.testMonthlyUnion) As foo;