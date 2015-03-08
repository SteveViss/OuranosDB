

-- object: idx_rs_var | type: INDEX --
-- DROP INDEX ouranos_dev.idx_rs_var;
CREATE INDEX idx_rs_var ON rs_clim.fut_clim_vars
    USING btree
    (
      rs_var ASC NULLS LAST
    );
-- ddl-end --

-- object: idx_rs_date | type: INDEX --
-- DROP INDEX ouranos_dev.idx_rs_date;
CREATE INDEX idx_rs_date ON rs_clim.fut_clim_vars
    USING btree
    (
      rs_date ASC NULLS LAST
    );
-- ddl-end --


-- object: spatial_idx | type: INDEX --
-- DROP INDEX ouranos_dev.spatial_idx;
CREATE INDEX spatial_idx ON rs_clim.fut_clim_vars
    USING gist
    (
      st_convexhull(raster)
    );
-- ddl-end --
