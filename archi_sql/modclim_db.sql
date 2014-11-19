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

-- object: ouranos_dev | type: SCHEMA --
-- DROP SCHEMA ouranos_dev;
CREATE SCHEMA ouranos_dev;
-- ddl-end --

SET search_path TO pg_catalog,public,ouranos_dev;
-- ddl-end --

-- object: ouranos_dev.rs_metadata_tbl | type: TABLE --
-- DROP TABLE ouranos_dev.rs_metadata_tbl;
CREATE TABLE ouranos_dev.rs_metadata_tbl(
	md_id serial NOT NULL,
	ouranos_version varchar(20),
	ref_model_ipcc varchar(15) NOT NULL,
	ref_scenario_ipcc varchar(15) NOT NULL,
	run smallint NOT NULL,
	dscaling_method varchar(10) NOT NULL,
	is_obs boolean NOT NULL,
	is_pred boolean NOT NULL,
	bioclim_var varchar(20) NOT NULL,
	CONSTRAINT rs_metadata_tbl_pkey PRIMARY KEY (md_id),
	CONSTRAINT mdata_const_uq UNIQUE (ouranos_version,ref_model_ipcc,ref_scenario_ipcc,run,dscaling_method,is_obs,is_pred,bioclim_var)

);
-- ddl-end --
-- object: idx_rs_metadata_pkey | type: INDEX --
-- DROP INDEX ouranos_dev.idx_rs_metadata_pkey;
CREATE UNIQUE INDEX idx_rs_metadata_pkey ON ouranos_dev.rs_metadata_tbl
	USING btree
	(
	  md_id ASC NULLS LAST
	);
-- ddl-end --

-- object: idx_rs_metadata_uq | type: INDEX --
-- DROP INDEX ouranos_dev.idx_rs_metadata_uq;
CREATE UNIQUE INDEX idx_rs_metadata_uq ON ouranos_dev.rs_metadata_tbl
	USING btree
	(
	  ouranos_version ASC NULLS LAST,
	  ref_model_ipcc ASC NULLS LAST,
	  ref_scenario_ipcc ASC NULLS LAST,
	  run ASC NULLS LAST,
	  dscaling_method ASC NULLS LAST,
	  is_obs ASC NULLS LAST,
	  is_pred ASC NULLS LAST,
	  bioclim_var ASC NULLS LAST
	);
-- ddl-end --


-- object: ouranos_dev.rs_content_tbl | type: TABLE --
-- DROP TABLE ouranos_dev.rs_content_tbl;
CREATE TABLE ouranos_dev.rs_content_tbl(
	rs_id serial NOT NULL,
	raster raster NOT NULL,
	rs_date date NOT NULL,
	md_id_rs_metadata_tbl integer NOT NULL,
	CONSTRAINT rs_content_pkey PRIMARY KEY (rs_id)

);
-- ddl-end --
-- object: idx_rs_content_pkey | type: INDEX --
-- DROP INDEX ouranos_dev.idx_rs_content_pkey;
CREATE INDEX idx_rs_content_pkey ON ouranos_dev.rs_content_tbl
	USING btree
	(
	  rs_id ASC NULLS LAST
	);
-- ddl-end --


-- object: rs_metadata_tbl_fk | type: CONSTRAINT --
-- ALTER TABLE ouranos_dev.rs_content_tbl DROP CONSTRAINT rs_metadata_tbl_fk;
ALTER TABLE ouranos_dev.rs_content_tbl ADD CONSTRAINT rs_metadata_tbl_fk FOREIGN KEY (md_id_rs_metadata_tbl)
REFERENCES ouranos_dev.rs_metadata_tbl (md_id) MATCH FULL
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --



