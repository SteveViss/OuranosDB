--CREATE TABLESPACE dbindexes LOCATION '/var/lib/pgsql/indexes';

-- DROP INDEX clim_rs.idx_clim_center;
CREATE INDEX idx_clim_center_bio ON clim_rs.fut_clim_biovars
    USING btree
    (
      clim_center ASC
    )
TABLESPACE dbindexes;
-- ddl-end --

-- DROP INDEX clim_rs.idx_mod_run;
CREATE INDEX idx_mod_run_bio ON clim_rs.fut_clim_biovars
    USING btree
    (
      mod ASC,
      run ASC
    )
TABLESPACE dbindexes;
-- ddl-end --

-- DROP INDEX clim_rs.idx_scenario;
CREATE INDEX idx_scenario_bio ON clim_rs.fut_clim_biovars
    USING btree
    (
      scenario ASC
    )
TABLESPACE dbindexes;
-- ddl-end --

-- DROP INDEX clim_rs.idx_var;
CREATE INDEX idx_var_bio ON clim_rs.fut_clim_biovars
    USING btree
    (
      var ASC
    )
TABLESPACE dbindexes;
-- ddl-end --

-- DROP INDEX clim_rs.idx_var;
CREATE INDEX idx_yr_bio ON clim_rs.fut_clim_biovars
    USING btree
    (
      yr ASC
    )
TABLESPACE dbindexes;
-- ddl-end --

-- object: spatial_idx | type: INDEX --
-- DROP INDEX clim_rs.idx_spatial_bio;
CREATE INDEX idx_spatial_bio ON clim_rs.fut_clim_biovars
    USING gist
    (
      st_convexhull(raster)
    )
TABLESPACE dbindexes;
-- ddl-end --
