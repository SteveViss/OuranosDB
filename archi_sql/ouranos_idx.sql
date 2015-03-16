CREATE TABLESPACE indexes LOCATION '/var/lib/pgsql/indexes';

-- DROP INDEX clim_rs.idx_clim_center;
CREATE INDEX idx_clim_center ON clim_rs.fut_clim_vars
    USING btree
    (
      clim_center ASC
    );
-- ddl-end --

-- DROP INDEX clim_rs.idx_mod_run;
CREATE INDEX idx_mod_run ON clim_rs.fut_clim_vars
    USING btree
    (
      mod ASC,
      run ASC
    );
-- ddl-end --

-- DROP INDEX clim_rs.idx_scenario;
CREATE INDEX idx_scenario ON clim_rs.fut_clim_vars
    USING btree
    (
      scenario ASC
    );
-- ddl-end --

-- DROP INDEX clim_rs.idx_var;
CREATE INDEX idx_var ON clim_rs.fut_clim_vars
    USING btree
    (
      var ASC
    );
-- ddl-end --

-- DROP INDEX clim_rs.idx_var;
CREATE INDEX idx_yr ON clim_rs.fut_clim_vars
    USING btree
    (
      yr ASC
    );
-- ddl-end --

-- DROP INDEX clim_rs.idx_var;
CREATE INDEX idx_mth ON clim_rs.fut_clim_vars
    USING btree
    (
      mth ASC
    );
-- ddl-end --

-- object: spatial_idx | type: INDEX --
-- DROP INDEX ouranos_dev.spatial_idx;
CREATE INDEX idx_spatial ON clim_rs.fut_clim_vars
    USING gist
    (
      st_convexhull(raster)
    );
-- ddl-end --
