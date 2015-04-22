--CREATE TABLESPACE dbindexes LOCATION '/var/lib/pgsql/indexes';

-- DROP INDEX clim_rs.idx_clim_center;
CREATE INDEX idx_clim_center_mth ON clim_rs.fut_clim_vars
    USING btree
    (
      clim_center ASC
    )
TABLESPACE dbindexes;
-- ddl-end --

-- DROP INDEX clim_rs.idx_mod_run;
CREATE INDEX idx_mod_run_mth ON clim_rs.fut_clim_vars
    USING btree
    (
      mod ASC,
      run ASC
    )
TABLESPACE dbindexes;
-- ddl-end --

-- DROP INDEX clim_rs.idx_scenario;
CREATE INDEX idx_scenario_mth ON clim_rs.fut_clim_vars
    USING btree
    (
      scenario ASC
    )
TABLESPACE dbindexes;
-- ddl-end --

-- DROP INDEX clim_rs.idx_var;
CREATE INDEX idx_var_mth ON clim_rs.fut_clim_vars
    USING btree
    (
      var ASC
    )
TABLESPACE dbindexes;
-- ddl-end --

-- DROP INDEX clim_rs.idx_var;
CREATE INDEX idx_yr_mth ON clim_rs.fut_clim_vars
    USING btree
    (
      yr ASC
    )
TABLESPACE dbindexes;
-- ddl-end --

-- DROP INDEX clim_rs.idx_var;
CREATE INDEX idx_mth ON clim_rs.fut_clim_vars
    USING btree
    (
      mth ASC
    )
TABLESPACE dbindexes;
-- ddl-end --

-- object: spatial_idx | type: INDEX --
-- DROP INDEX ouranos_dev.spatial_idx;
CREATE INDEX idx_spatial_mth ON clim_rs.fut_clim_vars
    USING gist
    (
      st_convexhull(raster)
    )
TABLESPACE dbindexes;
-- ddl-end --
