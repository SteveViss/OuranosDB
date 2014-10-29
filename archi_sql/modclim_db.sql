-- Database generated with pgModeler (PostgreSQL Database Modeler).
-- pgModeler  version: 0.7.1
-- PostgreSQL version: 9.3
-- Project Site: pgmodeler.com.br
-- Model Author: ---

SET check_function_bodies = false;
-- ddl-end --


-- Database creation must be done outside an multicommand file.
-- These commands were put in this file only for convenience.
-- -- object: modclim_db | type: DATABASE --
-- -- DROP DATABASE modclim_db;
-- CREATE DATABASE modclim_db
-- ;
-- -- ddl-end --
-- 

-- object: modclim | type: SCHEMA --
-- DROP SCHEMA modclim;
CREATE SCHEMA modclim;
-- ddl-end --

SET search_path TO pg_catalog,public,modclim;
-- ddl-end --

-- object: modclim.rs_clim_tbl | type: TABLE --
-- DROP TABLE modclim.rs_clim_tbl;
CREATE TABLE modclim.rs_clim_tbl(
	rs_id bigint NOT NULL,
	rs_mod raster NOT NULL,
	rs_id_rs_metadata_tbl bigint,
	CONSTRAINT rs_clim_tbl_pkey PRIMARY KEY (rs_id)

);
-- ddl-end --
-- object: idx_rs_clim_tbl_pkey | type: INDEX --
-- DROP INDEX modclim.idx_rs_clim_tbl_pkey;
CREATE INDEX idx_rs_clim_tbl_pkey ON modclim.rs_clim_tbl
	USING btree
	(
	  rs_id ASC NULLS LAST
	);
-- ddl-end --


-- object: modclim.rs_metadata_tbl | type: TABLE --
-- DROP TABLE modclim.rs_metadata_tbl;
CREATE TABLE modclim.rs_metadata_tbl(
	rs_id bigint NOT NULL,
	ouranos_version varchar(20),
	ref_model_ipcc varchar(15) NOT NULL,
	ref_scenario_ipcc varchar(15) NOT NULL,
	run smallint NOT NULL,
	dscaling_method varchar(10) NOT NULL,
	is_obs boolean NOT NULL,
	is_pred boolean NOT NULL,
	bioclim_var varchar(20) NOT NULL,
	date_mod date NOT NULL,
	CONSTRAINT rs_metadata_tbl_pkey PRIMARY KEY (rs_id)

);
-- ddl-end --
-- object: idx_rs_metadata_pkey | type: INDEX --
-- DROP INDEX modclim.idx_rs_metadata_pkey;
CREATE UNIQUE INDEX idx_rs_metadata_pkey ON modclim.rs_metadata_tbl
	USING btree
	(
	  rs_id ASC NULLS LAST
	);
-- ddl-end --

-- object: idx_metadata_search | type: INDEX --
-- DROP INDEX modclim.idx_metadata_search;
CREATE UNIQUE INDEX idx_metadata_search ON modclim.rs_metadata_tbl
	USING btree
	(
	  ref_model_ipcc ASC NULLS LAST,
	  ref_scenario_ipcc ASC NULLS LAST,
	  dscaling_method ASC NULLS LAST,
	  bioclim_var ASC NULLS LAST,
	  date_mod ASC NULLS LAST
	);
-- ddl-end --


-- object: rs_metadata_tbl_fk | type: CONSTRAINT --
-- ALTER TABLE modclim.rs_clim_tbl DROP CONSTRAINT rs_metadata_tbl_fk;
ALTER TABLE modclim.rs_clim_tbl ADD CONSTRAINT rs_metadata_tbl_fk FOREIGN KEY (rs_id_rs_metadata_tbl)
REFERENCES modclim.rs_metadata_tbl (rs_id) MATCH FULL
ON DELETE RESTRICT ON UPDATE CASCADE;
-- ddl-end --


-- object: rs_clim_tbl_uq | type: CONSTRAINT --
-- ALTER TABLE modclim.rs_clim_tbl DROP CONSTRAINT rs_clim_tbl_uq;
ALTER TABLE modclim.rs_clim_tbl ADD CONSTRAINT rs_clim_tbl_uq UNIQUE (rs_id_rs_metadata_tbl);
-- ddl-end --


