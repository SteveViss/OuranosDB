

-- object: idx_rs_var | type: INDEX --
-- DROP INDEX ouranos_dev.idx_rs_var;
CREATE INDEX idx_rs_var ON ouranos_dev.mod_rs_ouranos
    USING btree
    (
      rs_var ASC NULLS LAST
    );
-- ddl-end --

-- object: idx_rs_date | type: INDEX --
-- DROP INDEX ouranos_dev.idx_rs_date;
CREATE INDEX idx_rs_date ON ouranos_dev.mod_rs_ouranos
    USING btree
    (
      rs_date ASC NULLS LAST
    );
-- ddl-end --


-- object: spatial_idx | type: INDEX --
-- DROP INDEX ouranos_dev.spatial_idx;
CREATE INDEX spatial_idx ON ouranos_dev.mod_rs_ouranos
    USING gist
    (
      st_convexhull(raster)
    );
-- ddl-end --
